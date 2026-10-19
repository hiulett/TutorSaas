# Reporte Final — Economía del Juego y Estrategia de Monetización

**Proyecto:** TutorSaas / Dungeon of English
**Fecha:** 2026-08-06
**Fuentes:** Código (`lib/features/economy/`, `conversation`, `missions`, `subscription`), BD Supabase (proyecto `sipiumfdpvnszthykyog`), docs existentes (`docs/06_Economy/`, `docs/08_AI/Monetization.md`, `docs/11_QA`).

---

## 1. Resumen ejecutivo

La app tiene un **sistema económico completo y desacoplado** (monedas, energía, inventario, tienda, rachas, battle pass, misiones, loot) sobre el que se apoya una **monetización por suscripción** (4 planes) más **microtransacciones de energía**. El núcleo es sólido, pero hay **incoherencias de datos**, **items sin efecto**, y **flujos de conversión sin pulir** que limitan la monetización.

**Veredicto:** economía ~80% funcional; monetización bien fundada pero con 3 correcciones de datos y 2 flujos de conversión pendientes.

---

## 2. Las monedas y recursos — qué es cada cosa y para qué sirve

### 2.1 Gemas (cristales) 💎 — moneda premium
| | |
|---|---|
| Almacenamiento | `user_language_profiles.total_gems` |
| Cómo se ganan | Recompensa diaria (5/50/100/300 por racha), loot, compras de gemas |
| Cómo se gastan | Tienda (`cosmetic_catalog`), freezes de racha (30), entrenamientos de la tienda |
| Rol | **Moneda de pago/valor**: cosméticos, títulos, marcos, auras, mascotas, temas |

### 2.2 Oro 🪙 — moneda de recompensa
| | |
|---|---|
| Almacenamiento | `user_language_profiles.total_gold` (default 100) |
| Cómo se gana | Misiones, recompensas de juego |
| Cómo se gasta | Entrenamientos de la tienda (`entrenamiento_fluidez` 100, `entrenamiento_elite` 250) → +5/+15 invocaciones |
| Rol | **Moneda de progreso**: recargas de energía del núcleo arcano |

### 2.3 Núcleo Arcano (invocaciones / energía) 🔮 — límite diario de IA
| | |
|---|---|
| Almacenamiento | `player_daily_state.invocations_used/max` |
| Base diaria | **20 invocaciones** +5 por cada 7 días de racha |
| Consumo | Cada conversación con IA (STT/LLM/TTS) consume 1 |
| Recarga | `consumible_invocacion5` (+5), `consumible_invocacion20` (+20), entrenamientos |
| Rol | **Gate de uso IA** diario — protege costos del servidor |

### 2.4 Pergaminos 📜 — repaso de vocabulario (SRS)
| | |
|---|---|
| Almacenamiento | `player_pergaminos` + `player_daily_state.pergaminos_used/max` (base 5/día) |
| Cómo se ganan | Recompensa diaria (2/5/8/15 por racha), consumible `consumible_pergamino10/50` |
| Cómo se usan | Repaso de vocabulario aprendido (SRS) vía `SrsFlashcardModal` |
| Rol | **Herramienta de retención** (repaso espaciado de palabras) |

### 2.5 Fragmentos ✨ — moneda de contenido
| | |
|---|---|
| Almacenamiento | `user_language_profiles.fragments` |
| Cómo se ganan | Fin de sesión IA (5+bonus por meta) |
| Cómo se gastan | Canje (títulos/colecciones) |
| Rol | **Moneda secundaria de contenido** (colecciones del cazador) |

### 2.6 Items del inventario 🎒
`player_inventory` + `cosmetic_catalog` (37 items). Tipos: `title`, `skin`, `frame`, `aura`, `pet`, `emote`, `theme`, `table_theme`, `guild_decoration`, `relic`, `consumable`, `key`, `book`, `mission_modifier`.

### 2.7 Racha 🔥 y Streak Freezes
| | |
|---|---|
| Racha | `player_streaks.current_streak/longest_streak`; 1 día consecutivo = +1, >1 día = consume freeze o resetea |
| Streak Freeze | Compra 30 gemas; protege la racha al fallar 1 día |
| Recompensa diaria escalonada | <7d: 5💎+2📜 · ≥7d: 50💎+5📜 · ≥14d: 100💎+8📜 · ≥30d: 300💎+15📜 |
| Rol | **Retención** (D1, D7, D14, D30) |

### 2.8 Battle Pass del Gremio 🏰
`guild_battle_pass` (temporada `season_2026_02`): 1000 XP por nivel, recompensas por tier, `is_premium`. Vinculado a planes premium.

### 2.9 Loot (drops) 🎲
`drop_loot.dart`: XP base 15, rarezas con peso (común 65%, raro 25%, épico 8%, legendario 2%) → XP 15/23/30/45. Rolas al completar lecciones.

---

## 3. Todos los premios exactos (valores del código)

### Recompensa diaria por racha (`claimDailyReward`)
| Racha | 💎 Gemas | 📜 Pergaminos |
|---|---|---|
| < 7 días | 5 | 2 |
| ≥ 7 días | 50 | 5 |
| ≥ 14 días | 100 | 8 |
| ≥ 30 días | 300 | 15 |

### Fin de sesión IA (`endSession`)
- Fragmentos: `metas_completadas × (5 + bonus_nivel)`, bonus: A1=0, A2=1, B1=2, B2=3, C1=4, C2=5.
- Gemas: `metas_completadas × (2 + bonus_nivel)`.
- **Bonus de stats RPG** (nuevo): puntos STR/INT/DEX/LUK sobre base 5 → +XP real por meta.

### Loot por lección
| Rareza | Peso | XP |
|---|---|---|
| Común | 65% | 15 |
| Raro | 25% | 23 |
| Épico | 8% | 30 |
| Legendario | 2% | 45 |

### Tienda (precios en gemas, ajustados T-507)
| Item | Precio | Efecto |
|---|---|---|
| `consumible_invocacion5` | 40 | +5 invocaciones |
| `consumible_invocacion20` | 150 | +20 invocaciones |
| `consumible_pergamino10` | 80 | +10 pergaminos |
| `consumible_pergamino50` | 300 | +50 pergaminos |
| `title_eloquente` | 450 | Título |
| `title_cazador_sombras` | 750 | Título |
| `title_leyenda_viva` | 1800 | Título |
| `frame_escudo` | 550 | Marco |
| `frame_dragón` | 1100 | Marco |
| `aura_mana/fuego/sombras` | 750/1400/2300 | Aura |
| `pet_lunático/fénix` | 1400/2300 | Mascota |
| `theme_mesa_bosque/abismo` | 1800/2800 | Tema de mesa |
| `mod_recompensa_x2` | 120 | Modificador |
| `key_mazmorra_oculta` | 150 | Llave |
| `skin_cazador/arcano` | 800/1600 | Skin |

### Entrenamientos (oro)
| Item | Precio (oro) | Efecto |
|---|---|---|
| `entrenamiento_fluidez` | 100 | +5 invocaciones |
| `entrenamiento_elite` | 250 | +15 invocaciones |

---

## 4. Estrategia de monetización

### 4.1 Modelo principal: suscripción (4 planes en BD, verificados live)
| Plan | Precio | Audio IA/mes | Diferenciador |
|---|---|---|---|
| Free | $0.00 | 30 min | 5 conv/día, corrección básica, mapa, 1 boss/semana, historial 7d |
| Monthly | $1.99 | 300 min | IA ilimitada, gramática avanzada, Speech DNA, Blind Listening, Battle Pass |
| Annual | $14.99 | 1200 min | Todo monthly + 1200 min, títulos/cosméticos exclusivos, soporte |
| Lifetime | $29.99 | 1200 min | Todo annual + por vida, cosméticos futuros, expansiones, prioridad |

### 4.2 Capas de monetización (multi-skin)
1. **Suscripción** (ingreso principal): 4 planes + paywall dinámico en onboarding.
2. **Microtransacciones de energía** (gemas → invocaciones): tienda.
3. **Gemas premium** (compra futura sugerida en MO-06).
4. **Battle Pass** (gancho de upgrade: free niveles 1-5 → premium).

### 4.3 Flujo de conversión objetivo
```
Free (30 min/mes + 20 núcleos/día)
  ↓ modal "NÚCLEO AGOTADO" → "RECARGAR" (gemas) | "IR PREMIUM"
  ↓ fin de sesión exitosa → paywall suave "CONVIÉRTETE EN PREMIUM"
  ↓ Battle Pass free (niveles 1-5) → upgrade premium
Monthly $1.99 → Annual $14.99 (ahorra 37%) → Lifetime $29.99
```

### 4.4 Anclas de retención (vinculadas a monetización)
- Racha diaria + recompensa escalonada (D1/D7/D14/D30).
- Streak freezes (30 gemas) como gasto de emergencia.
- Repaso SRS con pergaminos (diario).
- Battle Pass por temporada.

---

## 5. Problemas encontrados

### 🔴 Críticos
| ID | Problema | Detalle |
|---|---|---|
| E-01 | **`consumible_pergamino10/50` sin efecto** | `purchaseItem` cobra gemas pero NO genera pergaminos (solo maneja invocaciones) |
| E-02 | **`get_leaderboard` RPC con permiso denegado** para el rol anónimo/autenticado en el tab Estado | Devuelve datos falsos o vacío |
| E-03 | **`equipped_title_code` leído del progress pero guardado en `users`** | Inconsistencia de fuente (nuevo cambio) |

### 🟡 Altos
| ID | Problema | Impacto |
|---|---|---|
| E-04 | **Oro con poca lógica**: solo 2 entrenamientos lo gastan; default 100 sin fuente clara | Recurso infrautilizado |
| E-05 | **Fragmentos sin flujo de gasto claro** en UI | Moneda secundaria huérfana |
| E-06 | **Freezes de racha sin UI de compra** visible | Monetización oculta |
| E-07 | **Battle Pass sin pantalla de recompensas detallada** (solo niveles) | Menos incentivo premium |
| E-08 | **`generateDailyPergaminos` crea contenido placeholder** (no real) | Repaso sin valor pedagógico |
| E-09 | **Núcleo agotado sin CTA de recarga/premium** (MO-C/D pendientes) | Conversión perdida |
| E-10 | **Doble límite IA** (núcleo diario + minutos mensuales) confunde al free | Fricción de UX |

### 🟢 Bajos
| ID | Problema |
|---|---|
| E-11 | Recompensa diaria escalonada: pasar `Future` como valor (bug menor históricamente documentado) |
| E-12 | `title_novato`/`title_imparable`/reliquias con precio 0 en catálogo (¿gratis?) |
| E-13 | Loot solo visual en lecciones, sin integración con inventario |

---

## 6. Recomendaciones priorizadas

| # | Recomendación | Prioridad | Tipo |
|---|---|---|---|
| 1 | **Arreglar `consumible_pergamino10/50`** para que genere pergaminos reales | P0 | Bug de monetización |
| 2 | **Corregir permisos RLS de `get_leaderboard`** | P0 | Bug de datos |
| 3 | **Unificar `equipped_title_code`** (leer de `users` en todos lados) | P0 | Bug |
| 4 | **Modal de energía agotada** con "RECARGAR"/"IR PREMIUM" (MO-C) | P1 | Conversión |
| 5 | **Conectar recarga de invocaciones** con el modal (MO-D) | P1 | Conversión |
| 6 | **Diseñar gasto de fragmentos** (colecciones/reliquias) | P1 | Profundidad |
| 7 | **Generar pergaminos de contenido real** (diálogo del escenario) | P1 | Valor pedagógico |
| 8 | **Añadir paquete de gemas** como compra (MO-06) | P2 | Ingreso |
| 9 | **Battle Pass premium separado por temporada** (MO-07) | P2 | Ingreso recurrente |

---

## 7. Conclusión

La economía del juego es **completa en estructura** (9 sistemas de recursos interconectados: gemas, oro, núcleo, pergaminos, fragmentos, inventario, racha, battle pass, loot) y la monetización tiene **una base sólida** (4 planes + microtransacciones + retención escalonada). 

**Para maximizar ingresos y consistencia:**
1. Corregir los 3 bugs críticos (pergaminos sin efecto, leaderboard, título).
2. Pulir los 2 flujos de conversión (energía agotada + paywall suave).
3. Dar propósito a las monedas secundarias (oro/fragmentos) para que cada premio "valga algo" de forma visible.

**Estado global:** economía ~80% · monetización ~70% (falta pulir el flujo de conversión y 2 incoherencias de datos ya documentadas en `08_AI/Monetization.md`).
