#!/usr/bin/env python3
"""Comprueba la matriz de roles del portal (CUR-10).

Verifica el criterio de la historia —seis roles y `editor` que no publica— y las
capacidades de cada rol contra la base aplicada.

    python scripts/check_admin_roles.py
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

import import_curriculum as ic  # noqa: E402

EXPECTED_ROLES = ["viewer", "reviewer", "editor", "publisher", "content_admin", "superadmin"]

EXPECTED_CAPABILITIES = {
    "viewer": {"read"},
    "reviewer": {"read", "review"},
    "editor": {"read", "edit_draft"},
    "publisher": {"read", "review", "publish"},
    "content_admin": {"read", "edit_draft", "review", "publish"},
    "superadmin": {"read", "edit_draft", "review", "publish", "manage_roles"},
}


def check(client: ic.RestClient) -> list:
    problems = []

    roles = client.select("admin_roles", "code,order_index")
    codes = sorted(row["code"] for row in roles)
    if codes != sorted(EXPECTED_ROLES):
        problems.append(f"roles: {codes} != {sorted(EXPECTED_ROLES)}")

    matrix: dict = {}
    for row in client.select("admin_role_capabilities", "role_code,capability"):
        matrix.setdefault(row["role_code"], set()).add(row["capability"])
    for role, expected in EXPECTED_CAPABILITIES.items():
        got = matrix.get(role, set())
        if got != expected:
            problems.append(f"{role}: {sorted(got)} != {sorted(expected)}")

    # El criterio de la historia, explícito y en la base (no en este script).
    for role, capability, expected in (
        ("editor", "publish", False),
        ("editor", "edit_draft", True),
        ("publisher", "publish", True),
        ("reviewer", "publish", False),
        ("viewer", "edit_draft", False),
        ("viewer", "publish", False),
        ("superadmin", "manage_roles", True),
        ("content_admin", "manage_roles", False),
    ):
        got = client.rpc("admin_role_can", {"p_role": role, "p_capability": capability})
        if bool(got) is not expected:
            problems.append(f"admin_role_can({role}, {capability}) = {got}, se esperaba {expected}")

    # Sin sesión no hay permiso ni sesión: service_role no hereda roles.
    if client.rpc("admin_can", {"p_capability": "publish"}) is not False:
        problems.append("admin_can('publish') sin usuario no es false")
    if client.rpc("admin_session", {}) is not None:
        problems.append("admin_session() sin usuario no es null")

    # Un rol inventado no concede nada y no se puede asignar.
    if client.rpc("admin_role_can", {"p_role": "inventado", "p_capability": "publish"}) is not False:
        problems.append("un rol inventado concede permisos")

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
    print(json.dumps({"roles": len(EXPECTED_ROLES), "matriz": "ok"}, ensure_ascii=False))
    print("OK · 6 roles; editor no publica")
    return 0


if __name__ == "__main__":
    sys.exit(main())
