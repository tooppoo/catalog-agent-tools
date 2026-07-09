# Bad Comment Patterns

This reference describes comments that should usually be removed, rewritten, or replaced by better code.

Use this file when reviewing existing comments or when deciding whether a proposed comment is harmful noise rather than useful maintenance knowledge.

## Basic Rule

A bad comment either repeats what the code already says, hides a design problem, or gives maintainers misleading confidence.

Bad comments are not harmless.

They can:

* make code harder to scan
* become stale
* obscure the actual invariant
* preserve obsolete reasoning
* encourage maintainers to trust the comment instead of the code
* make AI agents overfit to misleading explanations
* compensate for poor naming instead of fixing it

A comment should earn its place.

## 1. Code Translation Comment

A code translation comment restates the code in natural language.

Bad:

```ts
// Increment index by one.
index += 1;
```

Bad:

```ts
// If the user is active, return true.
if (user.active) {
  return true;
}
```

These comments add no maintenance knowledge.

They should be removed.

Better:

```ts
index += 1;
```

```ts
if (user.active) {
  return true;
}
```

If the code is hard to understand, improve names or structure instead of translating it.

## 2. Syntax Explanation Comment

A syntax explanation comment explains the programming language rather than the program.

Bad:

```ts
// Use await to wait for the promise.
const result = await loadConfig();
```

Bad:

```rs
// Match on the enum.
match command {
    Command::Init => run_init(),
    Command::Add => run_add(),
}
```

These comments are not useful for maintainers who can read the language.

If the syntax is genuinely obscure, prefer extracting a named helper or linking to a design reason, not explaining basic syntax.

## 3. Naming Compensation Comment

A naming compensation comment explains a poorly named variable, function, type, or module.

Bad:

```ts
// d is the destination directory.
const d = resolveDestination(input);
```

Better:

```ts
const destinationDirectory = resolveDestination(input);
```

Bad:

```ts
// Handles manifest loading and validation.
function process(input: string) {
  ...
}
```

Better:

```ts
function loadAndValidateManifest(input: string) {
  ...
}
```

If a better name can remove the comment, rename first.

## 4. Obvious Comment

An obvious comment states a fact that is already clear from the code.

Bad:

```ts
// Return the result.
return result;
```

Bad:

```ts
// Create an empty array.
const errors: Diagnostic[] = [];
```

Bad:

```ts
// Throw an error if path is missing.
if (!path) {
  throw new Error("path is required");
}
```

Remove these comments unless they explain a non-obvious policy or invariant.

## 5. Commented-Out Code

Commented-out code should usually be removed.

Bad:

```ts
// const result = oldParser(input);
const result = newParser(input);
```

Reasons to remove it:

* version control already preserves history
* it is unclear whether the old code is still relevant
* it can mislead readers
* it invites accidental restoration

If the old behavior matters, explain the current compatibility rule instead.

Better:

```ts
// Keep accepting the old parser's field names so pre-v0.3 manifests remain loadable.
const result = newParser(input);
```

## 6. Raw Historical Note

A raw historical note records past events without explaining current relevance.

Bad:

```ts
// This was changed during the parser rewrite.
return parseManifest(input);
```

Better:

```ts
// Preserve the parser rewrite's stricter duplicate-key behavior because diagnostics depend on it.
return parseManifest(input);
```

History is useful only when it explains a present constraint.

If the history is substantial, move it to an ADR, design document, migration note, or issue.

## 7. Vague Warning

A vague warning tells maintainers to be careful without explaining the risk.

Bad:

```ts
// Be careful when changing this.
return resolveConfig(input);
```

Bad:

```ts
// Important.
const normalized = normalize(input);
```

Better:

```ts
// Do not resolve user config before project config. Project config must remain able to override user defaults.
return resolveConfig(input);
```

A useful warning identifies the failure mode.

## 8. Vague Security Comment

A vague security comment uses security language without specifying the security property.

Bad:

```ts
// Sanitize for security.
const safePath = normalizePath(input);
```

Better:

```ts
// Reject parent-relative segments so untrusted input cannot escape the workspace root.
const safePath = normalizePath(input);
```

Security comments must be concrete.

They should state what attack, misuse, or unsafe state is being prevented.

## 9. Aspirational Comment

An aspirational comment describes what the code should do, not what it actually guarantees.

Bad:

```ts
// This ensures the file is always safe.
writeFile(path, contents);
```

If the code does not actually ensure the property, the comment is misleading.

Better:

```ts
// Atomic rename prevents readers from observing a partially written file.
writeTempFile(tempPath, contents);
rename(tempPath, finalPath);
```

Do not use comments to claim guarantees that the implementation does not provide.

## 10. Comment That Hides a Design Problem

A comment can make bad structure look acceptable.

Bad:

```ts
// This function validates input, resolves providers, writes files, prints CLI output,
// and updates global state.
function run(input: Input) {
  ...
}
```

The comment reveals that the function has too many responsibilities.

Better:

```ts
const resolved = resolveProviders(input);
const validated = validateInput(resolved);
const result = writeFiles(validated);
printResult(result);
```

If a comment describes too many responsibilities, consider refactoring.

## 11. Comment That Explains a Workaround Without a Boundary

A workaround comment is weak if it does not explain the condition under which the workaround can be removed.

Bad:

```ts
// Workaround for Windows.
const pathText = path.replaceAll("\\", "/");
```

Better:

```ts
// Normalize separators before snapshot comparison because snapshots use POSIX-style paths on all platforms.
const pathText = path.replaceAll("\\", "/");
```

Even better, when temporary:

```ts
// TODO(#231): Remove this once snapshot serialization normalizes paths before comparison.
const pathText = path.replaceAll("\\", "/");
```

A workaround comment should explain whether the workaround is permanent, compatibility-preserving, or temporary.

## 12. Bare Issue or ADR Reference

A bare reference forces the reader to leave the code before understanding the local rule.

Bad:

```ts
// See #184.
return resolveProvider(input);
```

Bad:

```ts
// ADR-0007.
return resolveProvider(input);
```

Better:

```ts
// Resolve providers before validation so diagnostics can include provider-specific requirements.
// See docs/adr/0007-provider-resolution-order.md.
return resolveProvider(input);
```

A reference should support a local explanation, not replace it.

## 13. Duplicated ADR Rationale

The opposite error is copying the full ADR into code.

Bad:

```ts
// We considered three options for provider resolution. The first was to resolve providers
// inside the domain layer, but that would require provider-specific defaults to leak into
// domain types. The second was to resolve after validation, but that produced diagnostics
// that changed depending on command order. The third was to resolve at the CLI boundary,
 // which we accepted because it keeps the domain independent while preserving diagnostics.
return resolveProvider(input);
```

Better:

```ts
// Resolve at the CLI boundary so provider-specific defaults do not leak into domain types.
// See docs/adr/0007-provider-resolution-order.md.
return resolveProvider(input);
```

Keep durable design reasoning in design records.

Keep code comments local.

## 14. Stale Comment

A stale comment contradicts the current code.

Bad:

```ts
// This returns null when config is missing.
return defaultConfig;
```

Stale comments are defects.

They are often worse than no comment because they actively mislead maintainers.

When reviewing comments, verify that they still match the implementation.

## 15. Over-Broad Comment

An over-broad comment claims more than the code proves.

Bad:

```ts
// Validate manifest.
validateRequiredFields(manifest);
```

If the function only validates required fields, do not claim full manifest validation.

Better:

```ts
// Validate required fields before schema-level checks produce less specific diagnostics.
validateRequiredFields(manifest);
```

Comments should be precise about scope.

## 16. Policy Hidden in a Local Comment

A local code comment is not the right place to define broad project policy.

Bad:

```ts
// We always use JSON for machine-readable data and KDL for human-authored data.
writeProvenanceJson(data);
```

Better:

```ts
// Provenance is machine-readable, so it follows the project JSON policy.
// See docs/adr/0015-machine-readable-provenance-json.md.
writeProvenanceJson(data);
```

The policy should live in an ADR or design document.

The code comment should state the local application of that policy.

## 17. Misleading TODO

A TODO is misleading when it is vague, unowned, untracked, or not actionable.

Bad:

```ts
// TODO: fix later.
```

Bad:

```ts
// TODO: improve this code.
```

Better:

```ts
// TODO(#184): Remove legacy field support after the v0.4 migration window closes.
```

A good TODO states:

* what should change
* when or why it should change
* where the work is tracked

If the TODO represents an unresolved decision, use `TBD.md` instead.

## 18. Emotional or Blaming Comment

Comments should not blame previous authors, users, dependencies, or maintainers.

Bad:

```ts
// This stupid API returns inconsistent values.
```

Better:

```ts
// The API returns either a scalar or an array, so normalize before validation.
```

A comment should be operationally useful.

Do not encode frustration in code.

## 19. Comment Used Instead of a Test

A comment cannot prove behavior.

Bad:

```ts
// This handles empty manifests correctly.
return parseManifest(input);
```

Better:

```ts
return parseManifest(input);
```

Add or update a test that proves the behavior.

Use a comment only if there is a non-obvious reason behind the behavior.

## 20. Comment Used Instead of a Type

A comment should not replace type information that can be expressed directly.

Bad:

```ts
// id is a non-empty string.
const id: string = input.id;
```

Better:

```ts
type NonEmptyString = string & { readonly __brand: unique symbol };

const id: NonEmptyString = parseNonEmptyString(input.id);
```

Use comments for knowledge the type system cannot reasonably express.

Do not use comments as a substitute for available type-level guarantees.

## Review Procedure

When reviewing a bad or suspicious comment:

1. Identify what knowledge the comment claims to preserve.
2. Check whether that knowledge is already visible from the code.
3. Check whether the comment is still true.
4. Check whether better naming, typing, extraction, or restructuring would remove the need for it.
5. Check whether the comment belongs in code or in a design record.
6. Remove the comment if it adds no maintenance value.
7. Rewrite the comment if it contains useful knowledge in a poor form.
8. Create or reference a durable design record if the reasoning is too large for code.

## Rewrite Patterns

### From code translation to intent

Bad:

```ts
// Sort entries.
entries.sort(compareEntries);
```

Better:

```ts
// Keep generated output deterministic across platforms.
entries.sort(compareEntries);
```

### From vague warning to failure mode

Bad:

```ts
// Do not change this.
return normalize(input);
```

Better:

```ts
// Normalize before validation so diagnostics report canonical paths.
return normalize(input);
```

### From raw history to current constraint

Bad:

```ts
// Added after the v0.2 parser bug.
return parse(input);
```

Better:

```ts
// Reject duplicate keys so manifests affected by the v0.2 parser bug fail explicitly.
return parse(input);
```

### From bare reference to local implication

Bad:

```ts
// See ADR-0008.
loadConfiguration();
```

Better:

```ts
// Load project config before user config so project-local policy wins.
// See docs/adr/0008-configuration-precedence.md.
loadConfiguration();
```

## Removal Checklist

Remove a comment when:

* it only restates the code
* it explains syntax
* it compensates for a bad name
* it is stale
* it is vague
* it claims a guarantee the code does not provide
* it records history without current relevance
* it duplicates a design document
* it hides a design problem
* it should be a test, type, ADR, issue, or `TBD.md` entry instead

Keep or rewrite a comment when it preserves necessary maintenance knowledge that the code cannot express directly.
