# 04 — Progresión pedagógica (Learning Progression)

## Curva de dificultad continua A1 → C2

El currículo oficial de 120 lecciones sigue una progresión de dificultad natural alineada con CEFR. La siguiente secuencia muestra la evolución temática y lingüística por nivel.

### A1 — Principiante (sobrevivir en lo cotidiano)
Temática: necesidades básicas y presentación personal. Gramática: presente simple, *to be*, *have*, preguntas wh-.

```
Ordering Coffee → Hotel Check-in → Street Directions → Grocery → Taxi
→ Introduce Yourself → Order Pizza → Buy Clothes → Daily Routine → Weather/Time
→ Doctor Reception → Pet Shop → Hobbies → Birthday → Bus Tickets
→ City Bike → Pharmacy → Phone Setup → Family Album → Bakery Breakfast
```

### A2 — Elemental (situaciones frecuentes)
Temática: resolver incidencias y gestionar trámites. Gramática: pasado simple, *going to*, comparativos básicos.

```
Restaurant Issue → Return Item → City Tour → Cold Advice → Train Delay
→ Bank Account → Gym Signup → Rent Car → Doctor (ankle) → Roommate Rules
→ Job Description → Birthday Gift → Recipe → Weekend Trip → Historic Tour
→ Lost Wallet → Hairdresser → Music Festival → Library Card → Food Delivery
```

### B1 — Intermedio (independencia conversacional)
Temática: opiniones, experiencias, trabajo y problemas. Gramática: *present perfect*, 1ª condicional, narración.

```
Job Interview → Past Work Challenges → Apartment Viewing → IT Troubleshooting
→ Refund Negotiation → Movies & Themes → Group Trip Budget → Weekly Status
→ Missing Package → Fitness Targets → Community Volunteering → Surprise Party
→ Career Ambitions → Workplace Miscommunication → Sustainable Habits
→ Remote Office → University Electives → Flea Market Bargain → Flight Changes
→ Cultural Traditions
```

### B2 — Intermedio alto (argumentación)
Temática: negociación, debate y gestión profesional. Gramática: condicionales 2ª/3ª, discurso indirecto, *modals* de deducción.

```
Tech Architecture Interview → Product Pitch → Remote vs Hybrid Debate
→ Salary & Equity Negotiation → Nuanced Opinions → Art Gallery Critique
→ Disappointed Client → Deadline Extension → Energy Policy Debate
→ Startup VC Pitch → Government Bureaucracy → Ethics in AI → Team Conflict
→ Emergency Abroad → Real Estate Investment → Keynote Prep → Crisis Mitigation
→ Media Bias Analysis → Career Pivot → Sports Analytics
```

### C1 — Avanzado (fluidez y precisión)
Temática: negociación compleja, análisis crítico y discurso estructurado.

```
Contract Negotiation → Macroeconomic Debate → Board Strategy → Ethics & AI
→ Literary Analysis → M&A Strategy → Energy Security → IP Litigation
→ Medical Case → Cloud Architecture → Diplomatic Protocol → Press Conference
→ VC Due Diligence → Climate Accord → Cloud Security Audit → Governance
→ Higher-Ed Reform → Peer Review Defense → Franchise Expansion → Bioethics
```

### C2 — Maestría (discurso abstracto y experto)
Temática: argumentación legal, científica y diplomática de nivel nativo.

```
Multilateral Treaties → Constitutional Argument → Epistemology → Quantum Peer Review
→ Post-Modern Deconstruction → Central Bank Summit → Cyber Warfare → Trade Arbitration
→ Corporate Restructuring → Art Authentication → Ethnomusicology → Dark Energy
→ Human Rights Charter → BCI Speech → Arbitral Enforcement → Executive Crisis Address
→ ZK-STARK Consensus → Geo-Engineering Ethics → Post-Quantum Crypto → Beethoven Quartets
```

## Propiedades de la curva

1. **Carga cognitiva creciente**: de pedir un café (A1) a argumentar ante un tribunal supremo (C2).
2. **Abstracción creciente**: concreto → abstracto → teórico → especializado.
3. **Complejidad gramatical creciente**: presente simple → pasado → perfect → condicionales → discurso indirecto → modales de deducción.
4. **Reutilización de vocabulario**: los temas (travel, business, health) se repiten en niveles ascendentes con mayor profundidad léxica.
5. **Escenarios reales y comunicativos**: cada lección es una situación auténtica, no un ejercicio aislado.

## Categorías por nivel (equilibrio temático)

El seed cubre categorías variadas: `travel`, `cooking`, `business`, `art`, `history`, `technology`, `science`, `sports`, `music`, `general`. Distribución global de categorías (sobre 120):

| Categoría | Ocurrencias |
|---|---|
| business | 33 |
| science | 16 |
| history | 15 |
| travel | 13 |
| technology | 11 |
| art | 8 |
| cooking | 6 |
| music | 6 |
| sports | 5 |

> A1 domina `travel/cooking` (cotidiano); C1/C2 dominan `business/history/science` (abstracto) — coherente con la curva.

## Verificación de orden en la app

El roadmap (`learning_path_roadmap.dart`) y el desbloqueo (`LessonUnlockService`) ordenan por la **posición física de la lista `LessonCatalog.catalog`**. El catálogo generado mantiene el orden A1-01 → C2-20 del seed, garantizando la progresión secuencial.
