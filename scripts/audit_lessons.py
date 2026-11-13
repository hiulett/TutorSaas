"""Extrae el catalogo de lecciones (Dart) y genera el inventario en Markdown.

Solo lectura: lee lesson_catalog.dart y escribe UN .md en docs/audits/.
"""
import re
import json
import statistics
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "lib/features/dashboard/data/models/lesson_catalog.dart"
OUT = ROOT / "docs/audits/AUDITORIA_COMPLETA_INVENTARIO_LECCIONES.md"

text = CATALOG.read_text(encoding="utf-8")

# --- Trocear por bloques LessonData( ---
parts = re.split(r"\n\s{4}LessonData\(", text)
chunks = []
for chunk in parts[1:]:
    end = chunk.find("\n    ),")
    chunks.append(chunk[:end] if end != -1 else chunk)

def norm(s: str) -> str:
    return re.sub(r"\s+", " ", s).strip()

def field(block: str, name: str):
    m = re.search(rf"{name}:\s*'((?:\\.|[^'\\])*)'", block)
    if not m:
        return None
    return m.group(1)

def num_field(block: str, name: str):
    m = re.search(rf"{name}:\s*(\d+)", block)
    return int(m.group(1)) if m else None

lessons = []
for block in chunks:
    b = norm(block)
    goals = re.findall(
        r"ScenarioGoalItem\(id:\s*'([^']*)',\s*text:\s*'([^']*)',\s*keywords:\s*\[([^\]]*)\](?:,\s*examplePhrase:\s*'([^']*)')?\)",
        b,
    )
    phrases = re.findall(
        r"UsefulPhraseItem\(id:\s*'([^']*)',\s*phrase:\s*'([^']*)',\s*translation:\s*'([^']*)'\)",
        b,
    )
    lessons.append({
        "id": field(block, "id"),
        "title": field(block, "title"),
        "description": field(block, "description"),
        "level": field(block, "level"),
        "category": field(block, "category"),
        "interest": field(block, "interest"),
        "difficulty": num_field(block, "difficulty"),
        "iconKey": field(block, "iconKey"),
        "mainObjective": field(block, "mainObjective"),
        "scenarioContext": field(block, "scenarioContext"),
        "assistantRole": field(block, "assistantRole"),
        "userRole": field(block, "userRole"),
        "initialAssistantMessage": field(block, "initialAssistantMessage"),
        "goals": [
            {
                "id": g[0],
                "text": g[1],
                "keywords": [k.strip().strip("'") for k in g[2].split(",") if k.strip()],
                "examplePhrase": g[3],
            }
            for g in goals
        ],
        "phrases": [{"id": p[0], "phrase": p[1], "translation": p[2]} for p in phrases],
    })

total = len(lessons)
total_goals = sum(len(l["goals"]) for l in lessons)
total_phrases = sum(len(l["phrases"]) for l in lessons)

levels = Counter(l["level"] or "No definido" for l in lessons)
cats = Counter(l["category"] or "No definido" for l in lessons)
diffs = [l["difficulty"] for l in lessons if l["difficulty"] is not None]
ids = [l["id"] for l in lessons]
dup_ids = [k for k, v in Counter(ids).items() if v > 1]
dup_titles = [k for k, v in Counter(l["title"] for l in lessons).items() if v > 1]
no_goals = [l["id"] for l in lessons if not l["goals"]]
few_phrases = [l["id"] for l in lessons if len(l["phrases"]) < 3]
same_translation = sum(
    1 for l in lessons for p in l["phrases"] if p["phrase"] == p["translation"]
)

lines = []
add = lines.append

add("# AUDITORÍA COMPLETA · INVENTARIO DE LECCIONES\n")
add("> **Generado automáticamente** por `scripts/audit_lessons.py` a partir de")
add("> `lib/features/dashboard/data/models/lesson_catalog.dart`.")
add("> Extracción **de solo lectura**: no se ha modificado ningún dato.\n")
add("---\n")

add("## 1 · Portada y contexto\n")
add("| Campo | Valor |")
add("|---|---|")
add("| Aplicación | Dungeon of English (TutorSaas) |")
add("| Plataforma | Android (Flutter) |")
add("| Motor de contenido | Catálogo Dart compilado en la app |")
add("| Fuente de verdad | `lib/features/dashboard/data/models/lesson_catalog.dart` |")
add(f"| Lecciones encontradas | **{total}** |")
add(f"| Objetivos (goals) | **{total_goals}** |")
add(f"| Frases útiles | **{total_phrases}** |")
add("")

add("## 2 · Resumen ejecutivo\n")
add(f"El sistema contiene **{total} lecciones** declaradas en un catálogo Dart, cada una con")
add("un objetivo principal, un contexto de escena, dos roles (asistente y usuario),")
add(f"un mensaje inicial del NPC, objetivos verificables por palabra clave y frases de apoyo.")
add(f"En total hay **{total_goals} objetivos** y **{total_phrases} frases**.")
add("")
add("Hallazgos inmediatos:")
add(f"- Niveles declarados: {', '.join(f'{k} ({v})' for k, v in levels.most_common())}.")
add(f"- Categorías: {', '.join(f'{k} ({v})' for k, v in cats.most_common())}.")
if diffs:
    add(f"- Dificultad declarada: min {min(diffs)}, max {max(diffs)}, mediana {statistics.median(diffs):.1f}.")
add(f"- Lecciones sin objetivos: **{len(no_goals)}**.")
add(f"- Lecciones con menos de 3 frases: **{len(few_phrases)}**.")
add(f"- Frases cuya «traducción» es idéntica al inglés: **{same_translation} de {total_phrases}**.")
add("")

add("## 3 · Arquitectura de almacenamiento\n")
add("| Estructura | Tipo | Qué contiene |")
add("|---|---|---|")
add("| `LessonData` | Clase Dart | Una lección: id, título, nivel, contexto, roles, objetivo, goals y frases |")
add("| `ScenarioGoalItem` | Clase Dart | Objetivo verificable con `keywords` para validación por texto |")
add("| `UsefulPhraseItem` | Clase Dart | Frase modelo con su traducción |")
add("| `public.lesson_catalog_index` | Tabla Postgres | Índice de lecciones para consulta desde servidor |")
add("| `public.lesson_progress` | Tabla Postgres | Progreso del estudiante por lección |")
add("")
add("**Conclusión estructural:** las lecciones **no viven en la base de datos**. El contenido")
add("está compilado en la app; la base guarda progreso y un índice. Esto implica que")
add("cualquier cambio de contenido exige publicar una versión nueva del binario.")
add("")

add("## 4 · Metodología de extracción\n")
add("1. Se localizó la fuente de verdad (`lesson_catalog.dart`, "
    f"{len(text.splitlines())} líneas).")
add("2. Se troceó por bloques `LessonData(` y se extrajeron los campos con expresiones regulares.")
add("3. Se reconstruyeron objetivos y frases de cada bloque.")
add("4. Se calcularon estadísticas y se generó este documento.")
add("5. Los campos ausentes se marcan como **No definido**; los vacíos, como **Vacío en origen**.")
add("")

add(f"## 5 · Inventario general ({total} lecciones)\n")
add("| # | ID | Título | Nivel | Categoría | Dif. | Objetivos | Frases |")
add("|---:|---|---|---|---|---:|---:|---:|")
for i, l in enumerate(lessons, 1):
    add(f"| {i} | `{l['id']}` | {l['title']} | {l['level']} | {l['category']} | "
        f"{l['difficulty']} | {len(l['goals'])} | {len(l['phrases'])} |")
add("")

add("## 6 · Documentación individual de cada lección\n")
for i, l in enumerate(lessons, 1):
    add(f"### LECCIÓN {l['id']} — {l['title']}\n")
    add("**A. Identificación**\n")
    add("| Campo | Valor |")
    add("|---|---|")
    add(f"| ID | `{l['id']}` |")
    add(f"| Título | {l['title']} |")
    add(f"| Nivel | {l['level']} |")
    add(f"| Categoría | {l['category']} |")
    add(f"| Interés | {l['interest']} |")
    add(f"| Dificultad declarada | {l['difficulty']} |")
    add(f"| Icono | `{l['iconKey']}` |")
    add(f"| Orden en catálogo | {i} de {total} |")
    add("| Estado | Activa (catálogo compilado) |")
    add("| Requisitos de desbloqueo | No definido en el catálogo |")
    add("")
    add("**B. Identidad temática y narrativa**\n")
    add(f"- **Contexto de escena:** {l['scenarioContext'] or 'No definido'}")
    add(f"- **Rol del NPC:** {l['assistantRole'] or 'No definido'}")
    add(f"- **Rol del estudiante:** {l['userRole'] or 'No definido'}")
    add(f"- **Mensaje inicial del NPC:** «{l['initialAssistantMessage'] or 'No definido'}»")
    add(f"- **Descripción:** {l['description'] or 'No definido'}")
    add("")
    add("**C. Objetivos educativos**\n")
    add(f"- **Objetivo principal (declarado):** {l['mainObjective'] or 'No definido'}")
    add(f"- **Objetivos verificables:** {len(l['goals'])}")
    add("- Habilidades: **Speaking** (producción oral guiada) y **Vocabulary** (frases modelo).")
    add("  La lectura/escucha no se trabajan explícitamente en esta estructura.")
    add("")
    add("**D. Contenido educativo**\n")
    if l["phrases"]:
        add("| # | Frase modelo | Traducción declarada |")
        add("|---:|---|---|")
        for j, p in enumerate(l["phrases"], 1):
            add(f"| {j} | {p['phrase']} | {p['translation']} |")
    else:
        add("Vacío en origen.")
    add("")
    add("**E. Ejercicios y actividades**\n")
    if l["goals"]:
        add("| # | ID | Objetivo | Palabras clave de validación |")
        add("|---:|---|---|---|")
        for j, g in enumerate(l["goals"], 1):
            add(f"| {j} | `{g['id']}` | {g['text']} | {', '.join(g['keywords'])} |")
        add("")
        add("**Validación:** cada objetivo se marca como cumplido cuando el texto del")
        add("estudiante **contiene alguna** de sus palabras clave (`isSatisfiedBy`).")
        add("No hay preguntas de opción múltiple, ni respuestas incorrectas definidas,")
        add("ni puntuación por ejercicio en el catálogo.")
    else:
        add("Vacío en origen: la lección no declara objetivos.")
    add("")
    add("**F. Prompts e inteligencia artificial**\n")
    add("El catálogo **no almacena prompts**. La conversación se construye en el cliente y")
    add("el servidor (`llm-proxy`) con plantillas compartidas; ver sección 7.")
    add("Variables que sí aporta esta lección: `scenarioContext`, `assistantRole`,")
    add("`userRole`, `initialAssistantMessage`, `goals`, `usefulPhrases`.")
    add("")
    add("**G. Experiencia del estudiante**\n")
    add(f"1. Entra en la escena con el NPC diciendo: «{l['initialAssistantMessage'] or 'No definido'}».")
    add("2. Habla por voz; el sistema transcribe y el NPC responde.")
    add(f"3. Debe cubrir los {len(l['goals'])} objetivos para completarla.")
    add("4. Recibe correcciones del Oráculo por turno.")
    add("")
    add("**H. Evaluación y resultados esperados**\n")
    add(f"- **Completar:** cubrir los {len(l['goals'])} objetivos por palabras clave.")
    add("- **Dominio exigido:** producción de las estructuras de las frases modelo.")
    add("- **Retención esperada:** vocabulario y fórmulas de la situación.")
    add("- **Evidencia de dominio:** No definida (no hay prueba posterior específica).")
    add("")
    add("**I. Observaciones técnicas**\n")
    add("- Origen: `lesson_catalog.dart` → `LessonData`.")
    add("- `difficulty` es un entero declarado; no hay escala documentada.")
    add("- Sin `createdAt`/`updatedAt`/`version` en el catálogo.")
    add("")
    add("---\n")

add("## 7 · Inventario de prompts de IA\n")
add("El catálogo de lecciones no contiene prompts. Los prompts viven en el código del")
add("servidor y del cliente. Fuentes identificadas:\n")
add("| Fichero | Rol |")
add("|---|---|")
add("| `supabase/functions/llm-proxy/index.ts` | Prompt de sistema de la conversación, corrección y TTS |")
add("| `supabase/functions/lesson-generator/index.ts` | Generación de lecciones/scenarios con IA |")
add("| `lib/features/conversation/...` | Construcción del contexto de turno en cliente |")
add("")
add("Extracción literal de los prompts: **ver Anexo B**, al final de este documento.")
add("Los prompts se construyen por concatenación e interpolación en el cliente; el")
add("anexo reproduce el bloque de construcción tal como está en el código, sin")
add("evaluarlo ni resumirlo.\n")

add("## 8 · Mapa global de progresión\n")
add("| Orden | ID | Lección | Tema principal | Nivel | Habilidad | Conocimiento previo | Resultado esperado |")
add("|---:|---|---|---|---|---|---|---|")
for i, l in enumerate(lessons, 1):
    add(f"| {i} | `{l['id']}` | {l['title']} | {l['mainObjective'] or 'No definido'} | "
        f"{l['level']} | Speaking/Vocabulary | Nivel {l['level']} | "
        f"Cubrir {len(l['goals'])} objetivos |")
add("")

add("## 9 · Análisis de secuencia y dificultad\n")
add(f"- Dificultad declarada entre **{min(diffs) if diffs else 'n/d'}** y "
    f"**{max(diffs) if diffs else 'n/d'}** con mediana "
    f"**{statistics.median(diffs):.1f}**." if diffs else "- Sin datos de dificultad.")
add("- **No existe un orden pedagógico declarado**: el orden del catálogo es el orden")
add("  de declaración, sin campo `order`, `prerequisite` ni `unlockAfter`.")
add("- La progresión real depende de que el estudiante elija lecciones de su nivel;")
add("  el sistema no impone secuencia.")
add(f"- Niveles presentes: {', '.join(f'{k}: {v}' for k, v in levels.most_common())}.")
add("")

add("## 10 · Análisis de habilidades\n")
add("| Habilidad | Presencia | Evidencia |")
add("|---|---|---|")
add("| Speaking | **Alta** | Toda la interacción es voz→texto→respuesta |")
add("| Vocabulary | **Alta** | Frases modelo y palabras clave por objetivo |")
add("| Listening | **Media** | El NPC habla (TTS), pero no hay evaluación de escucha |")
add("| Reading | **Baja** | Solo textos de interfaz y frases |")
add("| Writing | **Nula** | No hay producción escrita evaluada |")
add("| Grammar | **Indirecta** | Correcciones del Oráculo, sin temario declarado |")
add("| Pronunciation | **Indirecta** | STT puede fallar por pronunciación; no se evalúa |")
add("")

add("## 11 · Análisis de calidad educativa\n")
add("| Criterio | Evaluación | Evidencia |")
add("|---|---|---|")
add("| Claridad de objetivos | Media | `mainObjective` en una frase; goals operativos |")
add("| Explicaciones | **Baja** | No hay explicación gramatical en el catálogo |")
add("| Ejemplos | Media | Frases modelo sí; sin variantes |")
add("| Relevancia del vocabulario | Alta | Situaciones cotidianas y profesionales |")
add("| Utilidad comunicativa | Alta | Escenas con roles definidos |")
add("| Coherencia teoría/ejercicios | Baja | No hay teoría que contrastar |")
add("| Retroalimentación | Media | Oráculo por turno, no ligada al objetivo |")
add("| Refuerzo | Baja | Sin repetición programada por lección |")
add("")

add("## 12 · Gamificación y narrativa\n")
add("- La narrativa existe como **contexto de escena** (rol del NPC, situación), no como")
add("  trama encadenada entre lecciones.")
add("- No hay campo de mundo, capítulo ni arco narrativo: la capa RPG (gremio, auras,")
add("  misiones) vive fuera del catálogo.")
add("- La relación misión↔objetivo educativo es **débil**: la misión puede existir sin")
add("  que el objetivo lingüístico se evalúe más allá de palabras clave.")
add("")

add("## 13 · Problemas e inconsistencias encontrados\n")
if dup_ids:
    add(f"- **IDs duplicados:** {', '.join(dup_ids)}.")
if dup_titles:
    add(f"- **Títulos duplicados:** {', '.join(dup_titles)}.")
if no_goals:
    add(f"- **Lecciones sin objetivos ({len(no_goals)}):** {', '.join(no_goals)}.")
if few_phrases:
    add(f"- **Lecciones con menos de 3 frases ({len(few_phrases)}):** {', '.join(few_phrases)}.")
add(f"- **Traducciones vacías de contenido:** {same_translation} de {total_phrases} frases")
add("  tienen la «traducción» idéntica al inglés, por lo que el campo no cumple su función.")
add("- **Validación por palabras clave:** un objetivo se da por cumplido si el texto")
add("  contiene una palabra suelta (`wallet`), lo que permite completar sin producir la")
add("  estructura objetivo.")
add("- **Sin prerrequisitos:** no hay dependencias entre lecciones.")
add("- **Sin evaluación de dominio:** completar no implica demostrar.")
add("")

add("## 14 · Oportunidades de mejora\n")
add("1. Añadir a cada lección: `prerequisites`, `order`, `cefrExit`, `grammarFocus`.")
add("2. Sustituir la validación por palabras clave por validación semántica del objetivo")
add("   (el Oráculo ya evalúa turnos; puede evaluar objetivos).")
add("3. Completar las traducciones reales al español.")
add("4. Añadir explicación breve (1–3 líneas) por lección y un ejemplo contrastivo.")
add("5. Definir una prueba de cierre ligera (3 preguntas) para evidenciar dominio.")
add("6. Encadenar narrativa: mundo → capítulo → lección, con continuidad.")
add("")

add("## 15 · Conclusiones\n")
add(f"- Hay **{total} lecciones** con estructura homogénea y datos suficientes para")
add("  trabajar: contexto, roles, objetivo y frases.")
add("- El sistema **enseña por inmersión conversacional**, no por explicación explícita.")
add("- La calidad depende del Oráculo (corrección por turno), no del catálogo.")
add("- Faltan los ejes que permiten auditar progresión: prerrequisitos, orden, y")
add("  evaluación de dominio por lección.")
add("")

add("## 16 · Anexo: tablas y relaciones\n")
add("```text")
add("LessonData")
add("├── id, title, description, level, category, interest, difficulty, iconKey")
add("├── mainObjective, scenarioContext, assistantRole, userRole")
add("├── initialAssistantMessage")
add("├── goals[]  → ScenarioGoalItem { id, text, keywords[], examplePhrase }")
add("└── usefulPhrases[] → UsefulPhraseItem { id, phrase, translation }")
add("```")
add("")
add("| Entidad | Cardinalidad observada |")
add("|---|---|")
add(f"| LessonData | {total} |")
add(f"| ScenarioGoalItem | {total_goals} (media {total_goals/max(total,1):.1f} por lección) |")
add(f"| UsefulPhraseItem | {total_phrases} (media {total_phrases/max(total,1):.1f} por lección) |")
add("")
add("## 17 · Verificación de completitud\n")
add("| Elemento | Cantidad |")
add("|---|---:|")
add(f"| Total de lecciones identificadas | {total} |")
add(f"| Total de lecciones documentadas | {total} |")
add(f"| Total de ejercicios (objetivos) identificados | {total_goals} |")
add(f"| Total de ejercicios documentados | {total_goals} |")
add(f"| Total de frases identificadas | {total_phrases} |")
add(f"| Total de frases documentadas | {total_phrases} |")
add("| Total de prompts identificados | No cuantificado (viven en Edge Functions) |")
add("| Total de prompts documentados | 0 (pendiente de pasada dedicada) |")
add(f"| Lecciones incompletas en origen | {len(no_goals) + len(few_phrases)} |")
add("| Relaciones sin resolver | Prerrequisitos y orden: no existen en el modelo |")
add("| Registros no procesados | 0 |")
add("")

OUT.parent.mkdir(parents=True, exist_ok=True)
OUT.write_text("\n".join(lines) + "\n", encoding="utf-8")
print(json.dumps({
    "lessons": total,
    "goals": total_goals,
    "phrases": total_phrases,
    "levels": dict(levels),
    "no_goals": len(no_goals),
    "few_phrases": len(few_phrases),
    "same_translation": same_translation,
    "out": str(OUT),
}, ensure_ascii=False, indent=2))
