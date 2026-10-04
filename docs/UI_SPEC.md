# UI / UX Specification — Imposter

## 1. Visual direction

The visual identity should feel:

- dark-first;
- modern;
- playful;
- slightly mysterious;
- high contrast;
- easy to read at arm's length.

Use a restrained palette with one strong accent color.

Do not use large amounts of decorative content that distract from gameplay.

The app should look polished on a normal modern Android phone without requiring a flagship device.

---

## 2. Navigation map

```text
Home
├── New Game
│   ├── Player Setup
│   └── Game Settings
│       └── Game
│           ├── Pass Screen
│           ├── Reveal Screen
│           ├── Hide/Next
│           └── ...repeat...
│               └── Starting Player
│                   └── Discussion
│                       └── Results
│                           ├── Play Again → Game
│                           └── New Game → Player Setup
├── How to Play
└── Settings
```

---

## 3. Home

Primary:

```text
IMPOSTER

[ New Game ]
```

Secondary:

```text
[ How to Play ]
[ Settings ]
```

The home screen must not require account creation.

---

## 4. Player Setup

### Header

```text
Players
```

### List item

```text
Alex                         Edit / Remove
Sarah                        Edit / Remove
John                         Edit / Remove
```

### Primary control

```text
+ Add Player
```

### Bottom action

```text
Continue
```

Disable Continue until at least 3 valid players exist.

### Add/edit behavior

Use a simple modal/sheet rather than a full screen when that produces a faster interaction.

Validate on submit.

---

## 5. Game Settings

Show the most important settings first.

Suggested order:

1. Imposter count
2. Categories
3. Difficulty
4. Imposter hint
5. Optional advanced settings

Primary CTA:

```text
Start Game
```

Do not allow Start Game to produce an unplayable round.

---

## 6. Pass screen

This screen protects the previous player's information.

Example:

```text
PASS THE PHONE

Give the phone to

ALEX

Make sure nobody else
can see the screen.

[ I'm Alex ]
```

The player name must be large and unmistakable.

Do not reveal role or word on this screen.

---

## 7. Identity confirmation

The player should acknowledge that they are the intended player before seeing any secret.

If the product later removes the button for speed, it must preserve an equivalent deliberate reveal step.

---

## 8. Reveal screen

### Normal player

Before reveal:

```text
ALEX

Your information is ready.

[ Reveal ]
```

After reveal:

```text
YOUR WORD

PIZZA

Remember your word.

[ Hide & Pass ]
```

The secret should be visually prominent.

### Imposter

After reveal:

```text
YOU ARE THE IMPOSTER

Hint:
ITALIAN FOOD

Remember your hint.

[ Hide & Pass ]
```

If hints are disabled:

```text
YOU ARE THE IMPOSTER

You do not know the word.

[ Hide & Pass ]
```

Never show the secret word on this screen.

---

## 9. Hide behavior

Pressing Hide & Pass must:

1. remove the secret/reveal content from the active widget tree;
2. advance to a safe state;
3. prepare the next player's pass screen;
4. not briefly flash the previous secret during transition.

Avoid transitions that animate the old secret across a navigation boundary.

---

## 10. Last-player transition

After the final player hides their information:

```text
Everyone has seen their role.

[ Reveal Starting Player ]
```

Do not automatically jump into the starting-player reveal so fast that the last player can accidentally see or infer another player's role.

---

## 11. Starting-player reveal

Create a small moment of suspense.

Possible animation:

```text
CHOOSING STARTING PLAYER...

ALEX
SARAH
JOHN
MIKE

→ JOHN
```

Then:

```text
JOHN STARTS

Discuss. Give clues.
Find the imposter.

[ Continue ]
```

The chosen player can be an imposter.

---

## 12. Discussion screen

This screen is intentionally simple.

```text
DISCUSSION

Starting player:
JOHN

Discuss and vote manually.

[ Reveal Result ]
```

Optional copy:

> Do not show your screens to other players.

---

## 13. Result screen

Before reveal:

```text
READY?

Vote manually first.

[ Reveal Result ]
```

After reveal:

```text
THE IMPOSTER(S)

SARAH
DAVID

THE WORD

PIZZA
```

Then:

```text
[ Play Again ]
[ New Game ]
```

Do not include a voting UI.

---

## 14. Play Again experience

Preserve:

- players;
- category selection;
- difficulty;
- hint mode;
- other retained settings.

Generate a new:

- word;
- imposters;
- starting player;
- phone order.

The Play Again action should avoid sending the user back through setup unnecessarily.

---

## 15. Touch and typography

Use generous touch areas.

Avoid placing critical controls directly against device edges.

The secret word and role should be easily readable from normal hand-held distance.

Do not depend on thin fonts or low contrast.

---

## 16. Motion

Motion should communicate state, not decorate every interaction.

Recommended:

- subtle reveal animation;
- subtle hide transition;
- short starting-player suspense animation;
- lightweight button feedback.

Avoid long animations that make the game feel slow.

Provide a reduced-motion path where practical.

---

## 17. Haptics and sound

Haptics should be subtle.

Sound should be off or unobtrusive by default unless product decisions later specify otherwise.

Never use a sound that explicitly announces "imposter" or another secret in a shared environment.

---

## 18. Privacy-sensitive UI

The reveal screen is the most sensitive surface in the app.

Requirements:

- no secret in a page title, notification, or external share;
- safe task-switcher behavior;
- no accidental secret persistence in text fields;
- no debug overlays in release;
- no secret content in accessibility labels unless explicitly designed for a safe interaction;
- no secret content in analytics.

---

## 19. Empty/error states

Examples:

### Not enough players

```text
Add at least 3 players to start.
```

### No usable words

```text
These categories do not contain enough playable words.
Choose another category.
```

### Invalid custom word

```text
Enter a word before saving.
```

Errors should tell the user what to do next.

---

## 20. Orientation

Portrait is the default.

The layout should not break if the device orientation changes during non-sensitive screens.

For sensitive reveal screens, behavior must prioritize privacy and predictable state over preserving a partially visible animation.

---

## 21. Keep-awake

During setup and active gameplay, the app should prevent normal screen timeout where platform APIs allow it.

Restore normal behavior when leaving active gameplay.
