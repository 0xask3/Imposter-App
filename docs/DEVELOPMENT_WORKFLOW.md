# Development Workflow — Imposter

## 1. First Codex session

The first agent task should be:

> Read `AGENTS.md` and every file in `docs/`. Inspect the repository. Do not implement gameplay yet. Report the current repository state, proposed implementation phases, and any specification conflicts.

After that, implement phases one at a time.

---

## 2. Task sizing

Prefer tasks that produce one coherent result.

Good:

```text
Implement and test the player validation service.
```

Good:

```text
Implement the deterministic round generator and its tests.
```

Avoid:

```text
Build everything.
```

---

## 3. Before changing architecture

Ask whether the requested feature can be implemented within the current boundaries.

Only introduce a new layer, dependency, or persistence technology when it solves a real problem.

---

## 4. Before a UI change

Check:

- the screen's state transitions;
- secret exposure implications;
- accessibility;
- navigation/back behavior;
- interruption/background behavior.

---

## 5. Before a game-rule change

Update:

- `docs/GAME_RULES.md`;
- relevant domain tests;
- `docs/PRODUCT_SPEC.md` if player-visible;
- `docs/UI_SPEC.md` if the UX changes.

---

## 6. Suggested command sequence

Use the repository's actual toolchain, but the baseline Flutter workflow is conceptually:

```text
format
analyze
unit/widget tests
integration tests
build
```

Do not fabricate successful results. Report exact failures.

---

## 7. Manual smoke test

After a playable build exists:

1. Add 4–6 players.
2. Configure 1 imposter.
3. Enable hints.
4. Start a round.
5. Pass phone through every player.
6. Verify normal players see the same word.
7. Verify imposter sees only hint/role.
8. Verify the starting player is announced.
9. Manually "vote".
10. Reveal result.
11. Play Again.
12. Repeat with 2 imposters.
13. Repeat with hints off.
14. Repeat in airplane mode.
15. Background the app during reveal and verify privacy behavior.

---

## 8. Change reporting

Every completed task should state:

- what changed;
- which tests ran;
- which files changed;
- any known limitations.

Keep reports factual and brief.
