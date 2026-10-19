# Auditoría de Experiencia Visual — Dungeon of English

> **Documento:** Julio 2026  
> **Propósito:** Convertir la aplicación en una experiencia viva con microinteracciones, feedback visual y sensorial coherente con la temática Isekai System HUD

---

## PARTE 1 — Auditoría Completa por Pantalla

### 1.1 Welcome Screen

| Aspecto | Estado | Problema | Solución |
|---|---|---|---|
| Logo animado | ❌ Ausente | Marca estática, sin personalidad | Logo con glow pulsante + partículas flotantes de maná |
| Botones | ✅ Presentes | Sin feedback hover/tap | Scale 0.97 en tap, glow en hover |
| Fondo | ⚠ Genérico | Orbes de luz genéricos | Partículas flotantes tipo "maná en el aire" |
| Transición a login | ❌ Ausente | Cambio instantáneo | Fade + slide sutiles |

### 1.2 Onboarding / Character Creation

| Aspecto | Estado | Solución |
|---|---|---|
| Selección de clase | ⚠ Estático | Cards con glow pulsante en hover, icono animado por clase |
| Input de nombre | ✅ Funcional | Correcto, mantener simple |
| Transición al Oráculo | ❌ Sin efecto | Portal de entrada: fade a negro con partículas, luego aparece el Oráculo |
| Avatar selector | ⚠ Simple | Pequeña rotación 3D al seleccionar, glow en el elegido |

### 1.3 Oracle Test Screen

| Aspecto | Estado | Solución |
|---|---|---|
| Burbuja del Oráculo | ✅ GlassCard con runic corners | Correcto — añadir leve floating idle animation |
| Input de respuesta | ✅ Funcional | Correcto |
| Progress bar | ⚠ Barra simple | Convertir en "Cristales que se llenan" — 5 cristales, uno se ilumina por pregunta |
| Resultado (nivel) | ⚠ Círculo estático | Animación de "revelación": el nivel aparece con partículas y glow expansivo |
| Transición a cazador | ❌ Sin efecto | Slow fade con partículas doradas |

### 1.4 Conversation Screen

| Aspecto | Estado | Solución |
|---|---|---|
| Llegada de mensajes | ❌ Sin animación | Slide up + fade (300ms, ease-out) para cada mensaje |
| Burbuja del tutor | ⚠ GlassCard | Añadir glow leve en el borde cuando el tutor "está escribiendo" |
| Burbuja del usuario | ✅ | Correcta |
| Waveform visualizer | ✅ Bueno | Mantener, es uno de los mejores elementos visuales |
| Mic button (mana orb) | ✅ Implementado | Correcto — el diseño de orbe pulsante funciona |
| Indicador de procesando | ✅ | Correcto |
| NPC DraggableMonster | ⚠ Separado | Añadir reacción: cuando el usuario habla, el monstruo "mira" hacia el mensaje |
| Goals tracker | ⚠ Pequeño | Agregar micro-celebración visual cuando una meta se completa (✓ + glow verde + partícula) |
| Corrección gramatical | ⚠ Texto plano | Añadir glow naranja suave en el panel de corrección |

### 1.5 Guild Hall (Chat Rooms)

| Aspecto | Estado | Solución |
|---|---|---|
| NPC Maestro del Gremio | ✅ Card estática | Añadir breathing animation (scale 1.0↔1.02), leve floating |
| Cards de mesa | ⚠ Estáticas | Glow en hover, leve scale, indicador "en vivo" pulsante |
| Stats cards (XP, vocabulario) | ⚠ Números fríos | Contadores animados que suben al valor real (500ms ease-out) |
| Misión diaria bar | ⚠ Barra estática | La barra de progreso debe animarse al completarse |
| Categorías | ✅ | Correcto |
| Transición a sala de voz | ❌ Sin efecto | Efecto "portal" al entrar: brief flash cyan |

### 1.6 Voice Room Screen

| Aspecto | Estado | Solución |
|---|---|---|
| Grid de oradores | ⚠ Tarjetas estáticas | Cuando alguien habla, su card debe tener glow + leve scale + borde animado |
| Moderador IA | ✅ | Correcto — gold glow |
| Tips rotativos | ✅ AnimatedSwitcher | Correcto |
| Audience strip | ⚠ Avatares genéricos | Indicador de "oyente" con latido suave |
| Chat sheet | ⚠ Container simple | Añadir glass efect, scroll suave |

### 1.6 Dashboard / Home

| Aspecto | Estado | Solución |
|---|---|---|
| Urgent quest card | ✅ | Correcto |
| Bottom nav | ⚠ Iconos estáticos | Añadir micro bounce al seleccionar tab |
| Progress tab stats | ⚠ Números fríos | Contadores animados |
| Radar chart | ✅ fl_chart | Correcto |
| Heatmap | ✅ | Correcto |
| Tab transitions | ❌ Sin efecto | AnimatedSwitcher con fade |

### 1.7 Hunter Status Screen

| Aspecto | Estado | Solución |
|---|---|---|
| Avatar con rank | ✅ | Correcto |
| Segmented bars | ✅ | Correcto |
| Atributos | ⚠ Barras estáticas | Animar al aparecer (cascade: cada barra aparece con 100ms de delay) |
| Radar chart | ✅ | Correcto |
| Achievements carrusel | ⚠ Items estáticos | Glow en los desbloqueados, los locked con leve opacidad |
| Títulos equipables | ⚠ Botones planos | Efecto de "equipar" con glow y partículas breves |

### 1.8 Paywall Screen

| Aspecto | Estado | Solución |
|---|---|---|
| Plan cards | ⚠ Estáticas | Glow en seleccionado, hover en no seleccionado |
| Features list | ✅ | Correcto |
| CTA button | ⚠ | Añadir pulse suave en el botón principal |

---

## PARTE 2 — Microinteracciones (Catálogo Completo)

### Sistema de Progresión

| Evento | Animación | Duración | Sonido | Efecto HUD |
|---|---|---|---|---|
| **Ganar XP** | Contador numérico que sube + floating text "+50 XP" que se desvanece hacia arriba | 600ms ease-out | ✅ Chime ascendente breve | Texto flotante dorado |
| **Subir de nivel** | Scale del badge de nivel (1→1.2→1) + glow expansivo + partículas doradas | 1200ms | ✅ Fanfarria corta | Banner "LEVEL UP!" con duración 2s, auto-dismiss |
| **Completar misión** | Check verde animado (draw path) + card con glow + confeti sutil | 800ms | ✅ Logro completado | Toast tipo "Misión Completada" + botón "Reclamar" |
| **Racha diaria** | Fuego animado (partículas naranjas) alrededor del contador + texto "🔥 Día 7!" | 400ms | ✅ Fuego crepitar suave | Indicador en streak bar |
| **Nuevo logro** | Icono del logro emerge con scale + glow + partículas del color del logro | 1000ms | ✅ Logro especial | Banner pequeño que se desvanece (3s) |
| **Desbloquear título** | Pergamino que se despliega visualmente + texto del título con glow | 800ms | ✅ Pergamino | Notificación flotante |

### Sistema de Recompensas

| Evento | Animación | Duración |
|---|---|---|
| **Abrir cofre** | Tapa se abre (scale Y), glow dorado, items emergen uno a uno | 1000ms |
| **Obtener oro** | Monedas giran y caen al contador con sonido de monedas | 500ms |
| **Obtener gema** | Cristal aparece con sparkle + el contador de gems se actualiza | 400ms |
| **Obtener item cosmético** | Item emerge con glow + se muestra en vista previa 3D simple | 800ms |
| **Comprar en tienda** | Brief flash verde + check + item aparece en inventario | 300ms |

### Sistema Social (Gremio)

| Evento | Animación | Duración |
|---|---|---|
| **Alguien se une a la mesa** | Breve glow en su slot + notificación sutil | 300ms |
| **Alguien habla** | Ola de glow en su card + borde pulsante | 200ms (mientras habla) |
| **Alguien levanta la mano** | Icono ✋ con bounce + glow amarillo en su slot | 400ms |
| **Nuevo mensaje en chat** | Slide left + fade | 200ms |
| **Moderador asigna turno** | Flecha animada hacia el slot asignado | 500ms |
| **Completar misión colaborativa** | Barra de progreso del gremio se llena con glow + cofre aparece | 1500ms |

### Sistema de IA

| Evento | Animación | Duración |
|---|---|---|
| **IA está procesando** | Ondas suaves en el avatar del tutor (tipo radar pulse) | Mientras procesa |
| **IA terminó de hablar** | Brief glow verde en la burbuja | 200ms |
| **Invocación usada** | Cristal de maná se oscurece ligeramente + contador baja | 200ms |
| **Sin invocaciones** | Cristal se vuelve gris con leve shake | 400ms |
| **Recargar invocaciones** | Cristal se ilumina de abajo a arriba con glow | 600ms |

---

## PARTE 3 — Sistema de Notificaciones

### Taxonomía de Notificaciones

```
JERARQUÍA DE NOTIFICACIONES
(Urgencia ↓, Frecuencia ↑)

🔴 CRÍTICAS (raro, importante)
   • Error de conexión → Modal del sistema con runas rojas
   • Sin invocaciones → Pantalla Núcleo Arcano (ya implementada)

🟠 IMPORTANTES (ocasional)
   • Logro desbloqueado → Banner horizontal + glow, auto-dismiss 3s
   • Subir de nivel → Banner con partículas, auto-dismiss 3s
   • Misión completada → Toast con botón "Reclamar"

🟡 INFORMATIVAS (frecuente)
   • XP ganado → Floating text " +50 XP " se desvanece hacia arriba
   • Item obtenido → Mini toast con icono, 1.5s
   • Meta completada → Check verde + glow, 1s

🟢 SUTILES (constante)
   • Conectado a sala → Indicador verde en slot
   • IA procesando → Onda en avatar
   • Nuevo mensaje → Leve notificación en chat
```

### Estilos Visuales por Tipo

| Tipo | Estilo | Posición | Duración |
|---|---|---|---|
| **Floating Text** | Texto que emerge y flota hacia arriba + fade out | Sobre el elemento relevante | 1200ms |
| **Toast RPG** | GlassCard con icono + texto, sin botones | Top-center (debajo del HUD) | 2000ms |
| **Banner** | GlassCard ancho con glow, aparece desde arriba | Top (cubre HUD levemente) | 3000ms |
| **Partículas** | Sin texto, solo efecto visual | Donde ocurrió la acción | 600-1000ms |
| **HUD Pulse** | Glow breve en el elemento del HUD relevante | En el HUD | 400ms |
| **Panel Lateral** | Se desliza desde la derecha, semi-transparente | Right edge | 3000ms o hasta dismiss |

### Lo que NUNCA debe usarse

| ❌ Evitar | Razón |
|---|---|
| AlertDialog tradicional | Rompe inmersión completamente |
| SnackBar de Material | Se ve como app genérica |
| BottomSheet que interrumpe | Bloquea la conversación |
| Popup que requiere tap para cerrar | Fricción innecesaria |
| Overlay ocupando >30% de la pantalla | Oculta contenido importante |

---

## PARTE 4 — Sistema HUD

### Información Siempre Visible

| Elemento | Pantalla | Formato |
|---|---|---|
| Maná (invocaciones restantes) | Todas | Barra segmentada delgada (4px) arriba |
| Racha actual | Dashboard, Guild | Indicador 🔥 + número |
| Nivel / Rango CEFR | Dashboard, Status | Badge pequeño |
| Conexión a IA | Conversation | Indicador verde en el header |

### Información que Aparece Solo al Cambiar

| Elemento | Trigger | Animación | Auto-dismiss |
|---|---|---|---|
| "+50 XP" | Al ganar XP | Floating text | 1.2s |
| "Misión Completada" | Al cumplir objetivos | Banner | 3s |
| "Subiste a B2" | Al avanzar CEFR | Banner + partículas | 4s |
| "Item obtenido" | Al recibir loot | Toast | 2s |
| Error de conexión | Al fallar API | Modal runas | Hasta dismiss |

### Información que Nunca Debe Animarse

| Elemento | Razón |
|---|---|
| Texto de la conversación | La lectura no debe distraerse |
| Botones de acción principales | Deben ser predecibles |
| Input fields | El usuario escribe, no necesita animación |
| Mensajes de error de API | Mostrar inmediatamente |

---

## PARTE 5 — Sistema de Animaciones

### Curvas y Timing

| Tipo | Curva | Duración | Uso |
|---|---|---|---|
| **Entrada** | `easeOutCubic` | 200-300ms | Mensajes, cards, paneles |
| **Salida** | `easeInCubic` | 150-200ms | Dismiss, cerrar |
| **Feedback** | `easeOutBack` | 300ms | Logros, checkmarks |
| **Glow/Pulse** | `sine` | 1000-2000ms loop | Indicadores "en vivo" |
| **Transición** | `easeInOutCubic` | 300-400ms | Cambio de pantallas |
| **Partículas** | `linear` | 600-1000ms | Efectos de recompensa |

### Animaciones por Componente

| Componente | Animación | Timing |
|---|---|---|
| **Botón (tap)** | Scale 1.0 → 0.95 → 1.0 | 150ms |
| **Card (tap)** | Scale 1.0 → 0.98 → 1.0 + glow leve | 200ms |
| **Mensaje nuevo** | Slide up 20px + fade in | 300ms easeOutCubic |
| **List item** | Fade in con stagger (50ms delay) | 200ms c/u |
| **Badge/Icon** | Scale bounce 1.0 → 1.2 → 1.0 | 400ms easeOutBack |
| **Modal bottom sheet** | Slide up 100% → final position | 350ms easeOutCubic |
| **Page transition** | Fade + scale 0.98→1.0 | 300ms easeInOutCubic |
| **Progress bar fill** | Width 0 → target | 500ms easeOutCubic |
| **Counter** | Animar número | 500-800ms según magnitud |
| **Notification toast** | Slide in from top + fade out | 200ms in, display 2s, 300ms out |

---

## PARTE 6 — Efectos Visuales

### Catálogo de Efectos

| Efecto | Dónde | Intensidad | Coste rendimiento |
|---|---|---|---|
| **Glow (cyan)** | Bordes de glasscard, burbujas activas, selección | Baja | Mínimo |
| **Glow (dorado)** | Logros, niveles, items legendarios | Media | Mínimo |
| **Partículas de maná** | Fondo del onboarding, transiciones | Baja | Medio |
| **Sparkle** | Al obtener item, al completar misión | Breve (300ms) | Bajo |
| **Onda expansiva** | Al subir de nivel, al desbloquear logro | 600ms, única | Medio |
| **Scanline** | Fondo sutil del System HUD | Opacidad 0.05 | Mínimo |
| **Blur** | Fondos de modal, panels | Variable | Medio |
| **Runa giratoria** | NPC Oráculo, cargando IA | 15s loop | Mínimo (1 rotación) |
| **Floating** | NPC Maestro, Oráculo, mascotas | 2s loop, 5px | Mínimo |
| **Breathing** | Cards de personajes, slots de sala | 2s loop, scale 1.0↔1.03 | Mínimo |

### Dónde NO usar efectos

| ❌ Situación | Razón |
|---|---|
| Durante la transcripción de voz | El usuario necesita concentrarse en hablar |
| Mientras la IA está generando respuesta | No distraer del texto que aparece |
| En el campo de texto | Interfiere con la escritura |
| En botones de acción urgente (salir, enviar) | Deben ser inmediatos |
| Más de 2 efectos simultáneos | Saturación visual |

---

## PARTE 7 — Sonido (Efectos SFX)

### Catálogo de Sonidos

| Evento | Sonido | Prioridad |
|---|---|---|
| **Aceptar misión** | 📜 Pergamino desenrollándose | 🔴 Alta |
| **Completar misión** | ✨ Campanada ascendente + suspiro de alivio | 🔴 Alta |
| **Ganar XP** | 🔊 Chime corto ascendente | 🔴 Alta |
| **Subir de nivel** | 🎺 Fanfarria corta (1s) | 🔴 Alta |
| **Obtener logro** | 🏆 Tono especial de logro | 🟠 Media |
| **Click botón** | 🔘 Click suave (tipo mecánico) | 🟠 Media |
| **Abrir panel** | 🔓 Desbloqueo suave | 🟠 Media |
| **Cerrar panel** | 🔒 Cierre suave | 🟡 Baja |
| **Error** | ⚠️ Tono grave corto | 🔴 Alta |
| **Enviar mensaje** | 📤 Whoosh suave | 🟡 Baja |
| **Recibir mensaje** | 📩 Pop suave (no notificación molesta) | 🟡 Baja |
| **Iniciar grabación** | 🎙️ Click de inicio | 🟠 Media |
| **Detener grabación** | 🎙️ Click de fin | 🟠 Media |
| **Llegar al Guild** | 🏰 Apertura de puerta | 🟠 Media |
| **Abrir tienda** | 🛒 Sonido de monedas | 🟡 Baja |
| **Racha diaria** | 🔥 Fuego crepitante suave | 🟠 Media |
| **Invocación IA** | 🔮 Cristal resonando | 🟠 Media |
| **Sin invocaciones** | 🫗 Cristal vacío | 🟠 Media |

### Principios de Sonido

| Regla | Descripción |
|---|---|
| **1 sonido a la vez** | Nunca superponer efectos |
| **Volumen relativo** | 0.3 para clicks, 0.5 para recompensas, 0.7 para logros |
| **Silencio durante conversación** | No sonidos mientras el usuario habla o escucha TTS |
| **Prefire on-device** | Usar assets locales, no streaming |
| **Configurable** | El usuario debe poder desactivar SFX |

---

## PARTE 8 — Avatares y NPC

### Estado Actual y Mejoras

| NPC | Estado Actual | Mejora Propuesta |
|---|---|---|
| **🔮 Oráculo** (onboarding) | Solo texto en burbuja | Añadir icono 🔮 animado (floating + glow pulsante). Al "pensar", el icono gira lentamente |
| **🏰 Maestro del Gremio** (guild hall) | Card estática con emoji | Breathing animation + floating leve. Al saludar al usuario, un glow recorre el borde de la card |
| **👾 Monstruo NPC** (conversación) | DraggableMonsterWidget con animaciones | Ya tiene animaciones complejas (floating, breathing, speaking wave, rune rotation). Mantener. Mejorar: que mire hacia el último mensaje |
| **🎭 Oradores en sala** | Cards con iniciales | Mostrar emoji/icono según clase del jugador. Cuando hablan, el glow pulse debe coincidir con la voz |
| **🤖 Moderador IA** | Card con icono smart_toy | Correcto. El gold glow funciona bien |

### Comportamiento de Avatares

| Estado | Animación |
|---|---|
| **Idle** | Floating leve (2s loop, 5px Y) |
| **Escuchando** | Leve tilt hacia el orador activo |
| **Hablando** | Glow pulsante + breathing intensificado |
| **Pensando/Procesando** | Runa giratoria + shimmer |
| **Reaccionando** | Brief scale bounce cuando algo importante ocurre |
| **Inactivo** | Opacidad reducida al 70% |

---

## PARTE 9 — Personalización Visual (Catálogo de Cosméticos)

### Elementos con Alto Potencial Comercial

| Categoría | Elemento | Implementación | Precio sugerido |
|---|---|---|---|
| **🎨 Temas de HUD** | Esquemas de color del System HUD | Cambiar paleta de colores de la UI (cyan, violeta, dorado, rojo) | 1000-2000💎 |
| **🖼️ Fondos** | Backgrounds animados del System | Reemplazar fondo estático por animación (lluvia de maná, estrellas, runas) | 800-1500💎 |
| **💬 Burbujas** | Estilos de chat bubble | Borde diferente, glow color, runic corners más elaborados | 300-600💎 |
| **✨ Efectos de entrada** | Animación al llegar al Guild o a una sala | Partículas personalizadas (hojas, fuego, hielo, sombras) | 500-1200💎 |
| **🎵 Música ambiental** | Temas para el Guild Hall | Loop musical de fondo (jazz oscuro, épico, misterioso) | 300-800💎 |
| **👾 Mascotas** | Acompañantes visuales | Criatura que flota cerca del avatar (ya hay catálogo) | 800-2500💎 |
| **🛡️ Auras** | Efecto alrededor del avatar | Glow de color, partículas, electricidad, fuego | 500-1500💎 |
| **📜 Insignias** | Decoración del perfil | Iconos especiales visibles en el gremio | 200-500💎 |
| **🏰 Decoración de mesa** | Temas de mesa en el Guild | Fondo de mesa, borde, glow, emoji | 500-2000💎 |
| **🎭 Emotes** | Reacciones animadas en chat | GIFs ligeros estilo webtoon | 100-300💎 c/u |

### Elementos Libres (no monetizar)

| Elemento | Razón |
|---|---|
| Avatar base | Identidad del jugador, debe ser gratis |
| Marco de nivel | Indicador de progreso |
| Títulos de logro (los que se ganan) | Recompensa por esfuerzo |
| Efecto de XP | Feedback vital del sistema |
| Partículas de misión completada | Refuerzo positivo necesario |

---

## PARTE 10 — Elementos Innecesarios

### Lo que debe eliminarse o simplificarse

| Elemento | Pantalla | Problema | Acción |
|---|---|---|---|
| **Glow orbs decorativos** (Positioned con blur) | Múltiples pantallas | Ocupan recursos de GPU, apenas visibles en móvil. No añaden inmersión significativa | **Eliminar** o reducir a 1 por pantalla |
| **BackdropFilter** excesivo | Varias | El blur en tiempo real es costoso en GPU. Se abusa de él | **Reemplazar** por colores semi-sólidos con opacidad |
| **5 iconos en control row** | Conversation | Demasiadas opciones. El fingerprint y topics no se usan frecuentemente | **Reducir** a 3 principales (compass, mic, keyboard) + menú contextual |
| **Audience strip con iniciales** | Voice Room | Iniciales de UUID no aportan valor. Ocupan espacio | **Simplificar**: solo contar número "12 espectadores" |
| **Scanline overlay** | Global | Apenas perceptible en pantallas móviles pequeñas | **Eliminar** (costo de render sin beneficio) |
| **6 slot grid vacíos en sala** | Voice Room | 6 slots con "➕ Subir" ocupan mucho espacio cuando hay 1-2 personas | **Mostrar solo slots ocupados + 1 vacío** |
| **Animación de speaking simulada** (random) | Voice Room | Random boolean no refleja la realidad. Mejor mostrar basado en datos reales de audio | **Eliminar** speaking sim; solo mostrar estado real |
| **BackdropFilter en glow orbs** | Múltiples | `ImageFilter.blur` en Positioned circles es carísimo en GPU móvil | **Reemplazar** por BoxDecoration con gradient + alpha |
| **Títulos de sección redundantes** | Dashboard | "Salas Activas de Conversación" + botón "Crear" es obvio | **Simplificar** títulos |

### Optimizaciones de Rendimiento

| Optimización | Impacto |
|---|---|
| Reemplazar `BackdropFilter` por colores con alpha | -30% GPU |
| Eliminar glow orbs redundantes | -15% GPU |
| Usar `AnimatedBuilder` solo donde necesario | -10% CPU |
| Limitar partículas a máximo 20 por escena | -20% GPU |
| Preferir `Transform.scale` sobre `Container` animations | -5% CPU |

---

## PARTE 11 — Plan de Implementación Priorizado

### 🔴 Imprescindibles (Semana 1-2)

| # | Mejora | Pantallas | Complejidad | Tiempo | Impacto UX |
|---|---|---|---|---|---|
| 1 | **Animación de entrada de mensajes** (slide up + fade) | Conversation | Baja | 4h | 🔥 Alto |
| 2 | **Floating text "+XP"** al ganar experiencia | Dashboard, Conversation | Baja | 3h | 🔥 Alto |
| 3 | **Scale en botones al tap** (0.97) | Global | Muy baja | 2h | 🔥 Alto |
| 4 | **Contadores animados** (XP, nivel, stats) | Dashboard, Status | Media | 6h | 🟠 Medio |
| 5 | **Glow pulsante en NPC Maestro** | Guild Hall | Baja | 2h | 🟠 Medio |
| 6 | **Reemplazar BackdropFilter** por colores alpha | Múltiples | Media | 8h | 🟢 Bajo (rendimiento) |
| 7 | **Check animado en metas completadas** | Conversation, Guild | Baja | 3h | 🟠 Medio |
| 8 | **Cascade animation en atributos** (status) | Hunter Status | Baja | 3h | 🟠 Medio |

### 🟠 Muy Importantes (Semana 3-4)

| # | Mejora | Pantallas | Complejidad | Tiempo | Impacto |
|---|---|---|---|---|---|
| 9 | **Notificación tipo toast RPG** (reemplazar SnackBar) | Global | Media | 8h | 🔥 Alto |
| 10 | **Banner de logro/nivel** con partículas | Global | Media | 10h | 🔥 Alto |
| 11 | **Animación al completar misión** | Guild, Dashboard | Media | 8h | 🔥 Alto |
| 12 | **Efecto portal al entrar a sala** | Voice Room | Baja | 4h | 🟠 Medio |
| 13 | **Glow en hover de cards** | Guild, Paywall | Baja | 4h | 🟠 Medio |
| 14 | **Indicador de IA procesando** (runa giratoria) | Conversation | Baja | 3h | 🟠 Medio |
| 15 | **Partículas al obtener item/recompensa** | Global | Media | 8h | 🟠 Medio |

### 🟡 Deseables (Semana 5-6)

| # | Mejora | Complejidad | Tiempo |
|---|---|---|---|
| 16 | Breathing animation en NPCs | Baja | 4h |
| 17 | Animación de revelación de nivel (Oráculo) | Media | 6h |
| 18 | Page transition animadas (fade+scale) | Media | 6h |
| 19 | Cristales que se llenan (en vez de progress bar) | Media | 8h |
| 20 | SFX básicos (click, XP, logro) | Media | 10h |
| 21 | Slots de sala solo ocupados + 1 vacío | Baja | 3h |

### 🟢 Futuras Expansiones (Mes 2+)

| # | Mejora | Complejidad | Tiempo |
|---|---|---|---|
| 22 | Temas de HUD (cosméticos de UI) | Alta | 20h |
| 23 | Música ambiental por sala | Media | 10h |
| 24 | Efecto de entrada personalizado por usuario | Alta | 15h |
| 25 | Emotes animados en chat de gremio | Alta | 15h |
| 26 | Partículas de clase (Berserker=fuego, Mago=runa, Pícaro=sombras) | Media | 10h |
| 27 | Mascotas con animaciones idle | Alta | 20h |

---

## Resumen de Impacto

| Dimensión | Antes | Después (estimado) |
|---|---|---|
| Percepción de "app viva" | 20% | 80% |
| Feedback del sistema | 30% | 90% |
| Inmersión visual | 35% | 75% |
| Rendimiento (GPU) | 50% (con BackdropFilter) | 85% (optimizado) |
| Retención por delight visual | Bajo | 🔥 Alto |
| Competitividad visual vs juegos AAA | 10% | 40% (mejorable) |

### Regla de Oro

> *Cada animación debe responder a una acción del usuario. Nunca al revés.*  
> *Si no hay acción del usuario, no hay animación.*  
> *Si la animación no ayuda a entender el resultado de una acción, sobra.*
