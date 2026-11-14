#!/usr/bin/env python3
"""Puerta de activación del currículo en base de datos (CUR-24).

Encender `curriculum_source='db'` sin publicar una app nueva solo es seguro si la
base devuelve **exactamente** lo que hoy sirve el catálogo publicado, en el mismo
orden. Este checker comprueba eso y que el interruptor es reversible:

- el catálogo Dart (fuente de verdad de la app) tiene 140 lecciones, 20 por nivel;
- para los 7 niveles, `get_curriculum_pack` devuelve las mismas lecciones en el
  mismo orden que el catálogo (un orden distinto cambiaría la Ruta del alumno);
- todas las lecciones del pack existen como publicadas en `lessons`;
- `content_version` es positivo (sirve de etag);
- el flag conmuta `dart → db → dart`, rechaza valores inválidos y se audita.

    python scripts/check_curriculum_activation.py

El flag se restaura en el `finally`: si el checker falla a mitad, la app queda
como estaba. No toca contenido ni versiones.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

import import_curriculum as ic  # noqa: E402

CATALOG = ROOT / "lib/features/dashboard/data/models/lesson_catalog.dart"

# Prefijo de id en el catálogo → (id de `curriculum_levels`, CEFR).
LEVELS = {
    "prea1_": ("pre_a1", "PRE-A1"),
    "a1_": ("a1", "A1"),
    "a2_": ("a2", "A2"),
    "b1_": ("b1", "B1"),
    "b2_": ("b2", "B2"),
    "c1_": ("c1", "C1"),
    "c2_": ("c2", "C2"),
}

EXPECTED_PER_LEVEL = 20


def catalog_order() -> dict:
    """`level_id -> [lesson_id]` en el orden en que la app los sirve."""
    text = CATALOG.read_text(encoding="utf-8")
    ids = re.findall(r"LessonData\(\s*id: '([a-z0-9_]+)'", text)
    order: dict = {level_id: [] for level_id, _ in LEVELS.values()}
    for lesson_id in ids:
        for prefix, (level_id, _) in LEVELS.items():
            if lesson_id.startswith(prefix):
                order[level_id].append(lesson_id)
                break
        else:
            order.setdefault("desconocido", []).append(lesson_id)
    return order


def check_packs(client: ic.RestClient, expected: dict, published: set) -> list:
    problems = []
    for level_id, catalog_ids in expected.items():
        pack = client.rpc(
            "get_curriculum_pack", {"p_level": level_id, "p_since_version": 0}
        )
        if pack["level"]["id"] != level_id:
            problems.append(f"{level_id}: el pack devuelve {pack['level']['id']}")
        if not pack.get("content_version"):
            problems.append(f"{level_id}: content_version vacío")

        units = pack["units"]
        if len(units) != 4:
            problems.append(f"{level_id}: {len(units)} unidades != 4")
        pack_ids = [lesson["id"] for unit in units for lesson in unit["lessons"]]
        if len(pack_ids) != EXPECTED_PER_LEVEL:
            problems.append(f"{level_id}: {len(pack_ids)} lecciones != {EXPECTED_PER_LEVEL}")
        if pack_ids != catalog_ids:
            first = next(
                (index for index, (a, b) in enumerate(zip(pack_ids, catalog_ids)) if a != b),
                min(len(pack_ids), len(catalog_ids)),
            )
            got = pack_ids[first] if first < len(pack_ids) else "<fin>"
            want = catalog_ids[first] if first < len(catalog_ids) else "<fin>"
            problems.append(
                f"{level_id}: el orden difiere desde la posicion {first} "
                f"(base={got}, catalogo={want})"
            )
        for lesson in pack_ids:
            if lesson not in published:
                problems.append(f"{lesson}: el pack lo sirve pero no esta publicado en lessons")
    return problems


def check_flag(client: ic.RestClient) -> list:
    problems = []
    original = client.rpc("get_curriculum_source", {})
    if original not in ("dart", "db"):
        problems.append(f"valor inicial inesperado: {original!r}")

    try:
        changed = client.rpc("admin_set_curriculum_source", {"p_value": "db"})
        if changed.get("value") != "db":
            problems.append(f"encender no devolvio db: {changed}")
        if client.rpc("get_curriculum_source", {}) != "db":
            problems.append("get_curriculum_source no refleja db")

        client.rpc("admin_set_curriculum_source", {"p_value": "dart"})
        if client.rpc("get_curriculum_source", {}) != "dart":
            problems.append("apagar no devuelve a dart")

        try:
            client.rpc("admin_set_curriculum_source", {"p_value": "mysql"})
            problems.append("acepto un valor invalido")
        except SystemExit as error:
            if "curriculum_source inv" not in str(error):
                problems.append(f"valor invalido falla distinto: {str(error)[:120]}")
        if client.rpc("get_curriculum_source", {}) != "dart":
            problems.append("el rechazo cambio el valor")
    finally:
        try:
            client.rpc("admin_set_curriculum_source", {"p_value": original})
        except SystemExit as error:
            problems.append(f"no se pudo restaurar el flag: {error}")

    if client.rpc("get_curriculum_source", {}) != original:
        problems.append(f"el flag no quedo en su valor original ({original})")
    return problems


def main() -> int:
    env = ic.load_env()
    url = env.get("SUPABASE_URL")
    key = env.get("SUPABASE_SERVICE_ROLE_KEY")
    if not url or not key:
        print("faltan SUPABASE_URL o SUPABASE_SERVICE_ROLE_KEY (entorno o .env)", file=sys.stderr)
        return 2

    expected = catalog_order()
    problems = []
    total = sum(len(ids) for ids in expected.values())
    if total != ic.EXPECTED_LESSONS:
        problems.append(f"el catalogo Dart tiene {total} lecciones != {ic.EXPECTED_LESSONS}")
    for level_id, ids in expected.items():
        if len(ids) != EXPECTED_PER_LEVEL:
            problems.append(f"{level_id}: {len(ids)} lecciones en el catalogo != 20")

    client = ic.RestClient(url, key)
    lessons = client.select("lessons", "id,status,current_version")
    published = {
        row["id"]
        for row in lessons
        if row["status"] == "published" and (row.get("current_version") or 0) > 0
    }

    problems += check_packs(client, expected, published)
    problems += check_flag(client)

    for problem in problems:
        print(f"PROBLEMA  {problem}", file=sys.stderr)
    if problems:
        return 1
    print(f"OK · {len(expected)} niveles y {total} lecciones identicas al catalogo; flag reversible")
    return 0


if __name__ == "__main__":
    sys.exit(main())
