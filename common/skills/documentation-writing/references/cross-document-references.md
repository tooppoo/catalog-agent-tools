# Cross-Document References

Read this file whenever information is needed in more than one document, when splitting or moving documents, or when reviewing documentation for duplication.

## Single authoritative home

Every substantive piece of durable knowledge should have one authoritative home.

Examples:

- exact syntax belongs in a generated syntax reference
- a user workflow belongs in the user guide
- an architecture invariant belongs in the developer guide
- a design decision belongs in an ADR
- reading order belongs in an index or AI guide

Other documents should link to the authoritative home.

## No substantive duplication

Do not copy or paraphrase the same substantive explanation into multiple documents.

This rule applies even when:

- the second document serves a different audience
- repeating the information seems more convenient
- the copied section is short
- the documents are maintained by different teams
- the wording is changed

Changing the wording does not eliminate duplication.
The duplicated claim can still drift.

## How to reference existing information

When another document contains the needed information:

1. provide only the local context required to explain why the reader should follow the link
2. use descriptive link text
3. link to the most specific stable section or anchor when practical
4. do not summarize the linked section in detail
5. keep the authoritative statement in one place

Good:

```md
The parser rejects unsupported tuple validation during schema preparation.
See [the schema preparation rules](semantics/schema-preparation.md#tuple-validation) for the normative behavior.
```

Avoid:

```md
The parser rejects unsupported tuple validation during schema preparation because only homogeneous arrays are supported.
The same rule is also described in the schema preparation document.
```

The second example duplicates the rule and creates two sources that may diverge.

## Index descriptions

Indexes may contain short descriptions such as:

- the document's role
- its audience
- when to read it
- whether it is normative, generated, historical, or planned

Indexes must not reproduce the document's substantive argument, specification, or procedure.

Good:

```md
- [Execution model](guide/execution-model.md): Read this before writing assertions that depend on checkpoints.
```

Avoid copying the execution model into the index.

## Cross-audience references

Different audiences may need the same underlying fact.

Use layered references:

- user guide explains the workflow and links to the generated contract
- developer guide explains the invariant and links to the same generated contract
- AI guide links to both in the required reading order

Do not create separate copies of the contract for each audience.

## Repetition required by external formats

Some formats require standalone completeness, such as:

- generated command help
- machine-readable schemas
- published package metadata
- externally mandated notices

When the same content must appear in multiple outputs:

1. generate all copies from one authoritative source
2. do not maintain the copies independently
3. add drift checks
4. document the source and generation path

Manual duplication remains prohibited.

## Moving or splitting documents

When moving or splitting documentation:

1. identify the authoritative home of every substantive section
2. move the section rather than copy it
3. replace removed copies with references
4. update indexes
5. update source comments and AI reading guides
6. update generated paths, fixtures, snapshots, and checks
7. search for stale references to the old path
8. preserve historical path mentions in ADRs only when clearly historical

## Link durability

Prefer:

- relative repository links
- stable headings and anchors
- descriptive labels
- links to authoritative documents rather than temporary issues

Use issue links for active planning or unresolved work.
Move durable conclusions into documentation or ADRs when the decision is finalized.

## Review test

For every repeated-looking statement, ask:

> If this fact changes, how many files must be edited?

The preferred answer is one authoritative source plus regenerated outputs.
If multiple hand-written files must be edited, the documentation structure is duplicating knowledge.
