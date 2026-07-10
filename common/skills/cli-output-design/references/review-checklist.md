# CLI Output Review Checklist

Use this checklist when reviewing a design, implementation, issue, or pull request.

## 1. Command Outcomes

- [ ] Each command has a defined successful result.
- [ ] Each command identifies whether it reads or mutates persistent state.
- [ ] Success output contains only information needed by the user or caller.
- [ ] Command-specific result data is separated from common diagnostics.

## 2. Format Support

- [ ] Every command supports `--format json`.
- [ ] Text output remains available explicitly or as the default.
- [ ] Additional formats do not introduce format-specific business behavior.
- [ ] `--format json` emits exactly one JSON value.
- [ ] JSON contains no ANSI escapes, spinners, or terminal decoration.

## 3. Format-Independent Design

- [ ] Business logic does not inspect the output format.
- [ ] Validation does not inspect the output format.
- [ ] Warning generation does not inspect the output format.
- [ ] Error classification does not inspect the output format.
- [ ] Recovery guidance does not inspect the output format.
- [ ] File-change tracking does not inspect the output format.
- [ ] Format selection is confined to the CLI/output boundary.
- [ ] Text and JSON render the same structured outcome.

## 4. Stream Behavior

### Text

- [ ] Successful normal output goes to stdout.
- [ ] Errors go to stderr.
- [ ] Warnings go to stderr.
- [ ] Requested logs may be emitted incrementally.

### JSON

- [ ] Successful envelope goes to stdout.
- [ ] Failed envelope goes to stderr.
- [ ] The opposite stream remains empty under normal handled execution.
- [ ] Warnings are included in `warnings[]`, not separately printed.
- [ ] Requested logs are included in `logs[]`, not separately printed.
- [ ] Subprocesses cannot write directly around the JSON renderer.

## 5. JSON Envelope

- [ ] `schemaVersion` exists.
- [ ] `status` exists and is valid.
- [ ] `command` is a stable identifier, not raw argv.
- [ ] `exitCode` matches the actual process status.
- [ ] `dryRun` exists.
- [ ] `fileChanges` always exists.
- [ ] `warnings` always exists.
- [ ] `logs` always exists.
- [ ] Successful envelopes contain `result` and omit `error`.
- [ ] Failed envelopes contain `error` and normally omit `result`.
- [ ] Machine interpretation does not require parsing human messages.

## 6. Exit Codes

- [ ] Broad error categories are documented.
- [ ] Numeric exit-code mappings are documented.
- [ ] Known failures do not all use exit code `1`.
- [ ] Exit code `1`, if used, is a justified fallback.
- [ ] JSON `error.category` matches the exit-code category.
- [ ] Compatibility expectations for exit codes are documented.

## 7. Error Diagnostics

- [ ] Every handled error has a stable detailed code.
- [ ] Every handled error has a concise message.
- [ ] Every handled error states user recoverability explicitly.
- [ ] Every recoverable error gives a concrete next action.
- [ ] Non-recoverable internal errors do not blame the user.
- [ ] Specific file causes include a path.
- [ ] Available line, column, range, field, key, or entry information is included.
- [ ] Precision is not fabricated when unavailable.
- [ ] Multiple causes are ordered deterministically where practical.

## 8. Warnings

- [ ] Warning support is introduced only when needed.
- [ ] Warnings are non-fatal by default.
- [ ] Default warning behavior preserves exit code `0`.
- [ ] Warnings have stable codes when automation may inspect them.
- [ ] Actionable warnings include remediation guidance.
- [ ] A strict-equivalent setting promotes warnings to failures.
- [ ] Strict behavior is documented and tested.
- [ ] Promotable warnings are evaluated before irreversible mutation where practical.

## 9. File Mutations

- [ ] Every mutating command supports `--dry-run`.
- [ ] `--dry-run` works with `--format json`.
- [ ] Dry-run performs no target mutation.
- [ ] Dry-run reports planned creates, modifications, and deletions.
- [ ] Normal success reports actual creates, modifications, and deletions.
- [ ] Failure reports changes completed before failure.
- [ ] Rollback success and failure are distinguishable.
- [ ] Single-file replacement is atomic where practical.
- [ ] Temporary files are cleaned up.
- [ ] Multi-file operations do not falsely claim transaction-level atomicity.
- [ ] Concurrent modification conflicts are detected where necessary.

## 10. Sensitive Information

- [ ] Passwords are never output.
- [ ] Tokens and API keys are never output.
- [ ] Private keys and authorization headers are never output.
- [ ] Raw argv is not output.
- [ ] Secret environment values are not output.
- [ ] Credential-bearing and signed URLs are sanitized.
- [ ] Invalid secret values are identified by field and location, not echoed.
- [ ] Raw exceptions are mapped to safe errors.
- [ ] Subprocess output is captured and redacted.
- [ ] Debug and verbose modes follow the same redaction policy.
- [ ] JSON nested fields are covered by leakage tests.

## 11. Tests

- [ ] Text success output is tested.
- [ ] Text failure output and stderr selection are tested.
- [ ] JSON success envelope and stdout selection are tested.
- [ ] JSON failure envelope and stderr selection are tested.
- [ ] JSON mode emits exactly one value.
- [ ] The unused stream is empty for handled JSON outcomes.
- [ ] Warning behavior is tested in text and JSON.
- [ ] Strict warning promotion is tested.
- [ ] Exit-code categories are tested.
- [ ] Stable error codes are tested.
- [ ] Recoverability and recovery guidance are tested.
- [ ] File paths and locations are tested.
- [ ] Dry-run non-mutation is tested.
- [ ] Partial mutation reporting is tested.
- [ ] Atomic write failure behavior is tested.
- [ ] Synthetic secret leakage is tested across every output channel.
- [ ] Output ordering is deterministic where promised.

## 12. Documentation and Decisions

- [ ] User documentation explains `--format json`.
- [ ] User documentation explains `--dry-run` for mutating commands.
- [ ] Exit codes and broad categories are documented.
- [ ] Stable error-code policy is documented.
- [ ] JSON envelope versioning is documented.
- [ ] Warning strictness is documented when warnings exist.
- [ ] Any intentional exception is explicit and justified.
- [ ] Durable cross-command decisions are proposed for an ADR.

## Review Result

A review should conclude with one of:

- **Compliant**: required rules are satisfied.
- **Compliant with follow-up**: required rules are satisfied; optional improvements remain.
- **Not compliant**: one or more required rules are violated.
- **Blocked**: required information is unavailable, and the missing information is identified.

Do not mark a design compliant solely because examples look reasonable. Verify the architecture, stream behavior, schema, exit codes, mutation semantics, and redaction path.
