# Privacy & Secret-Handling Specification — Impostor

## 1. Privacy principle

The most important security property of this app is not account security. It is **local secret isolation between people sharing the same physical device**.

Treat game secrets as transient sensitive data.

---

## 2. Sensitive data

The following are secrets during a live round:

- secret word;
- impostor role;
- impostor hint;
- mapping between player and role;
- any state from which the secret can be inferred.

---

## 3. Data minimization

The app should collect/process as little data as possible.

MVP should not require:

- account;
- email;
- phone number;
- contacts;
- exact location;
- camera;
- microphone;
- cloud account;
- remote game state.

---

## 4. Persistence

Do not persist active round reveal payloads unless a future feature explicitly requires it.

Prefer in-memory storage for:

- current secret;
- current role;
- current reveal index;
- active round assignments.

Persist only durable user preferences/content/history that have a clear user benefit.

---

## 5. Logs

Never log:

```text
secret word
impostor names
impostor IDs
hints
full round state
reveal payload
```

Bad:

```text
debugPrint("Impostor: $player");
```

Good:

```text
debugPrint("Player reveal completed");
```

Production logging should avoid sensitive metadata.

---

## 6. Analytics

No analytics in MVP.

If analytics are later introduced:

- do not send game secrets;
- do not send individual role assignments;
- do not send custom words;
- do not create an event payload that reconstructs the round.

Analytics should be opt-in/consent-aware where legally required.

---

## 7. Screenshots and app previews

The app should prevent or obscure secret information from appearing in:

- recent-apps/task-switcher previews;
- automated screenshots during sensitive states;

where platform APIs permit.

Because platform behavior can vary, test on real supported OS versions.

---

## 8. Backgrounding

When the app goes to the background during a sensitive reveal:

- enter a privacy-safe state;
- obscure visible sensitive content;
- do not leave a secret plainly visible in the app preview.

On resume, the app must ensure the secret cannot appear unexpectedly to the wrong person.

A conservative implementation may require re-confirmation before continuing a sensitive reveal.

---

## 9. Accessibility leak

Screen-reader services may expose rendered text.

Therefore:

- sensitive content must not be duplicated into unnecessary semantic labels;
- do not make a secret announcement unless the interaction is explicitly designed around a private user session;
- accessibility behavior must be tested on supported platforms.

The objective is not to disable accessibility globally; it is to avoid unnecessary duplication of sensitive content.

---

## 10. Clipboard/share

Do not automatically copy or share:

- secret words;
- hints;
- roles.

Do not offer normal share-sheet actions from the reveal screen unless a future use case explicitly requires it.

---

## 11. Notifications

The app should not create notifications containing:

- secret word;
- role;
- hint;
- player assignment.

---

## 12. Permissions

MVP should request no sensitive device permissions.

---

## 13. Threat model

Primary threat:

> Another person physically present sees a previous player's secret because of UI state, OS behavior, or accidental navigation.

Secondary threats:

- screenshots;
- task-switcher preview;
- logs during development;
- crash reports;
- accessibility duplication;
- app interruption;
- rapid taps;
- stale state after replay.

The architecture and tests should prioritize these threats.

---

## 14. Privacy verification

Before every release, manually inspect:

- debug output;
- crash-report metadata if enabled;
- app previews;
- notifications;
- background/resume;
- screenshots;
- result screen transitions.

No secret should escape intended on-device gameplay.
