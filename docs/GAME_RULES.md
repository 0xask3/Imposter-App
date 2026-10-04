# Game Rules — Impostor

## 1. Basic rule

A round has:

- one secret word;
- one or more impostors;
- one starting player;
- zero or more hints for impostors.

Every normal player receives the secret word.

Every impostor receives:

- their impostor role;
- optionally, a hint;
- never the secret word.

---

## 2. Valid player count

Minimum:

```text
3
```

Maximum for MVP:

```text
20
```

The engine must reject counts outside this range.

---

## 3. Valid impostor count

The rule is:

```text
1 <= impostorCount < playerCount
```

Therefore:

```text
3 players → max 2 impostors
4 players → max 3 impostors
10 players → max 9 impostors
```

However, the UI should discourage extreme configurations because they reduce gameplay quality.

A future rule may introduce recommended maximums without changing the mathematical validity rule.

---

## 4. Random impostor selection

For each round:

- select exactly `impostorCount` distinct players;
- all players must have an equal probability of being selected, assuming the configured random source is unbiased;
- no player may be selected twice;
- previous-round impostor status must not influence the next selection unless a future explicit rule adds balancing.

The app should not try to "make it fair" by forcing a player to become impostor after they have not been selected recently. That would alter the intended randomness.

---

## 5. Secret word selection

Select exactly one word from the effective word pool.

The effective pool is:

```text
selected categories
∩
selected difficulty policy
−
temporarily excluded recent words
```

If no words remain after exclusions, the engine may relax only the no-repeat exclusion according to the no-repeat policy.

It must never return an invalid/empty word.

---

## 6. Hints

When hints are enabled:

- every word must have an associated hint;
- the hint must be relevant enough to be useful;
- the hint must not equal the word;
- the hint should not trivially reveal the exact answer.

Example:

```text
Secret word: Pizza
Hint: Italian food
```

Bad:

```text
Secret word: Pizza
Hint: Pizza
```

The content pipeline is responsible for hint quality.

---

## 7. Player reveal payloads

Normal player payload:

```text
role: normal
secretWord: <word>
hint: null
```

Impostor with hints disabled:

```text
role: impostor
secretWord: null
hint: null
```

Impostor with hints enabled:

```text
role: impostor
secretWord: null
hint: <hint>
```

The UI should render only the appropriate fields for the player's role.

Do not represent an impostor as a normal player whose word is hidden only by a UI conditional. The domain payload itself should express the difference.

---

## 8. Starting player

Choose one player uniformly at random from the full player list.

The starting player may also be an impostor.

Do not exclude impostors unless a future rule explicitly requires it.

Once chosen, the starting player remains fixed for the round.

---

## 9. Phone-pass order

The app should create a randomized order containing every player exactly once.

This order is independent of:

- impostor selection;
- starting player selection.

The starting player does not need to be first in the reveal order.

The purpose of the randomized phone-pass order is to avoid a predictable relationship between setup order and reveal order.

---

## 10. No-repeat words

Recent-word history should be stored locally.

A default recent history window may be chosen by implementation, but it must be configurable in code and documented.

Recommended initial policy:

- do not repeat a word until at least 20 rounds have passed when enough unique words exist;
- if the available pool has fewer than 20 eligible words, use as many unique words as possible;
- once the pool is exhausted, allow older words again.

No-repeat is a preference, not a mathematical guarantee when the pool is too small.

---

## 11. Round invariants

A valid generated round must satisfy:

```text
players.length >= 3
players.length <= 20
impostors.length == impostorCount
impostors contains no duplicate ids
startingPlayerId exists in players
phoneOrder contains every player id exactly once
secretWord is non-empty
normal players all map to the same secret word
impostors have secretWord == null in their reveal payload
```

With hints enabled:

```text
every impostor has a valid, non-empty hint
hint != secretWord
```

---

## 12. Reset rules

At the beginning of a new round:

- previous reveal state is discarded;
- previous impostor selection is discarded;
- previous starting-player UI state is discarded;
- previous secret display state is discarded;
- a fresh round is generated.

Player list and game settings are retained for Play Again.

---

## 13. Interruption rule

If the app is backgrounded during a private reveal, the app should move to a safe privacy state when possible.

At minimum:

- the currently visible secret must not remain exposed in an OS task switcher preview;
- returning to the app must not display a secret to a different player.

If a platform limitation prevents full control, document the limitation and choose the safest practical behavior.

---

## 14. What the app does not decide

The app does not determine:

- who is voted out;
- whether the group voted correctly;
- who wins;
- discussion order beyond the random starting player;
- how players phrase clues.

Those are intentionally left to the group.
