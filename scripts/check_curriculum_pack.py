#!/usr/bin/env python3
"""Comprueba el RPC `get_curriculum_pack` contra la base (CUR-07).

Recorre los 7 niveles y compara el paquete con el inventario importado:

- el nivel devuelto es el pedido y tiene sus 4 unidades y 5 lecciones cada una;
- los objetivos y frases del pack suman 540 y 539 en total;
- `content_version` es positivo y sirve de etag: pedir el nivel con
  `since_version = content_version` devuelve 0 lecciones;
- un nivel inexistente falla con error, no devuelve un pack vacío.

    python scripts/check_curriculum_pack.py
"""
from __future__ import annotations

import json
import sys
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

import import_curriculum as ic  # noqa: E402

EXPECTED_LEVELS = ["pre_a1", "a1", "a2", "b1", "b2", "c1", "c2"]


def call_pack(client: ic.RestClient, level: str, since: int = 0) -> dict:
    return client.rpc(
        "get_curriculum_pack", {"p_level": level, "p_since_version": since}
    )


def check(client: ic.RestClient) -> list:
    problems = []
    totals = {"lessons": 0, "objectives": 0, "phrases": 0}

    for level in EXPECTED_LEVELS:
        pack = call_pack(client, level)
        if pack["level"]["id"] != level:
            problems.append(f"{level}: devuelve el nivel {pack['level']['id']}")
        if not pack["content_version"]:
            problems.append(f"{level}: content_version vacío")

        units = pack["units"]
        if len(units) != 4:
            problems.append(f"{level}: {len(units)} unidades != 4")
        for unit in units:
            if len(unit["lessons"]) != 5:
                problems.append(f"{level}/{unit['slug']}: {len(unit['lessons'])} lecciones != 5")
            for lesson in unit["lessons"]:
                totals["lessons"] += 1
                totals["objectives"] += len(lesson["objectives"])
                totals["phrases"] += len(lesson["phrases"])
                if not lesson["title"]:
                    problems.append(f"{lesson['id']}: sin título")
                if not lesson["objectives"]:
                    problems.append(f"{lesson['id']}: sin objetivos")

        # El etag debe dejar el nivel sin novedades.
        fresh = call_pack(client, level, pack["content_version"])
        pending = sum(len(unit["lessons"]) for unit in fresh["units"])
        if pending:
            problems.append(f"{level}: since_version no filtra ({pending} lecciones)")

    if totals["lessons"] != ic.EXPECTED_LESSONS:
        problems.append(f"lecciones: {totals['lessons']} != {ic.EXPECTED_LESSONS}")
    if totals["objectives"] != ic.EXPECTED_OBJECTIVES:
        problems.append(f"objetivos: {totals['objectives']} != {ic.EXPECTED_OBJECTIVES}")
    if totals["phrases"] != ic.EXPECTED_PHRASES:
        problems.append(f"frases: {totals['phrases']} != {ic.EXPECTED_PHRASES}")

    try:
        call_pack(client, "nivel_que_no_existe")
        problems.append("un nivel inexistente no falla")
    except SystemExit as error:
        if "P0002" not in str(error) and "nivel desconocido" not in str(error):
            problems.append(f"nivel inexistente falla con otro error: {error}")

    return problems, totals


def main() -> int:
    env = ic.load_env()
    url = env.get("SUPABASE_URL")
    key = env.get("SUPABASE_SERVICE_ROLE_KEY")
    if not url or not key:
        print("faltan SUPABASE_URL o SUPABASE_SERVICE_ROLE_KEY (entorno o .env)", file=sys.stderr)
        return 2

    problems, totals = check(ic.RestClient(url, key))
    print(json.dumps(totals, indent=2))
    for problem in problems:
        print(f"PROBLEMA  {problem}", file=sys.stderr)
    if problems:
        return 1
    print(f"OK · {len(EXPECTED_LEVELS)} niveles, {totals['lessons']} lecciones")
    return 0


if __name__ == "__main__":
    sys.exit(main())
