#!/usr/bin/env python3
"""Comprueba la cola de traducciones (CUR-15).

La cola es de solo lectura: lo que se verifica es que lista exactamente las
frases que necesitan trabajo, con los totales del inventario y filtrable por
nivel.

    python scripts/check_admin_translations.py
"""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

import import_curriculum as ic  # noqa: E402


def check(client: ic.RestClient) -> list:
    problems: list = []

    full = client.rpc("admin_translations", {"p_limit": 500})
    totals = full["totals"]
    if totals["identical"] != ic.EXPECTED_IDENTICAL:
        problems.append(f"idénticas: {totals['identical']} != {ic.EXPECTED_IDENTICAL}")
    if totals["pending"] != 0:
        problems.append(f"pendientes: {totals['pending']} != 0")
    if totals["identical"] + totals["pending"] + totals["ok"] != ic.EXPECTED_PHRASES:
        problems.append(
            f"la suma de estados ({totals['identical']}+{totals['pending']}+{totals['ok']}) != {ic.EXPECTED_PHRASES}"
        )

    rows = full["rows"]
    if len(rows) != min(500, ic.EXPECTED_IDENTICAL):
        problems.append(f"filas devueltas: {len(rows)}")
    if any(row["status"] != "identical" for row in rows):
        problems.append("la cola por defecto no es solo de idénticas")
    if any(not row["phrase"] or row["phrase"] != row["translation"] for row in rows):
        problems.append("una fila idéntica no repite la frase")

    # Filtro por nivel y coherencia con el pack.
    per_level = {}
    for level in ("pre_a1", "a1", "c2"):
        filtered = client.rpc("admin_translations", {"p_level": level, "p_limit": 500})
        per_level[level] = filtered["totals"]["identical"]
        if any(row["level_id"] != level for row in filtered["rows"]):
            problems.append(f"{level}: la cola trae filas de otro nivel")
    if sum(per_level.values()) != totals["identical"]:
        problems.append(f"los niveles no suman el total: {per_level}")

    # El estado no válido se rechaza.
    try:
        client.rpc("admin_translations", {"p_status": "inventado"})
        problems.append("un estado inválido no falla")
    except SystemExit as error:
        if "estado de traducción inválido" not in str(error):
            problems.append(f"estado inválido falla distinto: {str(error)[:100]}")

    # Paginación: dos páginas no se solapan.
    first = client.rpc("admin_translations", {"p_limit": 10, "p_offset": 0})["rows"]
    second = client.rpc("admin_translations", {"p_limit": 10, "p_offset": 10})["rows"]
    if len({(row["lesson_id"], row["order_index"]) for row in first} & {(row["lesson_id"], row["order_index"]) for row in second}):
        problems.append("las páginas se solapan")

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
    print("OK · la cola lista las 481 idénticas y filtra por nivel")
    return 0


if __name__ == "__main__":
    sys.exit(main())
