# Source of Truth and Generation

Read this file when documenting facts about syntax, CLI commands, configuration, schemas, protocols, diagnostics, artifacts, APIs, or implementation structure.

## Generation-first rule

Prefer generated documentation when information can be derived deterministically from:

1. executable or mechanically validated specifications
2. schemas or structured registries
3. implementation definitions
4. fixtures or tests
5. hand-written prose

The earlier source should be preferred as the authoritative source when practical.

Hand-written reference tables are the fallback, not the default.

## Strong candidates for generation

Prefer generation or mechanical verification for:

- CLI commands, options, arguments, defaults, and allowed values
- configuration keys and types
- syntax and grammar
- schema definitions
- diagnostic and error codes
- exit codes
- artifact and protocol fields
- API surfaces
- generated file layouts
- module or component inventories
- exact output examples
- state-machine transitions
- compatibility matrices that can be derived from structured data

## What should not be generated

Do not treat these as generation targets merely because generation is technically possible:

- why the project exists
- why a design was selected
- why alternatives were rejected
- goals and non-goals
- trade-offs
- maintenance cautions
- user mental models
- task-oriented explanation
- conceptual introductions
- ethical or product rationale
- unresolved questions

These require human judgment and should remain hand-authored.

## Generated document requirements

A generated document should make its status clear.

When practical, provide:

- the authoritative source
- the generator
- the generation command
- a drift-check command
- a generated-file header
- a warning against direct editing
- deterministic output
- tests for the generator

Change the source or generator, not the generated output.

## Verification as an alternative

Full generation is not always necessary.

Mechanical verification may be sufficient when:

- prose structure requires human organization
- examples need explanation
- a generated format would be less readable
- the source only covers part of the document

Possible verification techniques include:

- executing documented commands
- checking examples against fixtures
- validating tables against schemas
- snapshot testing generated fragments
- checking listed identifiers against a registry
- link checking
- asserting byte-for-byte generated sections

Use verification to prevent factual drift without forcing all prose into generated form.

## Fallback sequence

Before writing implementation-derived facts manually, consider:

1. Can the information be generated from a schema, registry, or executable specification?
2. Can a fixture or test become the authoritative source?
3. Can a small generated section be embedded in a hand-written document?
4. Can the prose link directly to an existing generated reference?
5. Can a validation check ensure that the hand-written statement remains accurate?

Only duplicate facts manually when none of these approaches is practical.

## Relationship to user and developer guides

A generated reference answers "what exactly exists?"

A user guide answers:

- when to use it
- how to use it in a workflow
- what mistakes to avoid
- how to interpret the result

A developer guide answers:

- why the boundary exists
- what invariants must be preserved
- what changes together
- where the authoritative definitions live

Do not copy complete generated tables into user or developer guides.
Link to the generated reference and explain only the relevant context.

## Drift review

When implementation-derived behavior changes, verify all of the following:

- the authoritative source changed
- generated output was regenerated
- drift checks pass
- user workflows remain accurate
- developer design explanations remain accurate
- AI reading guides still point to the correct reference
- indexes still classify the document correctly
