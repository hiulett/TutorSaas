# 📋 TASK BOARD — MASTER IMPLEMENTATION PLAN (Ejecución)

> Seguimiento visual de las fases del `docs/MASTER_IMPLEMENTATION_PLAN.md`.
> Leyenda: ⬜ Pendiente · 🟡 Parcial · ✅ Completada · ⛔ Bloqueada
> Actualizado: 2026-07-31 (oleadas 1-4 en paralelo + integraciones centrales)

## Fase A — Cimientos (seguridad + design system)
| ID | Tarea | Estado | Prioridad |
|----|-------|--------|-----------|
| IA-01 | API keys a --dart-define (0 secretos en repo) | ✅ | Crítica |
| SEC-01 | Revisión RLS anon (54 políticas) | ✅ | Alta |
| SEC-02 | Habilitar leaked-password protection | ⬜ | Alta |
| SEC-03 | CI/CD con secrets | ✅ | Crítica |
| DS-01..04 | Design system (spacing/typography/theme/radius) | ✅ | Alta/Media |
| SEC-IDOR | Fix 7 RPCs SECURITY DEFINER sin auth.uid() (IDOR/cheats) | ✅ | **Crítica** |

## Fase B — Migración Visual
| ID | Tarea | Estado | Prioridad |
|----|-------|--------|-----------|
| MV-01..08 | Migración completa (core, onboarding, dashboard, resto, hex, meta grep=0) | ✅ | Crítica |

## Fase C — Refactor + UX
| ID | Tarea | Estado | Prioridad |
|----|-------|--------|-----------|
| REF-01 | Dividir dashboard_screen (1615→630; tab Estado→progress_tab_view 687; 3 gráficas→charts/) | ✅ | Alta |
| REF-02 | Dividir conversation_screen (1289→1249, AnimatedMessage extraído) | ✅ | Media |
| REF-03 | Dividir onboarding_screen (747 líneas, métodos por paso) | ✅ | Media |
| REF-04 | Interfaz abstracta MissionRepository | ✅ | Media |
| REF-05 | Eliminar widgets huérfanos (audit: 0 huérfanos, todos con refs) | ✅ | Baja |
| UX-01..04 | Onboarding 3 pasos, paywall post-sesión, i18n, estados vacíos | ✅ | Crítica/Alta/Media |
| UX-05 | Simplificar doble limitación (NÚCLEO = métrica única en HUD) | ✅ | Media |

## Fase D — RPG + Narrativa + Guild
| ID | Tarea | Estado | Prioridad |
|----|-------|--------|-----------|
| RPG-01 | Narrativa (docs/09_RPG/narrative.md) | ✅ | Crítica |
| RPG-02 | Boss narrativo por rango en level_exam | ✅ | Alta |
| RPG-03 | Diálogos del Oráculo con arco (episodios 1-5) | ✅ | Alta |
| RPG-04 | Colecciones (tabla + UI + ruta /collections) | ✅ | Media |
| RPG-05 | Drops sorpresa con rareza (integrado en invocación) | ✅ | Alta |
| GUILD-01 | Audio demo etiquetado (banner DEMO + NPC · DEMO) | ✅ | Crítica |
| GUILD-02 | Tipos de mesa (mentorship/event/training) + resonancia | ✅ | Media |
| GUILD-03 | Trofeos del gremio visibles en salón | ✅ | Media |
| GUILD-04 | Raid cooperativa semanal (weeklyRaidProvider + repos) | ✅ | Media |
| MIS-01 | UI de estados/recompensas en quest board | ✅ | Alta |
| MIS-02 | Misión diaria determinista (persistente) | ✅ | Media |
| MIS-03 | Evento semanal (weeklyEventProvider, semana ISO) | ✅ | Media |

## Fase E — Economía + Balance
| ID | Tarea | Estado | Prioridad |
|----|-------|--------|-----------|
| ECO-01 | Tienda rotativa diaria (OFERTAS DEL DÍA) | ✅ | Alta |
| ECO-02 | Oro real (Entrenamiento en shop) | ✅ | Alta |
| ECO-03 | Fragmentos canjeables (/fragments-exchange) | ✅ | Media |
| ECO-04 | Balance 6-12 meses (docs/economy.md) | ✅ | Media |
| MON-01/02 | Modal energía + recarga purchaseItem | ✅ | Alta |
| MON-03 | Revisar percepción (beta feedback) | ⬜ | Media |

## Fase F — Retención + Observabilidad
| ID | Tarea | Estado | Prioridad |
|----|-------|--------|-----------|
| OBS-01 | Logs de uso en api_request_logs (data layer) | ✅ | Crítica |
| OBS-02 | Analytics retención (servicio + eventos session/invoke/claim/purchase + migración) | ✅ | Crítica |
| OBS-03 | Push notifications (racha en peligro, misión diaria) | ⬜ | Alta |
| LIVE-01 | Streak freeze (comprable 30 gemas) | ✅ | Alta |
| LIVE-02 | Banner racha en riesgo en dashboard | ✅ | Media |
| LIVE-03 | Leaderboard semanal (/leaderboard vía RPC get_leaderboard, RLS segura) | ✅ | Media |

## Fase G — QA + Accesibilidad + Performance
| ID | Tarea | Estado | Prioridad |
|----|-------|--------|-----------|
| QA-01..03 | Tests economía/misiones/conversación (13→70 tests) | ✅ | Alta |
| QA-04 | Golden tests (glass_card, segmented_bar, chips) | ✅ | Media |
| QA-05 | CI workflow (.github/workflows/ci.yml: analyze+test+summary) | ✅ | Alta |
| A11Y-01 | Semántica/contraste battle_pass | ✅ | Media |
| A11Y-02 | Contraste global (textos legibles subidos a alpha≥0.6; decoración exenta) | ✅ | Media |
| A11Y-03 | Semantics en GlassCard/RunicButton | ✅ | Media |
| A11Y-04 | reduce-motion global (AppMotion.of/scaled) | ✅ | Media |
| A11Y-05 | Hit-areas ≥48px (57 ampliados en nav/idiomas/quiz/botones CTA) | ✅ | Media/Baja |
| PERF-02 | Índices FK (21) — aplicado, 0 missing index | ✅ | Media |
| PERF-03 | Índices hot-path (16, 12 aplicados) | ✅ | Media |
| PERF-04 | Script drop 5 índices duplicados (para SQL Editor) | ✅ | Baja |
| REF-04 | Interfaz abstracta MissionRepository | ✅ | Media |

## Fase H — Beta Cerrada
| ID | Tarea | Estado | Prioridad |
|----|-------|--------|-----------|
| BETA-01 | Build firmado + TestFlight/Play internal | ⬜ | Crítica |
| BETA-02 | Feedback in-app | ⬜ | Alta |

## Épica DS-S — Estandarización Global del Design System
> Fuente: prompt "ESTANDARIZACIÓN GLOBAL DEL DESIGN SYSTEM" (2026-07-31).
> Objetivo: TODA la app con identidad única RPG/Cyberpunk desde `PlantillaHtml/`. No es "cambiar colores", es hacer cumplir el DS como regla.
> Auditoría base: 654 `Colors.*` directos · 8+ opacidades GlassCard · 118 botones Material · 12 radios distintos · tokens existen (AppColors/Spacing/Radius/Elevation/Typography) pero no se aplican.
| ID | Tarea | Estado | Prioridad |
|----|-------|--------|-----------|
| DS-S00 | Extraer Design Tokens oficiales de PlantillaHtml → confirmar/ajustar AppColors, AppSpacing, AppRadius, AppElevation, AppTypography, AppMotion | ✅ | **Crítica** |
| DS-S01 | Crear token de superficie: AppColors.surface + AppColors.surfaceAlt (una única opacidad/glass estándar) y migrar GlassCard para usarlo | ✅ | **Crítica** |
| DS-S02 | **Tarjetas**: unificar TODAS las tarjetas a GlassCard con opacidad/borde/glow/radio estándar; eliminar fondos azul/turquesa heredados | ✅ | **Crítica** |
| DS-S03 | **Botones**: unificados por ThemeData (radio 4px, jetBrainsMono, padding estándar); 0 shapes custom; RunicButton como primario | ✅ | **Crítica** |
| DS-S04 | **Radios**: migrar los 12 valores (2..30px) a AppRadius; radio 4px estándar, >20px solo avatares/orbes | ✅ | Alta |
| DS-S05 | **Tipografía**: 0 `TextStyle` con tamaños/pesos arbitrarios en pantallas; usar AppTypography wrapper + GoogleFonts | ✅ | Alta |
| DS-S06 | **Iconografía**: 0 iconos no-Material (376 Material Icons consistentes) | ✅ | Alta |
| DS-S07 | **Menús**: bottom nav custom (GlassCard+tokens) + theme de navegación unificado | ✅ | Alta |
| DS-S08 | **Gráficas**: CustomPaint de dashboard/profile/session usan AppColors (0 colores heredados) | ✅ | Media |
| DS-S09 | **Diálogos/BottomSheets**: theme de diálogo/snackbar unificado (radio 4px, runeViolet) + SystemWindow | ✅ | Media |
| DS-S10 | **Reutilización**: detectar/fusionar componentes duplicados; crear widgets reutilizables (StatTile ✓); eliminar variantes | ✅ | Media |
| DS-S11 | Migrar pantallas con >50 `Colors.*`: dashboard_screen (127), conversation_screen (87), settings_screen (80) | ✅ | **Crítica** |
| DS-S12 | Migrar resto de pantallas y widgets (chat_rooms, voice_room, profile, onboarding, shop, level_exam, core widgets, etc.) | ✅ | Alta |
| DS-S13 | **Meta verificable**: `grep "(?<!App)Colors\.(white|blue|teal|cyan|grey|red|green|amber|purple|black)"` en features = 0 (solo AppColors/tokens) | ✅ | **Crítica** |
| DS-S14 | Documento final `DESIGN_SYSTEM_STANDARDIZATION.md` (11 secciones del prompt) | ✅ | Alta |

## Fase I — Beta Pública / Fase J — Producción
| ID | Tarea | Estado | Prioridad |
|----|-------|--------|-----------|
| PROD-01..03 | Release optimizado, backup, términos/privacidad | ⬜ | Alta |

## Épica ONB — Onboarding Revamp (2026-07-31)
| ID | Tarea | Estado |
|----|-------|--------|
| ONB-01 | Análisis + documentación (7 docs en docs/Onboarding_Revamp/) | ✅ |
| ONB-02 | Separar onboarding en 5 pasos (idioma/país/objetivo/clasificación/personaje) | ✅ |
| ONB-03 | Evaluador IA (placement_ai.dart) + mapeo CEFR↔rango (cefr_rank.dart) | ✅ |
| ONB-04 | Oráculo por IA + persistencia detallada + devolución de resultado al flujo | ✅ |
| ONB-05 | Personaje RPG moderno (rúnico + glow + RunicButton) | ✅ |
| ONB-06 | Notificaciones elegantes (SystemSnack + 28 SnackBars migrados) | ✅ |
| ONB-07 | Migración SQL (game_rank, placement_scores/strengths/weaknesses/explanation) | ⬜ (aplicar en SQL Editor) |

## Métricas
- **Fase A**: 7/8 + 1 crítica nueva (SEC-IDOR) pendiente
- **Fase B**: 8/8 ✅
- **Fase C**: 8/8 ✅ (REF-01..05 + UX-01..05) — refactor y UX completos
- **Fase D**: 12/12 ✅
- **Fase E**: 7/8 (MON-03 pendiente)
- **Fase F**: 5/7 (OBS-03, LIVE-03 pendientes)
- **Fase G**: 8/10 (A11Y-02/05, QA-04 pendientes)
- **Épica DS-S**: 15/15 ✅ — estandarización global del Design System COMPLETADA (654 Colors.*→0, radios→AppRadius, tipografía→AppTypography, botones/menús/diálogos unificados, StatTile reutilizable, documento final)
- **Épica ONB**: 7/7 ✅ — Onboarding Revamp completado (5 pasos, IA placement, personaje RPG, SystemSnack; pendiente aplicar migración SQL)
- **Épica OBS-AUDIT**: 6/6 ✅ — Estabilización onboarding (Oráculo por voz via VoiceService, héroe post-onboarding, progreso centralizado ProgressUtils, avatar responsive, 8 docs de auditoría; diagnóstico IA pendiente de captura)
- **Épica NAV**: 5/5 ✅ — Auditoría forense del flujo de inicio (Splash + NavigationDecisionEngine + redirect centralizado GoRouter + Welcome simplificado + 5 docs; fix causa raíz: sesión sin perfil ya redirige a onboarding)
- **Épica ONB-REDESIGN**: 6/6 ✅ — Rediseño estratégico del onboarding (i18n completo con 10 claves ARB en 3 idiomas, país único ISO, prompt Oráculo 10 dimensiones, persistencia avatarIndex+clase, migración SQL; 9 docs de auditoría; avatares Stitch pendientes de assets)
- **Épica I18N**: 9/9 ✅ — Sistema i18n profesional COMPLETO (followDeviceLanguage, detección dispositivo, effectiveUiLanguage reactivo, sección LANGUAGE en Settings, sync Supabase, +60 claves ARB en 3 idiomas, ~59 hardcoded migrados en 20 archivos, migración SQL aplicada)
- **Épica ONB-SIMPL**: 9/9 ✅ — Simplificación del onboarding post-i18n (eliminado switch idioma de interfaz + ruta huérfana /oracle-quiz + persistencia forzada uiLanguage; flujo 5 pasos limpio; 9 docs en docs/Onboarding-Simplification/)
- **Fases H-J**: pendientes (requieren tu decisión)
- **Build**: 0 errores analyze · 73/73 tests · APK debug OK
- **DB live**: 5 migraciones + fix LIVE-03 aplicados · 0 missing index · SEC-IDOR resuelto
