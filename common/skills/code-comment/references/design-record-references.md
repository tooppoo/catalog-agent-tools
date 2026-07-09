# Design Record References in Comments

This reference explains when code comments should refer to ADRs, design documents, issues, or `TBD.md` entries.

Use this file when a code comment needs more background than should be placed directly in code.

## Basic Rule

Code comments should not become miniature design documents.

When the full reasoning is too large for a local comment, keep only a short local summary in the code and point to a durable record.

Use this pattern:

```ts
// Keep provider-specific resolution out of the domain layer.
// See docs/adr/0007-provider-resolution-boundary.md.
```

The local summary prevents misreading.

The reference preserves the full reasoning.

## What Belongs in Code

A code comment should contain the minimum local knowledge needed to avoid an unsafe edit.

Good local comment contents include:

* the current invariant
* the architectural boundary being protected
* the external constraint that affects this code
* the specific reason the implementation looks unusual
* the concrete risk of changing it
* a short pointer to the durable record

A code comment should not contain:

* the full historical debate
* long rejected alternatives
* complete issue discussion
* large migration plans
* extensive rationale copied from an ADR
* unresolved product or architecture questions

## What Belongs in ADRs

Use an ADR when the comment depends on a significant design decision.

An ADR is appropriate when the reasoning involves:

* a selected architecture
* a rejected architecture
* compatibility policy
* storage format policy
* dependency policy
* security model
* public API behavior
* long-term migration direction
* cross-module responsibility boundaries
* a decision that future maintainers must understand beyond one local code site

Code comment:

```ts
// Store snapshots as normalized data, not presentation text.
// See docs/adr/0012-snapshot-normalization.md.
```

ADR:

```md
# ADR 0012: Normalize snapshot data before presentation

## Status

Accepted

## Context

...

## Decision

...

## Consequences

...
```

The comment should not duplicate the ADR.

It should only summarize the local implication.

## What Belongs in Design Documents

Use a design document when the reasoning is broader than one decision or still describes an evolving subsystem.

A design document is appropriate for:

* subsystem overview
* terminology
* data flow
* lifecycle
* command behavior
* generated file behavior
* integration behavior
* operational model
* multiple related decisions

Code comment:

```ts
// This parser accepts only the consumer manifest shape.
// Catalog manifest parsing is intentionally separate.
// See docs/manifest-format.md.
```

The design document should contain the full model.

The code comment should state the local boundary.

## What Belongs in Issues

Use an issue reference when the comment points to pending work, a known limitation, or a tracked migration.

Issue references are appropriate when:

* the current code is intentionally temporary
* a workaround should be removed later
* compatibility support has a planned removal path
* an incomplete behavior is accepted for now
* a follow-up task has clear scope
* the implementation is blocked by another change

Code comment:

```ts
// Keep accepting this legacy field until the migration in #184 is complete.
```

Avoid issue references for permanent design decisions.

If the issue contains a decision that should remain durable after the issue is closed, create or update an ADR or design document.

## What Belongs in `TBD.md`

Use `TBD.md` when a question is intentionally unresolved and must not be silently settled by implementation.

A `TBD.md` entry is appropriate when:

* a decision is explicitly deferred
* multiple alternatives remain viable
* the implementation chooses a temporary behavior
* future work must revisit the question
* the code must avoid implying that a policy has been finalized

Code comment:

```ts
// Temporary default while catalog alias semantics remain undecided.
// See TBD.md#catalog-alias-resolution.
```

The `TBD.md` entry should state:

* the unresolved question
* known alternatives
* current temporary behavior
* what evidence or decision would close the question
* affected code or documents

Do not use `TBD.md` for ordinary TODOs.

Use it only for unresolved decisions that need deliberate future judgment.

## References Must Not Replace Local Meaning

A bare reference is usually insufficient.

Bad:

```ts
// See ADR-0009.
return resolveProvider(input);
```

Good:

```ts
// Resolve providers before validation so diagnostics can report provider-specific requirements.
// See docs/adr/0009-provider-resolution-order.md.
return resolveProvider(input);
```

The good comment tells a maintainer what not to break even before reading the ADR.

## Avoid Copying Long Rationale into Code

Bad:

```ts
// We considered keeping provider resolution in the domain layer, but this would require every
// domain type to understand provider-specific defaults. We also considered performing resolution
// after validation, but this would produce unstable diagnostics. Therefore we resolve before
// validation and keep the provider-specific logic in the CLI adapter layer. See ADR-0009.
return resolveProvider(input);
```

Good:

```ts
// Resolve before validation so diagnostics are provider-aware without moving provider logic into the domain layer.
// See docs/adr/0009-provider-resolution-order.md.
return resolveProvider(input);
```

Put the full rationale in the ADR.

Keep the code comment local and operational.

## Stable Reference Format

Prefer references that are stable within the repository.

Recommended:

```ts
// See docs/adr/0012-snapshot-normalization.md.
```

Acceptable:

```ts
// See #184.
```

Risky:

```ts
// See the discussion in Slack.
```

Avoid references to private, ephemeral, or inaccessible discussions.

If the reasoning matters, copy the relevant conclusion into a durable repository document.

## Referencing GitHub Issues

Issue references are useful, but they have limits.

Use issue references for:

* active follow-up work
* temporary compatibility code
* tracked cleanup
* migration progress
* unresolved implementation tasks

Do not use issue references as the only durable record for major design decisions.

When an issue becomes the place where a design decision is settled, convert the decision into an ADR or design document before relying on it from code.

## Referencing ADRs

ADR references should be used when the code implements or protects an accepted decision.

Good:

```ts
// Keep provenance machine-readable only. Human-authored metadata remains KDL.
// See docs/adr/0015-provenance-json.md.
```

Avoid referencing an ADR when the comment is only about a local implementation detail.

## Referencing Design Documents

Design document references should be used when the code belongs to a broader subsystem model.

Good:

```ts
// This path handles only project-scoped configuration.
// User and machine scopes are loaded by the configuration precedence layer.
// See docs/configuration.md.
```

A design document reference should help the reader find the larger model.

## Referencing `TBD.md`

`TBD.md` references should make uncertainty explicit.

Good:

```ts
// Do not infer branch aliases here. Alias semantics are intentionally unresolved.
// See TBD.md#branch-aliases.
```

Bad:

```ts
// TODO: maybe support aliases later.
```

The good comment avoids accidentally turning a deferred decision into an implicit implementation decision.

## TODO Comments

Use TODO comments only when they point to specific, actionable work.

Good:

```ts
// TODO(#184): Remove oldName after the v0.4 migration window closes.
```

Bad:

```ts
// TODO: improve this.
```

A TODO should normally include:

* what should be done
* why it is not done now, if non-obvious
* a tracking issue or document reference
* an expiry condition, when applicable

If a TODO represents an unresolved decision rather than an implementation task, prefer `TBD.md`.

## Historical Background

Avoid putting raw history in comments.

Bad:

```ts
// This used to be parsed differently before the parser rewrite.
```

Good:

```ts
// Accept both forms so manifests created before the parser rewrite remain loadable.
```

History is useful only when it explains a current constraint.

If the historical background is substantial, move it to an ADR, migration note, or design document.

## Comment Shape with References

Prefer this shape:

```ts
// <short local reason or invariant>.
// See <durable-reference>.
```

Examples:

```ts
// Preserve discovery order because diagnostics report the first user-visible cause.
// See docs/manifest-resolution.md.
```

```ts
// Keep this duplicate validation. The CLI and library entry points can be called independently.
// See docs/adr/0018-validation-boundaries.md.
```

```ts
// Temporary behavior while registry alias semantics are undecided.
// See TBD.md#registry-alias-semantics.
```

## Review Checklist

When reviewing a comment that references a design record, ask:

* Does the comment contain a short local reason?
* Is the referenced file durable and accessible?
* Is the reference specific enough?
* Is the full rationale kept out of code?
* Is the comment still true after the referenced decision?
* Is an issue being used where an ADR or design document is more appropriate?
* Is `TBD.md` being used for an actually unresolved decision, not an ordinary task?
* Does the comment prevent a plausible unsafe edit?

If the comment only says `See X`, rewrite it to include the local implication.
