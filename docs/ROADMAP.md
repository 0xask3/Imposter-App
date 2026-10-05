# Roadmap — Imposter

## Phase 0 — Repository foundation

### Goal

Create a clean Flutter application with specifications and engineering conventions.

Deliverables:

- project skeleton;
- `AGENTS.md`;
- docs/specs;
- lint/format/test configuration;
- baseline CI if desired.

Acceptance:

- app builds;
- analyzer clean;
- basic test passes.

---

## Phase 1 — Domain engine

### Goal

Build the complete round generator without UI dependence.

Deliverables:

- models;
- validation;
- random source abstraction;
- word selection;
- imposter selection;
- starting-player selection;
- reveal payload generation;
- phone-order generation;
- no-repeat policy;
- unit/property tests.

Acceptance:

- all round invariants pass.

---

## Phase 2 — Setup UI

### Goal

Create the flow required to configure a game.

Deliverables:

- Home;
- Player Setup;
- Game Settings;
- input validation.

Acceptance:

- a valid game can be configured entirely through the UI.

Implementation note: Phase 2 uses a small authored seed catalog so category,
difficulty, and hint settings can be validated against real entries. This is
only a development-sized seed; the larger initial catalog remains Phase 5.

---

## Phase 3 — Secret reveal flow

### Goal

Implement the core pass-the-phone experience.

Deliverables:

- named reveal prompt;
- reveal;
- hide/pass;
- next-player transition;
- safe state handling.

Acceptance:

- every player sees only their own payload in normal tested usage.

Android privacy handling: the reveal route blocks screenshot/task-switcher
capture while active and returns to player confirmation after an interruption.

---

## Phase 4 — Starting player and results

### Goal

Complete the end-to-end game loop.

Deliverables:

- starting-player reveal;
- discussion screen;
- manual-vote messaging;
- result reveal;
- Play Again;
- New Game.

Acceptance:

- group can complete repeated rounds without resetting the app.

Implementation note: the generated starting player is shown after a separate
reveal action, discussion asks the group to vote manually, and results appear
when the group selects Reveal Result. Play Again preserves the setup and
generates a fresh round; New Game keeps the player list and returns to setup.
On Android, results are hidden again after app interruption and protected from
screenshots/task previews.

---

## Phase 5 — Content

### Goal

Populate enough content to make the app immediately playable.

Deliverables:

- 15–20 initial categories;
- high-quality word entries;
- hints;
- difficulty;
- automated content validation;
- no-repeat history.

Target:

- approximately 50–100 playable entries per initial category.

---

## Phase 6 — Custom content

### Goal

Allow groups to make their own game packs.

Deliverables:

- create category;
- add/edit/delete words;
- optional hints;
- validation;
- local persistence.

---

## Phase 7 — UX polish

Deliverables:

- refined visual system;
- animations;
- haptics;
- sound;
- keep-awake;
- accessibility improvements;
- interruption/background privacy handling;
- performance pass.

---

## Phase 8 — Localization

First target:

- English

Future priority:

- German

Content should support language-specific word/hint values.

---

## Phase 9 — Release hardening

Deliverables:

- full test suite;
- release builds;
- physical-device testing;
- airplane-mode testing;
- privacy verification;
- store assets;
- release notes;
- versioning.

---

## Phase 10 — Post-MVP

Potential features:

- more categories;
- curated themed packs;
- custom themes;
- optional premium content;
- advanced difficulty;
- rule variants;
- optional round statistics.

Do not add these until the core experience is stable.
