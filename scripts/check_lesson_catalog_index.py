#!/usr/bin/env python3
"""Comprueba que `lesson_catalog_index` se sirve desde `lessons` (CUR-06).

Es una vista materializada, así que lo que hay que verificar es que no se queda
vieja: que refleja a `lessons` y que un cambio de estado se propaga solo.

    python scripts/check_lesson_catalog_index.py
"""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

import import_curriculum as ic  # noqa: E402

PROBE_LESSON = "zz_probe_index_lesson"


def index_rows(client: ic.RestClient) -> dict:
    rows = client.select("lesson_catalog_index", "lesson_id,level,title,category")
    return {row["lesson_id"]: row for row in rows}


def check(client: ic.RestClient) -> list:
    problems: list = []

    published = {
        row["id"]
        for row in client.select("lessons", "id,status", filters={"status": "eq.published"})
    }
    index = index_rows(client)

    if len(index) != ic.EXPECTED_LESSONS:
        problems.append(f"filas del índice: {len(index)} != {ic.EXPECTED_LESSONS}")
    if set(index) != published:
        missing = published - set(index)
        extra = set(index) - published
        problems.append(f"el índice no coincide con lessons: faltan {len(missing)}, sobran {len(extra)}")

    units = {unit["id"]: unit for unit in client.select("curriculum_units", "id,level_id")}
    levels = {level["id"]: level for level in client.select("curriculum_levels", "id,cefr")}
    sample = next(iter(published))
    lesson = client.select("lessons", "id,title,category,unit_id", filters={"id": f"eq.{sample}"})[0]
    expected_level = levels[units[lesson["unit_id"]]["level_id"]]["cefr"]
    if index[sample]["level"] != expected_level:
        problems.append(f"{sample}: level {index[sample]['level']} != {expected_level}")
    if index[sample]["title"] != lesson["title"]:
        problems.append(f"{sample}: título distinto en el índice")

    # El trigger debe mantenerla fresca sin refresco manual.
    try:
        client.rpc(
            "admin_save_lesson",
            {
                "p_lesson": {
                    "id": PROBE_LESSON,
                    "unit_id": lesson["unit_id"],
                    "title": "Lección de prueba del índice",
                    "category": "daily",
                    "difficulty": 1,
                    "objectives": [
                        {"code": "g1", "description": "Objetivo", "competency": "speaking"}
                    ],
                    "phrases": [{"phrase": "Hi", "translation": "Hola"}],
                }
            },
        )
        if PROBE_LESSON in index_rows(client):
            problems.append("el borrador aparece en el índice antes de publicarse")
    finally:
        client.delete("lessons", {"id": f"eq.{PROBE_LESSON}"})

    if PROBE_LESSON in index_rows(client):
        problems.append("el índice conserva la lección de prueba tras borrarla")

    if len(index_rows(client)) != ic.EXPECTED_LESSONS:
        problems.append("el índice no volvió a 140 filas tras la prueba")

    # Refresco manual disponible para los publicadores.
    refreshed = client.rpc("admin_refresh_catalog_index", {})
    if refreshed["rows"] != ic.EXPECTED_LESSONS:
        problems.append(f"admin_refresh_catalog_index devolvió {refreshed['rows']} filas")

    return problems


def main() -> int:
    env = ic.load_env()
    url = env.get("SUPABASE_URL")
    key = env.get("SUPABASE_SERVICE_ROLE_KEY")
    if not url or not key:
        print("faltan SUPABASE_URL o SUPABASE_SERVICE_ROLE_KEY (entorno o .env)", file=sys.stderr)
        return 2

    problems = check(ic.RestClient(url, key))
    for problem in problems:
        print(f"PROBLEMA  {problem}", file=sys.stderr)
    if problems:
        return 1
    print("OK · el índice refleja lessons y sigue los cambios")
    return 0


if __name__ == "__main__":
    sys.exit(main())
