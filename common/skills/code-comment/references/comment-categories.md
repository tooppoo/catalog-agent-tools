  
# Comment Categories

This reference describes common categories of useful code comments.

Use this file when the compact rule in `SKILL.md` is not enough to decide whether a comment is justified, or when you need examples of comments that preserve meaningful design knowledge.

## Basic Rule

A good comment preserves knowledge that is necessary for safe maintenance and cannot be read directly from the code.

A comment is usually justified when it explains one of these things:

* why the code has this shape
* why a simpler-looking alternative is wrong
* what invariant must be preserved
* what semantic behavior must not change
* what external constraint affects the implementation
* what boundary the code is protecting
* what future maintainers or AI agents must not accidentally change

A comment is not justified merely because the code is complex.

If the complexity can be removed by better naming, typing, extraction, or restructuring, improve the code first.

## 1. Why This Code Exists

Use this kind of comment when the reason for the code is not visible from the local implementation.

The comment should explain the purpose, not translate the operations.

Bad:

```ts
// Check if the value is null.
if (value === null) {
  return defaultValue;
}
```

Good:

```ts
// Treat explicit null as "use the default" for compatibility with legacy config files.
if (value === null) {
  return defaultValue;
}
```

The good comment explains a compatibility rule that is not obvious from the condition itself.

## 2. Rejected Simpler Alternative

Use this kind of comment when a simpler implementation would look attractive but would be wrong.

The comment should prevent future maintainers or AI agents from "simplifying" the code incorrectly.

Bad:

```ts
// Use a loop here.
for (const item of items) {
  result.push(normalize(item));
}
```

Good:

```ts
// Do not use Array.prototype.map here. Some supported runtimes patch Array methods,
 // and this path must remain independent of patched prototypes.
for (const item of items) {
  result.push(normalize(item));
}
```

A rejected-alternative comment is especially useful when the current code looks unnecessarily verbose, defensive, or indirect.

## 3. Semantic Behavior

Use this kind of comment when the important point is not the operation itself, but the meaning of the behavior.

Bad:

```ts
// Sort the entries.
entries.sort(compareEntries);
```

Good:

```ts
// Keep output deterministic so generated snapshots do not change across platforms.
entries.sort(compareEntries);
```

The good comment explains the semantic role of sorting.

## 4. Invariant

Use this kind of comment when a condition must remain true across future changes.

The invariant should be stated explicitly.

Bad:

```ts
// Validate count.
if (count < 0) {
  throw new Error("count must be non-negative");
}
```

Good:

```ts
// Invariant: count is non-negative after this point because downstream range generation assumes it.
if (count < 0) {
  throw new Error("count must be non-negative");
}
```

Use invariant comments sparingly.

If the invariant can be expressed through the type system or a smaller abstraction, prefer that.

## 5. Boundary or Layer Responsibility

Use this kind of comment when the code is protecting an architectural boundary.

This is useful in codebases where domain logic, infrastructure logic, CLI logic, generated code, or compatibility layers must remain separated.

Bad:

```ts
// Convert the value.
const output = toCliOutput(result);
```

Good:

```ts
// Keep CLI formatting at the boundary. Domain results must stay independent of terminal output concerns.
const output = toCliOutput(result);
```

Boundary comments should identify the responsibility being protected.

Do not use them to justify arbitrary layering.

## 6. External Constraint

Use this kind of comment when the implementation is constrained by something outside the codebase.

Examples include:

* protocol behavior
* file format compatibility
* operating system behavior
* compiler or runtime limitations
* third-party API behavior
* security model constraints
* migration requirements
* generated output stability

Bad:

```ts
// Use LF.
const newline = "\n";
```

Good:

```ts
// Always emit LF because generated files are compared byte-for-byte in CI.
const newline = "\n";
```

When the external constraint is durable and documented elsewhere, prefer a short local summary plus a reference.

## 7. Error Semantics

Use this kind of comment when error handling has non-obvious meaning.

This is especially useful when the code intentionally continues, retries, suppresses an error, converts an error type, or preserves partial state.

Bad:

```ts
// Ignore the error.
try {
  await removeTemporaryFile(path);
} catch {
}
```

Good:

```ts
// Cleanup failure must not mask the original operation result. The temporary file is best-effort cleanup.
try {
  await removeTemporaryFile(path);
} catch {
}
```

Error comments should explain why the behavior is safe or necessary.

If the behavior is not safe, the comment is not a substitute for fixing it.

## 8. Security-Sensitive Behavior

Use this kind of comment when code exists to preserve a security property that is not obvious locally.

Good examples include comments explaining:

* why a path must be normalized before use
* why a symlink check is repeated
* why shell invocation is avoided
* why environment variables are filtered
* why untrusted input is not interpolated
* why a race condition defense is structured in a particular way

Bad:

```ts
// Sanitize path.
const safePath = normalizeUserPath(input);
```

Good:

```ts
// Normalize before joining so absolute or parent-relative user input cannot escape the workspace root.
const safePath = normalizeUserPath(input);
```

Security comments should be concrete.

Avoid vague comments such as `// for security`.

## 9. Compatibility Behavior

Use this kind of comment when code preserves behavior for existing users, old files, old configuration, or older versions of a tool.

Bad:

```ts
// Support old name.
const value = config.newName ?? config.oldName;
```

Good:

```ts
// Keep reading oldName so projects created before v0.3 remain loadable.
const value = config.newName ?? config.oldName;
```

Compatibility comments should usually identify the compatibility target.

If the compatibility requirement has an expiry condition, record it in an issue, TODO, or migration document.

## 10. Long or Non-Obvious Block Purpose

Use this kind of comment when a block is locally complex and cannot immediately be extracted without making the code worse.

The comment should summarize the block's semantic purpose.

Bad:

```ts
// Loop over files and collect results.
for (const file of files) {
  ...
}
```

Good:

```ts
// Build the dependency closure in discovery order so diagnostics can report the first user-visible cause.
for (const file of files) {
  ...
}
```

Prefer extraction when a named function would communicate the meaning better.

Use a block comment only when extraction would obscure locality or introduce artificial abstractions.

## 11. Generated Code and Snapshots

Use this kind of comment when code controls generated output, snapshot stability, or regeneration behavior.

Good comments explain:

* whether a file is generated
* how to regenerate it
* whether manual edits are allowed
* why ordering or formatting must remain stable
* how generated and checked-in files are compared

Example:

```sh
# Keep this order stable. The generated install script is compared with the checked-in copy in CI.
generate_install_script
```

Generated-code comments should prevent accidental manual drift.

## 12. Domain-Specific Meaning

Use this kind of comment when a term, rule, or transformation has domain meaning that is not visible from generic code.

Bad:

```ts
// Filter invalid states.
const validStates = states.filter(isValidState);
```

Good:

```ts
// Exclude transitional states. They are observable in logs but must not appear in persisted snapshots.
const validStates = states.filter(isPersistableState);
```

Domain comments are useful when a future maintainer may know the programming language but not the domain rule.

## 13. Performance Constraint

Use this kind of comment when the implementation is shaped by a real performance constraint.

The comment should identify the constraint.

Bad:

```ts
// Faster.
const cache = new Map<string, Result>();
```

Good:

```ts
// Cache parsed manifests because large workspaces may reference the same catalog entry hundreds of times.
const cache = new Map<string, Result>();
```

Avoid speculative performance comments.

If the performance constraint was measured, reference the benchmark, issue, or profiling note when practical.

## 14. Concurrency or Ordering Constraint

Use this kind of comment when ordering, locking, atomicity, or idempotency matters.

Bad:

```ts
// Do this first.
await writeTempFile(path, contents);
await renameTempFile(path, finalPath);
```

Good:

```ts
// Write then rename so readers never observe a partially written file.
await writeTempFile(path, contents);
await renameTempFile(path, finalPath);
```

Concurrency and ordering comments should explain the failure mode being avoided.

## 15. AI-Agent Guardrail

Use this kind of comment when an AI agent is likely to make an unsafe edit because the local code appears redundant, verbose, or inconsistent.

This category should be used carefully.

It must not become a general excuse for noisy comments.

Good:

```ts
// Keep this duplicate validation. The CLI path and library path can be called independently.
validateInput(input);
```

A good AI-agent guardrail comment identifies the mistaken edit it is preventing.

## Comment Quality Checklist

Before keeping or adding a comment, ask:

* Does it explain knowledge that is not directly visible from the code?
* Would a future maintainer be likely to make a wrong change without it?
* Does it explain why, not merely what?
* Is it still true?
* Is it specific enough to guide maintenance?
* Could better naming, typing, extraction, or restructuring make it unnecessary?
* Does it belong in code, or should the durable reasoning live in an ADR, design document, issue, or `TBD.md`?

If the answer is unclear, prefer improving the code or creating a durable design record rather than adding a weak comment.

