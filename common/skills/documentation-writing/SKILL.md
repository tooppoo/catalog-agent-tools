---
name: documentation-writing
description: Plan, organize, write, generate, and review durable repository documentation by separating user, developer, and AI audiences; preferring generated references from executable specifications or implementation; avoiding duplicated knowledge across documents; and reserving hand-written prose for rationale, purpose, workflows, trade-offs, and other context that cannot be derived mechanically.
---

# Documentation Writing

## Purpose

Create repository documentation that is navigable, resistant to drift, explicit about audience, and clear about its authoritative source.

This skill applies both to documentation architecture and to documentation prose.
It extends ordinary writing rules with source-of-truth, generation, indexing, audience separation, and cross-document reference rules.

## Core principles

1. Separate user-facing guidance, developer-facing design documentation, and AI-facing navigation.
2. Provide index files that explain what to read, who should read it, and when.
3. Prefer generated reference material for facts that can be derived from executable specifications, schemas, registries, fixtures, tests, or implementation.
4. Use hand-written documentation primarily for purpose, rationale, rejected alternatives, trade-offs, workflows, mental models, and responsibility boundaries.
5. Do not duplicate substantive information across documents.
6. When another document already contains the required information, link to that document instead of rewriting the same information.
7. Keep AI-facing documentation thin and navigational.
8. Do not treat generated files as hand-edited sources.
9. Preserve semantic line breaks and navigable file references.
10. Validate generated output, links, examples, indexes, and prose before declaring documentation work complete.

## Scope

Apply the full skill when creating, reorganizing, or reviewing durable repository documentation, including:

- documentation trees
- user guides
- developer guides
- AI-facing reading guides
- generated references
- architecture and design documents
- ADRs
- README files that act as documentation entrypoints
- documentation generation and validation workflows

For issue descriptions, PR descriptions, changelogs, and similar prose, apply the relevant prose and link rules.
Do not impose the full repository documentation architecture unless the task changes durable documentation.

For code-comment content decisions, use the repository's code-comment skill when available.
This skill still governs documentation links and prose structure inside comments.

## Default workflow

1. Inspect the existing documentation tree, indexes, implementation, executable specifications, schemas, fixtures, tests, generators, and ADRs.
2. Identify the target audience and the document role.
3. Find whether the required information already has an authoritative home.
4. If it already exists, reference it instead of duplicating it.
5. Decide whether each factual section can be generated or mechanically verified.
6. Generate implementation-derived reference material whenever practical.
7. Write only the human-authored context that cannot be derived mechanically.
8. Update the relevant user, developer, AI, and root indexes.
9. Run generators, drift checks, examples, link validation, and repository-provided documentation checks.
10. Review the result for duplicated knowledge, unclear authority, orphaned documents, and stale references.

## Supporting references

Read only the references needed for the current task.

- Read [documentation architecture](references/documentation-architecture.md) when creating, reorganizing, or splitting documentation by audience, or when adding or reviewing index files.
- Read [source of truth and generation](references/source-of-truth-and-generation.md) when documenting syntax, CLI behavior, configuration, schemas, protocols, diagnostics, artifacts, APIs, or other facts that may be generated from executable specifications or implementation.
- Read [human-authored documentation](references/human-authored-documentation.md) when writing purpose, rationale, goals, non-goals, workflows, mental models, trade-offs, rejected alternatives, responsibility boundaries, or ADR-like material.
- Read [cross-document references](references/cross-document-references.md) whenever information is needed in more than one document, when moving or splitting documents, or when reviewing for duplication.
- Read [prose and links](references/prose-and-links.md) when editing Markdown prose, file references, documentation comments, or line structure.
- Read [the review checklist](references/review-checklist.md) before declaring a documentation change complete.

## Compact decision rules

### Audience

- Users need task-oriented guidance, concepts, troubleshooting, and links to exact references.
- Developers need architecture, invariants, responsibility boundaries, extension points, and change procedures.
- AI agents need reading order, constraints, and pointers to authoritative documents.
- ADRs preserve why a decision was made and why alternatives were rejected.

### Generation

Ask:

> Can this information be derived deterministically from an executable specification, schema, registry, fixture, test, or implementation?

If yes, prefer generation or mechanical verification.
Do not manually duplicate the generated facts in prose.

### Duplication

Ask:

> Does another document already contain this substantive information?

If yes, link to it.
Do not restate it merely for convenience.

Indexes may contain short role descriptions and reading-order guidance, but must not reproduce the substantive contents of the indexed documents.

### Hand-written content

Use hand-written prose for knowledge that code and specifications do not preserve well:

- purpose
- rationale
- intent
- goals and non-goals
- rejected alternatives
- trade-offs
- mental models
- workflows
- responsibility boundaries
- maintenance cautions
- unresolved questions

## Skill maintenance

Keep this file as a compact entrypoint and reading guide.

If this skill would exceed 500 lines:

1. move detailed rules, examples, exceptions, and checklists into files under `references/`
2. keep only the purpose, core principles, default workflow, compact rules, and reference index here
3. explain exactly when each reference should be read
4. split by responsibility and task context, not by arbitrary line count
5. avoid duplicating the same rule between this file and a reference file
6. make one location authoritative and link to it from the others
