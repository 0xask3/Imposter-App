# Codex Bootstrap Prompts

These prompts are intentionally sequential.

## Prompt 1 — Inspect and plan

Read `AGENTS.md` and all files under `docs/`.

Inspect the repository without making changes.

Report:
- current project state;
- missing project foundation;
- implementation order;
- specification conflicts, if any.

Do not write gameplay code yet.

---

## Prompt 2 — Foundation

Implement the project foundation and folder structure described in `docs/ARCHITECTURE.md`.

Requirements:
- keep domain code independent of Flutter UI;
- establish formatting/static-analysis conventions;
- establish test structure;
- do not implement screens yet.

Run relevant checks.

---

## Prompt 3 — Game engine

Implement the complete domain/game engine from `docs/GAME_RULES.md`.

Requirements:
- injectable randomness;
- validated player/settings inputs;
- random secret word;
- unique imposters;
- random starting player;
- randomized phone order;
- correct reveal payloads;
- no-repeat word history policy.

Write comprehensive unit tests and property-style tests where practical.

Do not build UI.

---

## Prompt 4 — Setup UI

Implement Home, Player Setup, and Game Settings according to `docs/UI_SPEC.md`.

Use the existing domain layer rather than adding game logic to widgets.

Write widget tests for validation and navigation.

---

## Prompt 5 — Reveal flow

Implement the pass-the-phone, identity confirmation, reveal, hide, and next-player flow.

Treat `docs/PRIVACY.md` as a release-blocking requirement.

Add widget/integration tests for secret isolation.

---

## Prompt 6 — Round completion

Implement starting-player reveal, discussion state, manual-vote messaging, result reveal, Play Again, and New Game.

Verify that Play Again creates a fresh round with fresh randomized assignments.

---

## Prompt 7 — Content

Implement the initial built-in word/category data model and validation.

Populate a useful initial content set following `docs/CONTENT_SPEC.md`.

Do not scrape third-party copyrighted lists.

---

## Prompt 8 — No-repeat and persistence

Implement local recent-word history and required local preferences.

Do not persist active secret assignments.

Add tests.

---

## Prompt 9 — Custom content

Implement custom categories and custom words according to the roadmap.

Keep built-in and custom content behind compatible repository abstractions.

---

## Prompt 10 — Polish

Implement:
- animations;
- haptics;
- sound where appropriate;
- keep-awake;
- accessibility improvements;
- background/app-switcher privacy behavior.

Do not compromise core game behavior for visual polish.

---

## Prompt 11 — Release audit

Perform a production audit against every requirement in:

- `AGENTS.md`
- `PRODUCT_SPEC.md`
- `GAME_RULES.md`
- `UI_SPEC.md`
- `ARCHITECTURE.md`
- `TEST_PLAN.md`
- `PRIVACY.md`

Run all applicable tests and build the release artifact.

Report any remaining gaps rather than silently ignoring them.
