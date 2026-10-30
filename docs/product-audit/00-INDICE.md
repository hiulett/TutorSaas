# 00 — Índice y resumen ejecutivo

**Auditoría integral de "Dungeon of English" (TutorSaas)**
Versión auditada: `1.0.21+22` · Fecha de medición: **25-oct-2026** ·
Alcance: repositorio completo + proyecto Supabase de producción (solo lectura).

> **Documento fechado.** Los capítulos 01–20 conservan las cifras del
> 25-oct-2026 tal como se midieron. La §3 de este índice muestra además el
> valor re-medido el 29-oct-2026; para cualquier afirmación sobre el estado
> **actual** manda [INDICE-DOCUMENTACION.md](../INDICE-DOCUMENTACION.md) y la
> consulta a producción.

---

## 1. Cómo leer esta documentación

| Documento | Para qué sirve |
|---|---|
| [01 — Visión del producto](01-VISION-DEL-PRODUCTO.md) | Qué es, a quién sirve, qué promete y qué no cumple |
| [02 — Arquitectura técnica](02-ARQUITECTURA-TECNICA.md) | Stack, capas, servicios, diagramas de arquitectura y de petición |
| [03 — Pantallas y navegación](03-PANTALLAS-Y-NAVEGACION.md) | 14 rutas, 4 pestañas, estados y problemas de navegación |
| [04 — Experiencia del usuario](04-EXPERIENCIA-DEL-USUARIO.md) | Ciclo de vida, flujo de aprendizaje, errores y fricciones |
| [05 — Sistema pedagógico](05-SISTEMA-PEDAGOGICO.md) | Currículo, niveles, competencias, evaluación, SRS |
| [06 — Gameplay y gamificación](06-GAMEPLAY-Y-GAMIFICACION.md) | Bucle, recursos, fórmulas, misiones, tienda, social |
| [07 — Inteligencia artificial](07-INTELIGENCIA-ARTIFICIAL.md) | Proveedores, prompts, casos de uso, seguridad, costes |
| [08 — Modelo de datos](08-MODELO-DE-DATOS.md) | 77 tablas, RLS, RPC, ER, integridad |
| [09 — Autenticación y perfiles](09-AUTENTICACION-Y-PERFILES.md) | Login, sesión, onboarding, perfiles, riesgos |
| [10 — Monetización y pagos](10-MONETIZACION-Y-PAGOS.md) | Planes, RevenueCat, qué desbloquea el premium |
| [11 — Retención y notificaciones](11-RETENCION-Y-NOTIFICACIONES.md) | Qué puede traer de vuelta al usuario (y qué no) |
| [12 — Calidad y mantenibilidad](12-CALIDAD-Y-MANTENIBILIDAD.md) | 159 tests, analyzer, errores, rendimiento, deuda |
| [13 — Catálogo de funcionalidades](13-CATALOGO-DE-FUNCIONALIDADES.md) | Matriz trazable de ~70 capacidades con estado |
| [14 — Flujos de datos](14-FLUJOS-DE-DATOS.md) | Qué se escribe en cada acción y respuestas transversales |
| [15 — Evaluación preliminar](15-EVALUACION-PRELIMINAR-DEL-PRODUCTO.md) | Engagement, retención, aprendizaje y monetización (interpretación) |
| [16 — Riesgos y pendientes](16-RIESGOS-Y-PENDIENTES.md) | 28 riesgos priorizados + preguntas sin resolver |
| [17 — Métricas y analítica](17-METRICAS-Y-ANALITICA.md) | Instrumentación actual y brechas |
| [18 — Inventario técnico](18-INVENTARIO-TECNICO.md) | Archivos, endpoints, RPC, dependencias, configuración |
| [19 — Matriz de trazabilidad](19-MATRIZ-DE-TRAZABILIDAD.md) | 53 hallazgos con archivo:línea y estado |

**Leyenda de estado usada en todos los documentos:** V (verificado) · P (parcial) ·
D (diseñado sin conexión) · NV (no verificable desde este entorno) · VP (verificado
en producción).

---

## 2. Metodología

1. **Lectura del repo completo** por subsistemas: navegación, conversación/IA,
   economía/misiones, backend/BD, pantallas, currículo, suscripciones.
2. **Verificación en producción** mediante consultas SQL de solo lectura al
   proyecto `sipiumfdpvnszthykyog`: esquema, RLS, funciones, cron, catálogos y
   conteos agregados.
3. **Ejecución de comprobaciones seguras** (re-medido el 29-oct-2026): `flutter
   test` (702 en verde) y `flutter analyze` (0 errores, 0 warnings, 126 infos).
4. **Contraste con la documentación previa** (`docs/*.md`), registrando la deriva.
5. **Sin cambios**: no se modificó código, datos, configuración ni migraciones. No
   se ejecutó la app en dispositivo ni se probaron compras.

**Relación con la documentación existente:** `docs/archive/auditoria_producto/`
contiene una auditoría anterior (116 KB) y `docs/estrategia_producto/` una fase 2
estratégica ya redactada. Este directorio no los sustituye: es la **foto verificada
del estado actual** (25-oct-2026) que sirve de base para decidir. Donde hay
conflicto, manda lo aquí verificado y se indica en cada documento.

---

## 3. Cifras clave (25-oct-2026 y re-medición del 29-oct-2026)

| Dato | 25-oct-2026 | 29-oct-2026 | Comando / fuente |
|---|---|---|---|
| Versión / plataforma | `1.0.21+22` · Android | igual | `pubspec.yaml` |
| Rutas | 14 | **20** | `lib/app/router.dart` |
| Features | 10 | **16** | `lib/features/*` |
| Lecciones en código | 140 (20 × 7 niveles) | igual | `lesson_catalog.dart` |
| Escenarios en BD | 500 | 500 | `scenarios` |
| Tablas | 77 | **89** | `information_schema.tables` |
| Políticas RLS | 122 | **134** (84 tablas) | `pg_policies` |
| Funciones `public` | 58 | **98** | `pg_proc` |
| Vistas | — | 14 | `information_schema.views` |
| Edge Functions activas | 6 | **8** | `supabase functions list` |
| Jobs cron | 3 | 3 | `cron.job` |
| Claves i18n | 951 | **1.287** (en/es/pt) | `app_en.arb` |
| Pruebas | 530 | **702** en verde (0 saltadas) | `flutter test` |
| Analyzer | 0 err · 0 warn · 127 infos | 0 err · 0 warn · **126 infos** | `flutter analyze` |
| Migraciones aplicadas | 98 | **106** | `schema_migrations` |
| Archivos `.sql` (raíz) | 164 | **170** (95 con prefijo, 75 sin) | `ls` |
| Usuarios / conversaciones / mensajes | 60 / 68 / 740 | foto del 25-oct; no re-medida | producción |
| Compras / inventario / suscripciones | 0 / 0 / 11 | foto del 25-oct; no re-medida | producción |
| Misiones creadas / completadas | 533 / 7 | foto del 25-oct; no re-medida | producción |

---

## 4. Resumen ejecutivo

**¿Qué hace realmente la app hoy?** Un tutor de inglés conversacional por voz con
escenarios, evaluación de metas por IA y una capa de progreso tipo RPG. El
pipeline de voz (grabar → transcribir → responder → narrar) funciona de extremo a
extremo.

**¿Cuáles son sus módulos principales?** `conversation` (voz e IA), `dashboard`
(ruta, progreso, ajustes, resumen), `economy` (maná, oro, tienda, inventario),
`missions`, `subscription`, `onboarding`, `chat_rooms` (gremio y voz), `vocabulary`
(SRS), `auth`, `presence`.

**¿Cómo se organiza el aprendizaje?** Siete niveles CEFR con 20 lecciones cada uno
en el catálogo Dart y hasta 80 escenarios por nivel en la base. Cada escenario
tiene un objetivo, 3-5 metas con palabras clave y frases útiles. Se supera con el
75 % de las metas; las lecciones del mismo nivel se desbloquean en orden.

**¿Cómo funciona el gameplay?** Hablar consume maná (12/15/8 por turno). Al cerrar,
el servidor acredita XP (`minutos×10`), oro y fragmentos según objetivos y nivel.
El XP da nivel (1 cada 1.000) y el aura; el rango es una etiqueta del CEFR. Hay
misiones diarias, recompensa diaria, tienda de cosméticos con oro y leaderboard
por XP.

**¿Qué hace la IA y cómo está integrada?** DeepSeek (`deepseek-v4-flash`) detrás de
la Edge Function `llm-proxy`, con Groq Whisper para voz. Cuatro usos: respuesta
conversacional, evaluación booleana de metas por turno, examen/placement del
Oráculo y generación de lecciones de refuerzo (esta última rota). El cobro de
maná se hace **en el servidor** desde P-07 (`consume_mana` dentro de
`llm-proxy`); el 25-oct todavía no lo validaba.

**¿Cómo se almacenan los datos?** Supabase Postgres con 89 tablas (77 el
25-oct), RLS en todas y 98 funciones (58 entonces); las escrituras sensibles van
por RPC `SECURITY DEFINER`. El repo de migraciones no reproduce el esquema: a
29-oct hay 41 migraciones aplicadas sin archivo.

**¿Cómo se maneja la progresión?** CEFR (solo cambia con el Oráculo), XP, aura,
prestigio y títulos. La racha está rota: el trigger de guarda descarta las
escrituras del cliente y las RPC no la actualizan.

**¿Cómo se monetiza?** Suscripción por Play Billing + RevenueCat (maná mensual:
3.000 / 17.000 / 20.500 / 25.500). El premium no desbloquea funcionalidades: solo
añade maná. No hay compras de maná ni de gemas operativas.

**¿Qué podría motivar a continuar?** La conversación en sí, la ruta de lecciones,
el aura/prestigio, la recompensa diaria y las misiones. Ninguno de esos ganchos
está reforzado por notificaciones, y varios muestran datos incorrectos.

**¿Principales puntos de fricción?** Onboarding largo antes de la primera lección;
resumen con cifras fijas; racha inexistente; errores de IA mostrados como tutor;
maná que se agota sin aviso; gremio vacío; misiones semanales invisibles.

**¿Funcionalidades incompletas?** Refuerzo por IA, misiones semanales/secretas/
eventos, battle pass, exportar/borrar cuenta, reporte de errores, gremio.

**¿Principales riesgos técnicos?** IA sin validación de maná; recompensas de misión
con importes del cliente; `add_mana_item` sin identidad; migraciones no
reproducibles; sin staging; sin medición de coste ni de errores.

**¿Qué falta para evaluar la retención real?** Usuarios reales y una taxonomía de
eventos (embudo de onboarding, sesión, coste de IA, errores). Hoy solo hay 4 días
de actividad de cuentas de prueba en los últimos 30.

**¿Qué oportunidades estudiar en la fase 2?** Cerrar el bucle de recompensa con
datos reales; convertir la racha en un hábito funcional; un canal de retorno
(push/email); un resumen que demuestre aprendizaje; decidir el valor real del
premium; una sola fuente de currículo.

---

## 5. Cobertura de los criterios de aceptación

| # | Criterio | Estado | Dónde |
|---|---|---|---|
| 1 | Estructura del proyecto y dependencias inventariadas | ✅ | 02, 18 |
| 2 | Todas las pantallas y rutas documentadas | ✅ | 03 |
| 3 | Flujo completo del usuario reconstruido | ✅ | 04, 14 |
| 4 | Catálogo de cursos/niveles/actividades | ✅ | 05 |
| 5 | Mecánicas de juego y reglas reales | ✅ | 06 |
| 6 | Fórmulas de XP/recompensas/progresión | ✅ | 06 (§4-§5) |
| 7 | Cada caso de uso de IA | ✅ | 07 |
| 8 | Modelo de datos y relaciones | ✅ (parcial en columnas secundarias) | 08 |
| 9 | Autenticación, persistencia y sincronización | ✅ | 09, 14 |
| 10 | Mecanismos reales de monetización | ✅ | 10 |
| 11 | Notificaciones y retención | ✅ | 11 |
| 12 | Pruebas, seguridad, rendimiento y mantenibilidad | ✅ | 12, 16 |
| 13 | Catálogo trazable de funcionalidades | ✅ | 13, 19 |
| 14 | Diagramas que permita la evidencia | ✅ (11 diagramas Mermaid) | 02, 03, 04, 06, 08, 09, 10, 14 |
| 15 | Riesgos y brechas de información | ✅ | 16 |
| 16 | Evaluación preliminar separada de los hechos | ✅ | 15 |
| 17 | Referencias para validar hallazgos | ✅ | 19 |
| 18 | Sin modificar funcionalidades ni datos | ✅ | — |

**Parcial:** el desglose exhaustivo de las 77 tablas (columnas de todas) no se
incluyó; se documentan las 15 tablas que participan en flujos reales y se listan
las 62 restantes por dominio. El panel `web_admin/` se revisó por rutas y servicio,
no pantalla por pantalla.

**Bloqueado:** pruebas en dispositivo, compras reales y estado del pipeline en
GitHub Actions (requiere cuenta/dispositivo).

---

## 6. Diagramas incluidos

| # | Diagrama | Documento |
|---|---|---|
| 1 | Arquitectura general | 02 §9 |
| 2 | Petición de conversación (secuencia) | 02 §10 |
| 3 | Navegación de pantallas | 03 §2 |
| 4 | Ciclo de gameplay | 06 §2 |
| 5 | Flujo de una lección hasta persistencia | 14 §2 |
| 6 | Evaluación y feedback con IA | 07 §3 |
| 7 | Modelo entidad-relación | 08 §4 |
| 8 | Autenticación y arranque | 09 §2 |
| 9 | Pagos y control de acceso | 10 §4; 14 §4 |
| 10 | Viaje del usuario | 04 §2 |
| 11 | Flujo principal de aprendizaje | 04 §3 |

---

## 7. Limitaciones declaradas

1. **No se ejecutó la app**: no hay evidencia de comportamiento visual, permisos,
   latencia ni TTS real.
2. **No se probaron compras** ni el Customer Center.
3. **No se accedió a logs** de Edge Functions ni de Auth en ventanas reales.
4. **Los conteos de filas** son una foto y pueden incluir cuentas de prueba.
5. **No hay datos de usuarios reales**: cualquier afirmación de retención o
   conversión sería inventada.
6. **La documentación previa contiene errores** corregidos aquí (tablas, modelo de
   IA, endpoint `/stt`, `retention_events`, número de tests).

---

## 8. Cómo mantener este audit

- Re-medir las cifras de producción (§3) al cerrar cada release.
- Actualizar 13 y 19 cuando cambie una funcionalidad.
- Si se corrige un riesgo de 16, marcarlo con fecha y commit.
- Este directorio describe el **estado actual**; las propuestas van en
  `docs/estrategia_producto/`.

