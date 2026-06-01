---
name: comment-audit
description: Audit and clean up source-code comments in any language. Use when asked to audit comments, clean up comments, remove LLM comment smell, fix comment rot, or do a comment cleanup. Removes stale cross-references (Jira/GitHub/RFC/phase refs), temporal/LLM-authorship tells ("for now", "in a real implementation", "previously"), and WHAT-not-WHY narration; keeps WHY/HOW comments.
---

# Comment Audit

Audit comments for rot and noise, then apply fixes behind one review gate. Headline principle: **no comment is better than a bad comment.**

## Architecture

ONE read pass over the target files into memory. Then THREE sequential audit passes over that in-memory content — do not re-read files per pass. Collect all findings, present them grouped, gate once, then apply approved edits.

Read-only tools (Read, Grep, Glob, git) during the audit. Make edits only after the gate approves.

## Workflow

1. **Resolve scope.** If the user named files, directories, or a diff, audit those. Otherwise default to the current git diff (`git diff --name-only` plus staged) and state that you are doing so. Skip generated and vendored files (lockfiles, `vendor/`, `node_modules/`, `dist/`, `*.pb.go`, `*_generated.*`, minified assets).
2. **Read once.** Read each in-scope file fully into memory. This is the only read pass.
3. **Run the three passes** over the in-memory content. See [references/comment-smells.md](references/comment-smells.md) for the full detection catalog — trigger phrases, why each is harmful, and the remedy per family.
   - Pass 1 — Shifting / meta references.
   - Pass 2 — Temporal anchoring (LLM-authorship smell).
   - Pass 3 — Poor structure / WHAT-not-WHY bloat.
4. **Present findings**, grouped by pass then by file. Per finding: `file:line`, the offending comment, which family it hit, and the proposed remedy (delete / rewrite-to-state-constraint / upgrade-to-WHY). Quote the exact replacement for rewrites.
5. **Gate once.** Call `AskUserQuestion` with header `Review` and options `Apply` / `Revise`. On `Apply`, make the edits. On `Revise`, take the user's adjustments and re-present, then gate again. Do not edit before approval.
6. **Apply** approved edits and report a one-line-per-file summary of what changed.

## Pass summary

Detail and examples live in [references/comment-smells.md](references/comment-smells.md). Quick map:

- **Pass 1 — Shifting / meta references.** Comments anchored to identifiers outside the source (issue IDs, spec/RFC sections, task-plan phases) that drift independently and rot into misdirection. Remedy: if the comment's value *is* the cross-ref, delete it; if it states a real constraint, rewrite to state the constraint directly without the volatile ref.
- **Pass 2 — Temporal anchoring.** Three sub-families: *forward-deferral* ("for now", "eventually"), *stub-admission* ("in a real implementation", "for simplicity"), *retro-temporal* ("previously", "now we", "as of this change"). Remedies, respectively: do the work or write an auditable TODO with owner + concrete trigger; implement properly or fail loudly (raise/panic/not-implemented); delete — that history belongs in VCS.
- **Pass 3 — Poor structure.** WHAT-narration that restates the code (`// increment i`), commented-out code, and stale doc-comments that contradict the code. Remedy: delete pure WHAT-narration and commented-out code; upgrade salvageable comments to state the WHY (rationale, tradeoff, non-obvious constraint, invariant, gotcha); fix doc-comments that lie. Keep comments that explain WHY, or HOW at a level the code can't show.

## Rules

- Never delete a comment whose content is a genuine WHY/HOW or a real constraint; instead, rewrite it to drop the volatile anchor while preserving the substance.
- Never silently downgrade a stub into shipped code; instead, implement it or make it fail loudly.
- Never re-read a file mid-pass; instead, operate on the in-memory copy from the single read pass.
- Never apply edits before the gate; instead, present all findings and wait for `Apply`.
- When a comment's intent is ambiguous (could be WHY or could be noise), flag it as `uncertain` and propose, but defer to the user at the gate rather than auto-deleting.
