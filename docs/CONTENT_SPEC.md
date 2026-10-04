# Content Specification — Imposter

## 1. Content goals

Words are part of the game design, not filler.

Good entries create conversations where:

- normal players can give clues without naming the word;
- the imposter can infer the topic from the discussion;
- the word is recognizable enough for the target audience;
- the word is not so obvious that the game becomes trivial.

---

## 2. Initial categories

Recommended initial categories:

1. Animals
2. Food
3. Drinks
4. Countries
5. Cities
6. Movies
7. TV Shows
8. Video Games
9. Sports
10. Celebrities
11. Fictional Characters
12. Brands
13. Technology
14. Vehicles
15. Jobs
16. Everyday Objects
17. Places
18. Nature
19. Music
20. Pop Culture

Categories can be renamed/reordered without changing game logic.

---

## 3. Entry schema

Each word entry should have:

```text
id
word
hint
categoryIds
difficulty
```

Example:

```json
{
  "id": "animal_penguin",
  "word": "Penguin",
  "hint": "Cold-climate bird",
  "categoryIds": ["animals"],
  "difficulty": "easy"
}
```

---

## 4. Difficulty

### Easy

Widely recognized, concrete words.

### Medium

Recognizable but allows more varied discussion.

### Hard

Less obvious, more specific, or culturally narrower, while still being playable.

Difficulty should be judged for the intended language/audience, not only by dictionary rarity.

---

## 5. Hint design

Hints should be:

- related;
- concise;
- not synonyms of the exact word;
- not an exact category label when that makes the word trivial, unless intentional;
- useful enough that an imposter can participate.

Good:

```text
Word: Penguin
Hint: Cold-climate bird
```

Potentially too revealing:

```text
Word: Penguin
Hint: A black-and-white Antarctic bird
```

The quality bar should improve over time through content review.

---

## 6. Avoid duplicates

Do not include:

- exact duplicate words in the same effective pool;
- obvious duplicate variants unless strategically useful;
- entries whose difference is only punctuation/capitalization.

Where the same term belongs to multiple categories, reuse one word entry with multiple category IDs.

---

## 7. Safety/content quality

Avoid content that is:

- hateful;
- sexually explicit;
- discriminatory;
- needlessly graphic;
- defamatory toward living individuals;
- likely to cause avoidable moderation issues.

Celebrity/brand content should be factual and not framed as allegations.

---

## 8. Copyright

Do not copy a third-party copyrighted word list wholesale.

Content should be authored, licensed, public-domain, or otherwise legally usable.

---

## 9. Localization-ready design

Do not assume a hint translates word-for-word.

Future localized entries should be able to store language-specific:

```text
word
hint
difficulty
```

The same internal content ID can map to different localized text.

---

## 10. Custom content

Users should be able to create:

```text
Custom Category
  ├── Word A
  ├── Word B
  ├── Word C
```

Custom entries must go through the same validation as built-in content.

At minimum:

- non-empty word;
- sensible length;
- non-empty category;
- hint required when hint mode needs it.

---

## 11. Content validation

Automated validation should detect:

- empty IDs;
- duplicate IDs;
- empty words;
- duplicate words within the same locale/effective pool;
- missing hints where required;
- hint equal to word;
- missing category IDs;
- invalid difficulty;
- malformed content records.

Invalid built-in content should fail validation early rather than silently degrading gameplay.
