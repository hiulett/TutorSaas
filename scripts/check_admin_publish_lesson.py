#!/usr/bin/env python3
"""Comprueba el RPC `admin_publish_lesson` contra la base (CUR-09).

El criterio de la historia es «falla entera si algo no valida», así que además
del camino feliz se comprueba que un fallo no deja estado a medias: ni fila de
versión, ni `current_version` movido, ni registro de auditoría.

Trabaja con lecciones de prueba propias y las borra al terminar.

    python scripts/check_admin_publish_lesson.py
"""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

import import_curriculum as ic  # noqa: E402

PROBE_OK = "zz_probe_publish_ok"
PROBE_EMPTY = "zz_probe_publish_empty"


def payload(lesson_id: str, unit_id: str, objectives: int, phrases: int) -> dict:
    return {
        "id": lesson_id,
        "unit_id": unit_id,
        "title": f"Lección {lesson_id}",
        "category": "daily",
        "difficulty": 2,
        "order_index": 8 if lesson_id == PROBE_OK else 7,
        "objectives": [
            {
                "code": f"g{n}",
                "description": f"Objetivo {n}",
                "competency": "speaking",
                "order_index": n,
            }
            for n in range(1, objectives + 1)
        ],
        "phrases": [
            {"phrase": f"Phrase {n}", "translation": f"Frase {n}", "order_index": n}
            for n in range(1, phrases + 1)
        ],
    }


def versiones(client: ic.RestClient, lesson_id: str) -> list:
    return client.select(
        "lesson_versions",
        "version,published_by,snapshot",
        filters={"lesson_id": f"eq.{lesson_id}"},
    )


def audit_count(client: ic.RestClient, lesson_id: str) -> int:
    return len(
        client.select(
            "content_audit_logs", "action", filters={"entity_id": f"eq.{lesson_id}"}
        )
    )


def expect_error(client: ic.RestClient, lesson_id: str, needle: str) -> list:
    try:
        client.rpc("admin_publish_lesson", {"p_lesson_id": lesson_id})
    except SystemExit as error:
        if needle in str(error):
            return []
        return [f"se esperaba «{needle}» y llegó: {str(error)[:140]}"]
    return [f"se esperaba error «{needle}» y no hubo error"]


def check(client: ic.RestClient) -> list:
    problems: list = []
    units = client.select("curriculum_units", "id,slug")
    unit_id = next(unit["id"] for unit in units if unit["slug"] == "a1-u1")

    try:
        # 1 · Publicar un borrador válido
        client.rpc(
            "admin_save_lesson",
            {"p_lesson": payload(PROBE_OK, unit_id, objectives=2, phrases=2)},
        )
        published = client.rpc("admin_publish_lesson", {"p_lesson_id": PROBE_OK})
        if published["version"] != 1:
            problems.append(f"versión publicada {published['version']} != 1")

        row = client.select(
            "lessons", "status,current_version", filters={"id": f"eq.{PROBE_OK}"}
        )[0]
        if (row["status"], row["current_version"]) != ("published", 1):
            problems.append(f"estado tras publicar: {row}")

        versions = versiones(client, PROBE_OK)
        if len(versions) != 1:
            problems.append(f"versiones tras publicar: {len(versions)}")
        elif versions[0]["snapshot"].get("source") != "portal":
            problems.append("el snapshot no marca el origen del portal")

        audit_before = audit_count(client, PROBE_OK)

        # 2 · Publicar dos veces falla y no deja rastro
        problems += expect_error(client, PROBE_OK, "no hay borrador pendiente")
        row = client.select(
            "lessons", "status,current_version", filters={"id": f"eq.{PROBE_OK}"}
        )[0]
        if (row["status"], row["current_version"]) != ("published", 1):
            problems.append(f"un fallo movió el estado: {row}")
        if len(versiones(client, PROBE_OK)) != 1:
            problems.append("un fallo dejó una versión nueva")
        if audit_count(client, PROBE_OK) != audit_before:
            problems.append("un fallo dejó un registro de auditoría")

        # 3 · Un borrador sin objetivos falla entero, sin escribir nada
        client.rpc(
            "admin_save_lesson",
            {"p_lesson": payload(PROBE_EMPTY, unit_id, objectives=0, phrases=1)},
        )
        problems += expect_error(client, PROBE_EMPTY, "no tiene objetivos")
        if versiones(client, PROBE_EMPTY):
            problems.append("un fallo escribió una fila de versión")
        empty = client.select(
            "lessons", "status,current_version", filters={"id": f"eq.{PROBE_EMPTY}"}
        )[0]
        if empty["status"] != "draft":
            problems.append(f"un fallo publicó la lección: {empty}")

        # 4 · Un borrador sin frases tampoco publica
        client.rpc(
            "admin_save_lesson",
            {"p_lesson": payload(PROBE_EMPTY, unit_id, objectives=1, phrases=0)},
        )
        problems += expect_error(client, PROBE_EMPTY, "no tiene frases")
        if versiones(client, PROBE_EMPTY):
            problems.append("un borrador sin frases dejó una versión")
    finally:
        client.delete("lessons", {"id": f"eq.{PROBE_OK}"})
        client.delete("lessons", {"id": f"eq.{PROBE_EMPTY}"})

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
    print("OK · publica en una transacción y falla entera sin dejar estado")
    return 0


if __name__ == "__main__":
    sys.exit(main())
