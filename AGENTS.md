# AGENTS.md — Impostor

## 1. Project identity

**Project:** Impostor  
**Product type:** Offline-first mobile party game  
**Primary platform:** Android  
**Future platform:** iOS  
**Primary interaction model:** One phone passed between players  
**Core mechanic:** Most players receive the same secret word; one or more randomly selected impostors do not.

The purpose of this file is to tell coding agents how to work safely and consistently in this repository.

This is an engineering instruction file, not merely a product brief.

---

## 2. Non-negotiable product behavior

The following are contractual requirements for the core game:

1. The game must be playable on one physical phone.
2. No account, sign-in, internet connection, or second device is required for the core gameplay.
3. Players can be added, removed, renamed, and reordered before a round.
4. The game supports a configurable number of impostors, subject to validity rules in `docs/GAME_RULES.md`.
5. Words come from built-in categories initially, with architecture supporting custom categories/words.
6. Impostors are selected randomly and independently for each round.
7. The starting player is selected randomly for each round.
8. The app does not provide an in-app voting system.
9. Players discuss and vote manually outside the app.
10. The reveal flow must minimize the chance that a player sees information intended for another player.
11. A completed round can be replayed quickly using the same setup but fresh randomized assignments.
12. The core game remains fully usable offline.

Do not violate these requirements for convenience.

---

## 3. Repository instructions

Before editing code, read:

- `AGENTS.md`
- `docs/PRODUCT_SPEC.md`
- `docs/GAME_RULES.md`
- `docs/UI_SPEC.md`
- `docs/ARCHITECTURE.md`
- `docs/CONTENT_SPEC.md`
- `docs/TEST_PLAN.md`
- `docs/PRIVACY.md`
- `docs/ROADMAP.md`

When a task affects one of these areas, update the corresponding document in the same change.

### Specification precedence

If documents conflict:

1. Current explicit user/developer instruction
2. `AGENTS.md`
3. `docs/GAME_RULES.md`
4. `docs/PRODUCT_SPEC.md`
5. `docs/UI_SPEC.md`
6. `docs/ARCHITECTURE.md`
7. `docs/TEST_PLAN.md`
8. `docs/CONTENT_SPEC.md`
9. `docs/PRIVACY.md`
10. `docs/ROADMAP.md`
11. Existing implementation

If the conflict cannot be resolved safely, stop and report it instead of inventing a new rule.

---

## 4. Definition of a complete change

A change is not complete merely because the app compiles.

A complete change should, when applicable:

- implement the requested behavior;
- preserve the documented game rules;
- update tests;
- update affected documentation;
- handle loading, empty, invalid, and error states;
- preserve offline operation;
- preserve privacy of secrets;
- avoid introducing unnecessary dependencies;
- keep public APIs coherent;
- run formatting/static analysis/tests relevant to the change.

Do not mark a task complete when known test failures remain.

---

## 5. Architecture rules

Use clear separation between:

```text
UI / Presentation
        ↓
Application / State coordination
        ↓
Domain / Game engine
        ↓
Data / Persistence
```

### Domain layer

The domain/game engine owns:

- player validation;
- game-setting validation;
- word selection;
- impostor selection;
- starting-player selection;
- reveal payload generation;
- round lifecycle rules;
- no-repeat selection policy.

The domain layer must not import Flutter UI packages.

### Presentation layer

Presentation owns:

- rendering;
- navigation;
- animations;
- accessibility;
- input handling;
- visual state.

Presentation must not contain independent game-randomization logic.

### Data layer

Data owns:

- built-in word data loading;
- local persistence;
- custom categories/words;
- recent-word history;
- preferences.

---

## 6. Randomness rules

Random choices must be centralized behind an injectable abstraction.

Do not call global randomness directly from UI widgets.

A recommended shape is:

```dart
abstract interface class RandomSource {
  int nextInt(int max);
  double nextDouble();
}
```

The exact API may differ, but it must:

- be injectable;
- permit deterministic tests;
- avoid duplicate selections unless the game rule explicitly permits them.

For production, use a suitable secure or system randomness source where appropriate. The choice should be documented in `docs/ARCHITECTURE.md`.

Never use predictable hard-coded randomness.

---

## 7. Secret handling rules

Secret information includes:

- secret word;
- impostor status;
- impostor hint;
- any derived information that can reveal the secret or role.

Rules:

1. Keep secret state in memory only for as long as needed.
2. Do not persist per-player secret assignments unless there is an explicit requirement.
3. Do not log secret words, impostor identities, or reveal payloads in production logs.
4. Do not put secrets into analytics events.
5. Do not include secrets in crash-reporting metadata.
6. When the reveal is hidden, ensure the secret is no longer rendered.
7. Avoid screenshots/previews of secret screens where platform support allows prevention.
8. When the app leaves the foreground during a secret reveal, obscure or invalidate the reveal state as defined by the UI specification.
9. Treat copy/paste, accessibility exposure, and OS app previews as potential leak surfaces.

See `docs/PRIVACY.md`.

---

## 8. State-management rules

There should be a single authoritative game session state.

Avoid duplicated representations such as:

- one impostor list in the controller;
- another in the screen;
- another inferred from widgets.

A round should be generated once and then consumed by the presentation flow.

UI state such as:

- current player index;
- whether the reveal is visible;
- whether a pass screen is shown;

may exist separately from domain state, but the source of truth must remain clear.

---

## 9. Navigation rules

Use named/typed routes or a centralized navigation approach.

Do not allow arbitrary widgets to navigate directly to unrelated screens without going through the intended application flow.

The core flow is:

```text
Home
  ↓
Player Setup
  ↓
Game Settings
  ↓
Pass-to-Player
  ↓
Reveal
  ↓
Hide / Next Player
  ↓
...
  ↓
Starting Player
  ↓
Discussion
  ↓
Result / Reveal Impostors
  ↓
Play Again or New Game
```

Back-navigation from secret screens must be handled deliberately. Never allow back navigation to expose stale secret content accidentally.

---

## 10. Dependency rules

Before adding a package:

- verify that the Flutter SDK cannot reasonably provide the feature;
- confirm the package is maintained and suitable;
- check license compatibility;
- prefer small, focused dependencies;
- avoid packages that introduce networking or telemetry unless necessary;
- document important dependency decisions.

Do not add a state-management library, database, analytics SDK, or backend merely because it is popular.

---

## 11. Code quality

Prefer:

- small cohesive classes;
- immutable domain models where practical;
- explicit types;
- meaningful names;
- exhaustive handling of states;
- pure functions for game rules;
- low coupling;
- dependency injection at boundaries.

Avoid:

- giant screens;
- deeply nested callbacks;
- business logic inside build methods;
- magic numbers;
- hidden global state;
- unnecessary singletons;
- duplicated validation;
- silent exception swallowing.

Use comments to explain **why**, not what obvious code is doing.

---

## 12. Error handling

Expected invalid input should be represented explicitly, not through generic exceptions where avoidable.

Examples:

- too few players;
- too many impostors;
- empty player name;
- category with no usable words;
- impossible no-repeat selection.

Errors shown to players should be human-readable and actionable.

Developer diagnostics may be detailed, but must not contain secrets.

---

## 13. Accessibility

All important controls must be usable with:

- large text;
- screen readers;
- sufficient contrast;
- semantic labels;
- touch targets appropriate for mobile use.

Do not communicate critical state by color alone.

Secret/reveal states require extra caution: accessibility services can expose content that another person can hear. The privacy design in `docs/PRIVACY.md` takes precedence.

---

## 14. Performance

The app should feel instant for normal party sizes.

Target assumptions:

- 3–20 players;
- 1,000–10,000 built-in words over time;
- local-only gameplay;
- no network dependency for the round flow.

Do not optimize prematurely, but avoid unnecessary work in every widget rebuild.

---

## 15. Content rules

Built-in word content must be:

- understandable;
- category-appropriate;
- playable in conversation;
- non-duplicative;
- culturally reasonable for the supported language;
- tagged with difficulty;
- paired with a suitable hint when hints are enabled.

See `docs/CONTENT_SPEC.md`.

Do not insert copyrighted lists scraped from third-party sources.

---

## 16. Testing rules

Every meaningful game-rule change requires tests.

At minimum, test:

- player validation;
- impostor-count validation;
- random assignment invariants;
- unique impostors;
- valid starting player;
- valid reveal payloads;
- no-repeat word behavior;
- empty/invalid content handling;
- play-again reset behavior.

UI tests should cover the most important privacy-sensitive transitions.

See `docs/TEST_PLAN.md`.

---

## 17. Testable game-engine invariant

For any valid round:

```text
playerCount >= 3
1 <= impostorCount
impostorCount < playerCount
all impostors are distinct players
all normal players receive the same secret word
no impostor receives the secret word as their primary payload
startingPlayer is one of the players
phoneOrder contains every player exactly once
```

If hint mode is enabled, the impostor receives a non-empty hint associated with the selected word. The hint must not equal the secret word.

---

## 18. Release rules

Before a release:

- format code;
- run analyzer/linter;
- run unit tests;
- run widget/integration tests relevant to the release;
- verify release build;
- test on a real Android device;
- test the full pass-the-phone flow with multiple people;
- test interruption/backgrounding during reveal;
- verify no secret data appears in logs;
- verify app works with airplane mode enabled.

Do not claim a build is production-ready without completing the applicable checks.

---

## 19. Agent workflow

For each task:

1. Read the relevant specifications.
2. Inspect existing code before modifying it.
3. Identify the smallest coherent implementation.
4. Implement.
5. Add/update tests.
6. Run checks.
7. Update documentation if behavior changed.
8. Summarize exactly what changed and any remaining limitations.

Avoid unrelated refactors.

If the repository has uncommitted user changes, do not overwrite them without necessity.

---

## 20. Git discipline

Keep commits small and logically grouped.

Prefer commits such as:

```text
feat: add player setup flow
feat: implement round engine
test: cover impostor assignment
feat: add custom categories
fix: clear reveal state on app background
```

Do not mix:

- large formatting rewrites;
- unrelated refactors;
- feature work;
- dependency upgrades;

unless required by the same change.

---

## 21. Codex-specific stop conditions

Do not independently decide to add:

- subscriptions;
- ads;
- cloud sync;
- accounts;
- online multiplayer;
- social login;
- remote analytics;
- AI-generated hints at runtime;
- in-app voting;
- chat;
- location access;
- contacts access;

unless explicitly requested.

Do not change the fundamental pass-the-phone interaction model without explicit instruction.

Do not weaken secret handling to simplify UI implementation.

---

## 22. Current implementation priority

Follow `docs/ROADMAP.md`.

When a task is vague, prefer the smallest implementation that satisfies the current milestone and preserves future extensibility.

Do not build future features early unless their architecture is required to avoid rework.

---

## 23. Completion message format

When finishing a coding task, report:

```text
Implemented:
- ...

Tests:
- ...

Files changed:
- ...

Known limitations:
- ...
```

Do not claim tests were run if they were not run.
