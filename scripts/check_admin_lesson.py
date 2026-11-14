#!/usr/bin/env python3
"""Comprueba `admin_lesson`, la lectura que usa el editor (CUR-13).

Lo que puede fallar en silencio es la detección del borrador: que el editor
enseñe lo publicado creyendo que es el borrador, o al revés. Aquí se guarda un
borrador sobre una lección publicada real, se comprueba que se lee como
borrador, y se limpia.

    python scripts/check_admin_lesson.py
"""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

import import_curriculum as ic  # noqa: E402

PUBLISHED_ID = "a1_ordering_coffee_at_a_cafe"
PROBE_ID = "zz_probe_lesson_editor"


def check(client: ic.RestClient) -> list:
    problems: list = []
    draft_created = False
    probe_created = False

    try:
        # 1 · Una lección publicada se lee con su versión y su contenido
        lesson = client.rpc("admin_lesson", {"p_lesson_id": PUBLISHED_ID})
        if lesson["status"] != "published":
            problems.append(f"estado inesperado: {lesson['status']}")
        if lesson["published_version"] != 1:
            problems.append(f"published_version: {lesson['published_version']}")
        if lesson["draft_version"] is not None:
            problems.append("una lección sin tocar ya tiene borrador")
        if not lesson["objectives"] or not lesson["phrases"]:
            problems.append("la lección llega sin objetivos o sin frases")
        if not lesson["title"]:
            problems.append("la lección llega sin título")

        # 2 · Las 140 se leen completas
        ids = [row["id"] for row in client.select("lessons", "id")]
        empty = []
        for lesson_id in ids:
            loaded = client.rpc("admin_lesson", {"p_lesson_id": lesson_id})
            if not loaded["objectives"]:
                empty.append(lesson_id)
        if empty:
            problems.append(f"{len(empty)} lecciones sin objetivos en el editor (p.ej. {empty[:3]})")

        # 3 · Guardar un borrador se ve como borrador y no cambia lo publicado
        client.rpc(
            "admin_save_lesson",
            {
                "p_lesson": {
                    "id": PUBLISHED_ID,
                    "unit_id": lesson["unit_id"],
                    "title": lesson["title"],
                    "category": lesson["category"],
                    "difficulty": lesson["difficulty"],
                    "order_index": lesson["order_index"],
                    "objectives": lesson["objectives"],
                    "phrases": lesson["phrases"],
                }
            },
        )
        draft_created = True
        with_draft = client.rpc("admin_lesson", {"p_lesson_id": PUBLISHED_ID})
        if with_draft["draft_version"] != 2:
            problems.append(f"draft_version: {with_draft['draft_version']} != 2")
        if with_draft["published_version"] != 1:
            problems.append("el borrador movió la versión publicada")
        if with_draft["status"] != "published":
            problems.append("guardar un borrador despublicó la lección")
        if with_draft["version"] != 2:
            problems.append(f"el editor debería leer la v2 y lee la v{with_draft['version']}")

        # 4 · Una lección sin publicar se lee como borrador puro
        client.rpc(
            "admin_save_lesson",
            {
                "p_lesson": {
                    "id": PROBE_ID,
                    "unit_id": lesson["unit_id"],
                    "title": "Lección de prueba del editor",
                    "category": "daily",
                    "difficulty": 1,
                    "objectives": [{"code": "g1", "description": "Objetivo", "competency": "speaking"}],
                    "phrases": [{"phrase": "Hi", "translation": "Hola"}],
                }
            },
        )
        probe_created = True
        probe = client.rpc("admin_lesson", {"p_lesson_id": PROBE_ID})
        if probe["published_version"] is not None:
            problems.append("una lección nueva no debería tener versión publicada")
        if probe["status"] != "draft":
            problems.append(f"lección nueva con estado {probe['status']}")

        # 5 · Id inexistente falla, no devuelve vacío
        try:
            client.rpc("admin_lesson", {"p_lesson_id": "no_existe"})
            problems.append("un id inexistente no falla")
        except SystemExit as error:
            if "lección inexistente" not in str(error):
                problems.append(f"id inexistente falla distinto: {str(error)[:100]}")
    finally:
        if probe_created:
            client.delete("lessons", {"id": f"eq.{PROBE_ID}"})
        if draft_created:
            client.delete("lesson_objectives", {"lesson_id": f"eq.{PUBLISHED_ID}", "version": "eq.2"})
            client.delete("lesson_phrases", {"lesson_id": f"eq.{PUBLISHED_ID}", "version": "eq.2"})

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
    print("OK · admin_lesson distingue borrador y publicado")
    return 0


if __name__ == "__main__":
    sys.exit(main())
