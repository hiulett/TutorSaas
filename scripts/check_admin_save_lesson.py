#!/usr/bin/env python3
"""Comprueba el RPC `admin_save_lesson` contra la base (CUR-08).

Cubre lo que la historia pide (valida, escribe borrador, audita) y la regla que
protege a la app: **editar una lección publicada no la despublica**.

Trabaja con una lección de prueba propia y limpia lo que escribe; el registro de
auditoría se queda a propósito, porque es inmutable.

    python scripts/check_admin_save_lesson.py
"""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

import import_curriculum as ic  # noqa: E402

PROBE_ID = "zz_probe_save_lesson"
PUBLISHED_ID = "a1_ordering_coffee_at_a_cafe"


def lesson_payload(unit_id: str, **overrides) -> dict:
    payload = {
        "id": PROBE_ID,
        "unit_id": unit_id,
        "title": "Lección de prueba de guardado",
        "category": "daily",
        "difficulty": 1,
        "order_index": 9,
        "main_objective": "Probar el guardado de borradores",
        "objectives": [
            {
                "code": "g1",
                "description": "Pedir un café",
                "competency": "speaking",
                "evidence_examples": {"keywords": ["coffee"], "example_phrase": "A coffee, please"},
                "order_index": 1,
            },
            {
                "code": "g2",
                "description": "Pedir la cuenta",
                "competency": "speaking",
                "order_index": 2,
            },
        ],
        "phrases": [
            {"phrase": "A coffee, please.", "translation": "Un café, por favor.", "order_index": 1},
            {"phrase": "The bill, please.", "translation": "La cuenta, por favor.", "order_index": 2},
        ],
    }
    payload.update(overrides)
    return payload


def expect_error(client: ic.RestClient, lesson: dict, needle: str) -> list:
    try:
        client.rpc("admin_save_lesson", {"p_lesson": lesson})
    except SystemExit as error:
        if needle in str(error):
            return []
        return [f"se esperaba «{needle}» y llegó: {str(error)[:120]}"]
    return [f"se esperaba error «{needle}» y no hubo error"]


def find_lesson(pack: dict, lesson_id: str):
    for unit in pack["units"]:
        for lesson in unit["lessons"]:
            if lesson["id"] == lesson_id:
                return {**lesson, "unit_id": unit["id"]}
    return None


def check(client: ic.RestClient) -> list:
    problems: list = []
    units = client.select("curriculum_units", "id,slug,level_id")
    unit_id = next(unit["id"] for unit in units if unit["slug"] == "a1-u1")

    try:
        # 1 · Crear borrador
        saved = client.rpc("admin_save_lesson", {"p_lesson": lesson_payload(unit_id)})
        if saved["draft_version"] != 1:
            problems.append(f"borrador nuevo con versión {saved['draft_version']} != 1")
        if saved["lesson_status"] != "draft":
            problems.append(f"lección nueva con estado {saved['lesson_status']} != draft")
        if (saved["objectives"], saved["phrases"]) != (2, 2):
            problems.append(f"conteos del borrador: {saved}")

        rows = client.select(
            "lessons", "id,status,current_version", filters={"id": f"eq.{PROBE_ID}"}
        )
        if len(rows) != 1 or rows[0]["status"] != "draft":
            problems.append(f"fila de lección inesperada: {rows}")

        # 2 · Guardar otra vez no acumula filas
        client.rpc("admin_save_lesson", {"p_lesson": lesson_payload(unit_id)})
        objectives = client.select(
            "lesson_objectives", "code", filters={"lesson_id": f"eq.{PROBE_ID}"}
        )
        phrases = client.select(
            "lesson_phrases", "order_index", filters={"lesson_id": f"eq.{PROBE_ID}"}
        )
        if len(objectives) != 2 or len(phrases) != 2:
            problems.append(
                f"guardar dos veces duplicó filas: {len(objectives)} objetivos, {len(phrases)} frases"
            )

        # 3 · Validación
        problems += expect_error(
            client,
            lesson_payload(
                unit_id,
                objectives=[{"code": "g1", "description": "x", "competency": "cantar"}],
            ),
            "competency inválida",
        )
        problems += expect_error(
            client,
            lesson_payload(
                unit_id, objectives=[{"description": "sin code", "competency": "speaking"}]
            ),
            "sin code",
        )
        problems += expect_error(
            client,
            lesson_payload(
                unit_id,
                phrases=[{"phrase": "a", "order_index": 1}, {"phrase": "b", "order_index": 1}],
            ),
            "order_index de frase repetido",
        )
        problems += expect_error(
            client,
            lesson_payload(unit_id, activities=[{"activity_type": "inventada", "payload": {}}]),
            "tipo de actividad inexistente",
        )
        problems += expect_error(
            client, lesson_payload(unit_id, title="   "), "falta el título"
        )

        # 4 · Editar una lección publicada no la despublica
        published = client.select(
            "lessons", "id,status,current_version", filters={"id": f"eq.{PUBLISHED_ID}"}
        )[0]
        if published["status"] != "published":
            problems.append(f"{PUBLISHED_ID} no está publicada: {published['status']}")

        pack_before = client.rpc(
            "get_curriculum_pack", {"p_level": "a1", "p_since_version": 0}
        )
        before = find_lesson(pack_before, PUBLISHED_ID)
        if before is None:
            problems.append(f"{PUBLISHED_ID} no aparece en el pack de A1")
        else:
            client.rpc(
                "admin_save_lesson",
                {
                    "p_lesson": {
                        "id": PUBLISHED_ID,
                        "unit_id": before["unit_id"],
                        "title": before["title"],
                        "category": before["category"],
                        "difficulty": before["difficulty"],
                        "order_index": before["order_index"],
                        "objectives": before["objectives"],
                        "phrases": before["phrases"],
                    }
                },
            )

            after_row = client.select(
                "lessons", "id,status,current_version", filters={"id": f"eq.{PUBLISHED_ID}"}
            )[0]
            if after_row["status"] != "published":
                problems.append("editar despublicó la lección")
            if after_row["current_version"] != published["current_version"]:
                problems.append("editar movió la versión publicada")

            pack_after = client.rpc(
                "get_curriculum_pack", {"p_level": "a1", "p_since_version": 0}
            )
            after = find_lesson(pack_after, PUBLISHED_ID)
            if after is None:
                problems.append("la lección publicada desapareció del pack tras editarla")
            elif after["title"] != before["title"] or len(after["phrases"]) != len(
                before["phrases"]
            ):
                problems.append("el pack cambió tras guardar un borrador")

        # 5 · Auditoría
        logs = client.select(
            "content_audit_logs",
            "entity,entity_id,action,diff",
            filters={"entity_id": f"eq.{PROBE_ID}"},
        )
        if not logs or logs[0]["action"] != "save_draft":
            problems.append(f"sin registro de auditoría: {logs}")
        elif logs[0]["diff"]["objectives"] != 2:
            problems.append(f"auditoría con diff incompleto: {logs[0]['diff']}")
    finally:
        # Limpieza: el borrador de la lección real y la lección de prueba.
        client.delete(
            "lesson_objectives", {"lesson_id": f"eq.{PUBLISHED_ID}", "version": "eq.2"}
        )
        client.delete("lesson_phrases", {"lesson_id": f"eq.{PUBLISHED_ID}", "version": "eq.2"})
        client.delete("lessons", {"id": f"eq.{PROBE_ID}"})

    return problems


def main() -> int:
    env = ic.load_env()
    url = env.get("SUPABASE_URL")
    key = env.get("SUPABASE_SERVICE_ROLE_KEY")
    if not url or not key:
        print(
            "faltan SUPABASE_URL o SUPABASE_SERVICE_ROLE_KEY (entorno o .env)",
            file=sys.stderr,
        )
        return 2

    problems = check(ic.RestClient(url, key))
    for problem in problems:
        print(f"PROBLEMA  {problem}", file=sys.stderr)
    if problems:
        return 1
    print("OK · valida, guarda borrador, audita y no despublica")
    return 0


if __name__ == "__main__":
    sys.exit(main())
