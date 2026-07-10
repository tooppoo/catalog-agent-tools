---
name: cli-output-design
description: Designs and reviews CLI output contracts that are concise for humans, structured for AI and automation, diagnosable on failure, safe around file mutations, and resistant to sensitive-data leakage.
---

# CLI Output Design Skill

## Purpose

Use this skill to design, review, or revise command-line interface output.

The goal is not to maximize the amount of output. The goal is to make every command result:

* clear enough for a human to act on
* structured enough for AI and automation to interpret reliably
* diagnosable when it fails
* explicit about file-system mutations
* safe against accidental disclosure of sensitive information

This skill applies to command output, exit codes, warnings, errors, execution logs, JSON output, dry-run behavior, and file-change reporting.

## Normative Terms

The terms **MUST**, **MUST NOT**, **SHOULD**, **SHOULD NOT**, and **MAY** express requirement strength.

* **MUST / MUST NOT**: required for compliance
* **SHOULD / SHOULD NOT**: expected unless a documented constraint justifies an exception
* **MAY**: optional

## Core Principles

1. Successful output SHOULD be concise.
2. Every command MUST support `--format json`.
3. Command behavior and diagnostic generation MUST NOT depend on the selected output format.
4. Exit codes MUST identify a broad error category; using exit code `1` for every failure is not acceptable.
5. Detailed failure causes MUST be represented by stable error codes and structured diagnostics.
6. Errors MUST state whether the user can recover from them.
7. Recoverable errors MUST state a concrete recovery action.
8. File mutations MUST be reported on both success and failure.
9. Commands that can create, modify, or delete files MUST support `--dry-run`.
10. File mutations SHOULD be implemented atomically where practical.
11. Sensitive information MUST NOT be emitted unless it is safely redacted.

## Required Output Formats

Commands MAY support additional formats, but they MUST support at least:

* `--format text`, either explicitly or as the default
* `--format json`

Do not use a dedicated `--json` flag as the primary interface when defining this contract. Use `--format json` so additional formats can be introduced without adding format-specific flags.

## Stream Contract

### Text format

* Successful results and requested normal output go to stdout.
* Errors go to stderr.
* Warnings go to stderr.
* Warnings normally preserve exit code `0`.
* Requested execution logs MAY be emitted as they occur.

### JSON format

* The command MUST emit exactly one JSON envelope.
* A successful envelope goes to stdout.
* A failed envelope goes to stderr.
* The opposite stream SHOULD remain empty.
* Warnings and requested execution logs MUST NOT be emitted separately as text.
* Warnings, logs, file changes, results, and errors MUST be accumulated and included in the final envelope.
* ANSI escape sequences, color codes, progress animations, and other terminal decoration MUST NOT appear in JSON output.

Read [references/json-envelope.md](references/json-envelope.md) for the common envelope contract and examples.

## Format-Independent Command Design

Business logic, validation, warning generation, error classification, recovery guidance, and file-change tracking MUST NOT branch on the selected output format.

The command MUST produce structured output records such as:

* result
* warning
* log
* file change
* error

The output layer alone decides how and when those records are rendered or flushed.

* A text output implementation MAY flush warnings and requested logs immediately.
* A JSON output implementation MUST buffer the records and emit one final envelope.

This is a language-independent architectural requirement. It does not prescribe a specific class hierarchy, interface name, callback type, event system, or library.

Read [references/output-model.md](references/output-model.md) when designing the command/output boundary.

## Exit Codes and Errors

Exit codes MUST distinguish broad categories such as:

* command usage
* invalid input or configuration
* file-system failure
* environment or dependency failure
* external service failure
* state conflict
* internal failure

A project MAY choose different category names and numeric values, but it MUST document a stable mapping.

Exit code `1` MAY remain available as an uncategorized fallback, but known error categories MUST use more specific exit codes.

Every handled error MUST include:

* a stable error code
* a broad category consistent with the exit code
* a concise user-facing message
* whether the user can recover from the error
* a concrete recovery action when recovery is possible

When a specific file caused the error, the diagnostic MUST include its path. When available, it SHOULD also include a line, column, range, key, field, entry, or other precise location.

Read [references/errors-warnings-exit-codes.md](references/errors-warnings-exit-codes.md) for detailed rules.

## Warnings

Warning support is optional.

If warnings are introduced:

* they normally preserve exit code `0`
* text output writes them to stderr
* JSON output includes them in `warnings[]`
* the CLI MUST provide a strict-equivalent setting that promotes warnings to failures

The strict-equivalent mechanism MAY be a command option, configuration value, environment-specific policy, or another documented interface.

## File Mutations

Commands that may create, modify, or delete files MUST:

* support `--dry-run`
* report planned changes during dry-run
* report actual changes after normal execution
* report partial changes if execution fails after changing files
* distinguish created, modified, and deleted files
* keep `--dry-run` compatible with `--format json`

Dry-run MUST NOT mutate files or other persistent state represented as part of the command's file operation.

File updates SHOULD use atomic replacement where practical, such as writing a validated temporary file in the target file system and then renaming it into place.

Rollback is a best-effort objective, not a universal requirement. Failure to roll back MUST NOT conceal partial changes.

Read [references/file-mutations.md](references/file-mutations.md) for detailed rules.

## Sensitive Information

Successful and failed output MUST NOT disclose sensitive information.

Potentially sensitive values include:

* passwords
* access tokens
* API keys
* private keys
* authorization headers
* cookies and session identifiers
* secret environment variables
* credential-bearing URLs
* signed URLs
* secret command arguments
* sensitive subprocess output

Prefer identifying the field, source, and location of an invalid value without echoing the value itself.

Read [references/sensitive-output.md](references/sensitive-output.md) for redaction and review guidance.

## Design and Review Workflow

When designing or reviewing CLI output:

1. Identify each command's normal result and side effects.
2. Separate domain or application outcomes from output rendering.
3. Define the command-specific result data.
4. Apply the common JSON envelope.
5. Define broad exit-code categories and stable detailed error codes.
6. Define recoverability and concrete recovery guidance.
7. Define warning behavior and strict-equivalent behavior if warnings exist.
8. Define file-change and dry-run behavior for mutating commands.
9. Define sensitive-data boundaries and redaction rules.
10. Define tests for text output, JSON output, streams, exit codes, mutations, and redaction.
11. Identify durable project-wide decisions that should be recorded in an ADR or design document.

## Supporting References

Read only the references needed for the current task:

* For output architecture and format-independent processing, read [references/output-model.md](references/output-model.md).
* For the JSON envelope schema and examples, read [references/json-envelope.md](references/json-envelope.md).
* For exit codes, errors, warnings, recovery, and locations, read [references/errors-warnings-exit-codes.md](references/errors-warnings-exit-codes.md).
* For dry-run, atomic writes, rollback, and mutation reporting, read [references/file-mutations.md](references/file-mutations.md).
* For sensitive-data handling and redaction, read [references/sensitive-output.md](references/sensitive-output.md).
* For systematic design and implementation review, read [references/review-checklist.md](references/review-checklist.md).

## AI Agent Behavior

When applying this skill:

1. Distinguish existing behavior from proposed behavior.
2. Do not approve an output design merely because the messages are readable.
3. Check stream selection, exit codes, JSON structure, recoverability, file changes, dry-run, atomicity, and redaction separately.
4. Reject designs that implement JSON output by scattering format checks through command logic.
5. Reject JSON modes that emit warnings, logs, subprocess output, or progress text outside the final envelope.
6. Reject a universal exit code `1` when failures can be categorized.
7. Reject recoverable errors that do not include a concrete next action.
8. Reject file-related errors that omit an available path or precise location.
9. Reject mutating commands that lack `--dry-run` or fail to report partial changes.
10. Treat sensitive-data leakage as a defect even when it occurs only in verbose, debug, failure, or subprocess output.
11. Require tests for the output contract rather than relying only on manual inspection.
12. Call out unresolved design decisions instead of silently choosing project policy.

## Expected Review Output

A review SHOULD distinguish:

* **Findings**: contract violations or risks in the current design
* **Required changes**: changes needed for compliance
* **Optional improvements**: useful but non-required enhancements
* **Proposed contract**: exit codes, error codes, streams, envelope fields, and mutation behavior
* **Tests**: cases required to verify the contract
* **Open decisions**: project-specific policy that still requires a decision
* **ADR candidates**: durable decisions that should be recorded

## Compact Rule

A compliant CLI produces one format-independent structured outcome, renders it appropriately for text or JSON, categorizes failures, explains recovery, reports every file mutation, supports safe dry-run for mutating commands, and never leaks secrets.
