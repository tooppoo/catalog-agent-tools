---
name: code-comment
description: Reviews, writes, revises, and removes code comments by judging whether a comment is needed and ensuring comments explain intent, constraints, invariants, responsibility boundaries, external requirements, rejected alternatives, or deferred decisions rather than translating code into natural language.
---

# Code Comment Skill

## Purpose

This skill helps AI agents and human maintainers review, write, revise, and remove code comments.

The goal is not to increase the number of comments. The goal is to preserve knowledge that is necessary for safe maintenance and cannot be read directly from the code.

## Core Principle

Prefer self-explanatory code over explanatory comments.

Use comments only when the code alone cannot clearly communicate the relevant meaning, reason, constraint, risk, or responsibility boundary.

A comment is justified when it answers at least one of these questions:

- Why does this code exist?
- Why is an apparently simpler alternative not used?
- What semantic behavior must be preserved?
- What invariant must not be broken?
- What role does this module, type, function, or block play in the larger design?
- What external constraint affects this implementation?
- What should future maintainers or AI agents avoid changing accidentally?

Avoid comments that merely restate what the code does line by line.

## Comment Decision Rule

Use a comment when at least one of the following is true:

- the reason is not obvious from the code
- an apparently simpler implementation would be wrong
- an invariant must be preserved
- a module or layer boundary must be protected
- external behavior constrains the implementation
- error handling has non-obvious semantics
- deterministic, compatibility, security, recovery, or user-facing behavior depends on the current shape
- a long or non-obvious block has a semantic purpose that is not clear locally

Do not use a comment when:

- it merely repeats the code
- it explains syntax
- it compensates for poor naming
- it records change history without current relevance
- it states an obvious fact
- it makes complex code look acceptable instead of improving the code

If better naming, typing, or function extraction can make the comment unnecessary, improve the code first.

## Supporting References

Read these files only when the task needs details beyond the compact rules in this file:

- For detailed categories of good comments and examples, read
  [references/comment-categories.md](references/comment-categories.md).

- For comments that reference ADRs, design documents, issues, or TBD.md entries, read
  [references/design-record-references.md](references/design-record-references.md).

- For examples of comments that should be removed or rewritten, read
  [references/bad-comment-patterns.md](references/bad-comment-patterns.md).

- For systematic comment review, read
  [references/review-checklist.md](references/review-checklist.md).

## AI Agent Behavior

When asked to add, review, or revise comments:

1. First decide whether a comment is needed at all.
2. Prefer code improvement over comment addition when naming or structure is the real problem.
3. Add comments only where they explain intent, constraints, invariants, boundaries, rejected alternatives, external requirements, non-obvious error semantics, or deferred decisions.
4. Remove or rewrite comments that merely translate code.
5. Treat stale or misleading comments as defects.
6. Do not over-comment straightforward code.
7. If a design decision is too large for a code comment, suggest or create an ADR or design document and keep only a short local pointer in the code.
8. If a question is intentionally unresolved, ensure it is recorded in `TBD.md` and reference that entry from the code comment.
9. If an existing ADR, document, issue, or `TBD.md` entry already explains the background, reference it instead of duplicating the explanation.
10. Never use a bare reference when a short local summary is needed to prevent misreading.

## Compact Rule

A comment is justified when it preserves knowledge necessary for safe maintenance that cannot be read directly from the code.

A good comment says:

- why this shape exists
- what must remain true
- what boundary must not be crossed
- what external rule constrains the implementation
- what deferred decision must not be accidentally settled
- where to find the durable record when the full reasoning belongs elsewhere

A bad comment says only what the code already says.
