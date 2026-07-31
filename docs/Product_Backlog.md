# Product Backlog — TutorSaas / Dungeon of English

This backlog is built based on the Phase 0/1 Audits, design templates (`PlantillaHtml/`), and the current code state.

---

## Epic 1: Core Design System & Theme Alignment
### [DS-001] Introduce Danger Token & Spacing Constants
* **Objective:** Ensure theme consistency for error handling and standard layouts.
* **Description:** Add `AppColors.crimsonRed` to the color scheme as the error token. Create standard spacing constants (`app_spacing.dart`) using the 4px grid system: margin=20px, padding=24px, gutter=16px.
* **Priority:** High (P0)
* **Dependencies:** None
* **Files Affected:** 
  * `lib/core/theme/app_colors.dart`
  * [NEW] `lib/core/theme/app_spacing.dart`
* **Complexity:** Low (1)
* **Time Estimate:** 1.5h
* **Risk:** Low
* **Acceptance Criteria:** 
  * `AppColors.crimsonRed` is defined.
  * Spacing constants exist.
  * No hardcoded padding values inside screens where spacing is implemented.
* **Expected Result:** Uniform visual grid alignment and standardized colors.

### [DS-002] Create Custom QuestCard / RankCard Widget
* **Objective:** Standardize the representation of quest selections and achievements.
* **Description:** Build a reusable widget featuring a custom card with rank letters (S, A, B, C, D), a `SegmentedBar` for progress, and decorative runes using `GlassCard`.
* **Priority:** Medium (P1)
* **Dependencies:** [DS-001]
* **Files Affected:**
  * [NEW] `lib/core/widgets/quest_card.dart`
* **Complexity:** Medium (3)
* **Time Estimate:** 4h
* **Risk:** Low
* **Acceptance Criteria:**
  * Interactive card displaying scenario titles, rewards, and rank requirements.
  * Fits abyssal design guidelines perfectly.
* **Expected Result:** A reusable card widget for dungeons, missions, and session summary lists.

### [DS-003] Create SystemWindow Wrapper Widget
* **Objective:** Unified modal/window layouts across screens.
* **Description:** Standardize window structures by wrapping `GlassCard` with a consistent header, runic corners, and mono title styling.
* **Priority:** Medium (P1)
* **Dependencies:** [DS-001]
* **Files Affected:**
  * [NEW] `lib/core/widgets/system_window.dart`
* **Complexity:** Low (2)
* **Time Estimate:** 2.5h
* **Risk:** Low
* **Acceptance Criteria:**
  * Simple wrapper configuration to deploy popups, dialogs, and secondary overlay forms.
* **Expected Result:** Identical visual headers on all system cards.

---

## Epic 2: Onboarding & User Customization Flow
### [ONB-001] Wire Character Creation Wizard and Class Selection Screen
* **Objective:** Enable character creation during the onboarding phase.
* **Description:** Connect the untracked `character_creation_wizard.dart` widget and class selection screen to the onboarding flow and register the corresponding route.
* **Priority:** High (P0)
* **Dependencies:** [DS-001]
* **Files Affected:**
  * `lib/app/router.dart`
  * `lib/features/onboarding/presentation/screens/onboarding_screen.dart`
* **Complexity:** Medium (3)
* **Time Estimate:** 4h
* **Risk:** Medium (potential onboarding flow blockage)
* **Acceptance Criteria:**
  * User can select a class, customize the avatar, and advance to the placement exam or dashboard.
* **Expected Result:** Onboarding screen transitions smoothly to class selection.

### [ONB-002] Wire Oracle Placement Test Screen
* **Objective:** Setup initial levels based on user knowledge.
* **Description:** Connect the untracked placement test screen (Oracle Test) to the onboarding flow. Ensure score details persist into Supabase user profile profiles.
* **Priority:** High (P0)
* **Dependencies:** [ONB-001]
* **Files Affected:**
  * `lib/app/router.dart`
  * `lib/features/onboarding/presentation/screens/oracle_test_screen.dart`
* **Complexity:** Medium (3)
* **Time Estimate:** 5h
* **Risk:** Medium
* **Acceptance Criteria:**
  * Integration with backend state machine to save level data.
  * Correct route redirection to `/home` upon completion.
* **Expected Result:** User is successfully evaluated and initialized in the database.

---

## Epic 3: Dashboard & Hunter Profile System
### [DSH-001] Build Hunter Status Profile Screen (`/hunter-status`)
* **Objective:** High-fidelity profile visual matching `hunter_status_profile_system`.
* **Description:** Implement a fully interactive dashboard tab or standalone page showing level stats, attributes, equipment slots, title selection, and active buffs.
* **Priority:** High (P0)
* **Dependencies:** [DS-002]
* **Files Affected:**
  * `lib/app/router.dart`
  * [NEW] `lib/features/dashboard/presentation/screens/hunter_status_screen.dart`
* **Complexity:** High (5)
* **Time Estimate:** 8h
* **Risk:** Medium
* **Acceptance Criteria:**
  * S-Rank profile visual layout matching template.
  * Display stats, active achievements, equipped items, and experience curves.
* **Expected Result:** A fully animated stats board for the user character.

### [DSH-002] Create Dungeon Gateways Selection Map
* **Objective:** Provide visual scenario selection.
* **Description:** Implement `learning_dungeon_map_gateways` template as a interactive map layout showing locked/unlocked dungeons and progress levels.
* **Priority:** High (P0)
* **Dependencies:** [DS-002]
* **Files Affected:**
  * `lib/app/router.dart`
  * [NEW] `lib/features/dashboard/presentation/screens/dungeon_map_screen.dart`
* **Complexity:** High (5)
* **Time Estimate:** 7h
* **Risk:** Medium
* **Acceptance Criteria:**
  * Map selection scrollable lists matching the manhwa portal gate structure.
  * Visual representations of scenario locks.
* **Expected Result:** Interactive gateways selection mapping replacing static lists.

---

## Epic 4: Conversation Engine & Voice Experience
### [CONV-001] Visual Polish for Combat System Battle Screen
* **Objective:** Polish the conversation UI to resemble `combat_system_english_battle`.
* **Description:** Elevate the current conversation screen styling. Introduce RPG HUD frames, boss HP bars matching scenario difficulty, and action queues without altering the underlying Groq/DeepSeek voice pipeline.
* **Priority:** Medium (P1)
* **Dependencies:** [DS-001]
* **Files Affected:**
  * `lib/features/conversation/presentation/screens/conversation_screen.dart`
* **Complexity:** Medium (3)
* **Time Estimate:** 6h
* **Risk:** Medium (avoid regressions in voice capture callbacks)
* **Acceptance Criteria:**
  * High-fidelity combat layout.
  * Standard holding gestures function correctly.
* **Expected Result:** Visual voice exchange formatted as a fantasy system-window combat interface.

### [CONV-002] Integrate Conversational Tactics Selector
* **Objective:** Allow setting objectives before chat battles.
* **Description:** Wire the `conversational_tactics_navigator` modal to configure hints, topics, and grammar focal points before initiating voice interactions.
* **Priority:** Medium (P1)
* **Dependencies:** [DS-003]
* **Files Affected:**
  * `lib/features/conversation/presentation/screens/conversation_screen.dart`
* **Complexity:** Medium (3)
* **Time Estimate:** 4h
* **Risk:** Low
* **Acceptance Criteria:**
  * Tactics overlay selection popup appears before dungeon entry.
* **Expected Result:** Configured goals load dynamically into the session targets.

---

## Epic 5: Economy & Progression Integrations
### [ECON-001] Verify & Integrate Economy Modules
* **Objective:** Functional gems, streak counts, and inventory.
* **Description:** Connect the untracked `lib/features/economy/` structures into state flows and display active gems, shop transactions, and status boards.
* **Priority:** High (P1)
* **Dependencies:** [DSH-001]
* **Files Affected:**
  * `lib/features/dashboard/presentation/screens/dashboard_screen.dart`
  * `lib/features/economy/` files
* **Complexity:** High (4)
* **Time Estimate:** 6h
* **Risk:** Medium (state synchronization and db constraints)
* **Acceptance Criteria:**
  * Modifying gems/XP propagates correctly across all widgets.
* **Expected Result:** Economy system functional in dashboard profiles and shop views.

### [ECON-002] Build Shop & Shop Inventory Screen
* **Objective:** Provide a shop interface for buying scrolls, mana restoratives, and avatar frames.
* **Description:** Implement `/shop` page supporting micro-transactions with in-game currency.
* **Priority:** Medium (P2)
* **Dependencies:** [ECON-001]
* **Files Affected:**
  * `lib/app/router.dart`
  * [NEW] `lib/features/economy/presentation/screens/shop_screen.dart`
* **Complexity:** Medium (3)
* **Time Estimate:** 5h
* **Risk:** Low
* **Acceptance Criteria:**
  * Displays item inventories, prices, buy transactions, and unlocks.
* **Expected Result:** Functional store.

---

## Epic 6: Guild & Raid Rooms
### [GUILD-001] Fix Voice Room roomId Non-UUID Crash
* **Objective:** Resolve application crash during voice chat initialization.
* **Description:** Change database schema or repository parser to support custom room slug IDs alongside UUIDs for the social room lists.
* **Priority:** Critical (P0)
* **Dependencies:** None
* **Files Affected:**
  * `lib/features/chat_rooms/data/repositories/chat_rooms_repository_impl.dart`
* **Complexity:** Low (2)
* **Time Estimate:** 3h
* **Risk:** High (affects core multi-user features)
* **Acceptance Criteria:**
  * Social rooms initialize safely with slugs (like `guild_table_1`) without throwing SQL/UUID exceptions.
* **Expected Result:** Voice channels open reliably.

### [GUILD-002] Create Guild Room Builder Dialog
* **Objective:** Custom voice room creator interface.
* **Description:** Build `guild_room_creation` modal using `SystemWindow` to let users customize name, maximum players, and class requirements.
* **Priority:** Medium (P2)
* **Dependencies:** [DS-003]
* **Files Affected:**
  * `lib/features/chat_rooms/presentation/screens/chat_rooms_screen.dart`
* **Complexity:** Low (2)
* **Time Estimate:** 3h
* **Risk:** Low
* **Acceptance Criteria:**
  * Users can dynamically spin up new channel lists.
* **Expected Result:** Safe creation of room nodes.

---

## Epic 7: Database & Migrations Sync
### [DB-001] Database Migration Audit and Live Sync
* **Objective:** Deploy database schemas to the live project securely.
* **Description:** Validate applied database structures by executing migration queues. Implement missing tables (`oracle_questions`, `missions`, `pricing`, `inventory`) in Supabase.
* **Priority:** Critical (P0)
* **Dependencies:** None
* **Files Affected:**
  * Supabase configuration & migrations
* **Complexity:** High (4)
* **Time Estimate:** 5h
* **Risk:** High (live database writes/updates)
* **Acceptance Criteria:**
  * Migrations match live Supabase state. RLS policies verified on all writes.
* **Expected Result:** DB operates seamlessly with all client entities.
