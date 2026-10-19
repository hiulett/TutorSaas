# Reglas de negocio de desbloqueo (CEFR)

> **Ruta:** `Docs/Progression/CEFRProgressionRules.md`

---

## Principio
Si el usuario fue clasificado en un nivel N, **demostró dominar todos los niveles
anteriores**. Por tanto:

- **Niveles < N**: todas las lecciones **desbloqueadas** (marcadas como validadas por el Oráculo).
- **Nivel = N (actual)**: solo la **primera lección disponible**; el resto se desbloquea
  **secuencialmente** al completar la anterior.
- **Niveles > N**: todas **bloqueadas**.

## Tabla por nivel asignado

| Nivel asignado | A1 | A2 | B1 | B2 | C1 | C2 |
|---|---|---|---|---|---|---|
| **A1** | 1ª disponible, resto 🔒 | 🔒 | 🔒 | 🔒 | 🔒 | 🔒 |
| **A2** | ✅ todas | 1ª disponible, resto 🔒 | 🔒 | 🔒 | 🔒 | 🔒 |
| **B1** | ✅ todas | ✅ todas | 1ª disponible, resto 🔒 | 🔒 | 🔒 | 🔒 |
| **B2** | ✅ todas | ✅ todas | ✅ todas | 1ª disponible, resto 🔒 | 🔒 | 🔒 |
| **C1** | ✅ todas | ✅ todas | ✅ todas | ✅ todas | 1ª disponible, resto 🔒 | 🔒 |
| **C2** | ✅ todas | ✅ todas | ✅ todas | ✅ todas | ✅ todas | 1ª disponible, resto 🔒 |

## Progresión secuencial (dentro del nivel actual)
Una vez iniciado el nivel asignado:
```
Lección 1 ▶  →  Lección 2 ▶  →  Lección 3 ▶  →  ...
```
- No se desbloquean varias a la vez dentro del mismo nivel.
- Completar una lección (fila en `conversations`) desbloquea la siguiente.
- El desbloqueo por nivel se **recalcula en cada build** según el `level_code` actual.

## Reevaluación del Oráculo
Si el usuario sube de nivel (nueva evaluación), la ruta se **recalcula automáticamente**
porque la fuente es `userProgressProvider` (BD) y el servicio usa ese nivel en cada
renderización. No hay intervención manual.
