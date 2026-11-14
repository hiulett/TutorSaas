#!/usr/bin/env python3
"""Restaura el orden del currículo desde la exportación canónica (CUR-24).

`check_admin_units.py` movió lecciones reales de A1 para probar
`admin_move_lesson` y no devolvió su posición exacta: 8 lecciones quedaron
desplazadas dentro de `a1-u1` y `a1-u3`. El contenido es el mismo, pero
`get_curriculum_pack` las devuelve en otro orden, así que encender
`curriculum_source='db'` cambiaría la ruta que ve el alumno. Este script
recompone unidad y posición desde `build/curriculum/lessons.json` (la
exportación de CUR-02, misma que importó CUR-03) y verifica el resultado.

Uso:

    python scripts/fix_curriculum_order.py            # dry-run: solo el plan
    python scripts/fix_curriculum_order.py --apply    # repara y verifica

No crea contenido ni toca versiones: solo `lessons.unit_id` y
`lessons.order_index`, que no cambian ids ni progreso. La reparación usa la
pasada negativa temporal porque `unique (unit_id, order_index)` prohíbe dos
filas con la misma posición durante la reordenación.
"""
from __future__ import annotations

import argparse
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

import import_curriculum as ic  # noqa: E402


def build_expected(lessons: list) -> dict:
    """`lesson_id -> (level_id, unit_slug, order_index)` según la exportación."""
    expected: dict = {}
    seen: Counter = Counter()
    for lesson in lessons:
        level_id = ic.level_id_for(lesson.get("level"))
        index = seen[level_id]
        seen[level_id] += 1
        unit_no = index // ic.LESSONS_PER_UNIT + 1
        expected[lesson["id"]] = (
            level_id,
            f"{level_id}-u{unit_no}",
            index % ic.LESSONS_PER_UNIT + 1,
        )
    return expected


def read_state(client: ic.RestClient) -> tuple[dict, dict]:
    units = client.select("curriculum_units", "id,slug,level_id,order_index")
    by_id = {unit["id"]: unit for unit in units}
    by_slug = {unit["slug"]: unit for unit in units}
    lessons = client.select("lessons", "id,unit_id,order_index,status")
    state = {}
    for row in lessons:
        unit = by_id.get(row["unit_id"])
        state[row["id"]] = (unit["slug"] if unit else "", row["order_index"])
    return by_slug, state


def find_drift(expected: dict, state: dict) -> list:
    drift = []
    for lesson_id, (level_id, slug, position) in expected.items():
        current = state.get(lesson_id)
        if current is None:
            drift.append((level_id, lesson_id, "falta en la base", f"{slug}@{position}"))
            continue
        if current != (slug, position):
            drift.append(
                (level_id, lesson_id, f"{current[0]}@{current[1]}", f"{slug}@{position}")
            )
    return sorted(drift)


def apply_expected(client: ic.RestClient, expected: dict, slugs: dict) -> None:
    missing_units = sorted({slug for _, slug, _ in expected.values()} - set(slugs))
    if missing_units:
        raise SystemExit(
            "faltan unidades en la base: " + ", ".join(missing_units)
            + " (aplica 20261113150000_curriculum_schema.sql o revisa el import)"
        )

    # Pasada 1: sacar todas las lecciones a posiciones negativas únicas. Los ids
    # se capturan antes de tocar el orden porque tras esta pasada
    # `order by order_index` los devolvería invertidos.
    lesson_ids = list(expected)
    for offset, lesson_id in enumerate(lesson_ids):
        client.patch("lessons", {"id": f"eq.{lesson_id}"}, {"order_index": -(offset + 1)})

    # Pasada 2: unidad y posición definitivas.
    for lesson_id in lesson_ids:
        _, slug, position = expected[lesson_id]
        client.patch(
            "lessons",
            {"id": f"eq.{lesson_id}"},
            {"unit_id": slugs[slug]["id"], "order_index": position},
        )


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--apply", action="store_true", help="escribe la reparación")
    args = parser.parse_args()

    if not ic.SOURCE.exists():
        print(f"falta {ic.SOURCE}; no se puede reparar sin la exportación", file=sys.stderr)
        return 2

    expected = build_expected(ic.load_source())

    env = ic.load_env()
    url = env.get("SUPABASE_URL")
    key = env.get("SUPABASE_SERVICE_ROLE_KEY")
    if not url or not key:
        print("faltan SUPABASE_URL o SUPABASE_SERVICE_ROLE_KEY (entorno o .env)", file=sys.stderr)
        return 2

    client = ic.RestClient(url, key)
    slugs, state = read_state(client)
    drift = find_drift(expected, state)
    extra = sorted(set(state) - set(expected))

    print(f"lecciones en la exportación: {len(expected)}")
    print(f"lecciones en la base:        {len(state)}")
    print(f"fuera de su sitio:          {len(drift)}")
    for row in drift[:20]:
        print(f"  {row[0]}  {row[1]}  base={row[2]}  esperado={row[3]}")
    if extras := extra:
        print(f"en la base y no en la exportación (no se tocan): {len(extras)}")

    if not drift:
        print("OK · el orden ya coincide con la exportación")
        return 0 if not args.apply else _verify(client, expected)

    if not args.apply:
        print("dry-run · sin --apply no se escribe nada")
        return 0

    apply_expected(client, expected, slugs)
    return _verify(client, expected)


def _verify(client: ic.RestClient, expected: dict) -> int:
    _, state = read_state(client)
    remaining = find_drift(expected, state)
    if remaining:
        for row in remaining[:20]:
            print(f"PROBLEMA  {row[0]}  {row[1]}  base={row[2]}  esperado={row[3]}", file=sys.stderr)
        return 1
    print(f"OK · {len(expected)} lecciones en su unidad y posición de la exportación")
    return 0


if __name__ == "__main__":
    sys.exit(main())
