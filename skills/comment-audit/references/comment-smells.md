# Comment Smell Catalog

Detection guidance for the three audit passes. This is *reading guidance*, not regexes to execute — apply judgment by reading the comment in context. Trigger phrases are illustrative, not exhaustive; match intent, not literal strings. Language-agnostic: applies to `//`, `#`, `--`, `/* */`, `<!-- -->`, docstrings, doc-comments, and block headers alike.

For each family: **what it looks like → why it's harmful → remedy**.

---

## Pass 1 — Shifting / meta references

Comments anchored to an identifier that lives *outside* the source file and evolves on its own schedule. The referent moves, the comment doesn't, and the comment rots into misdirection.

### 1a. Issue-tracker IDs as the reason

- **Looks like:** `// ABC-1234`, `// fixes ABC-1234`, `# see #123`, `// per LINEAR-456`, `// ASANA task 789`, GitHub `#123` used as the *justification* for code.
- **Harmful:** The ticket gets closed, re-scoped, or deleted; the rationale is now unreachable from the code. A bare ID conveys nothing to a future reader without tracker access.
- **Remedy:** If the ID is the comment's only content, delete it (the link belongs in the commit/PR, where it's anchored to a diff). If the ticket documented a real constraint, inline the constraint: `// retry only on 429; the upstream API rate-limits per-account` instead of `// see ABC-1234`.

### 1b. Spec / RFC section references

- **Looks like:** `// §9.1`, `// per RFC 7231 §6.5.1`, `// see spec section 4.2`, `// matches the protocol doc table 3`.
- **Harmful:** Section numbering is reorganized across spec revisions; "section 4.2" silently points somewhere else. The reader still has to go read the spec to learn anything.
- **Remedy:** State the actual rule the spec imposes, in code terms: `// 404 must not carry a body per HTTP semantics` instead of `// per RFC 7231 §6.5.1`. Keep a stable identifier (the RFC number) only if it adds traceability *and* the constraint is also stated inline.

### 1c. Task-plan / phase references

- **Looks like:** `// Phase 7`, `// phase 2 work`, `// TODO(milestone 3)`, `// part of the Q3 migration`, `// step 4 of the rollout plan`.
- **Harmful:** Plans complete and are discarded; the phase label becomes archaeological noise that means nothing post-merge.
- **Remedy:** Delete. If the code is genuinely conditional on a migration state, encode that as a real guard (feature flag, version check) with a WHY comment — not a prose reference to a defunct plan.

---

## Pass 2 — Temporal anchoring (LLM-authorship smell)

Comments that narrate *time* — when work will happen, what shortcut was taken, or how the code changed. Strong tell of generated or hastily-edited code. Three sub-families.

### 2a. Forward-deferral

- **Looks like:** "for now", "for the time being", "going forward", "in the future", "down the line", "later", "eventually", plus deferral verbs bound to an open horizon — "handle X later", "fix this eventually", "implement properly going forward", "revisit", "refactor this someday", "clean up later".
- **Harmful:** Prose deferral is untracked and untrackable. It drifts: the "for now" becomes permanent, and nobody knows the trigger that was supposed to retire it.
- **Remedy:** Do the work now if cheap. Otherwise write an auditable TODO with an owner and a *concrete* trigger: `// TODO(jdoe): switch to streaming once payloads exceed 10MB in prod` instead of `// load it all for now, optimize later`. No owner + no trigger = delete the deferral.

### 2b. Stub-admission

- **Looks like:** "in a real implementation", "in a real system", "in the real world", "in production", "would normally", "for simplicity", "to keep things simple", "placeholder until", "for demo/illustration purposes", "toy example", "happy-path only", "this is just a stub".
- **Harmful:** Ships a stand-in dressed as complete. The admission lives in a comment nobody reads at call time; the stub silently returns wrong/partial results in production.
- **Remedy:** Implement it properly, or make the gap loud at runtime — `raise NotImplementedError`, `panic("unimplemented: <what>")`, a typed error. A failing call is recoverable; a silently-wrong stub is a latent incident. Never leave the gap documented only in a comment.

### 2c. Retro-temporal

- **Looks like:** "newly added", "now we", "as of this change", "previously", "used to", "updated to", "changed to", "this was X before", "refactored from".
- **Harmful:** Narrates edit history in the source. It's wrong the moment the *next* change lands, and the history it describes already lives — accurately and permanently — in VCS.
- **Remedy:** Delete. `git blame` / `git log` is the authoritative changelog. If a *current* invariant is worth stating, state it in present tense without reference to what it replaced.

---

## Pass 3 — Poor structure / WHAT-not-WHY bloat

**No comment is better than a bad comment.** A comment earns its place only by saying something the code cannot: WHY (rationale, tradeoff, non-obvious constraint) or HOW at a level the code doesn't show (algorithm choice, invariant, gotcha).

### 3a. WHAT-narration

- **Looks like:** `// increment i`, `// loop over users`, `// set the flag to true`, `// return the result`, `// constructor`, doc-comments that restate the signature (`// getName returns the name`).
- **Harmful:** Pure restatement. Doubles the surface to maintain, adds zero information, and goes stale when the code below it changes but the narration doesn't.
- **Remedy:** Delete WHAT-narration outright. If the line is non-obvious *for a reason*, replace the narration with the reason: `// users is pre-sorted by signup date; binary search is safe` instead of `// loop over users`.

### 3b. Commented-out code

- **Looks like:** Blocks of real code disabled with comment syntax, often with no explanation.
- **Harmful:** Dead weight. Readers can't tell if it's a deliberate alternative, a debugging leftover, or a half-done change. It also drifts out of sync with the live code around it.
- **Remedy:** Delete. VCS preserves it if it's ever needed. Rare exception: a deliberately-disabled alternative kept for a *stated* reason — then keep it with a WHY comment explaining the condition under which it'd be re-enabled.

### 3c. Stale / contradicting doc-comments

- **Looks like:** A doc-comment whose description, params, return, or examples no longer match the implementation.
- **Harmful:** Actively misleads — worse than no comment, because readers trust doc-comments and propagate the lie into call sites.
- **Remedy:** Fix it to match the code, or delete it if the signature is self-documenting. Never leave a doc-comment that lies.

---

## Keep list (do NOT flag)

These earn their place — leave them:

- WHY a non-obvious choice was made: `// LinkedHashMap to preserve insertion order for the API contract`.
- A real constraint or invariant: `// callers must hold the lock; mutates shared state`.
- A documented gotcha: `// off-by-one is intentional — the API uses inclusive ranges`.
- Algorithm rationale the code can't show: `// Boyer-Moore: input is huge and pattern is short`.
- Legal/license headers and required pragmas (`// nolint:...`, `# type: ignore`) — these are functional, not narrative.
