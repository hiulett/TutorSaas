"""Anexo de prompts: extrae literales de prompt del cliente Flutter y de Edge Functions.

Solo lectura. Regenera el documento (se ejecuta después de audit_lessons.py).
"""
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DOC = ROOT / "docs/audits/AUDITORIA_COMPLETA_INVENTARIO_LECCIONES.md"

TS_SOURCES = [
    ROOT / "supabase/functions/llm-proxy/index.ts",
    ROOT / "supabase/functions/lesson-generator/index.ts",
    ROOT / "supabase/functions/evaluate-placement/index.ts",
]
DART_SOURCES = [
    ROOT / "lib/features/conversation/data/repositories/conversation_repository_impl.dart",
    ROOT / "lib/features/chat_rooms/presentation/widgets/guild_master_floating_banner.dart",
]

TRIPLE = re.compile(r"('''|\"\"\")(.*?)\1", re.S)
ASSIGN = re.compile(
    r"(?:final|const|let|var)\s+(\w*[Pp]rompt\w*)\s*=\s*([`'\"])(.*?)\2", re.S
)

blocks = []


def add_block(path, line, name, body, kind):
    body = body.strip("\n")
    if len(body.strip()) < 80:
        return
    blocks.append({
        "file": str(path.relative_to(ROOT)).replace("\\", "/"),
        "line": line,
        "name": name,
        "kind": kind,
        "body": body,
    })


for path in DART_SOURCES:
    if not path.exists():
        continue
    text = path.read_text(encoding="utf-8")
    # Bloques completos de construccion del prompt (crudo, sin evaluar).
    for m in re.finditer(r"final systemPrompt =([\s\S]{0,6000}?);\n", text):
        line = text[: m.start()].count("\n") + 1
        add_block(path, line, "systemPrompt (construccion cruda)", m.group(1), "prompt-sistema")
    for m in TRIPLE.finditer(text):
        line = text[: m.start()].count("\n") + 1
        add_block(path, line, "literal-multilinea", m.group(2), "prompt-sistema")
    for m in ASSIGN.finditer(text):
        if m.group(2) in ("'''", '"""'):
            continue
        line = text[: m.start()].count("\n") + 1
        add_block(path, line, m.group(1), m.group(3), "prompt-asignado")

for path in TS_SOURCES:
    if not path.exists():
        continue
    text = path.read_text(encoding="utf-8")
    for m in ASSIGN.finditer(text):
        line = text[: m.start()].count("\n") + 1
        add_block(path, line, m.group(1), m.group(3), "prompt-servidor")
    for m in re.finditer(r"(?:You are|Act as|Eres|Actúa como)[\s\S]{80,400}", text):
        line = text[: m.start()].count("\n") + 1
        add_block(path, line, "instruccion-inline", m.group(0), "instruccion")

# Deduplicar
seen, unique = set(), []
for b in blocks:
    key = (b["file"], b["line"], b["body"][:60])
    if key in seen:
        continue
    seen.add(key)
    unique.append(b)

lines = []
add = lines.append
add("\n---\n")
add("## Anexo B · Prompts literales encontrados en el código\n")
add("> Extracción automática de literales de prompt. **No se ha modificado ni")
add("> resumido** su contenido; los placeholders se conservan tal cual.\n")
add(f"Total de bloques extraídos: **{len(unique)}**.\n")
add("| # | Fichero | Línea | Nombre | Tipo | Longitud |")
add("|---:|---|---:|---|---|---:|")
for i, b in enumerate(unique, 1):
    add(f"| {i} | `{b['file']}` | {b['line']} | `{b['name']}` | {b['kind']} | {len(b['body'])} |")
add("")

for i, b in enumerate(unique, 1):
    add(f"### Prompt {i} · `{b['name']}`\n")
    add(f"- **Fichero:** `{b['file']}`")
    add(f"- **Línea:** {b['line']}")
    add(f"- **Tipo:** {b['kind']}")
    add(f"- **Longitud:** {len(b['body'])} caracteres")
    add("")
    add("```text")
    add(b["body"])
    add("```")
    add("")

DOC.write_text(DOC.read_text(encoding="utf-8") + "\n".join(lines) + "\n", encoding="utf-8")
print(f"prompts extraidos: {len(unique)}")
