# Documentation Review Checklist

Read this file before declaring documentation work complete.

## Audience and architecture

- Is the target audience explicit?
- Is user guidance separated from developer design information?
- Is AI-facing documentation thin and navigational?
- Is the document reachable from an appropriate index?
- Does each index explain who should read the document and when?
- Are current, planned, generated, and historical materials distinguishable?

## Source of truth

- Does every substantive claim have one authoritative home?
- Is any implementation-derived fact maintained manually without need?
- Could a schema, registry, fixture, test, or implementation generate the information?
- Are generated files changed through their source or generator?
- Is the generated status visible?
- Is there a drift check?

## Duplication

- Does another document already contain the same substantive information?
- Has copied or paraphrased content been replaced with a link?
- Do indexes avoid reproducing substantive content?
- Do user, developer, and AI documents link to one shared reference instead of copying it?
- If duplication is externally required, are all copies generated from one source?
- If a fact changes, is there only one hand-written source to edit?

## Human-authored content

- Does the prose focus on purpose, rationale, workflows, mental models, trade-offs, rejected alternatives, or boundaries?
- Is code merely being translated into prose?
- Does rationale belong in an ADR?
- Are unresolved matters marked as non-normative planning content?
- Are exact contracts delegated to generated or verified references?

## Links and navigation

- Are prose file references links when practical?
- Are link labels descriptive?
- Are links relative and stable when possible?
- Are there orphan documents?
- Are moved or split documents reflected in all indexes?
- Are stale path references removed from current links, source comments, generators, fixtures, and snapshots?
- Are historical path mentions clearly historical?

## Prose structure

- Are line breaks semantic rather than width-based?
- Is any sentence mechanically hard-wrapped?
- Would a list make parallel conditions clearer?
- Are source comments split at semantic boundaries?
- Is excessive comment detail moved into durable documentation?

## Generation and validation

Run repository-provided checks when available.

Possible checks include:

```sh
git diff --name-only -- '*.md' '*.markdown' | scripts/docs/check-markdown-semantic-line-breaks.sh
git diff --name-only -- '*.md' '*.markdown' | scripts/docs/check-bare-markdown-paths.sh -n
```

Also run, when applicable:

- documentation generators
- generated-file drift checks
- executable examples
- fixture validation
- snapshot tests
- Markdown link checks
- schema validation
- AI reading-order generation
- repository-wide checks

Validation scripts are validators, not discovery tools.
Determine the relevant files from changed files, task scope, or the repository's check recipe.

If a required validator is unavailable:

1. state that clearly
2. perform the equivalent manual review
3. do not claim the unavailable check passed

Passing automated checks is necessary but not sufficient.
Complete the manual review in this checklist.

## Final questions

Before returning the change, ask:

- Can a new user find the correct starting point?
- Can a maintainer find the rationale and invariants?
- Can an AI agent identify the authoritative documents and reading order?
- Can exact facts drift independently across multiple files?
- Is generated information generated or mechanically verified?
- Is hand-written prose preserving knowledge that cannot be derived from code?
- Are all substantive cross-document repetitions replaced with references?
