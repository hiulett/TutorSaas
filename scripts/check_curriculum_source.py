#!/usr/bin/env python3
"""Comprueba el flag `curriculum_source` (CUR-16).

El flag es el interruptor que permite activar y **revertir** sin publicar una
versión nueva de la app, así que lo que se verifica es que cambia, que se
rechaza lo inválido y que vuelve a dejarse como estaba.

    python scripts/check_curriculum_source.py
"""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

import import_curriculum as ic  # noqa: E402


def check(client: ic.RestClient) -> list:
    problems: list = []
    original = client.rpc("get_curriculum_source", {})
    if original not in ("dart", "db"):
        problems.append(f"valor inicial inesperado: {original!r}")

    try:
        # Cambia a db y comprueba que se lee
        changed = client.rpc("admin_set_curriculum_source", {"p_value": "db"})
        if changed["value"] != "db":
            problems.append(f"el cambio no devolvió db: {changed}")
        if client.rpc("get_curriculum_source", {}) != "db":
            problems.append("get_curriculum_source no refleja el cambio")

        # Vuelve a dart
        client.rpc("admin_set_curriculum_source", {"p_value": "dart"})
        if client.rpc("get_curriculum_source", {}) != "dart":
            problems.append("no se pudo volver a dart")

        # Un valor inválido se rechaza y no deja rastro
        try:
            client.rpc("admin_set_curriculum_source", {"p_value": "mysql"})
            problems.append("aceptó un valor inválido")
        except SystemExit as error:
            if "curriculum_source inválido" not in str(error):
                problems.append(f"valor inválido falla distinto: {str(error)[:100]}")
        if client.rpc("get_curriculum_source", {}) != "dart":
            problems.append("el rechazo cambió el valor")

        # Queda auditado
        logs = client.select(
            "content_audit_logs",
            "action,entity_id,diff",
            filters={"action": "eq.set_curriculum_source"},
        )
        if not logs:
            problems.append("sin registro de auditoría del cambio")
        elif logs[0]["entity_id"] != "curriculum_source":
            problems.append(f"auditoría con entity_id {logs[0]['entity_id']}")
    finally:
        try:
            client.rpc("admin_set_curriculum_source", {"p_value": original})
        except SystemExit as error:
            problems.append(f"no se pudo restaurar el valor original: {error}")

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
    print("OK · el flag cambia, se audita y vuelve a su valor")
    return 0


if __name__ == "__main__":
    sys.exit(main())
