# Human-Authored Documentation

Read this file when writing conceptual guides, architecture explanations, design notes, ADRs, goals, non-goals, workflows, trade-offs, or rejected alternatives.

## Purpose

Human-authored documentation should preserve knowledge that implementation and executable specifications do not express adequately.

Its purpose is not to translate code into prose.
Its purpose is to preserve intent, context, judgment, and guidance.

## Appropriate content

Human-authored documents should focus on questions such as:

- Why does this feature or system exist?
- What problem is it intended to solve?
- What is explicitly outside its scope?
- Why was this design selected?
- Why were plausible alternatives rejected?
- What trade-offs were accepted?
- What responsibility boundary must be preserved?
- What mental model should a user or maintainer adopt?
- What workflow should be followed?
- What failure modes or misuse should be avoided?
- What remains undecided?

## Content to avoid duplicating

Do not manually repeat:

- complete CLI option lists
- exact grammar productions
- schemas
- protocol field lists
- diagnostic code inventories
- implementation-derived module lists
- generated examples
- facts already explained authoritatively in another document

Link to the authoritative source instead.

## User-oriented hand-written content

Useful user-guide prose includes:

- task-oriented walkthroughs
- conceptual introductions
- decision guidance
- troubleshooting
- example selection and interpretation
- warnings about misuse
- links to exact references

A user guide may mention a small fact needed to make a sentence understandable, but it should not reproduce the authoritative reference section.
Prefer phrasing such as:

```md
Configure the command in the project configuration.
See [the configuration reference](reference/configuration.md) for the complete field definitions.
```

## Developer-oriented hand-written content

Useful developer-guide prose includes:

- architecture rationale
- component responsibility
- invariants
- extension boundaries
- maintenance hazards
- expected change impact
- testing strategy
- links to implementation and generated references

Do not document every type or function manually.
Explain the design structure that helps a maintainer interpret those types and functions.

## ADR content

An ADR should preserve:

- the context at decision time
- the decision
- the alternatives considered
- the reasons for rejection
- the accepted consequences
- follow-up constraints

Do not turn an ADR into a second design manual.
Link to the current design documentation for the resulting architecture.

## Planning and unresolved questions

Separate planned or undecided behavior from current documentation.

Use a planning, proposal, or TBD document for unresolved matters.
Make its non-normative status explicit.
Do not let AI-facing reading order present planned behavior as implemented behavior.

## Review questions

Before keeping a hand-written section, ask:

- Does this preserve knowledge that cannot be derived mechanically?
- Is this the correct audience and document type?
- Is the same information already written elsewhere?
- Could this section be replaced by a short explanation and a link?
- Will a future implementation change make this prose stale?
- Does this belong in an ADR instead?
