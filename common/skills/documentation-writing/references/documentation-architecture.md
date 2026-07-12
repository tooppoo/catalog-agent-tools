# Documentation Architecture

Read this file when creating a documentation tree, reorganizing existing documents, separating audiences, or designing index files.

## Audience separation

Durable repository documentation should distinguish at least these audiences.

### User guide

The user guide helps someone use the product correctly.

It may contain:

- getting started
- task-oriented workflows
- conceptual introductions
- configuration guidance
- troubleshooting
- practical examples
- links to exact generated references

It should not expose internal implementation detail unless that detail is necessary for correct use.

Exact syntax, complete option tables, schemas, and other implementation-derived facts should normally live in generated or mechanically verified references.

### Developer guide

The developer guide helps maintainers understand and change the system safely.

It may contain:

- architecture
- component responsibilities
- data and control flow
- invariants
- extension points
- contribution workflows
- testing strategy
- change procedures
- compatibility boundaries
- links to ADRs and generated references

It should explain why responsibility boundaries exist.
It should not manually reproduce module inventories, API lists, schemas, or other facts that can be generated from implementation.

### AI-facing documentation

AI-facing documentation is a thin navigation layer.

It should contain:

- reading order
- task-specific entrypoints
- authoring constraints
- warnings about planned versus implemented behavior
- pointers to authoritative user, developer, generated, and ADR documents

It should not duplicate the full user guide, developer guide, or normative specification.
An AI-facing file should usually answer "what should be read next?" rather than "what is the entire specification?"

### ADRs

ADRs preserve decisions that cannot be reconstructed reliably from the final implementation.

They should contain:

- context
- decision
- considered alternatives
- rejected alternatives
- trade-offs
- consequences

ADRs should link to current design and implementation documentation rather than repeat their full contents.

## Index files

Provide an index for each major audience or documentation area.

A common layout is:

```text
docs/
├── README.md
├── guide/
│   └── README.md
├── design/
│   └── README.md
├── ai/
│   └── README.md
└── adr/
```

Repository conventions may use different names, but the roles should remain explicit.

Each index should explain:

- who the section is for
- what kinds of documents it contains
- when each document should be read
- recommended reading order
- which documents are normative, generated, explanatory, or historical

An index is not a summary copy of every document.
Use one or two sentences to explain a document's role, then link to it.

Every durable document should be reachable from at least one index.
A document that is intentionally excluded from normal reading order should still be discoverable from an appropriate planning, archive, or internal index.

## Information placement

Place information according to its durable responsibility.

- Exact externally observable contract: generated reference or executable specification
- How to perform a user task: user guide
- Why the implementation is divided this way: developer guide
- Why one design was chosen over another: ADR
- What an AI agent should read: AI index
- What remains undecided: planning or TBD document

Do not place the same substantive explanation in multiple locations.

## Splitting mixed documents

Split a document when it mixes responsibilities such as:

- user workflow and internal architecture
- normative specification and design rationale
- implemented behavior and future plans
- AI instructions and human explanation
- generated facts and hand-written interpretation

After splitting:

1. choose one authoritative home for each substantive claim
2. replace copied sections with links
3. update all relevant indexes
4. preserve stable identifiers when the repository exposes them externally
5. update generators, checks, fixtures, and references that depend on paths

## Navigation over registries

A central metadata registry is optional.

Do not introduce one merely because multiple indexes exist.
Use an existing registry when it already serves the same document set and ordering.
Introduce new metadata only when it solves a demonstrated synchronization or discovery problem.

Manually curated indexes are acceptable when they serve distinct audiences and do not duplicate substantive content.
