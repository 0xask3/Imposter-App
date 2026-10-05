# Architecture — Imposter

## 1. Goal

The architecture must keep game rules deterministic, testable, and independent from Flutter widgets.

The UI is a client of the game domain, not the owner of the rules.

---

## 2. Suggested folder structure

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── app_lifecycle.dart
├── domain/
│   ├── models/
│   ├── services/
│   ├── validators/
│   └── random/
├── application/
│   ├── game_session_controller.dart
│   ├── setup_controller.dart
│   └── preferences_controller.dart
├── data/
│   ├── builtin/
│   ├── repositories/
│   └── local/
├── presentation/
│   ├── screens/
│   ├── widgets/
│   ├── theme/
│   └── animations/
└── l10n/
```

The implementation may refine this structure, but responsibilities must remain separated.

---

## 3. Domain models

### Player

```text
id: stable local identifier
name: trimmed display name
```

### WordEntry

```text
id
word
hint
categoryIds
difficulty
```

### Category

```text
id
name
iconKey
```

### GameSettings

```text
imposterCount
selectedCategoryIds
difficultyFilter
hintsEnabled
noRepeatEnabled
```

### RevealPayload

```text
playerId
role
secretWord? 
hint?
```

For an imposter, `secretWord` must be null.

### Round

```text
id
secretWordId
secretWord
hint
players
imposterIds
startingPlayerId
phoneOrder
revealPayloads
createdAt
```

Avoid storing redundant secret data in multiple independent mutable objects. If denormalized data is retained for convenience, document why.

---

## 4. Game engine API

Conceptual interface:

```dart
abstract interface class GameEngine {
  Round createRound({
    required List<Player> players,
    required GameSettings settings,
  });
}
```

Supporting services:

```dart
abstract interface class WordSelector {
  WordEntry selectWord(...);
}

abstract interface class RoleAssigner {
  Set<String> selectImposters(...);
}

abstract interface class PlayerOrderSelector {
  List<String> createRevealOrder(...);
  String selectStartingPlayer(...);
}
```

The exact API can differ, but the engine must preserve the domain boundaries.

---

## 5. Random source

Inject randomness:

```dart
abstract interface class RandomSource {
  int nextInt(int max);
}
```

Tests can inject a seeded/fake implementation.

For production, `SystemRandomSource` wraps `dart:math`'s `Random.secure()`.
The game engine receives it through `RandomSource`; it does not call global
randomness directly. Tests inject a deterministic implementation.

Do not tie the engine to `dart:math.Random` in ways that make tests nondeterministic or difficult to reproduce.

---

## 6. Selection algorithms

A standard unbiased sampling algorithm may be used for selecting distinct imposters.

Fisher-Yates or equivalent should be used for shuffling where appropriate.

Do not select imposters by repeatedly generating random indexes without handling duplicates correctly.

---

## 7. State machine

The application-level session should have explicit states similar to:

```text
Idle
Setup
Assigning
PassingToPlayer
Revealing
Hiding
StartingPlayerReveal
Discussion
Result
Completed
```

Exact naming is flexible.

The important rule is that illegal transitions are prevented.

Examples:

```text
Idle → Result          invalid
Revealing → Discussion invalid
Result → Revealing     invalid unless a new round is created
```

---

For the private reveal flow, `SetupController` owns the randomized phone-order
cursor, identity confirmation, and whether the current payload may be rendered.
The presentation layer receives no payload before the reveal action; Hide & Pass
clears visibility before advancing the cursor. The reveal route blocks system
back navigation and returns to confirmation after an app lifecycle interruption.
On Android, the native activity enables `FLAG_SECURE` while the private reveal or
round-results route is mounted so the OS cannot capture secrets in screenshots
or task previews.

## 8. Persistence

Persist only what is useful across launches:

- player list, if the product later chooses to retain it;
- custom categories/words;
- user preferences;
- recent-word history.

Do not persist active secret assignments by default.

If crash recovery is ever added, it must use a privacy-reviewed design.

---

## 9. Content storage

Built-in content should be data-driven.

A JSON-like representation is acceptable:

```json
{
  "id": "food_pizza",
  "word": "Pizza",
  "hint": "Italian food",
  "categoryIds": ["food"],
  "difficulty": "easy"
}
```

The content loader should validate content at startup/build time where possible.

---

## 10. Persistence abstraction

Keep persistence behind repository interfaces:

```dart
abstract interface class SettingsRepository {}
abstract interface class CustomContentRepository {}
abstract interface class WordHistoryRepository {}
```

This allows the implementation to start with a simple local store and change later without rewriting the game domain.

The round generator requests the most recent 20 word IDs by default. The window
is configurable in code. Android history is persisted as a short list of word
IDs with Flutter's `shared_preferences` plugin; an in-memory implementation is
used for deterministic tests. Active round assignments are not persisted.

---

## 11. Lifecycle safety

Application lifecycle events must be treated as part of the privacy model.

When entering background during sensitive gameplay:

- obscure visible secrets where supported;
- invalidate or suspend reveal visibility;
- ensure the next resume cannot expose a secret to an unintended viewer.

Do not assume navigation state alone provides privacy.

---

## 12. Observability

Debug logging may be used during development.

Production logs must not contain:

- secret word;
- hint;
- imposter IDs/names;
- reveal payload;
- full round serialization.

Use event names such as:

```text
round_started
player_reveal_opened
player_reveal_hidden
round_completed
```

without secret values.

Only add analytics later if explicitly requested.

---

## 13. Future extensibility

Architecture should leave clear seams for:

- custom content;
- multiple languages;
- themes;
- content packs;
- advanced rule variants.

Do not pre-build unused infrastructure for:

- online matchmaking;
- cloud storage;
- accounts;
- remote game synchronization.
