# Code Comment Review Checklist

This reference provides a systematic checklist for reviewing code comments.

Use this file when a task explicitly asks for comment review, code review, comment cleanup, or comment quality assessment.

## Review Goal

The goal is not to maximize or minimize comments.

The goal is to ensure that every retained comment preserves necessary maintenance knowledge that cannot be read directly from the code.

A good review should identify:

* comments to keep
* comments to remove
* comments to rewrite
* places where a comment should be added
* places where code should be improved instead of commented
* places where an ADR, design document, issue, or `TBD.md` entry is more appropriate than a long comment

## Review Output Categories

Classify findings using these categories.

### Keep

Use this when the comment is accurate, useful, and appropriately local.

A kept comment should usually explain:

* intent
* invariant
* boundary
* external constraint
* rejected alternative
* compatibility requirement
* error semantics
* security property
* deterministic behavior
* deferred decision

### Remove

Use this when the comment adds no maintenance value or is actively harmful.

Remove comments that:

* restate the code
* explain syntax
* compensate for poor naming
* are stale
* are vague
* are misleading
* duplicate a design record
* preserve irrelevant history
* hide a design problem

### Rewrite

Use this when the comment contains useful knowledge but expresses it poorly.

Rewrite comments that:

* say what instead of why
* are too vague
* are too long
* lack the failure mode
* contain raw history instead of current constraints
* use a bare reference without local meaning
* overstate what the code guarantees

### Add

Use this when the code has a non-obvious maintenance risk that is not visible locally.

Add comments when:

* a simpler-looking implementation would be wrong
* an invariant must be preserved
* ordering or atomicity matters
* external compatibility constrains the code
* generated output must remain stable
* security behavior depends on a non-obvious shape
* error handling intentionally suppresses or converts errors
* a boundary must not be crossed
* an unresolved decision is intentionally deferred

### Refactor Instead

Use this when a comment is trying to explain code that should be clearer.

Prefer refactoring when:

* a better name would remove the comment
* a helper function would expose the intent
* a type could encode the constraint
* a test could prove the behavior
* a smaller module boundary would clarify responsibility
* the comment describes too many responsibilities

### Move to Design Record

Use this when the comment contains reasoning that is too large or durable for local code.

Move or summarize into:

* ADR, for accepted design decisions
* design document, for subsystem behavior
* issue, for tracked implementation work
* `TBD.md`, for intentionally unresolved decisions

## Step-by-Step Review

## 1. Read the Code Before Judging the Comment

Do not judge a comment in isolation.

Check:

* what the code actually does
* what surrounding code assumes
* what tests assert
* what names and types already communicate
* what module or layer the code belongs to
* whether the comment is still accurate

A comment that sounds good can still be stale.

A comment that sounds redundant may preserve a non-obvious external constraint.

## 2. Identify the Comment's Claim

Ask what the comment is claiming.

Common claim types:

* this code exists for compatibility
* this order matters
* this value must remain stable
* this layer must not depend on another layer
* this branch is intentionally unreachable
* this error is intentionally ignored
* this behavior is temporary
* this implements a design decision
* this prevents a security issue

If the claim is unclear, the comment probably needs rewriting.

## 3. Check Whether the Code Already Says It

Ask whether the same knowledge is already obvious from:

* function name
* variable name
* type name
* type constraint
* module name
* control flow
* test name
* surrounding abstraction

If yes, the comment may be redundant.

Example:

```ts
// Get user by ID.
const user = getUserById(id);
```

Remove it.

## 4. Check Whether the Comment Explains Why

A useful comment usually explains why the code has this shape.

Weak:

```ts
// Sort entries.
entries.sort(compareEntries);
```

Strong:

```ts
// Keep generated output deterministic across platforms.
entries.sort(compareEntries);
```

If a comment only says what, rewrite it to say why or remove it.

## 5. Check for a Plausible Wrong Edit

A comment is more justified when it prevents a plausible wrong edit.

Ask:

* Would an AI agent likely simplify this incorrectly?
* Would a maintainer remove a duplicate-looking validation?
* Would someone reorder calls and break diagnostics?
* Would someone change output ordering and break snapshots?
* Would someone inline a boundary and couple layers?
* Would someone remove compatibility behavior too early?

If no plausible wrong edit exists, the comment may not be necessary.

## 6. Check for Staleness

A stale comment is a defect.

Check whether:

* the described behavior still exists
* the referenced issue or ADR still applies
* the compatibility target still matters
* the TODO is still actionable
* the comment names the right type, command, field, or layer
* the comment describes the current failure mode

Do not preserve stale comments for historical interest.

## 7. Check Precision

A comment should not be broader than the implementation.

Bad:

```ts
// Validate manifest.
validateRequiredFields(manifest);
```

Better:

```ts
// Validate required fields before schema validation so diagnostics can identify missing keys precisely.
validateRequiredFields(manifest);
```

Ask:

* Does the comment overstate the guarantee?
* Does it describe the exact scope?
* Does it identify the specific invariant or failure mode?
* Does it use vague words like "safe", "important", "temporary", or "legacy" without explanation?

## 8. Check Whether Code Should Change Instead

Before adding or keeping a comment, ask whether the code can be made self-explanatory.

Prefer:

* clearer names
* smaller functions
* stronger types
* explicit domain objects
* narrower modules
* tests
* validation helpers
* named constants

Example:

Bad:

```ts
// t is the timeout in milliseconds.
const t = 5000;
```

Better:

```ts
const timeoutMilliseconds = 5000;
```

Do not let comments compensate for avoidable obscurity.

## 9. Check Design Record Placement

Ask whether the comment contains too much design reasoning.

If the reasoning is local, keep it in code.

If the reasoning is broad or durable, move it to a design record.

Use:

* ADR for accepted decisions
* design document for subsystem models
* issue for pending work
* `TBD.md` for unresolved decisions

Bad:

```ts
// See ADR-0009.
return resolveProvider(input);
```

Better:

```ts
// Resolve providers before validation so diagnostics can include provider-specific requirements.
// See docs/adr/0009-provider-resolution-order.md.
return resolveProvider(input);
```

The comment should include local meaning even when it references a durable record.

## 10. Check TODO and TBD Usage

TODO comments should be specific and actionable.

Good:

```ts
// TODO(#184): Remove oldName after the v0.4 migration window closes.
```

Bad:

```ts
// TODO: clean this up.
```

Use `TBD.md` when the question is intentionally unresolved.

Good:

```ts
// Temporary default while catalog alias semantics remain undecided.
// See TBD.md#catalog-alias-resolution.
```

Do not use TODO for open design questions that require deliberate judgment.

## 11. Check Security Comments

Security comments must identify the protected property or failure mode.

Bad:

```ts
// Sanitize for security.
const safePath = normalizePath(input);
```

Good:

```ts
// Reject parent-relative segments so untrusted input cannot escape the workspace root.
const safePath = normalizePath(input);
```

Ask:

* What attack or unsafe behavior is prevented?
* Is the comment precise?
* Does the implementation actually provide the claimed protection?
* Should the behavior be covered by a test?

## 12. Check Error Handling Comments

Error handling comments are useful when the behavior is non-obvious.

Good:

```ts
// Cleanup failure must not mask the original operation result.
try {
  await removeTemporaryFile(path);
} catch {
}
```

Ask:

* Why is the error ignored, wrapped, retried, or converted?
* Is the behavior safe?
* Is the original error preserved when needed?
* Is the user-facing diagnostic still correct?
* Should the behavior be tested?

## 13. Check Generated Output and Snapshot Comments

Generated output often needs comments because deterministic behavior may not be obvious.

Good:

```ts
// Keep this order stable. Generated snapshots are compared byte-for-byte in CI.
entries.sort(compareEntries);
```

Ask:

* Is ordering significant?
* Is formatting significant?
* Is this file generated?
* How is it regenerated?
* Are manual edits allowed?
* Is generated output compared with checked-in output?
* Should the comment point to a generator or test?

## 14. Check Compatibility Comments

Compatibility comments should identify the compatibility target.

Bad:

```ts
// Legacy support.
const value = config.newName ?? config.oldName;
```

Good:

```ts
// Keep reading oldName so projects created before v0.3 remain loadable.
const value = config.newName ?? config.oldName;
```

Ask:

* What old version, file, API, or behavior is supported?
* Is the compatibility support permanent or temporary?
* Is removal tracked?
* Is the migration window documented?

## 15. Check Architectural Boundary Comments

Boundary comments should state the responsibility being protected.

Good:

```ts
// Keep CLI formatting at the boundary. Domain results must stay independent of terminal output concerns.
const output = toCliOutput(result);
```

Ask:

* Which boundary is being protected?
* What dependency must not be introduced?
* Is the boundary already documented?
* Should this refer to an ADR or design document?

## 16. Check AI-Agent Risk

Some comments exist to prevent common AI-agent mistakes.

Use them only when the risk is concrete.

Good:

```ts
// Keep this duplicate validation. The CLI and library entry points can be called independently.
validateInput(input);
```

Bad:

```ts
// AI: do not change.
validateInput(input);
```

A useful AI-agent guardrail explains the reason, not merely the instruction.

## Finding Format

When reporting review findings, use this structure:

````md
## Finding: <short title>

Category: Keep | Remove | Rewrite | Add | Refactor Instead | Move to Design Record

Current comment:

```<language>
...
````

Assessment:

<Explain what the comment currently does and whether it preserves necessary maintenance knowledge.>

Recommendation:

<Concrete edit, removal, rewrite, or design-record action.>

```

For small reviews, a compact bullet list is sufficient.

## Compact Checklist

Use this checklist for quick review:

- Does the comment explain why, not merely what?
- Is the comment still true?
- Does it preserve knowledge not visible from code?
- Does it prevent a plausible wrong edit?
- Is it specific about the invariant, boundary, constraint, or failure mode?
- Could better naming, typing, extraction, or tests make it unnecessary?
- Is it too long for code?
- Should the durable reasoning live in an ADR, design document, issue, or `TBD.md`?
- Does any reference include a local summary?
- Does any TODO have a clear action and tracking reference?
- Does any security comment state the actual protected property?
- Does any compatibility comment identify the supported version or behavior?
- Does any generated-output comment explain ordering, formatting, or regeneration constraints?

## Final Review Judgment

After reviewing comments, summarize the result in these terms:

- acceptable as written
- acceptable after minor rewrites
- over-commented
- under-commented in non-obvious areas
- contains stale or misleading comments
- requires code refactoring rather than more comments
- requires ADR, design document, issue, or `TBD.md` updates

Prefer specific findings over broad style preferences.

The standard is maintainability, not comment density.
```
