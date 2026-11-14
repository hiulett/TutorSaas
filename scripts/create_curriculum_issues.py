"""Crea la epica y las historias CUR-* en GitHub a partir del plan.

Lee la tabla de historias del plan, crea la epica y una issue por historia.
No modifica el repositorio.
"""
import json
import re
import subprocess
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PLAN = ROOT / "docs/plans/PLAN_IMPLEMENTACION_MIGRACION_Y_ADMINISTRACION_LECCIONES.md"
REPO = "hiulett/TutorSaas"

text = PLAN.read_text(encoding="utf-8")

rows = []
for line in text.splitlines():
    s = line.strip()
    if not s.startswith("| CUR-"):
        continue
    cells = [c.strip() for c in s.strip("|").split("|")]
    if len(cells) < 5:
        continue
    rows.append({
        "id": cells[0],
        "title": cells[1],
        "phase": cells[2],
        "priority": cells[3],
        "criteria": " · ".join(c for c in cells[4:] if c),
    })

PRIO = {"P0": "P0-critico", "P1": "P1-alto", "P2": "P2-medio", "P3": "P3-bajo"}


def labels_for(row):
    labels = ["historia", "area/producto"]
    p = PRIO.get(row["priority"])
    if p:
        labels.append(p)
    if row["phase"] in ("2", "4", "7", "8"):
        labels.append("area/backend")
    if row["phase"] in ("5", "6"):
        labels.append("area/ux")
    if row["phase"] == "3":
        labels.append("area/backend")
    return ",".join(dict.fromkeys(labels))


def create(title, body, labels):
    with tempfile.NamedTemporaryFile("w", suffix=".md", delete=False, encoding="utf-8") as fh:
        fh.write(body)
        path = fh.name
    out = subprocess.run(
        ["gh", "issue", "create", "--repo", REPO, "--title", title,
         "--body-file", path, "--label", labels],
        capture_output=True, text=True, encoding="utf-8",
    )
    Path(path).unlink(missing_ok=True)
    if out.returncode != 0:
        return None, (out.stderr or out.stdout).strip()[:200]
    return out.stdout.strip().splitlines()[-1], None


epic_body = """Épica del **plan de migración del catálogo de lecciones a PostgreSQL, currículo evolutivo y administración web**.

**Documento de referencia:** `docs/plans/PLAN_IMPLEMENTACION_MIGRACION_Y_ADMINISTRACION_LECCIONES.md`
**Auditoría base:** `docs/audits/AUDITORIA_COMPLETA_INVENTARIO_LECCIONES.md` (140 lecciones, 540 objetivos, 539 frases).

**Decisión arquitectónica:** híbrida. El contenido educativo va a PostgreSQL y se administra
desde `web_admin`; los motores de ejecución (renderers de actividad, evaluación, seguridad,
prompts de sistema, caché) permanecen en código.

**Reglas de la épica**
1. Ningún cambio de contenido exige publicar una versión nueva de la app.
2. El progreso histórico (`lesson_progress.lesson_id`) no se rompe.
3. El cliente nunca publica contenido ni se puntúa un examen.
4. Los prompts de seguridad no son editables desde el portal.
5. Las 766 pruebas actuales siguen verdes al cerrar la fase 6.

**Fases:** 0 auditoría · 1 diseño · 2 migraciones · 3 importación · 4 backend · 5 portal ·
6 Flutter · 7 currículo · 8 evaluaciones · 9 despliegue.

**Estado:** planificación cerrada (seis decisiones tomadas el 2026-11-13). Sin implementación.
"""

epic_url, err = create(
    "Épica: migración del catálogo a PostgreSQL, currículo evolutivo y administración web",
    epic_body,
    "epic,area/producto,area/backend,area/ux",
)
if not epic_url:
    raise SystemExit(f"fallo creando epica: {err}")

created, failed = [], []
for row in rows:
    body = f"""**Épica:** {epic_url} · **Fase:** {row['phase']} · **Prioridad:** {row['priority']}

**Objetivo.** {row['title']}

**Criterios de aceptación (del plan).**
- {row['criteria']}

**Referencias.** `docs/plans/PLAN_IMPLEMENTACION_MIGRACION_Y_ADMINISTRACION_LECCIONES.md`
(secciones 5–26) · `docs/audits/AUDITORIA_COMPLETA_INVENTARIO_LECCIONES.md`.

**Nota.** Historia creada durante la fase de diseño: no hay implementación asociada todavía.
"""
    url, err = create(f"{row['id']} · {row['title']}", body, labels_for(row))
    if url:
        created.append(f"{row['id']} {url}")
    else:
        failed.append(f"{row['id']}: {err}")

print(json.dumps({
    "epic": epic_url,
    "created": len(created),
    "failed": failed,
    "issues": created,
}, ensure_ascii=False, indent=2))
