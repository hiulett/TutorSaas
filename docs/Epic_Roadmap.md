# Epic Roadmap — TutorSaas / Dungeon of English

## Epic-Level Timeline

### Phase 1: Foundation & Infrastructure Sync
**Target Focus:** Synchronize Supabase schemas and build core layout utilities.
* **DB-001:** Database Migration Audit and Live Sync
* **DS-001:** Introduce Danger Token & Spacing Constants
* **GUILD-001:** Fix Voice Room roomId Non-UUID Crash

---

### Phase 2: Design Components & Character Setup
**Target Focus:** Wire character setup steps and provide standard visual containers.
* **DS-003:** Create SystemWindow Wrapper Widget
* **ONB-001:** Wire Character Creation Wizard and Class Selection Screen
* **ONB-002:** Wire Oracle Placement Test Screen
* **DS-002:** Create Custom QuestCard / RankCard Widget

---

### Phase 3: Hunter Hub & Dungeon Exploration
**Target Focus:** Launch status portals and gateway maps.
* **DSH-001:** Build Hunter Status Profile Screen (`/hunter-status`)
* **DSH-002:** Create Dungeon Gateways Selection Map
* **CONV-001:** Visual Polish for Combat System Battle Screen
* **CONV-002:** Integrate Conversational Tactics Selector

---

### Phase 4: Progression Loops & Guild Customization
**Target Focus:** Shop integrations and voice group modifiers.
* **ECON-001:** Verify & Integrate Economy Modules
* **ECON-002:** Build Shop & Shop Inventory Screen
* **GUILD-002:** Create Guild Room Builder Dialog
* **SRS-001:** Vocab review Recalibration Modal
* **ERR-001:** System Mana Disruption Error Screen

---

## Roadmap Dependencies
```
[Phase 1] ──(Colors, DB & Slugs)──> [Phase 2] ──(QuestCards, Dialogs)──> [Phase 3] ──(Gateways & Profiles)──> [Phase 4]
```
No task in a later phase should be worked on unless its prerequisite modules in preceding phases are fully compiled, verified, and complete.
