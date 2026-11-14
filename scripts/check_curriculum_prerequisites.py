#!/usr/bin/env python3
"""Comprueba los prerrequisitos del currículo (CUR-18).

Lo que se verifica contra producción:

- `get_curriculum_pack` devuelve `prerequisites` en cada lección;
- el primero de cada nivel no tiene requisito y el resto requiere exactamente la
  lección anterior de su nivel (la cadena secuencial que ya aplicaba la app);
- la tabla `lesson_prerequisites` tiene 133 filas (140 lecciones − 7 primeros),
  todas `required`, y ningún requisito apunta hacia delante ni a otro nivel.

Es de solo lectura: no cambia datos ni el flag.

    python scripts/check_curriculum_prerequisites.py
"""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

import import_curriculum as ic  # noqa: E402

LEVELS = ["pre_a1", "a1", "a2", "b1", "b2", "c1", "c2"]
EXPECTED_ROWS = ic.EXPECTED_LESSONS - len(LEVELS)


def check_pack(client: ic.RestClient) -> list:
    problems = []
    for level in LEVELS:
        pack = client.rpc("get_curriculum_pack", {"p_level": level, "p_since_version": 0})
        lessons = [lesson for unit in pack["units"] for lesson in unit["lessons"]]
        ids = [lesson["id"] for lesson in lessons]
        for index, lesson in enumerate(lessons):
            prerequisites = lesson.get("prerequisites")
            if prerequisites is None:
                problems.append(f"{lesson['id']}: el pack no trae prerequisites")
                continue
            required = [
                item["lesson_id"] for item in prerequisites if item.get("kind") == "required"
            ]
            if index == 0:
                if required:
                    problems.append(f"{level}: la primera lección no debe tener requisito ({required})")
                continue
            if required != [ids[index - 1]]:
                problems.append(
                    f"{lesson['id']}: requisito {required} != [{ids[index - 1]}]"
                )
    return problems


def check_rows(client: ic.RestClient) -> list:
    problems = []
    rows = client.select("lesson_prerequisites", "lesson_id,requires_lesson_id,kind")
    if len(rows) != EXPECTED_ROWS:
        problems.append(f"filas: {len(rows)} != {EXPECTED_ROWS}")
    for row in rows:
        if row["kind"] != "required":
            problems.append(f"{row['lesson_id']}: kind {row['kind']} != required")
        if row["lesson_id"] == row["requires_lesson_id"]:
            problems.append(f"{row['lesson_id']}: se requiere a sí misma")
    return problems


def check_order(client: ic.RestClient) -> list:
    """Cada requisito debe ser una lección anterior del mismo nivel."""
    problems = []
    for level in LEVELS:
        pack = client.rpc("get_curriculum_pack", {"p_level": level, "p_since_version": 0})
        ids = [lesson["id"] for unit in pack["units"] for lesson in unit["lessons"]]
        position = {lesson_id: index for index, lesson_id in enumerate(ids)}
        for lesson in (lesson for unit in pack["units"] for lesson in unit["lessons"]):
            for item in lesson["prerequisites"]:
                required = item["lesson_id"]
                if required not in position:
                    problems.append(f"{lesson['id']}: requisito de otro nivel ({required})")
                elif position[required] >= position[lesson["id"]]:
                    problems.append(f"{lesson['id']}: requisito posterior ({required})")
    return problems


def main() -> int:
    env = ic.load_env()
    url = env.get("SUPABASE_URL")
    key = env.get("SUPABASE_SERVICE_ROLE_KEY")
    if not url or not key:
        print("faltan SUPABASE_URL o SUPABASE_SERVICE_ROLE_KEY (entorno o .env)", file=sys.stderr)
        return 2

    client = ic.RestClient(url, key)
    problems = check_pack(client) + check_rows(client) + check_order(client)

    for problem in problems:
        print(f"PROBLEMA  {problem}", file=sys.stderr)
    if problems:
        return 1
    print(
        f"OK · {EXPECTED_ROWS} prerrequisitos encadenados y presentes en el pack de los "
        f"{len(LEVELS)} niveles"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
