#!/usr/bin/env python3
"""Comprueba el RPC `admin_curriculum_stats` contra la base (CUR-11).

Los conteos del panel tienen que cuadrar con el inventario importado y sumar
igual por nivel que en el total; si no, el dashboard miente.

    python scripts/check_curriculum_stats.py
"""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

import import_curriculum as ic  # noqa: E402


def check(client: ic.RestClient) -> list:
    problems: list = []
    data = client.rpc("admin_curriculum_stats", {})
    totals = data["totals"]
    levels = data["levels"]

    expected = {
        "levels": 7,
        "units": 28,
        "lessons": ic.EXPECTED_LESSONS,
        "published": ic.EXPECTED_LESSONS,
        "draft": 0,
        "review": 0,
        "archived": 0,
        "versions": ic.EXPECTED_LESSONS,
        "objectives": ic.EXPECTED_OBJECTIVES,
        "phrases": ic.EXPECTED_PHRASES,
        "identical": ic.EXPECTED_IDENTICAL,
        "weak": ic.EXPECTED_WEAK_OBJECTIVES,
        "activities": 0,
    }
    for key, value in expected.items():
        if totals.get(key) != value:
            problems.append(f"totals.{key}: {totals.get(key)} != {value}")

    if len(levels) != 7:
        problems.append(f"niveles devueltos: {len(levels)}")
    if [level["order_index"] for level in levels] != list(range(1, 8)):
        problems.append("los niveles no vienen ordenados 1..7")

    for field in ("units", "lessons", "published", "objectives", "phrases", "identical", "weak"):
        summed = sum(level[field] for level in levels)
        if summed != totals[field]:
            problems.append(f"{field}: la suma por nivel ({summed}) != total ({totals[field]})")

    for level in levels:
        if level["lessons"] != level["published"]:
            problems.append(f"{level['id']}: {level['lessons']} lecciones pero {level['published']} publicadas")
        if level["lessons"] != 20:
            problems.append(f"{level['id']}: {level['lessons']} lecciones != 20")
        if level["identical"] + level["weak"] > level["objectives"] + level["phrases"]:
            problems.append(f"{level['id']}: deuda editorial mayor que el contenido")

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
    print("OK · conteos por nivel y total cuadran con el inventario")
    return 0


if __name__ == "__main__":
    sys.exit(main())
