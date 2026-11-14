#!/usr/bin/env python3
"""Comprueba el CRUD de unidades contra la base (CUR-12).

El criterio de la historia es «reordenar y asignar lecciones», y lo que puede
romperse es el índice único `(level_id, order_index)` / `(unit_id, order_index)`:
por eso se comprueba que tras mover y borrar no quedan huecos ni duplicados.

    python scripts/check_admin_units.py
"""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

import import_curriculum as ic  # noqa: E402

PROBE_UNIT_SLUG = "zz-probe-unit"
PROBE_LESSON = "zz_probe_unit_lesson"


def unit_state(client: ic.RestClient) -> tuple[list, list[str]]:
    data = client.rpc("admin_units", {"p_level": "a1"})
    level = data["levels"][0]
    return level["units"], [unit["slug"] for unit in level["units"]]


def orders(units: list) -> list[int]:
    return [unit["order_index"] for unit in units]


def expect_error(client: ic.RestClient, name: str, args: dict, needle: str) -> list:
    try:
        client.rpc(name, args)
    except SystemExit as error:
        if needle in str(error):
            return []
        return [f"{name}: se esperaba «{needle}» y llegó {str(error)[:120]}"]
    return [f"{name}: se esperaba error «{needle}»"]


def check(client: ic.RestClient) -> list:
    problems: list = []
    created_unit = None
    lesson_created = False

    try:
        units, slugs = unit_state(client)
        if len(units) != 4:
            problems.append(f"A1 empieza con {len(units)} unidades != 4")
        if orders(units) != [1, 2, 3, 4]:
            problems.append(f"orden inicial {orders(units)}")

        # 1 · Crear en medio y que el orden quede 1..5 sin huecos
        created = client.rpc(
            "admin_save_unit",
            {
                "p_unit": {
                    "level_id": "a1",
                    "slug": PROBE_UNIT_SLUG,
                    "title": "Unidad de prueba",
                    "order_index": 2,
                }
            },
        )
        created_unit = created["id"]
        units, slugs = unit_state(client)
        if orders(units) != [1, 2, 3, 4, 5]:
            problems.append(f"tras crear en 2, el orden es {orders(units)}")
        if units[1]["slug"] != PROBE_UNIT_SLUG:
            problems.append(f"la unidad nueva no quedó en la posición 2: {slugs}")

        # 2 · Reordenar la última a la primera
        last = units[-1]
        client.rpc("admin_save_unit", {"p_unit": {"id": last["id"], "level_id": "a1", "order_index": 1}})
        units, slugs = unit_state(client)
        if orders(units) != [1, 2, 3, 4, 5]:
            problems.append(f"tras reordenar, el orden es {orders(units)}")
        if units[0]["id"] != last["id"]:
            problems.append("la unidad movida no quedó la primera")

        # 3 · Borrar una unidad con lecciones se rechaza
        occupier = next(unit for unit in units if unit["lessons"])
        problems += expect_error(
            client,
            "admin_delete_unit",
            {"p_id": occupier["id"]},
            "tiene",
        )

        # 4 · Mover una lección de unidad y devolverla
        draft = client.rpc(            "admin_save_lesson",
            {
                "p_lesson": {
                    "id": PROBE_LESSON,
                    "unit_id": units[0]["id"],
                    "title": "Lección de prueba de unidades",
                    "category": "daily",
                    "difficulty": 1,
                    "objectives": [
                        {"code": "g1", "description": "Objetivo", "competency": "speaking"}
                    ],
                    "phrases": [{"phrase": "Hi", "translation": "Hola"}],
                }
            },
        )
        lesson_created = True

        target = next(unit for unit in units if unit["id"] != units[0]["id"])
        moved = client.rpc(
            "admin_move_lesson",
            {"p_lesson_id": PROBE_LESSON, "p_unit_id": target["id"], "p_order_index": 1},
        )
        if moved["order_index"] != 1:
            problems.append(f"la lección no quedó en 1: {moved}")
        units, _ = unit_state(client)
        target_orders = [lesson["order_index"] for lesson in next(u for u in units if u["id"] == target["id"])["lessons"]]
        if target_orders != list(range(1, len(target_orders) + 1)):
            problems.append(f"lecciones del destino sin orden compacto: {target_orders}")

        back = client.rpc(
            "admin_move_lesson",
            {"p_lesson_id": PROBE_LESSON, "p_unit_id": units[0]["id"], "p_order_index": 1},
        )
        units, _ = unit_state(client)
        first_orders = [lesson["order_index"] for lesson in units[0]["lessons"]]
        if first_orders != list(range(1, len(first_orders) + 1)):
            problems.append(f"lecciones al volver sin orden compacto: {first_orders}")
        if back["previous_unit"] != target["id"]:
            problems.append("el movimiento de vuelta no recuerda el origen")

        # 5 · Borrar la unidad de prueba vacía sí funciona
        client.rpc("admin_delete_unit", {"p_id": created_unit})
        created_unit = None
        units, slugs = unit_state(client)
        if PROBE_UNIT_SLUG in slugs:
            problems.append("la unidad de prueba sigue ahí tras borrarla")
        if orders(units) != [1, 2, 3, 4]:
            problems.append(f"tras borrar, el orden es {orders(units)}")

        # 6 · Auditoría
        logs = client.select(
            "content_audit_logs",
            "action,entity",
            filters={"action": "in.(save_unit,delete_unit,move_lesson)"},
        )
        actions = {log["action"] for log in logs}
        for expected in ("save_unit", "delete_unit", "move_lesson"):
            if expected not in actions:
                problems.append(f"sin registro de auditoría para {expected}")
    finally:
        if lesson_created:
            client.delete("lessons", {"id": f"eq.{PROBE_LESSON}"})
            # Borrar deja un hueco en el orden de la unidad: se recoloca la
            # primera lección en su sitio, que renumera la unidad entera.
            for unit in unit_state(client)[0]:
                orders_actual = [item["order_index"] for item in unit["lessons"]]
                if orders_actual and orders_actual != list(range(1, len(orders_actual) + 1)):
                    client.rpc(
                        "admin_move_lesson",
                        {
                            "p_lesson_id": unit["lessons"][0]["id"],
                            "p_unit_id": unit["id"],
                            "p_order_index": 1,
                        },
                    )
        if created_unit:
            try:
                client.rpc("admin_delete_unit", {"p_id": created_unit})
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
    print("OK · reordena y reasigna sin huecos ni duplicados")
    return 0


if __name__ == "__main__":
    sys.exit(main())
