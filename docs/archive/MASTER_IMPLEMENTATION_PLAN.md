# MASTER_IMPLEMENTATION_PLAN.md — TutorSaas / Dungeon of English
### Plan Maestro de Ejecución (CTO · CPO · Principal Architect · TPM · Game Design Lead · Engineering Manager)

> **Guía oficial de ejecución del proyecto.** Reemplaza el enfoque de auditoría por un plan de construcción medible.
> Base: `MASTER_AUDIT.md` + `MASTER_AUDIT_V2.md` (fuente oficial del estado) + `vision.md`, `roadmap.md` y docs por fase.
> Fecha: 2026-07-30 · Método: consolidar → agrupar → eliminar duplicados → priorizar → ejecutar en ciclos cortos.
> **Estado actual: LISTO PARA BETA CERRADA.** El plan lleva el producto a Beta Pública → Producción.

---

## 1. Resumen Ejecutivo

El proyecto tiene un **core funcional y estable** (conversación por voz con IA, misiones, economía, gremio). No requiere más análisis: requiere **ejecución disciplinada** en 4 frentes críticos que desbloquean Beta Pública:

1. **🔴 Seguridad/claves (IA-01)** — único bloqueador de seguridad restante.
2. **🔴 Migración visual** — eliminar la mezcla de estilos (17 archivos con diseño antiguo) hacia PlantillasHTML.
3. **🔴 Producto/Onboarding** — reducir fricción (9 pasos + paywall temprano) y reforzar la identidad RPG.
4. **🟠 Retención** — analytics + push + temporadas (el talón de Aquiles frente a Duolingo).

**Estrategia de entrega**: épicas en fases; cada fase termina con build OK + tests verdes + docs actualizadas. Ciclos cortos: 1 épica → 1 user story a la vez → validar → documentar.

---

## 2. Estado Consolidado del Proyecto

| Área | Estado (verificado) |
|---|---|
| Compilación / analyze / test | ✅ build OK · 0 errores · 13/13 (insuficiente cobertura) |
| Fases 2-6 (UX, Dashboard, Conversación, Misiones, Economía) | ✅ 27/27 tareas |
| Fase 7 Guild | ✅ 8/8 (NPC, quest board, mesas DB, prestigio, práctica IA) |
| Fase 8 IA | ✅ 3/3 (costos optimizados, plan free, monetización) |
| Fase 9 RPG | 🟡 items + modificadores OK; colecciones/trofeos pendientes |
| Fase 10 Microinteracciones | ✅ 7/7 (AppMotion, RunicButton, efectos) |
| Fase 11 QA | 🟡 seguridad DB QA-1/2/3 aplicados; veredicto beta cerrada |
| Seguridad | ❌ IA-01 (claves en repo) · RLS anon 54 · leaked-password off |
| Visual | ❌ 17 archivos diseño antiguo (orbitron/hankenGrotesk) |
| Técnica | ❌ sin CI/CD · sin observabilidad prod · sin analytics · tests insuficientes |
| Retención | ❌ sin push · sin temporadas · sin analytics |

---

## 3. Objetivos Estratégicos

1. **OE-1 (Seguridad)**: cero secretos en el repo y RLS endurecido antes de exponer usuarios.
2. **OE-2 (Visual)**: un solo lenguaje visual (PlantillasHTML) en TODA la app.
3. **OE-3 (Producto)**: onboarding en 3 pasos; paywall post-sesión; identidad RPG con narrativa.
4. **OE-4 (Retención)**: medir (analytics) y reactivar (push + temporadas + eventos).
5. **OE-5 (Ingeniería)**: CI/CD, observabilidad, tests ≥10 archivos, widgets divididos.
6. **OE-6 (Lanzamiento)**: Beta Cerrada → Beta Pública → Producción con checklists verificables.

---

## 4. Épicas

| Épica | Alcance |
|---|---|
| **EP-DS** Design System | Tokens (AppSpacing/AppTypography/AppRadius), ThemeData único, eliminación de fuentes antiguas |
| **EP-MV** Migración Visual | Migrar 17 archivos a PlantillasHTML; eliminar orbitron/hankenGrotesk; hex → tokens |
| **EP-REF** Refactorización | Dividir dashboard/conversation/onboarding; interfaz abstracta de misiones; eliminar duplicación |
| **EP-RPG** RPG | Narrativa (Reino/conflicto/boss), narrativa episódica, agencia, colecciones, drops |
| **EP-GUILD** Guild | Audio real (o etiquetado demo), tipos de mesa activos, trofeos, raids cooperativas |
| **EP-MIS** Misiones | UI de modificadores (MM-04), misiones secretas descubribles, eventos semanales |
| **EP-IA** IA | IA-01 claves, caché (IA-06), IA adaptativa de dificultad, embeddings (futuro) |
| **EP-ECO** Economía | Sinks (tienda rotativa, oro real, fragmentos canjeables), balance a 6-12 meses |
| **EP-UX** UX/UI | Onboarding 3 pasos, paywall post-sesión, i18n completo, estado vacío motivante |
| **EP-PERF** Performance | Dividir widgets, quitar glow loop innecesario, índices, RLS initplan |
| **EP-SEC** Seguridad | IA-01, QA-4/5, revisión de políticas RLS, CI/CD con secrets |
| **EP-QA** QA | Tests ampliados, test visual, regresión automatizada |
| **EP-A11Y** Accesibilidad | Fuentes, contraste, reduce-motion global, hit-areas |
| **EP-MON** Monetización | Modal energía con recarga, percepción de valor, simplificar doble limitación |
| **EP-LIVE** LiveOps | Temporada 1, eventos semanales, battle pass por temporada, leaderboard activo |
| **EP-OBS** Observabilidad | Sentry/Crashlytics, analytics de retención (D1/D7/D30), push |
| **EP-BETA** Beta | Cerrada → Pública con telemetría y soporte |
| **EP-PROD** Producción | Release optimizado, cumplimiento, backup, soporte, operación |

---

## 5. Product Backlog

Cada item: `[ID] Nombre · área · prioridad · complejidad (S/M/L) · dependencias · DoD`.

### EP-DS Design System
| ID | Item | Prio | Comp | Dep | DoD |
|---|---|---|---|---|---|
| DS-01 | Crear `app_spacing.dart` (grid 4px: 4/8/12/16/20/24/32) | Alta | S | — | Tokens usados en ≥3 pantallas |
| DS-02 | Crear `app_typography.dart` (wrapper SpaceGrotesk/Inter/JetBrainsMono) | Alta | S | — | Todas las nuevas refs usan wrapper |
| DS-03 | Unificar ThemeData: ColorScheme desde AppColors + textTheme desde wrapper | Alta | M | DS-02 | `Theme.of(context)` usa tokens; 0 hex en theme |
| DS-04 | Definir AppRadius (4px) y AppElevation (0/2/12) | Media | S | DS-01 | Tokens en GlassCard/RunicButton |

### EP-MV Migración Visual
| ID | Item | Prio | Comp | Dep | DoD |
|---|---|---|---|---|---|
| MV-01 | Migrar widgets core: mana_meter, status_window_modal, system_mana_disruption, draggable_monster | **Crítica** | M | DS-02 | 0 refs orbitron/hanken en core |
| MV-02 | Migrar onboarding_screen (18 hanken) | **Crítica** | L | MV-01 | 0 hanken; texto i18n completo |
| MV-03 | Migrar dashboard_screen (6 hanken) | **Crítica** | L | MV-01 | 0 hanken en dashboard |
| MV-04 | Migrar profile, session_summary, level_exam (4 orbitron), conversation (2 hanken) | Alta | M | MV-01 | 0 refs antiguas |
| MV-05 | Migrar shop (orbitron) + voice_room | Alta | M | MV-01 | 0 refs antiguas |
| MV-06 | Migrar 6 widgets de dashboard (12 hanken) | Alta | M | MV-01 | 0 hanken en widgets |
| MV-07 | Eliminar hex hardcodeados fuera de AppColors (grep `0xFF`) | Alta | M | MV-01..06 | 0 hex sueltos en features |
| MV-08 | Meta: `grep orbitron|hankenGrotesk` = 0 en todo lib/ | **Crítica** | S | MV-01..06 | Meta verificable |

### EP-REF Refactorización
| ID | Item | Prio | Comp | Dep | DoD |
|---|---|---|---|---|---|
| REF-01 | Dividir dashboard_screen (2040 líneas) en widgets por tab | Alta | L | MV-03 | Cada tab < 400 líneas |
| REF-02 | Dividir conversation_screen (1221) | Media | L | MV-04 | Pantalla < 500 líneas |
| REF-03 | Dividir onboarding_screen (1409) | Media | L | MV-02 | Por pasos como widgets |
| REF-04 | Interfaz abstracta para MissionRepository | Media | M | — | `MissionRepository` abstracto + impl |
| REF-05 | Eliminar widgets huérfanos (draggable_monster si sin uso, configuration_error revisar) | Baja | S | — | Confirmar 0 usos antes de borrar |

### EP-RPG
| ID | Item | Prio | Comp | Dep | DoD |
|---|---|---|---|---|---|
| RPG-01 | Definir narrativa: Reino, conflicto ("Vacío del Olvido"), objetivo final | **Crítica** | M | — | Doc `narrative.md` + texto en app |
| RPG-02 | Boss narrativo por rango (A1..C2) en level_exam | Alta | M | RPG-01 | Cada rango tiene boss con intro |
| RPG-03 | Diálogos del Oráculo con arco (episodios 1-5) | Alta | M | RPG-01 | Oracle usa guion en conversación |
| RPG-04 | Colecciones (tabla player_collections + UI) | Media | M | ECO-02 | 3 colecciones completables |
| RPG-05 | Drops sorpresa con rareza (cofre post-raid) | Alta | M | ECO-01 | Loot raro visible + FloatingReward |

### EP-GUILD
| ID | Item | Prio | Comp | Dep | DoD |
|---|---|---|---|---|---|
| GUILD-01 | Etiquetar audio del gremio como "demo" o implementar real | **Crítica** | L | — | Sin simulación falsa engañosa |
| GUILD-02 | Activar tipos de mesa (mentorship/event/training) en UI | Media | M | — | Cada tipo tiene flujo |
| GUILD-03 | Trofeos del gremio por misiones colaborativas | Media | M | ECO-02 | Trofeos visibles en salón |
| GUILD-04 | Raid cooperativa semanal (boss de vocabulario) | Media | L | RPG-02 | Progreso colectivo en guild_collaborative |

### EP-MIS Misiones
| ID | Item | Prio | Comp | Dep | DoD |
|---|---|---|---|---|---|
| MIS-01 | UI de modificadores de misión (MM-04) | Alta | M | — | Aplicar x2/facilidad/desafío desde la tarjeta |
| MIS-02 | Misiones secretas descubribles (pistas + trigger) | Media | M | RPG-01 | Usuario "descubre" una secreta |
| MIS-03 | Evento semanal (rotación de quest pool) | Media | M | LIVE-01 | Nuevo quest pool semanal |

### EP-IA
| ID | Item | Prio | Comp | Dep | DoD |
|---|---|---|---|---|---|
| IA-01 | Mover API keys a --dart-define; eliminar fallback `sk-592...`; rotar claves | **Crítica** | S | — | 0 secretos en repo; builds con dart-define |
| IA-02 | Caché de respuestas (frases sugeridas/saludos) | Media | M | — | Caché LRU en memoria; hit observable |
| IA-03 | IA adaptativa de dificultad (ajuste por errores) | Media | L | — | Nivel ajustado tras N errores |
| IA-04 | Embeddings (búsqueda de escenario por interés) — futuro | Baja | L | — | PoC de búsqueda semántica |

### EP-ECO Economía
| ID | Item | Prio | Comp | Dep | DoD |
|---|---|---|---|---|---|
| ECO-01 | Tienda rotativa diaria/semanal (sink de gemas) | Alta | M | — | Ofertas cambian; gemas gastables |
| ECO-02 | Oro real: gasto en entrenamiento/pergaminos | Alta | M | — | `spendGold` conectado a una acción |
| ECO-03 | Fragmentos canjeables por cosméticos raros | Media | M | — | 3 items de canje |
| ECO-04 | Balance 6-12 meses (curva de sinks vs income) | Media | S | ECO-01..03 | Simulación en `docs/economy.md` |

### EP-UX
| ID | Item | Prio | Comp | Dep | DoD |
|---|---|---|---|---|---|
| UX-01 | Onboarding 3 pasos (idioma, Oracle corto, 1ª raid) | **Crítica** | L | MV-02 | Flujo < 3 min |
| UX-02 | Paywall post-sesión (no en onboarding) | **Crítica** | M | UX-01 | Paywall tras 1ª raid |
| UX-03 | i18n completo de onboarding (descripciones) | Alta | M | MV-02 | 0 strings sueltos |
| UX-04 | Estados vacíos motivantes (misiones/inventario) | Media | S | — | Mensajes + CTA |
| UX-05 | Simplificar doble limitación (una métrica de energía) | Media | M | MON-01 | Una fuente de verdad en UI |

### EP-PERF
| ID | Item | Prio | Comp | Dep | DoD |
|---|---|---|---|---|---|
| PERF-01 | Desactivar glow rúnico en listas largas / con reduce-motion | Media | S | DS-04 | Glow solo en cards destacadas |
| PERF-02 | Índices FK faltantes (21) — script SQL | Media | S | — | Advisors perf reducen a <10 |
| PERF-03 | RLS initplan `(select auth.uid())` (55 políticas) | Media | L | — | Advisors perf reducen |
| PERF-04 | Eliminar índices duplicados/sin uso | Baja | S | — | Advisors limpios |

### EP-SEC
| ID | Item | Prio | Comp | Dep | DoD |
|---|---|---|---|---|---|
| SEC-01 | Revisión RLS anon (54 políticas) → autenticadas | Alta | M | — | Advisors security < 20 |
| SEC-02 | Habilitar leaked-password protection (QA-4) | Alta | S | — | Config Auth |
| SEC-03 | CI/CD con secrets (GitHub Actions + dart-define) | **Crítica** | M | IA-01 | Pipeline verde |

### EP-QA
| ID | Item | Prio | Comp | Dep | DoD |
|---|---|---|---|---|---|
| QA-01 | Tests economía (repo + RPC mocks) | Alta | M | — | ≥15 tests |
| QA-02 | Tests misiones (progresión, modifiers, claim) | Alta | M | — | ≥15 tests |
| QA-03 | Tests conversación (evaluación metas, ventana móvil) | Alta | M | — | ≥10 tests |
| QA-04 | Test visual (golden) de pantallas clave | Media | M | MV-01..06 | Golden de 5 pantallas |
| QA-05 | Test de regresión automatizado en CI | Alta | M | SEC-03 | CI ejecuta analyze+test |

### EP-A11Y
| ID | Item | Prio | Comp | Dep | DoD |
|---|---|---|---|---|---|
| A11Y-01 | Tamaños de fuente HUD (≥10px mínimo legible) | Media | S | — | Contraste verificable |
| A11Y-02 | Contraste de texto sobre fondo oscuro | Media | S | — | WCAG AA en textos principales |
| A11Y-03 | Semántica en widgets custom (Semantics) | Media | M | — | GlassCard/RunicButton anunciables |
| A11Y-04 | reduce-motion global (AppMotion.scaled en todas) | Media | M | DS-04 | 0 animaciones ignoran disableAnimations |
| A11Y-05 | Hit-areas ≥48px en botones | Baja | S | — | RunicButton por defecto |

### EP-MON
| ID | Item | Prio | Comp | Dep | DoD |
|---|---|---|---|---|---|
| MON-01 | Modal energía agotada con CTA "RECARGAR/IR PREMIUM" | Alta | S | — | Modal con 2 acciones |
| MON-02 | Conectar recarga con purchaseItem(invocacion5/20) | Alta | S | MON-01 | Compra desde modal |
| MON-03 | Revisar percepción: una métrica de energía (UX-05) | Media | M | UX-05 | Encuesta/beta feedback |

### EP-LIVE
| ID | Item | Prio | Comp | Dep | DoD |
|---|---|---|---|---|---|
| LIVE-01 | Temporada 1 (tema, battle pass por temporada) | Alta | L | RPG-01 | BP resetea por temporada |
| LIVE-02 | Eventos semanales (boss de gremio) | Media | L | GUILD-04 | Evento en calendario |
| LIVE-03 | Leaderboard activo (semanal) | Media | M | — | Ranking con recompensas |

### EP-OBS
| ID | Item | Prio | Comp | Dep | DoD |
|---|---|---|---|---|---|
| OBS-01 | Sentry/Crashlytics | **Crítica** | M | — | Crash reportado en consola |
| OBS-02 | Analytics de retención (D1/D7/D30, eventos clave) | **Crítica** | M | — | Dashboard con 10 eventos |
| OBS-03 | Push notifications (racha en peligro, misión diaria) | Alta | M | — | Notif programada |

### EP-BETA / EP-PROD
| ID | Item | Prio | Comp | Dep | DoD |
|---|---|---|---|---|---|
| BETA-01 | Preparar build cerrada + invitaciones | **Crítica** | M | EP-OBS | Apk firmado + TestFlight/Play internal |
| BETA-02 | Canal de feedback (formulario in-app) | Alta | S | — | Feedback llega a tabla |
| PROD-01 | Release optimizado (split per ABI) | Alta | M | BETA-02 | Apk < 40MB por ABI |
| PROD-02 | Backup/restore + retención de datos | Alta | M | — | Restore probado |
| PROD-03 | Términos/privacidad/consentimiento | Alta | S | — | Links en settings |

---

## 6. Roadmap por Fases

### Fase A — Cimientos (seguridad + design system) — [Crítico]
- **Objetivo**: eliminar bloqueadores (IA-01) y sentar tokens visuales.
- **Alcance**: IA-01, SEC-01/02/03, DS-01..04.
- **Dependencias**: ninguna.
- **Riesgos**: rotación de claves rompe builds → coordinar dart-define.
- **Entregables**: 0 secretos en repo, tokens base, CI verde.
- **Salida**: build OK + grep secretos limpio.

### Fase B — Migración Visual [Crítico]
- **Objetivo**: app uniforme PlantillasHTML.
- **Alcance**: MV-01..08.
- **Dependencias**: Fase A (DS).
- **Riesgos**: regresiones visuales → golden tests (QA-04) al final.
- **Salida**: grep `orbitron|hankenGrotesk` = 0.

### Fase C — Refactor + UX [Alto]
- **Objetivo**: widgets manejables + onboarding 3 pasos + paywall post-sesión.
- **Alcance**: REF-01..05, UX-01..05.
- **Dependencias**: Fase B (MV-02/03).
- **Riesgos**: onboarding nuevo puede bajar conversión temporal → testear.
- **Salida**: dashboard dividido, onboarding < 3 min.

### Fase D — RPG + Narrativa + Guild [Alto]
- **Objetivo**: convertir la app en un RPG real.
- **Alcance**: RPG-01..05, GUILD-01..04, MIS-01..03.
- **Dependencias**: Fase C.
- **Riesgos**: narrativa de baja calidad daña inmersión → guion revisado.
- **Salida**: Reino/conflicto/boss en app; audio etiquetado.

### Fase E — Economía + Balance [Alto]
- **Objetivo**: sinks y simulación 6-12 meses.
- **Alcance**: ECO-01..04, MON-01..03.
- **Dependencias**: Fase D (ECO conecta con RPG loot).
- **Riesgos**: sinks agresivos frustran → teste con beta.
- **Salida**: gemas/oro/fragmentos con uso claro.

### Fase F — Retención + Observabilidad [Alto]
- **Objetivo**: medir y reactivar.
- **Alcance**: OBS-01..03, LIVE-01..03.
- **Dependencias**: Fases A-E (baseline estable).
- **Riesgos**: analytics incompletos → definir eventos antes.
- **Salida**: Sentry + analytics D1/D7/D30 + push + temporada 1.

### Fase G — QA + Accesibilidad [Alto]
- **Objetivo**: calidad para beta pública.
- **Alcance**: QA-01..05, A11Y-01..05, PERF-02..04.
- **Dependencias**: Fases B-E (código estable).
- **Salida**: tests ≥50, advisors < umbrales.

### Fase H — Beta Cerrada [Crítico]
- **Objetivo**: validar con usuarios reales.
- **Alcance**: BETA-01/02 + telemetría.
- **Criterios de éxito**: D1≥40%, crash-free≥99%, feedback accionable.
- **Salida**: informe de beta.

### Fase I — Beta Pública [Crítico]
- **Objetivo**: lanzar a público.
- **Alcance**: ajustes de beta + BETA-02 + PROD-03.
- **Criterios**: D1≥40%, D7≥20%, crash-free≥99.5%.
- **Salida**: tiendas con versión pública.

### Fase J — Producción [Crítico]
- **Objetivo**: operar con garantías.
- **Alcance**: PROD-01..03, OBS completo, soporte.
- **Salida**: checklist producción 100%.

---

## 7. Plan de Migración Visual (detalle)

**Orden** (por riesgo creciente):
1. Widgets core (MV-01) — bajo riesgo, alto impacto de consistencia.
2. Pantallas de alto tráfico: onboarding → dashboard (MV-02/03).
3. Resto (MV-04/05/06).
4. Meta grep=0 (MV-08).

**Componentes reutilizables**: GlassCard, SystemWindow, SegmentedBar, AnimatedCounter, FloatingReward, RunicButton, RpgAvatar, CyberManhwaBackground, QuestCard.

**Widgets base a crear**: `StatTile`, `RunicButton` (ya existe), `AppTypography` wrapper, `AppSpacing` tokens.

**Eliminar**: `status_window_modal` (→ SystemWindow), fuentes antiguas.

**Unificación**: ThemeData consume AppColors + AppTypography; 0 hex sueltos; iconografía Material (consistente).

---

## 8. Plan de Refactorización

**Orden por impacto/riesgo**:
1. REF-04 (interfaz misiones) — riesgo bajo, mejora arquitectura.
2. REF-01 (dashboard) — riesgo medio, alto beneficio.
3. REF-02/03 (conversation/onboarding) — riesgo medio.
4. REF-05 (huérfanos) — riesgo bajo.

**Regla**: cada división debe mantener comportamiento idéntico (tests de regresión previos).

---

## 9. Plan de IA
- **P0**: IA-01 claves (con SEC-03 CI).
- **P1**: IA-02 caché, IA-03 adaptativa.
- **P2**: IA-04 embeddings.
- **Monitoreo**: costos por plan (dashboard) antes de beta pública.

---

## 10. Plan RPG
- **P0**: RPG-01 narrativa (documento + texto), RPG-02 boss, RPG-03 diálogos Oráculo.
- **P1**: RPG-05 drops sorpresa, RPG-04 colecciones.
- **Regla**: cosméticos puros (sin pay-to-win).

---

## 11. Plan de Guild
- **P0**: GUILD-01 (etiquetar audio o real).
- **P1**: GUILD-04 raid cooperativa, GUILD-02/03 tipos de mesa y trofeos.
- **Regla**: la simulación no debe engañar.

---

## 12. Plan de Economía
- **P0**: ECO-01 tienda rotativa, ECO-02 oro real.
- **P1**: ECO-03 fragmentos, ECO-04 balance simulado.
- **Meta**: a 12 meses, gemas con propósito y sin inflación.

---

## 13. Plan de UX/UI
- **P0**: UX-01 onboarding 3 pasos, UX-02 paywall post-sesión.
- **P1**: UX-03 i18n, UX-04 estados vacíos, UX-05 una métrica de energía.
- **Regla**: cada cambio de flujo con test A/B (cuando haya analytics).

---

## 14. Plan de Performance
- **P1**: PERF-01 glow selectivo, PERF-02/03 índices + RLS initplan.
- **P2**: PERF-04 índices sin uso.
- **Meta**: advisors perf < 30 hallazgos.

---

## 15. Plan de Seguridad
- **P0**: IA-01, SEC-03 CI con secrets.
- **P1**: SEC-01 RLS anon, SEC-02 leaked-password.
- **Meta**: advisors security < 20.

---

## 16. Plan de QA
- **P0**: QA-01/02/03 (economía/misiones/conversación).
- **P1**: QA-04 golden, QA-05 regresión en CI.
- **Meta**: ≥50 tests, 0 regresiones en CI.

---

## 17. Plan de Beta Cerrada
- **Mínimo**: build firmado, Sentry, analytics, feedback in-app.
- **Métricas**: D1≥40%, crash-free≥99%, sesión media ≥10 min, 5 raids/semana.
- **Bugs tolerables**: fallos cosméticos, textos; NO crashes, pérdida de progreso, ni fugas de datos.
- **Éxito**: feedback validado de 20-50 usuarios.

---

## 18. Plan de Beta Pública
- **Requisitos extra**: escalado de Supabase (índices), monitoreo de costos IA, soporte.
- **Métricas**: D1≥40%, D7≥20%, D30≥10%, crash-free≥99.5%.
- **Riesgos aceptables**: quejas de balance (a iterar), no críticas.

---

## 19. Plan de Producción
- **Checklist**: release optimizado, observabilidad total, backup probado, cumplimiento (términos/privacidad/consentimiento), escalado, soporte, operación con runbooks.
- **Regla**: nada en producción sin rollback planificado.

---

## 20. Matriz de Prioridades

| Prioridad | Criterio | Items |
|---|---|---|
| **Crítico** | Impide lanzar/continuar | IA-01, MV-01/02/03/08, UX-01/02, SEC-03, OBS-01/02, BETA-01 |
| **Alto** | Gran valor o reduce riesgo | MV-04..07, REF-01, RPG-01..03, GUILD-01, MIS-01, ECO-01/02, SEC-01/02, QA-01..05, OBS-03 |
| **Medio** | Mejora experiencia | REF-02..05, RPG-04/05, GUILD-02..04, MIS-02/03, IA-02/03, ECO-03/04, UX-03..05, PERF-01..03, A11Y-01..04, MON-01..03, LIVE-02/03, BETA-02 |
| **Bajo** | Post-lanzamiento | IA-04, PERF-04, A11Y-05, LIVE-01 (si retrasa), PROD-01..03 (parte tras beta) |

---

## 21. Matriz de Dependencias

```
Fase A (DS + SEC) ──► Fase B (MV) ──► Fase C (REF + UX) ──► Fase D (RPG + GUILD + MIS)
     │                                   │                        │
     └──► (paralelo) OBS/QA pueden prepararse tras A ───────────► Fase E (ECO)
Fase D ──► Fase E ──► Fase F (RET + LIVE) ──► Fase G (QA + A11Y) ──► H (Beta Cerrada) ──► I (Pública) ──► J (Prod)
```

**Paralelizables**: EP-DS con EP-SEC; EP-QA (tests) puede empezar tras Fase A; EP-OBS tras Fase A.

---

## 22. Matriz de Riesgos

| Fase | Riesgo técnico | Riesgo negocio/UX | Mitigación |
|---|---|---|---|
| A | Rotar claves rompe builds | — | Coordinar dart-define antes de rotar |
| B | Regresiones visuales | — | Golden tests + revisión por pantalla |
| C | Onboarding nuevo baja conversión | Usuarios confundidos | Test A/B, feedback beta |
| D | Narrativa pobre | Daña inmersión | Guion revisado por 2 personas |
| E | Sinks frustran | Percepción de avaricia | Balance conservador + beta feedback |
| F | Analytics incompletos | No medir retención | Definir eventos antes de integrar |
| G | Tests lentos | — | CI con cache |
| H | Crashes en dispositivo real | Abandono | Sentry + hotfix rápido |
| I | Costos IA escalan | Pérdida | Tope por plan + dashboard |
| J | Cumplimiento legal | Multas | Revisión legal antes de tienda |

---

## 23. Checklist por Fase
(derivada de los items de cada fase; ver roadmap + backlog — cada item tiene DoD verificable)

---

## 24. Definition of Done global (aplicable a cada item)
- [ ] Implementado sin romper build (`flutter build` OK).
- [ ] `flutter analyze` 0 errores (nuevos).
- [ ] Tests relevantes verdes (`flutter test`).
- [ ] Sin regresiones en funcionalidad existente.
- [ ] Documentación de la fase/épica actualizada (`docs/<épica>/Change_Log.md`).
- [ ] Si toca DB: migración SQL preparada para SQL Editor.
- [ ] Si toca UI: alineado con PlantillasHTML (sin refs antiguas).
- [ ] Actualizado `TASK_BOARD.md`.

---

## 25. Criterios de Lanzamiento

### Beta Cerrada
- [ ] 0 secretos en repo · CI verde · Sentry activo.
- [ ] Migración visual en pantallas de alta fricción (onboarding/dashboard).
- [ ] Onboarding 3 pasos + paywall post-sesión.
- [ ] Tests ≥30 · crash-free ≥99% en beta.

### Beta Pública
- [ ] grep `orbitron|hankenGrotesk` = 0.
- [ ] Analytics D1/D7/D30 activos + push.
- [ ] RLS anon revisado · leaked-password on.
- [ ] Tests ≥50 · crash-free ≥99.5% · costos IA con tope.
- [ ] Términos/privacidad.

### Producción
- [ ] Release optimizado · observabilidad total · backup probado.
- [ ] Cumplimiento completo · soporte con runbooks.
- [ ] LiveOps operativo (temporada 1, eventos, BP por temporada).
- [ ] Monitoreo de costos + escalado de índices.

---

## 26. Conclusión Ejecutiva

**El proyecto está en su punto de inflexión: la auditoría ya cumplió su función; ahora toca ejecutar.**

El plan prioriza en orden de impacto:
1. **Fase A (Crítico)**: seguridad (IA-01) + design system → desbloquea todo.
2. **Fase B (Crítico)**: migración visual completa → uniformidad percibida.
3. **Fase C-E (Alto)**: refactor + UX + RPG/narrativa + economía → producto.
4. **Fase F-H (Alto)**: retención + QA + beta cerrada → validación real.
5. **Fase I-J (Crítico)**: beta pública → producción.

**Regla de oro del modo ejecución**: ciclos cortos (1 épica → 1 story a la vez → validar → documentar). Sin nuevos documentos estratégicos de gran tamaño; solo actualizar los existentes conforme se implementa.

Con este plan, un equipo (o una IA) puede ejecutar de forma ordenada y medible hasta producción, sin reinterpretar las auditorías originales.
