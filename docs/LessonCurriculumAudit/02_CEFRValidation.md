# 02 — Validación CEFR del contenido

## Marco de referencia
Validación contra el **Marco Común Europeo de Referencia (CEFR)** y estándares internacionales de enseñanza (Cambridge, Oxford, British Council, EF).

- **A1**: puede presentarse, saludar, describir familia/origen, números, hora, comida, compras simples, direcciones. Frases aisladas memorizadas, presente simple, *to be/have*, preguntas wh- básicas.
- **A2**: situaciones cotidianas con frases frecuentes, pasado simple, rutinas, viajes, restaurante, hotel, compras con devolución, planes con *going to*.
- **B1**: conversación sostenida, opinión, experiencias, narración, trabajo, problemas cotidianos, condicionales básicas (1ª), *present perfect*, entrevistas.
- **B2**: argumentación matizada, hipótesis (2ª/3ª condicional), discurso indirecto, negociación, lenguaje profesional, debate, *modals* de deducción.
- **C1**: discurso fluido y estructurado, matices, negociación compleja, análisis crítico, textos académicos, sutilidad pragmática.
- **C2**: fluidez nativa, discurso abstracto, argumentación jurídica/científica/diplomática, matices culturales, control total.

## Veredicto del contenido en BD (contaminado)

| Problema | Ejemplo | Nivel correcto real | Decisión |
|---|---|---|---|
| Título avanzado en A1 | "A1 Art: Authenticating Renaissance Masterwork Provenance" | C1/C2 | ❌ Eliminar |
| Título avanzado en A1 | "A1 Business: Defending Annual Budget Strategy to Board" | C1 | ❌ Eliminar |
| Título avanzado en A1 | "A1 History: Debating Central Bank Macroeconomic Interest Rates" | C1 | ❌ Eliminar |
| Metas genéricas idénticas | "1. Iniciar conversación sobre X" (10/10 metas) | — | ❌ No válido |
| Frases placeholder | `travel_vocab_1`, `clave_16_travel` | — | ❌ No válido |
| Descripción placeholder | "Escenario real (n/15) nivel A1 travel." | — | ❌ No válido |

**Conclusión BD**: el 100% de las 3240 filas es contenido inválido (placeholders + nivel incorrecto + duplicados). Se descarta por completo.

## Veredicto del seed oficial (120 lecciones)

El seed `20260723000000_seed_20_lessons_per_level.sql` fue validado lección a lección. Cumple los criterios CEFR:

| Nivel | Ejemplo representativo | Gramática/discurso coherente |
|---|---|---|
| A1 | Ordering Coffee at a Cafe; Asking for Street Directions | Presente simple, pedir/decir, cortesía básica ✅ |
| A2 | Handling Restaurant Order Issue; Booking a Guided City Tour | Pasado simple, reservas, devoluciones ✅ |
| B1 | Job Interview: Strengths; Troubleshooting with IT | Present perfect, opinión, narración ✅ |
| B2 | Salary & Equity Negotiation; Debating Remote vs Hybrid | Condicionales, discurso indirecto, matices ✅ |
| C1 | Contract Scope & Royalty Negotiation; Academic Debate on Macro | Argumentación estructurada, léxico profesional ✅ |
| C2 | Supreme Court Constitutional Argument; Post-Quantum Crypto Migration | Discurso abstracto, léxico técnico/legal ✅ |

### Ejemplos concretos del seed (extraídos de `scenarios` vía script)

- **A1-01** "Ordering Coffee at a Cafe": metas `["Order a coffee drink", "Specify milk or sugar preferences", ...]`, frases `["I would like a coffee, please.", "Can I have oat milk?", ...]` → coherente A1.
- **C1** "Academic Debate on Macroeconomic Policy": metas `["Deconstruct inflation triggers...", "Cite historical stagflation precedents"...]`, frases `["Aggressive rate increases risk recessionary spiral.", ...]` → coherente C1.
- **C2** "Post-Quantum Cryptographic Standard Migration": metas sobre *Shor algorithm*, *CRYSTALS-Kyber/Dilithium* → coherente C2.

## Decisiones de nivel (movimientos/eliminaciones)

| Lección | Decisión |
|---|---|
| 3240 filas BD auto-generadas | **Eliminar** (TRUNCATE) |
| Seed oficial 120 | **Mantener** — es el currículo correcto |
| Catálogo Flutter 17 → 120 | **Completar** con las 120 oficiales |

## Resultado tras la validación

| Nivel | Existentes (válidas) | Requeridas | Faltantes |
|---|---|---|---|
| A1 | 20 | 20 | 0 |
| A2 | 20 | 20 | 0 |
| B1 | 20 | 20 | 0 |
| B2 | 20 | 20 | 0 |
| C1 | 20 | 20 | 0 |
| C2 | 20 | 20 | 0 |
| **Total** | **120** | **120** | **0** |
