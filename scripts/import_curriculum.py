#!/usr/bin/env python3
"""Importación idempotente del currículo a PostgreSQL (CUR-03).

Toma la exportación canónica de CUR-02 (`build/curriculum/lessons.json`) y la
lleva a las tablas `curriculum_*` creadas por la migración
`20261113150000_curriculum_schema.sql`.

Reglas (plan §7):

- **Ids intactos**: `lessons.id` es el mismo texto que el id del catálogo Dart,
  así que `lesson_progress.lesson_id` no cambia y el progreso no se pierde.
- **Idempotente por hash**: se calcula el sha256 del JSON canónico de cada
  lección. Si el hash no cambió no se escribe nada. Si cambió se crea una
  versión nueva; la anterior queda intacta (una versión nueva no revoca una
  completada).
- **Traducciones idénticas**: cuando `translation` coincide con `phrase` se
  guarda `translation_status='identical'` y **no** se corrige el texto. Es
  deuda editorial en cola (CUR-04), no un dato a inventar aquí.
- **Niveles y unidades**: los 7 niveles los siembra la migración (aquí solo se
  validan, no se inventan nombres). Las unidades son agrupación editorial: 4
  por nivel, una por cada bloque de 5 lecciones en el orden del catálogo.
- No toca el catálogo Dart ni la app.

Uso:

    python scripts/import_curriculum.py --dry-run   # plan y conteos, sin red
    python scripts/import_curriculum.py --apply     # escribe en Supabase
    python scripts/import_curriculum.py --verify    # comprueba lo guardado

Entorno: `SUPABASE_URL` y `SUPABASE_SERVICE_ROLE_KEY`, o un `.env` en la raíz
(ignorado por git). Sin credenciales, `--dry-run` sigue funcionando.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from collections import Counter
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "build/curriculum/lessons.json"

# Agrupación editorial: 4 unidades por nivel, 5 lecciones por unidad.
LESSONS_PER_UNIT = 5

# Conteos del inventario (docs/audits/AUDITORIA_COMPLETA_INVENTARIO_LECCIONES.md).
EXPECTED_LESSONS = 140
EXPECTED_OBJECTIVES = 540
EXPECTED_PHRASES = 539
EXPECTED_IDENTICAL = 481

# El origen no trae `competency` por objetivo: el catálogo es conversacional.
DEFAULT_COMPETENCY = "communication"

# Página de PostgREST (el máximo por defecto de Supabase es 1000).
PAGE = 1000


# ── Transformación (pura, sin red) ──────────────────────────────────────────


def canonical_json(value) -> str:
    """JSON estable: claves ordenadas, sin espacios, UTF-8 tal cual."""
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


def sha256_of(value) -> str:
    return hashlib.sha256(canonical_json(value).encode("utf-8")).hexdigest()


def level_id_for(cefr: str) -> str:
    """`'PRE-A1'` → `'pre_a1'`: los ids de `curriculum_levels`."""
    return (cefr or "").strip().lower().replace("-", "_")


def translation_status(phrase: str, translation: str) -> str:
    """`ok` | `identical` | `pending`, sin tocar el texto original.

    `identical` significa que la traducción no está traducida (misma cadena,
    ignorando mayúsculas y espacios exteriores). No se corrige: se marca.
    """
    translation = (translation or "").strip()
    if not translation:
        return "pending"
    if translation.casefold() == (phrase or "").strip().casefold():
        return "identical"
    return "ok"


def objective_evidence(goal: dict) -> dict:
    """Conserva las palabras clave del validador dentro del objetivo."""
    return {
        "keywords": list(goal.get("keywords") or []),
        "example_phrase": goal.get("examplePhrase"),
    }


def unit_title(level_id: str, unit_no: int) -> str:
    """Título editorial provisional: el portal (CUR-13) los renombra."""
    return f"{level_id.upper()} · Unidad {unit_no}"


def load_source(path: Path = SOURCE) -> list:
    data = json.loads(path.read_text(encoding="utf-8"))
    lessons = data["lessons"] if isinstance(data, dict) else data
    if not isinstance(lessons, list):
        raise SystemExit(f"{path}: se esperaba una lista de lecciones")
    return lessons


def build_plan(lessons: list) -> dict:
    """Convierte el origen en filas listas para upsert + hashes por lección."""
    units: dict = {}
    rows: list = []
    seen: Counter = Counter()

    for catalog_index, lesson in enumerate(lessons, start=1):
        level_id = level_id_for(lesson.get("level"))
        index_in_level = seen[level_id]
        seen[level_id] += 1
        unit_no = index_in_level // LESSONS_PER_UNIT + 1
        slug = f"{level_id}-u{unit_no}"

        units.setdefault(
            (level_id, slug),
            {
                "level_id": level_id,
                "slug": slug,
                "title": unit_title(level_id, unit_no),
                "description": None,
                "order_index": unit_no,
            },
        )

        # El snapshot es la lección de origen tal cual: es lo que se hashea y
        # lo que permite reconstruir la versión publicada.
        snapshot = dict(lesson)

        rows.append(
            {
                "id": lesson["id"],
                "level_id": level_id,
                "unit_slug": slug,
                "order_index": index_in_level % LESSONS_PER_UNIT + 1,
                "catalog_index": catalog_index,
                "title": lesson.get("title"),
                "category": lesson.get("category") or "daily",
                "difficulty": lesson.get("difficulty"),
                "main_objective": lesson.get("mainObjective"),
                "scenario_context": lesson.get("scenarioContext"),
                "assistant_role": lesson.get("assistantRole"),
                "user_role": lesson.get("userRole"),
                "initial_message": lesson.get("initialAssistantMessage"),
                "snapshot": snapshot,
                "hash": sha256_of(snapshot),
                "objectives": [
                    {
                        "code": goal.get("id"),
                        "description": goal.get("text"),
                        "competency": DEFAULT_COMPETENCY,
                        "evidence_examples": objective_evidence(goal),
                        "is_required": True,
                        "order_index": position,
                    }
                    for position, goal in enumerate(lesson.get("goals") or [], start=1)
                ],
                "phrases": [
                    {
                        "order_index": position,
                        "phrase": phrase.get("phrase"),
                        "translation": phrase.get("translation"),
                        "translation_status": translation_status(
                            phrase.get("phrase"), phrase.get("translation")
                        ),
                    }
                    for position, phrase in enumerate(lesson.get("phrases") or [], start=1)
                ],
            }
        )

    return {
        "levels": sorted({row["level_id"] for row in rows}),
        "units": list(units.values()),
        "lessons": rows,
    }


def summarize(plan: dict) -> dict:
    lessons = plan["lessons"]
    return {
        "lessons": len(lessons),
        "levels": len(plan["levels"]),
        "units": len(plan["units"]),
        "objectives": sum(len(row["objectives"]) for row in lessons),
        "phrases": sum(len(row["phrases"]) for row in lessons),
        "identical": sum(
            1
            for row in lessons
            for phrase in row["phrases"]
            if phrase["translation_status"] == "identical"
        ),
    }


def check_expected(summary: dict) -> list:
    """Diferencias contra el inventario. Lista vacía = conteos correctos."""
    problems = []
    for key, expected in (
        ("lessons", EXPECTED_LESSONS),
        ("objectives", EXPECTED_OBJECTIVES),
        ("phrases", EXPECTED_PHRASES),
        ("identical", EXPECTED_IDENTICAL),
    ):
        if summary[key] != expected:
            problems.append(f"{key}: {summary[key]} != {expected}")
    return problems


# ── Acceso a la base (PostgREST con service_role) ───────────────────────────


def load_env() -> dict:
    """Variables de entorno, con `.env` de la raíz como respaldo."""
    env = dict(os.environ)
    env_file = ROOT / ".env"
    if env_file.exists():
        for line in env_file.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, _, value = line.partition("=")
            env.setdefault(key.strip(), value.strip().strip("'\""))
    return env


class RestClient:
    """Cliente mínimo de PostgREST. `service_role` omite RLS a propósito."""

    def __init__(self, url: str, key: str, timeout: int = 60):
        self.url = url.rstrip("/")
        self.key = key
        self.timeout = timeout

    def _call(self, method: str, table: str, params: dict, body=None, prefer=None):
        query = urllib.parse.urlencode(params)
        target = f"{self.url}/rest/v1/{table}"
        if query:
            target = f"{target}?{query}"
        headers = {
            "apikey": self.key,
            "Authorization": f"Bearer {self.key}",
            "Content-Type": "application/json",
        }
        if prefer:
            headers["Prefer"] = prefer
        payload = None if body is None else json.dumps(body).encode("utf-8")
        request = urllib.request.Request(target, data=payload, headers=headers, method=method)
        try:
            with urllib.request.urlopen(request, timeout=self.timeout) as response:
                raw = response.read()
                return json.loads(raw) if raw else None
        except urllib.error.HTTPError as error:
            detail = error.read().decode("utf-8", "replace")
            raise SystemExit(f"{method} {table}: HTTP {error.code}\n{detail}") from error

    def select(self, table: str, select: str, order: str | None = None) -> list:
        rows: list = []
        offset = 0
        while True:
            params = {"select": select, "limit": PAGE, "offset": offset}
            if order:
                params["order"] = order
            page = self._call("GET", table, params) or []
            rows.extend(page)
            if len(page) < PAGE:
                return rows
            offset += PAGE

    def upsert(self, table: str, rows: list, on_conflict: str) -> None:
        if not rows:
            return
        for start in range(0, len(rows), PAGE):
            chunk = rows[start : start + PAGE]
            self._call(
                "POST",
                table,
                {"on_conflict": on_conflict},
                body=chunk,
                prefer="resolution=merge-duplicates,return=minimal",
            )


def lesson_row(row: dict, unit_id: str, version: int) -> dict:
    return {
        "id": row["id"],
        "unit_id": unit_id,
        "title": row["title"],
        "category": row["category"],
        "difficulty": row["difficulty"],
        "order_index": row["order_index"],
        "main_objective": row["main_objective"],
        "scenario_context": row["scenario_context"],
        "assistant_role": row["assistant_role"],
        "user_role": row["user_role"],
        "initial_message": row["initial_message"],
        "status": "published",
        "current_version": version,
    }


def apply_plan(plan: dict, client: RestClient) -> dict:
    """Upsert idempotente. Devuelve el recuento de lo escrito y lo omitido."""
    stats = {"created": 0, "new_versions": 0, "unchanged": 0}

    known_levels = {row["id"] for row in client.select("curriculum_levels", "id")}
    missing = [level for level in plan["levels"] if level not in known_levels]
    if missing:
        raise SystemExit(
            "faltan niveles en `curriculum_levels`: "
            + ", ".join(missing)
            + " (aplica la migración 20261113150000)"
        )

    client.upsert("curriculum_units", plan["units"], "level_id,slug")
    unit_ids = {
        (row["level_id"], row["slug"]): row["id"]
        for row in client.select("curriculum_units", "id,level_id,slug")
    }

    current_version = {
        row["id"]: row["current_version"]
        for row in client.select("lessons", "id,current_version")
    }

    # Hash de la última versión guardada, por lección.
    last_hash: dict = {}
    last_version: dict = {}
    for row in client.select("lesson_versions", "lesson_id,version,snapshot", order="lesson_id,version"):
        lesson_id = row["lesson_id"]
        if row["version"] >= last_version.get(lesson_id, 0):
            last_version[lesson_id] = row["version"]
            last_hash[lesson_id] = sha256_of(row["snapshot"])

    pending = [
        row for row in plan["lessons"] if last_hash.get(row["id"]) != row["hash"]
    ]
    stats["unchanged"] = len(plan["lessons"]) - len(pending)
    if not pending:
        return stats

    versions = {row["id"]: current_version.get(row["id"], 0) + 1 for row in pending}
    now = datetime.now(timezone.utc).isoformat()

    lessons = [
        lesson_row(row, unit_ids[(row["level_id"], row["unit_slug"])], versions[row["id"]])
        for row in pending
    ]
    snapshots = [
        {
            "lesson_id": row["id"],
            "version": versions[row["id"]],
            "snapshot": row["snapshot"],
            "changelog": f"CUR-03 import · sha256 {row['hash'][:12]}",
            "published_at": now,
        }
        for row in pending
    ]

    client.upsert("lessons", lessons, "id")
    client.upsert("lesson_versions", snapshots, "lesson_id,version")

    objectives = [
        {
            "lesson_id": row["id"],
            "version": versions[row["id"]],
            **objective,
        }
        for row in pending
        for objective in row["objectives"]
    ]
    phrases = [
        {
            "lesson_id": row["id"],
            "version": versions[row["id"]],
            **phrase,
        }
        for row in pending
        for phrase in row["phrases"]
    ]

    client.upsert("lesson_objectives", objectives, "lesson_id,version,code")
    client.upsert("lesson_phrases", phrases, "lesson_id,version,order_index")

    stats["created"] = sum(1 for row in pending if row["id"] not in current_version)
    stats["new_versions"] = len(pending) - stats["created"]
    return stats


# ── Verificación ────────────────────────────────────────────────────────────


def verify_plan(plan: dict, client: RestClient) -> dict:
    """Compara la base con el plan: ids, conteos, hashes y traducciones."""
    problems: list = []

    lessons = client.select("lessons", "id,current_version,unit_id,title")
    stored = {row["id"]: row for row in lessons}
    expected_ids = {row["id"] for row in plan["lessons"]}
    if len(lessons) != EXPECTED_LESSONS:
        problems.append(f"lessons en la base: {len(lessons)} != {EXPECTED_LESSONS}")
    missing = sorted(expected_ids - set(stored))
    extra = sorted(set(stored) - expected_ids)
    if missing:
        problems.append(f"lecciones ausentes: {len(missing)} (p.ej. {missing[:3]})")
    if extra:
        problems.append(f"lecciones sobrantes: {len(extra)} (p.ej. {extra[:3]})")

    for row in plan["lessons"]:
        found = stored.get(row["id"])
        if found and found["title"] != row["title"]:
            problems.append(f"{row['id']}: título distinto en la base")

    # Hash por lección contra la última versión.
    latest: dict = {}
    for row in client.select("lesson_versions", "lesson_id,version,snapshot", order="lesson_id,version"):
        if row["version"] >= latest.get(row["lesson_id"], (0, ""))[0]:
            latest[row["lesson_id"]] = (row["version"], sha256_of(row["snapshot"]))
    drift = [row["id"] for row in plan["lessons"] if latest.get(row["id"], (0, ""))[1] != row["hash"]]
    if drift:
        problems.append(f"checksum distinto en {len(drift)} lecciones (p.ej. {drift[:3]})")

    for row in plan["lessons"]:
        found = stored.get(row["id"])
        if found and latest.get(row["id"], (0, ""))[0] != found["current_version"]:
            problems.append(f"{row['id']}: versión actual != última versión guardada")

    # Objetivos y frases, solo de la versión vigente de cada lección.
    current = {row["id"]: row["current_version"] for row in lessons}
    objectives = [
        row
        for row in client.select("lesson_objectives", "lesson_id,version,code,description,competency")
        if current.get(row["lesson_id"]) == row["version"]
    ]
    phrases = [
        row
        for row in client.select("lesson_phrases", "lesson_id,version,order_index,phrase,translation,translation_status")
        if current.get(row["lesson_id"]) == row["version"]
    ]

    if len(objectives) != EXPECTED_OBJECTIVES:
        problems.append(f"objetivos: {len(objectives)} != {EXPECTED_OBJECTIVES}")
    if len(phrases) != EXPECTED_PHRASES:
        problems.append(f"frases: {len(phrases)} != {EXPECTED_PHRASES}")

    stored_objectives = Counter((row["lesson_id"], row["code"]) for row in objectives)
    expected_objectives = Counter(
        (row["id"], objective["code"]) for row in plan["lessons"] for objective in row["objectives"]
    )
    if stored_objectives != expected_objectives:
        problems.append("los objetivos no coinciden con el origen (código a código)")

    stored_phrases = Counter((row["lesson_id"], row["order_index"]) for row in phrases)
    expected_phrases = Counter(
        (row["id"], phrase["order_index"]) for row in plan["lessons"] for phrase in row["phrases"]
    )
    if stored_phrases != expected_phrases:
        problems.append("las frases no coinciden con el origen (posición a posición)")

    identical = sum(1 for row in phrases if row["translation_status"] == "identical")
    if identical != EXPECTED_IDENTICAL:
        problems.append(f"traducciones 'identical': {identical} != {EXPECTED_IDENTICAL}")

    status_by_key = {(row["lesson_id"], row["order_index"]): row["translation_status"] for row in phrases}
    text_by_key = {(row["lesson_id"], row["order_index"]): (row["phrase"], row["translation"]) for row in phrases}
    for row in plan["lessons"]:
        for phrase in row["phrases"]:
            key = (row["id"], phrase["order_index"])
            if status_by_key.get(key) != phrase["translation_status"]:
                problems.append(f"{row['id']} p{phrase['order_index']}: translation_status distinto")
            if text_by_key.get(key) != (phrase["phrase"], phrase["translation"]):
                problems.append(f"{row['id']} p{phrase['order_index']}: texto de frase alterado")

    return {
        "lessons": len(lessons),
        "units": len(client.select("curriculum_units", "id")),
        "objectives": len(objectives),
        "phrases": len(phrases),
        "identical": identical,
        "problems": problems,
    }


# ── CLI ─────────────────────────────────────────────────────────────────────


def print_summary(title: str, values: dict) -> None:
    print(title)
    for key, value in values.items():
        print(f"  {key:<12} {value}")


def main(argv: list) -> int:
    parser = argparse.ArgumentParser(description="Importación idempotente del currículo (CUR-03).")
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--dry-run", action="store_true", help="plan y conteos, sin tocar la base")
    group.add_argument("--apply", action="store_true", help="escribe en Supabase")
    group.add_argument("--verify", action="store_true", help="comprueba la base contra el origen")
    parser.add_argument("--source", type=Path, default=SOURCE, help="JSON de entrada (CUR-02)")
    args = parser.parse_args(argv)

    plan = build_plan(load_source(args.source))
    summary = summarize(plan)
    problems = check_expected(summary)

    if args.dry_run or not (args.apply or args.verify):
        print_summary(f"plan · {args.source}", summary)
        for problem in problems:
            print(f"  DESAJUSTE  {problem}")
        return 1 if problems else 0

    env = load_env()
    url = env.get("SUPABASE_URL")
    key = env.get("SUPABASE_SERVICE_ROLE_KEY")
    if not url or not key:
        print("faltan SUPABASE_URL o SUPABASE_SERVICE_ROLE_KEY (entorno o .env)", file=sys.stderr)
        return 2
    client = RestClient(url, key)

    if args.apply:
        if problems:
            print_summary("plan", summary)
            print("no se escribe: el origen no coincide con el inventario", file=sys.stderr)
            return 1
        stats = apply_plan(plan, client)
        print_summary("aplicado", stats)
        report = verify_plan(plan, client)
        print_summary("verificado", {k: v for k, v in report.items() if k != "problems"})
        for problem in report["problems"]:
            print(f"  PROBLEMA  {problem}", file=sys.stderr)
        return 1 if report["problems"] else 0

    report = verify_plan(plan, client)
    print_summary("verificado", {k: v for k, v in report.items() if k != "problems"})
    for problem in report["problems"]:
        print(f"  PROBLEMA  {problem}", file=sys.stderr)
    return 1 if report["problems"] else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
