#!/usr/bin/env python3
"""Comprueba el constructor de actividades (CUR-14).

Lo que puede romperse: aceptar un payload incompleto, dejar usar un tipo
deshabilitado, o escribir la actividad fuera de la versión en curso.

    python scripts/check_admin_activities.py
"""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

import import_curriculum as ic  # noqa: E402

PUBLISHED_ID = "a1_ordering_coffee_at_a_cafe"


def expect_error(client: ic.RestClient, args: dict, needle: str) -> list:
    try:
        client.rpc("admin_save_activity", args)
    except SystemExit as error:
        if needle in str(error):
            return []
        return [f"se esperaba «{needle}» y llegó {str(error)[:140]}"]
    return [f"se esperaba error «{needle}»"]


def check(client: ic.RestClient) -> list:
    problems: list = []
    toggled = []
    activity_version = None

    try:
        types = {row["code"]: row for row in client.rpc("admin_activity_types", {})["types"]}
        expected = {"conversation", "mcq", "fill_blank", "order_words"}
        if set(types) != expected:
            problems.append(f"tipos: {sorted(types)} != {sorted(expected)}")
        if not types["conversation"]["is_enabled"]:
            problems.append("conversation debería venir habilitado")
        for code in ("mcq", "fill_blank", "order_words"):
            if types[code]["is_enabled"]:
                problems.append(f"{code} debería venir deshabilitado")
        if types["mcq"]["required_keys"] != ["question", "options", "correct"]:
            problems.append(f"required_keys de mcq: {types['mcq']['required_keys']}")

        lesson = client.rpc("admin_lesson", {"p_lesson_id": PUBLISHED_ID})

        # Un tipo deshabilitado no se puede usar
        problems += expect_error(
            client,
            {
                "p_lesson_id": PUBLISHED_ID,
                "p_activity": {
                    "activity_type": "mcq",
                    "payload": {"question": "¿?", "options": ["a", "b"], "correct": "a"},
                },
            },
            "deshabilitado",
        )

        # Payload incompleto: dice qué clave falta
        problems += expect_error(
            client,
            {
                "p_lesson_id": PUBLISHED_ID,
                "p_activity": {"activity_type": "conversation", "payload": {"otra": 1}},
            },
            "goals",
        )

        # Una actividad válida se guarda en el borrador (v2), no en la publicada
        saved = client.rpc(
            "admin_save_activity",
            {
                "p_lesson_id": PUBLISHED_ID,
                "p_activity": {
                    "activity_type": "conversation",
                    "payload": {"goals": ["Order a coffee", "Ask the price"]},
                    "instructions": "Pide un café",
                },
            },
        )
        activity_version = saved["version"]
        if saved["version"] != lesson["published_version"] + 1:
            problems.append(f"la actividad fue a la v{saved['version']}, no al borrador")

        with_activity = client.rpc("admin_lesson", {"p_lesson_id": PUBLISHED_ID})
        if with_activity["draft_version"] != 2:
            problems.append("la lección no reconoce el borrador de solo actividad")
        if not with_activity["activities"]:
            problems.append("la actividad no aparece en la lectura del borrador")

        # Habilitar mcq y usarlo, con restauración al final
        client.rpc("admin_set_activity_enabled", {"p_code": "mcq", "p_enabled": True})
        toggled.append("mcq")
        problem = expect_error(
            client,
            {
                "p_lesson_id": PUBLISHED_ID,
                "p_activity": {"activity_type": "mcq", "payload": {"question": "¿?", "options": ["a"]}},
            },
            "correct",
        )
        if problem:
            problems += problem
        ok = client.rpc(
            "admin_save_activity",
            {
                "p_lesson_id": PUBLISHED_ID,
                "p_activity": {
                    "activity_type": "mcq",
                    "p_order_index": 2,
                    "payload": {"question": "¿Qué pides?", "options": ["café", "té"], "correct": "café"},
                },
            },
        )
        if ok["activity_type"] != "mcq":
            problems.append(f"mcq no se guardó: {ok}")
    finally:
        if activity_version is not None:
            client.delete(
                "lesson_activities",
                {"lesson_id": f"eq.{PUBLISHED_ID}", "version": f"eq.{activity_version}"},
            )
        for code in toggled:
            try:
                client.rpc("admin_set_activity_enabled", {"p_code": code, "p_enabled": False})
            except SystemExit:
                pass

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
    print("OK · valida payload, exige tipo habilitado y escribe en el borrador")
    return 0


if __name__ == "__main__":
    sys.exit(main())
