# Product Specification — Imposter

## 1. Product summary

Imposter is a free, simple, offline-first mobile party game designed for groups sharing one phone.

The app replaces the administrative work of classic "imposter" party games:

- maintaining players;
- selecting a word;
- choosing imposters;
- privately distributing roles;
- choosing a random starting player;
- revealing the result after the discussion.

The app deliberately does **not** run the group's vote.

---

## 2. Target experience

The ideal session should feel like this:

```text
Open app
→ tap New Game
→ add players
→ choose settings
→ start
→ pass phone around
→ privately reveal each player's information
→ app randomly selects starter
→ players discuss and vote manually
→ reveal result
→ Play Again
```

A returning group should spend more time playing than configuring.

---

## 3. MVP scope

### Included

- Home screen
- Add/remove/edit players
- 3–20 players
- Configurable imposter count
- Built-in categories
- Multiple category selection
- Difficulty selection
- Optional imposter hint mode
- Random imposters
- Random starting player
- Randomized phone-pass order
- Private reveal flow
- Result reveal
- Play Again
- Fully offline play
- Recent-word/no-repeat mechanism
- Keep-screen-awake during gameplay
- Haptic/sound support where appropriate
- Dark-first visual design
- Accessibility basics
- Unit/widget/integration tests

### Architecturally supported, but may be after MVP

- Custom categories
- Custom words
- Additional languages
- Premium content packs
- Themes
- Advanced statistics/preferences
- Optional "experienced players" rule variants

### Explicitly out of scope for the initial core game

- Online multiplayer
- Accounts
- Cloud synchronization
- In-app voting
- Chat
- Friends/social graph
- User profiles
- Location
- Camera/microphone
- Required ads
- Required internet access

---

## 4. Players

### Requirements

- Minimum: 3
- Recommended: 4+
- Maximum: 20 for MVP
- Names must be non-empty after trimming.
- Duplicate names should be prevented or clearly disambiguated.

### Name behavior

When a user enters `"  Alex  "`, store/display `"Alex"`.

Names should be limited to a sensible length to prevent layout breakage. Suggested initial limit: 24 characters.

Starting another New Game in the current app session keeps the existing player
names and round settings. The group can edit, add, remove, or reorder players
during setup.

### Player ordering

The setup list is a user-managed list.

The reveal/pass order should be randomized separately unless a specific setting later requests otherwise.

---

## 5. Game settings

### Imposter count

The user selects an integer.

Validity:

```text
imposterCount >= 1
imposterCount < playerCount
```

The UI should provide a sensible default.

Suggested initial default:

- 1 imposter for 3–7 players
- 2 imposters for 8+ players

This is a default only; the player can change it.

### Categories

Users can choose one or more categories.

"All Categories" should be available as a convenience option.

The game must reject a configuration where the effective category selection contains no usable words.

### Difficulty

Initial values:

- Easy
- Medium
- Hard
- Any

Difficulty affects word selection, not player skill or imposter count.

### Hint mode

Two modes:

- Off — imposter sees only their imposter role.
- On — imposter receives a related hint.

The secret word itself must never be displayed to an imposter.

---

## 6. Round lifecycle

A round contains:

```text
Round Setup
→ Assignment
→ Private Reveals
→ Starter Selection
→ Discussion
→ Manual Vote
→ Result Reveal
```

### Assignment

At round creation:

1. Validate settings.
2. Select a usable word.
3. Select unique imposters.
4. Select starting player.
5. Create a phone-pass order.
6. Generate the round state.
7. Begin private reveal flow.

### Private reveals

For each player:

1. Show pass-to-player screen.
2. Require acknowledgement.
3. Show reveal affordance.
4. Reveal that player's payload.
5. Hide/confirm.
6. Advance to next player.

No player should be able to advance without first reaching the intended reveal/hide state.

### Starter selection

After all private reveals are complete:

1. Select or confirm the already-selected random starting player.
2. Present the result.
3. Enter discussion phase.

The starting player should be determined once per round, not re-rolled every time the screen rebuilds.

### Manual vote

The app does not collect votes.

The app may show:

> "Vote now. Then reveal the answer."

### Result

Show:

- imposter name(s);
- secret word;
- optional hint;
- optionally, starting player.

The result screen must not expose more information than intended.

---

## 7. Play Again

"Play Again" should:

- retain the current player list;
- retain current game settings;
- generate a fresh word;
- generate fresh imposters;
- generate a fresh starting player;
- generate a fresh phone-pass order;
- reset all reveal UI state.

"New Game" should return to setup and allow the user to change players/settings.

---

## 8. Home screen

The home screen should prioritize:

```text
New Game
```

Secondary actions may include:

- How to Play
- Settings

Do not overcrowd the first screen.

---

## 9. Game design principles

The product should feel:

- playful;
- secretive;
- fast;
- modern;
- readable in a group;
- forgiving of interruptions.

Avoid:

- corporate dashboard styling;
- excessive text;
- tiny controls;
- dense configuration;
- mandatory tutorials;
- unnecessary popups.

---

## 10. Offline requirement

The following must work in airplane mode after installation:

- open app;
- manage players;
- configure game;
- start round;
- select word;
- assign roles;
- reveal roles;
- choose starting player;
- reveal result;
- play again;
- edit local custom content if implemented.

Network connectivity must not be required for core gameplay.

---

## 11. Content growth

The built-in word system should be data-driven.

Adding 500 more words should not require changing game-engine code.

Adding a new category should primarily involve content data, not new UI code.

---

## 12. Accessibility target

Aim for WCAG-inspired mobile accessibility practices:

- readable typography;
- sufficient contrast;
- semantic labels;
- usable dynamic text sizes;
- touch-friendly controls;
- non-color-only state communication.

The private reveal state is an intentional privacy-sensitive exception to normal screen-reader exposure patterns and must follow `docs/PRIVACY.md`.

---

## 13. Localization

English is the initial language.

Structure UI strings so localization can be added later.

Do not hard-code user-visible strings across business logic.

German is a high-priority future language because of the intended European audience, but it is not required for MVP unless explicitly promoted into the milestone.

---

## 14. Monetization principle

The base game should remain usable without payment.

Monetization, if introduced later, should be additive rather than blocking:

- optional premium content;
- optional themes;
- optional content packs.

Do not gate basic player setup or core rounds behind payment in the MVP.
