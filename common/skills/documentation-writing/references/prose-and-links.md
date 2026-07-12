# Prose and Links

Read this file when writing or editing Markdown prose, README files, ADRs, design documents, documentation comments, or natural-language source comments.

## Semantic line breaks

Do not insert a newline inside a natural-language sentence merely because the line is long.

Line breaks should express semantic structure, not visual column width.

If a line feels too long:

1. shorten the sentence
2. split it into multiple sentences
3. convert parallel conditions into a list
4. move excessive local detail into an appropriate document

Prefer one logical paragraph per physical line unless the repository intentionally uses sentence-per-line prose.

Bad:

```md
This command validates the workspace and reports diagnostics
for all configured providers before writing output.
```

Good:

```md
This command validates the workspace and reports diagnostics for all configured providers before writing output.
```

Also acceptable:

```md
This command validates the workspace.
It reports diagnostics for all configured providers before writing output.
```

## File references in Markdown prose

When referring to a repository file in Markdown prose, use a Markdown link whenever practical.

Prefer:

```md
See [the runtime requirements document](docs/generated-installer-runtime.md).
```

Avoid:

```md
See docs/generated-installer-runtime.md.
```

Use descriptive link text when the role of the file matters.

A path may remain inline code when it is a literal value, command argument, output, or syntax example.

Example:

```md
The default configuration path is `reportage.kdl`.
```

Do not invent links to files that do not exist unless the task explicitly proposes those files.
When proposing a new file, make its proposed status clear.

## Link exceptions

Do not linkify paths inside:

- code blocks
- terminal examples
- generated snapshots
- machine-readable configuration
- quoted source material
- literal command or syntax examples
- formats that do not support Markdown links

## Source comments

Do not split one comment sentence across multiple lines merely because of width.

Bad:

```ts
// The runner captures stdout and stderr separately so that
// callers can assert stream-specific behavior.
```

Good:

```ts
// The runner captures stdout and stderr separately so callers can assert stream-specific behavior.
```

Also good:

```ts
// The runner captures stdout and stderr separately.
// This lets callers assert stream-specific behavior.
```

When comment content becomes too large, move the durable explanation into a design document or ADR and leave a short local summary plus a link.

## Documentation comments

Split documentation comments at semantic boundaries.

Prefer:

```ts
/**
 * Parses the workspace path.
 *
 * Rejects absolute paths, empty paths, parent-directory segments, and paths that cannot be normalized safely.
 */
```

Use a list when the items are independently important.

## Allowed line breaks

A prose line break is appropriate for:

- a new paragraph
- a heading
- a list item
- a table row
- a code block boundary
- a sentence boundary in sentence-per-line repositories
- a deliberate separation between distinct comment statements
- format-required output

## Fidelity exceptions

Preserve hard line breaks when required by:

- exact quotations
- poetry or verse
- tables
- code blocks
- generated snapshots
- terminal output
- formatter-controlled source code
- an explicit repository convention

Apply exceptions narrowly.
