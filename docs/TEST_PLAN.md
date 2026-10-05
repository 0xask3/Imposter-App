# Test Plan — Imposter

## 1. Test pyramid

Use:

1. Domain/unit tests — majority
2. Widget tests — important user flows
3. Integration tests — end-to-end privacy/gameplay scenarios
4. Manual device testing — physical pass-the-phone behavior

---

## 2. Unit tests

### Player validation

Test:

- 2 players → invalid;
- 3 players → valid;
- 20 players → valid;
- 21 players → invalid;
- blank names → invalid;
- names trimmed;
- duplicate names handled according to product rule.

### Imposter assignment

For valid inputs:

- exact imposter count;
- unique imposter IDs;
- every selected player exists;
- no hidden duplicate;
- no UI dependency.

Run the generator many times to catch structural failures.

### Starting player

Verify:

- exactly one selected;
- selected player exists;
- imposter status does not exclude them;
- result remains stable after repeated reads of the same round.

### Reveal payload

Verify:

Normal:

```text
role == normal
secretWord != null
hint == null
```

Imposter, hints off:

```text
role == imposter
secretWord == null
hint == null
```

Imposter, hints on:

```text
role == imposter
secretWord == null
hint != null
hint != secretWord
```

### Phone order

Verify:

- count equals player count;
- every player appears exactly once.

### No-repeat

Test:

- recent word is excluded when alternatives exist;
- history grows correctly;
- old history is pruned/reset as defined;
- small pools do not deadlock selection.

### Settings validation

Test all invalid combinations.

---

## 3. Property-style tests

Where practical, generate many random valid configurations and assert invariants:

```text
for each valid configuration:
    round = createRound(configuration)

    assert player count valid
    assert imposter count exact
    assert imposters unique
    assert starting player valid
    assert phone order is a permutation
    assert every normal has same secret
    assert every imposter has no secret
```

---

## 4. Widget tests

Cover:

### Player setup

- add player;
- edit player;
- remove player;
- continue disabled with <3 players;
- continue enabled with valid players.

### Settings

- adjust imposter count;
- select categories;
- change difficulty;
- toggle hints;
- start valid game.

### Reveal

- named reveal prompt shows correct current player;
- secret is hidden before reveal;
- reveal action shows correct payload;
- hide action removes secret;
- next player sees only their named reveal prompt.

### Results

- manual-vote instruction present;
- imposters remain hidden until reveal action;
- Play Again retains setup.

---

## 5. Privacy/integration tests

Test on a real device:

1. Start a round.
2. Reveal a normal player's word.
3. Lock/background the app.
4. Return.
5. Verify no secret is visible to the next player.

Also test:

- app switcher preview;
- rotation;
- back button;
- rapid tapping;
- repeated reveal/hide;
- navigating during animation;
- device screen timeout;
- process recreation where practical.

---

## 6. Regression tests

Any fixed bug involving:

- secret leakage;
- wrong role assignment;
- wrong word assignment;
- wrong starting player;
- incorrect no-repeat behavior;

must receive a regression test.

---

## 7. Release checks

Before release:

```text
flutter format/analyze checks
unit tests
widget tests
integration tests
release build
physical Android test
airplane-mode test
```

Exact commands depend on project configuration.

---

## 8. Test data

Create deterministic fixtures:

```text
players_3
players_5
players_10
players_20

one_imposter
two_imposters

hints_on
hints_off

small_word_pool
large_word_pool
```

Use deterministic random sources in unit tests.

---

## 9. Definition of test completeness

The game engine is acceptable when the test suite establishes the round invariants for all supported configurations.

The UI is acceptable when the critical path can be executed without accidentally exposing one player's secret to another in tested interruption scenarios.
