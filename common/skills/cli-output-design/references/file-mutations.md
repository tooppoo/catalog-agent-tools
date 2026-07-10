# File Mutation and Dry-Run Policy

## Purpose

File-system state changes must remain observable even when a command fails. Mutating commands must also provide a safe way to inspect planned changes.

## Covered Operations

This policy applies when a command may:

- create a file
- modify a file
- delete a file
- replace a file
- rename or move a file
- generate files
- update a manifest, lock file, configuration file, or cache that is part of the command's durable result

A command that only reads files does not require `--dry-run` under this policy.

## Required `--dry-run`

Every covered command MUST support `--dry-run`.

Dry-run MUST:

- perform enough validation and planning to describe the expected operation
- avoid creating, modifying, deleting, renaming, or moving target files
- avoid committing other persistent state that represents the file operation
- report planned file changes
- work with text output
- work with `--format json`
- use the same path normalization and redaction rules as normal execution

Dry-run SHOULD detect errors that can be discovered without mutation. It must not claim that execution will certainly succeed when later environmental failures remain possible.

## File Change Records

Represent each file change with:

- action
- path
- state

Actions:

- `create`
- `modify`
- `delete`

States:

- `planned`: reported by dry-run
- `completed`: actually applied
- `rolledBack`: applied and then successfully reversed
- `rollbackFailed`: rollback was attempted but did not complete

Do not mark a change as completed before the operation has actually succeeded.

## Text Output

A concise text result may group changes:

```text
Updated 3 files:
  created   .claude/skills/cli-output-design/SKILL.md
  modified  README.md
  deleted   docs/old-output-contract.md
```

Dry-run should make planned status unmistakable:

```text
Would update 2 files:
  create    generated/config.json
  modify    README.md
```

Failure after partial mutation must identify the partial state:

```text
The operation failed after changing files.

Changed before failure:
  modified  README.md

Recovery:
  Inspect the changed files and restore unwanted changes from version control before retrying.
```

## JSON Output

Use `fileChanges[]` in the final envelope.

Dry-run records use `state: "planned"`.

Normal successful records use `state: "completed"`.

A failed envelope includes every known completed, rolled-back, or rollback-failed change.

Do not emit file-change JSON fragments before the final envelope.

## Atomic Update Objective

File mutation SHOULD be atomic where practical.

For a single-file replacement, a typical strategy is:

1. construct the complete new content
2. write it to a temporary file on the same target file system
3. validate the temporary content when applicable
4. preserve required permissions or metadata
5. rename or replace the target in one final operation
6. clean up the temporary file

Do not directly truncate and rewrite an existing file when a safer replacement strategy is practical.

A rename or move is not automatically sufficient in every environment. The implementation must account for platform and file-system behavior relevant to the project.

## Multiple Files

Per-file atomic replacement does not make a multi-file command transactional.

For multiple-file operations:

- validate all planned changes before applying them where practical
- prepare temporary content before replacing targets
- choose and document an application order when order matters
- stop safely after a failure
- report every completed change
- attempt rollback only when the implementation can do so reliably

Do not claim the operation is atomic if only individual file replacements are atomic.

## Rollback

Rollback is a best-effort objective.

A command MAY implement rollback when:

- original content is available
- restoring it is safe
- rollback semantics are understandable
- rollback failure can be detected and reported

Rollback MUST NOT:

- conceal the original failure
- conceal rollback failure
- overwrite unrelated concurrent changes
- imply that no mutation occurred when evidence is uncertain

If rollback is attempted, report `rolledBack` and `rollbackFailed` records as applicable.

## Backups

Backups are optional and project-specific.

Do not create backup files silently when they become durable user-visible state. If backups are created, document:

- location
- naming
- retention
- cleanup
- whether they appear in file-change output

## Generated Files

Generated files follow the same policy as hand-maintained files.

When a command generates or updates a file:

- dry-run reports the planned create or modify action
- normal execution reports the completed action
- validation or generation failure includes the relevant path
- generated content should be prepared before target replacement where practical

## Concurrency and Conflicts

A command SHOULD avoid overwriting changes made after planning began.

Possible protections include:

- checking original content hashes
- checking modification metadata
- using locks
- failing on unexpected target state

Conflict failures should use a conflict category and explain how the user can inspect or resolve the state.

## Paths

Use paths that let the user identify the affected file.

- prefer project-relative paths inside the project
- use normalized display-safe paths outside the project
- avoid leaking credential-bearing URL components
- preserve enough information for recovery

File-change reporting is not optional merely because a path is sensitive. Normalize or redact sensitive components without hiding which file changed.

## Tests

Mutating commands should test:

- dry-run makes no changes
- dry-run reports all planned changes
- normal success reports all completed changes
- failure before mutation reports no completed changes
- failure after mutation reports partial changes
- atomic replacement does not leave a truncated target
- temporary files are cleaned up
- rollback success is reported
- rollback failure is reported
- JSON output contains one envelope
- text and JSON describe equivalent file changes
