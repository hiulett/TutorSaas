# Auditoría Estratégica del Onboarding — Documento 02

# Problemas de UX Priorizados

> **Proyecto:** TutorSaas / Dungeon of English
> **Base:** hallazgos verificados (doc 01) — no re-análisis de código
> **Formato:** tabla priorizada por severidad × impacto, con evidencia `file:line`

---

## 1. Resumen de la matriz

| # | Problema | Categoría | Severidad | Impacto | Evidencia |
|---|---|---|---|---|---|
| P1 | Textos hardcodeados en español (i18n incompleto) | Localización | 🔴 Crítica | Alto | `onboarding_screen.dart:95,102,476,481,752,757`; `character_creation_wizard.dart:37-41,85` |
| P2 | Países/idiomas hardcodeados (no escalable) | Arquitectura/Producto | 🔴 Crítica | Alto | `onboarding_screen.dart:55-64,66-78,80-85,742` |
| P3 | Carga cognitiva (formulario de 5 pasos + wizard) | UX | 🟠 Alta | Alto | `onboarding_screen.dart` (estructura general, 1021 líneas) |
| P4 | Duración y fricción de la secuencia | UX/Retención | 🟠 Alta | Alto | `onboarding_screen.dart:92-110` (validaciones + push); `onboarding_screen.dart:143-158` |
| P5 | Falta de inmersión RPG (se siente formulario) | Narrativa/Gamificación | 🟠 Alta | Medio-Alto | `onboarding_screen.dart:740-759` (paso país como registro) |
| P6 | Pasos redundantes / datos no accionables | UX/Funnel | 🟡 Media | Medio | `onboarding_screen.dart:66-78` vs `:742` (país listado + sugeridos); `saveOnboardingData` (5 tablas, doc 01 §4) |
| P7 | Gap funcional: identidad de personaje no persistida | Funcional | 🟡 Media | Medio | `onboarding_screen.dart:170-182` (params sin clase/avatar/nombre) |
| P8 | Evaluación Oráculo desconectada de la narrativa | Integración UX | 🟡 Media | Medio | `onboarding_screen.dart:143-158` (push a ruta distinta) |
| P9 | Idioma objetivo limitado a 4 opciones | Producto | 🟠 Alta | Alto | `onboarding_screen.dart:80-85` |

---

## 2. Detalle priorizado

### P1 — Textos hardcodeados en español (i18n incompleto) — 🔴 CRÍTICA

**Descripción.** Aunque el proyecto tiene l10n (3 ARB) y el screen importa `AppLocalizations`, los textos clave del onboarding siguen en español literal.

**Evidencia.**
- Snackbar de validación nativo: `'Selecciona tu idioma nativo para continuar.'` — `onboarding_screen.dart:95`.
- Snackbar de validación objetivo: `'Selecciona el idioma que deseas aprender.'` — `onboarding_screen.dart:102`.
- Tarjeta héroe: `'¡BIENVENIDO,'` / `'CAZADOR!'` — `onboarding_screen.dart:476,481`.
- Cabecera y descripción del paso país: `'PAÍS DE ORIGEN'`, `'Dinos de dónde vienes...'` — `onboarding_screen.dart:752,757`.
- Wizard de personaje: `'Berserker'`, `'Mago Arcano'`, `'Pícaro'` y descripciones — `character_creation_wizard.dart:37-41`.
- `'NOMBRE DEL CAZADOR'` — `character_creation_wizard.dart:85`.

**Impacto.**
- Usuarios `pt` y `en` ven una mezcla idioma-objetivo/español: rompe la inmersión y la confianza en el producto.
- Existe duplicación: los ARB ya definen claves (`onboarding_country`, `character_name`, `oracle_continue` en `lib/l10n/app_es.arb:113,164,174`) que el widget no consume.
- Riesgo de que futuras traducciones "no funcionen" y se culpe al sistema de i18n.

**Criterio de salida:** 0 strings de onboarding en español fuera de los ARB.

---

### P2 — Países/idiomas hardcodeados (no escalable) — 🔴 CRÍTICA

**Descripción.** Las listas de opciones viven dentro del widget como constantes Dart, sin catálogo en base de datos ni por idioma de UI.

**Evidencia.**
- 8 idiomas nativos: `onboarding_screen.dart:55-64`.
- 11 países: `onboarding_screen.dart:66-78`.
- 4 idiomas objetivo con descripciones de marketing: `onboarding_screen.dart:80-85`.
- 5 países sugeridos: `onboarding_screen.dart:742`.

**Impacto.**
- **Escalabilidad nula:** entrar en un nuevo mercado (p.ej. Brasil, India, Japón) exige release de la app, no configuración.
- **Cobertura desigual:** el paso nativo ofrece 8 idiomas, el objetivo solo 4. Un usuario de habla portuguesa no puede aprender portugués; un usuario chino no puede elegir mandarín como objetivo.
- Los países sugeridos (`US/MX/BR/CN/IN`) se calculan filtrando la lista de 11: si el país no está en la lista, "sugerido" no aparece — inconsistencia lógica.
- Los nombres de país/idioma están en inglés o español según la entrada (`'México'` vs `'United States'`), sin localizar a la UI.

**Criterio de salida:** catálogos servidos por Supabase (`languages`, `countries`) con seed para 30+ países e idiomas, traducidos por idioma de UI; el widget consume providers.

---

### P3 — Carga cognitiva: formulario de 5 pasos + wizard — 🟠 ALTA

**Descripción.** El jugador debe tomar decisiones de registro (idioma, país, objetivo) con layout de formulario, y además completar un sub-wizard de personaje. La pantalla acumula 1021 líneas: el estado y el UI conviven en un solo StatefulWidget con ~20 campos de estado.

**Evidencia.**
- Un solo widget de 1.021 líneas: `onboarding_screen.dart` (firma: `ConsumerStatefulWidget`).
- 20+ variables de estado de decisión en el State: `onboarding_screen.dart:34-48`.
- Wizard anidado (`CharacterCreationWizard`) dentro del paso 4: `character_creation_wizard.dart`.

**Impacto.**
- Alto costo de mantenimiento y de testing.
- El usuario "completa formularios" en lugar de "jugar"; el abandono típico de onboarding-form (20-40%) se aplica.
- No hay foco: cada paso pide varios datos (p.ej. paso país pide país, e implícitamente define pronunciación).

**Criterio de salida:** una sola decisión por pantalla/misión, estado separado en providers (Riverpod), screen < 400 líneas.

---

### P4 — Duración y fricción de la secuencia — 🟠 ALTA

**Descripción.** Cinco pasos lineales con validaciones por bloqueo (snackbar) y un salto opcional (Oráculo) que puede no ocurrir. Si el usuario omite el Oráculo, avanza con un default silencioso (`A1`) y la promesa de gamificación se desinfla.

**Evidencia.**
- Validaciones que frenan en seco: `onboarding_screen.dart:94-106`.
- Oráculo opcional con fallback A1 silencioso: `onboarding_screen.dart:166-168`.
- El Oráculo exige `context.push` y volver: `onboarding_screen.dart:143-158` (costo de transición de ruta percibido como "salir del flujo").

**Impacto.**
- Time-to-value largo: el usuario no habla inglés hasta el paso 3 (si lo hace), y no entra a `/home` hasta el paso 4 + guardado.
- Fricción: cada paso es una barrera de decisión sin recompensa intermedia.
- Abandono en el punto medio (paso 2-3) es el riesgo más alto.

**Criterio de salida:** reducir a 3-4 "actos" con micro-recompensas inmediatas y permitir entrada directa si el usuario quiere "saltar al juego".

---

### P5 — Falta de inmersión RPG: se siente formulario — 🟠 ALTA

**Descripción.** La estética es RPG (GlassCard, runic, tipografía), pero la estructura y el copy son de formulario de registro: "PAÍS DE ORIGEN / Dinos de dónde vienes...". No hay mundo, no hay misión, no hay motivo de las preguntas dentro de la diégesis.

**Evidencia.**
- Cabeceras administrativas: `'PAÍS DE ORIGEN'` — `onboarding_screen.dart:752`.
- Copy de formulario: `'Dinos de dónde vienes para adaptar la pronunciación y las expresiones.'` — `onboarding_screen.dart:757`.
- Descripciones de idioma estilo "marketing": `'Global communication & professional growth'` — `onboarding_screen.dart:81`.
- La tarjeta héroe de bienvenida aparece **al final**, sin haber construido el personaje narrativamente: `onboarding_screen.dart:476-481`.

**Impacto.**
- Diferenciación débil frente a Duolingo/Elsa (que gamifican el mismo acto).
- La propuesta "System HUD / Isekai" se percibe como decoración, no como sistema.
- Menor retención del acto de registro (la identidad se construye después de pedir datos, al revés de los RPG).

**Criterio de salida:** toda pregunta enmarcada como objetivo de misión con contexto de mundo (ver doc 03).

---

### P6 — Pasos redundantes / datos no accionables — 🟡 MEDIA

**Descripción.** El país se pide dos veces de forma efectiva (lista completa + "sugeridos" derivados) y muchas preguntas no alimentan una experiencia visible para el usuario.

**Evidencia.**
- Lista completa de 11 países y a la vez 5 "sugeridos" filtrados de la misma lista: `onboarding_screen.dart:66-78` y `:742`.
- `saveOnboardingData` persiste 5 tablas (doc 01 §4) pero el usuario no ve ningún resultado de esa data en el onboarding (sin retroalimentación del perfil, sin feedback de configuración).

**Impacto.**
- Fatiga de elección en el paso país.
- Sensación de "me preguntan pero no se usa": motiva a saltar o inventar.
- Datos como `motivation`, `correctionStyle`, `tutorPersonality` se setean con valores fijos (`'career'`, `'balanced'`, `'friendly'`) sin preguntarse — datos muertos en el perfil: `onboarding_screen.dart:177-181`.

**Criterio de salida:** cada pregunta debe tener (a) un propósito visible y (b) un efecto posterior comprobable; eliminar preguntas no accionables o preguntarlas en el momento adecuado.

---

### P7 — Gap funcional: identidad del personaje no persistida — 🟡 MEDIA

**Descripción.** El paso 4 crea un personaje (nombre, clase, avatar) pero `saveOnboardingData` no recibe esos campos; la identidad vive solo en el widget.

**Evidencia.**
- Datos de creación: `CharacterCreationData(name, playerClass, avatarIndex)` — `character_creation_wizard.dart:11-21`.
- Parámetros de guardado **sin** clase/avatar/nombre: `onboarding_screen.dart:170-182`.
- Los parámetros fijos del perfil tampoco reflejan la clase elegida (`tutorPersonality: 'friendly'` hardcodeada, `learningStyle: 'auditory_interactive'` fija): `onboarding_screen.dart:179-181`.

**Impacto.**
- La promesa "crea tu personaje" es cosmética: al reiniciar sesión o en el dashboard el personaje no tiene persistencia.
- Oportunidad perdida: la clase podría mapearse a estilo de tutoría/retroalimentación.

**Criterio de salida:** perseguir la identidad en `user_profiles`/`users` y exponerla en el HUD.

---

### P8 — Evaluación Oráculo desconectada de la narrativa — 🟡 MEDIA

**Descripción.** El paso "clasificación IA" es un `push` a otra ruta con otra pantalla (chat de voz). Es el mejor momento del producto (voz + IA) pero está presentado como un formulario más, sin transición narrativa.

**Evidencia.**
- `context.push('/oracle-test')` con retorno de mapa: `onboarding_screen.dart:143-158`.
- Ruta y screen separados: import en `lib/app/router.dart:8`; screen `oracle_conversation_screen.dart`.
- El botón de lanzar también es un control de formulario: `onboarding_screen.dart:1005`.

**Impacto.**
- El pico emocional (hablar con un Oráculo y recibir rango E–SSS) no está enmarcado como momento de la historia → baja percepción de "mundo vivo".
- El cambio brusco de contexto (formulario ↔ chat) rompe el estado de flujo.

**Criterio de salida:** el Oráculo como acto central del prólogo con transición de pantalla dramática y contexto de misión (doc 03).

---

### P9 — Idioma objetivo limitado a 4 opciones — 🟠 ALTA

**Descripción.** Independiente de P2, es el problema de producto más visible: solo se puede elegir entre `en/fr/de/it`.

**Evidencia.**
- `_targetLanguages` con 4 entradas y descripciones: `onboarding_screen.dart:80-85`.
- Contrasta con los 8 nativos: `onboarding_screen.dart:55-64`.

**Impacto.**
- Mercados clave no atendidos (mandarín→inglés es la mayor población de aprendices del mundo; portugués→inglés para Brasil; japonés).
- La promesa del producto ("aprende inglés conversacional") no necesita catálogo grande, pero **sí** al menos `pt` y `zh` para coincidir con el público objetivo (LatAm + Brasil).

**Criterio de salida:** catálogo objetivo ≥ 6-8 idiomas, priorizando en/es/pt/zh/ja según mercado.

---

## 3. Prioridad sugerida de ataque

| Orden | Problemas | Fase |
|---|---|---|
| 1 | P1 (i18n) + P7 (persistencia de identidad) | Rápido / bajo riesgo, alto valor |
| 2 | P2 + P9 (catálogos servidos por backend) | Arquitectura de datos |
| 3 | P3 + P4 (estructura de flujo) | Rediseño del flujo (base del doc 03) |
| 4 | P5 + P8 (inmersión y narrativa) | Rediseño de experiencia |
| 5 | P6 (datos no accionables) | Limpieza de preguntas |

---

## 4. KPIs que debe mover el rediseño

| KPI | Hoy (inferido) | Objetivo post-rediseño |
|---|---|---|
| Tasa de completado de onboarding | Formulario de 5 pasos (baja esperable) | ≥ 85% |
| Abandono en paso 2-3 | Alto (punto medio sin recompensa) | Reducir a < 10% |
| % de usuarios que completan el Oráculo | Opcional → bajo | ≥ 70% (convertido en acto obligatorio del prólogo) |
| Tiempo de entrada a `/home` | ~5 pasos + wizard | ≤ 3-4 actos, con micro-recompensas |
| Idioma de la experiencia | Mezcla español + objetivo | 100% en idioma de UI |
