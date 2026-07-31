# Task Priorities & Estimates — TutorSaas / Dungeon of English

## 1. High Priority (P0) — Critical Blocks & Onboarding Core
These tasks resolve build/run failures, establish data stability, and handle user entry flows.

| Task ID | Task Title | Complexity | Estimate | Key Files Affected |
|---|---|---|---|---|
| **DB-001** | Database Migration Audit & Live Sync | High (4) | 5.0h | Supabase migrations, schemas |
| **GUILD-001**| Fix Voice Room roomId Non-UUID Crash | Low (2) | 3.0h | `lib/features/chat_rooms/` repositories |
| **DS-001** | Spacing Constants & Danger Token | Low (1) | 1.5h | `app_colors.dart`, `app_spacing.dart` |
| **ONB-001** | Wire Character Wizard & Class Screens | Medium (3) | 4.0h | `router.dart`, onboarding views |
| **ONB-002** | Wire Oracle Placement Test Screen | Medium (3) | 5.0h | `router.dart`, `oracle_test_screen.dart` |
| **DSH-001** | Build Hunter Status Profile Screen | High (5) | 8.0h | `hunter_status_screen.dart` |
| **DSH-002** | Create Dungeon Gateways Selection Map | High (5) | 7.0h | `dungeon_map_screen.dart` |

**Subtotal Estimate (P0):** 33.5 hours

---

## 2. Medium Priority (P1) — Standard Components & Core Visual Loop
These tasks enhance aesthetics and UI capabilities across core dialog systems.

| Task ID | Task Title | Complexity | Estimate | Key Files Affected |
|---|---|---|---|---|
| **DS-002** | Create Custom QuestCard / RankCard Widget| Medium (3) | 4.0h | `quest_card.dart` |
| **DS-003** | Create SystemWindow Wrapper Widget | Low (2) | 2.5h | `system_window.dart` |
| **CONV-001**| Visual Polish for Combat Battle Screen | Medium (3) | 6.0h | `conversation_screen.dart` |
| **CONV-002**| Integrate Conversational Tactics Selector| Medium (3) | 4.0h | `conversation_screen.dart` |
| **ECON-001**| Verify & Integrate Economy Modules | High (4) | 6.0h | `dashboard_screen.dart`, economy files |

**Subtotal Estimate (P1):** 22.5 hours

---

## 3. Low Priority (P2) — Supplementary Features & Monetization
These tasks expand the shop offerings, social halls, and errors management.

| Task ID | Task Title | Complexity | Estimate | Key Files Affected |
|---|---|---|---|---|
| **ECON-002**| Build Shop & Shop Inventory Screen | Medium (3) | 5.0h | `shop_screen.dart` |
| **GUILD-002**| Create Guild Room Builder Dialog | Low (2) | 3.0h | `chat_rooms_screen.dart` |
| **SRS-001** | Vocab review Recalibration Modal | Medium (3) | 4.0h | vocabulary screens |
| **ERR-001** | System Mana Disruption Error Screen | Low (2) | 2.5h | error page views |

**Subtotal Estimate (P2):** 14.5 hours

---

## Total Project Backlog Estimate: 70.5 Hours
