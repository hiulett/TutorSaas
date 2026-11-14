#!/usr/bin/env python3
"""Enciende o apaga el currículo en base sin publicar app (CUR-24).

- `db` exige pasar antes la puerta de activación (`check_curriculum_activation.py`):
  si el pack no es idéntico al catálogo, no se enciende.
- `dart` es el rollback y **no** comprueba nada: tiene que funcionar incluso si el
  contenido de la base está roto, que es justo cuando hace falta apagarlo.

Uso:

    python scripts/set_curriculum_source.py db
    python scripts/set_curriculum_source.py dart
    python scripts/set_curriculum_source.py            # solo muestra el valor

Tras el cambio, la app lo recuerda como mucho 60 s (`CurriculumRepository`); para
aplicarlo al instante en un cliente ya abierto, `invalidateSource()`.
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

import import_curriculum as ic  # noqa: E402

GATE = ROOT / "scripts/check_curriculum_activation.py"


def main() -> int:
    env = ic.load_env()
    url = env.get("SUPABASE_URL")
    key = env.get("SUPABASE_SERVICE_ROLE_KEY")
    if not url or not key:
        print("faltan SUPABASE_URL o SUPABASE_SERVICE_ROLE_KEY (entorno o .env)", file=sys.stderr)
        return 2

    client = ic.RestClient(url, key)
    current = client.rpc("get_curriculum_source", {})

    if len(sys.argv) == 1:
        print(f"curriculum_source = {current}")
        return 0

    value = sys.argv[1].strip().lower()
    if value not in ("dart", "db"):
        print(f"valor inválido: {sys.argv[1]!r} (usa dart o db)", file=sys.stderr)
        return 2

    if value == "db":
        print("comprobando que el pack es idéntico al catálogo antes de encender…")
        gate = subprocess.run([sys.executable, str(GATE)], cwd=str(ROOT))
        if gate.returncode != 0:
            print("la puerta de activación falló: no se enciende la base", file=sys.stderr)
            return gate.returncode

    result = client.rpc("admin_set_curriculum_source", {"p_value": value})
    if client.rpc("get_curriculum_source", {}) != value:
        print("la lectura no refleja el cambio", file=sys.stderr)
        return 1

    print(f"curriculum_source: {current} -> {result['value']} (auditado en content_audit_logs)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
