# JSON Envelope Contract

## Purpose

Every command supports `--format json` and emits one common envelope. Command-specific data belongs inside `result`; common execution and diagnostic data remains in the envelope.

## Common Shape

```json
{
  "schemaVersion": "1",
  "status": "success",
  "command": "apply",
  "exitCode": 0,
  "dryRun": false,
  "result": {},
  "fileChanges": [],
  "warnings": [],
  "logs": []
}
```

## Required Common Fields

### `schemaVersion`

- Type: string
- Required: always
- Meaning: version of the common envelope contract

Version command-specific result schemas separately when necessary. Do not change the meaning of common fields without changing `schemaVersion`.

### `status`

- Type: string
- Required: always
- Allowed values: `success`, `error`

`status` MUST agree with `exitCode`.

### `command`

- Type: string
- Required: always
- Meaning: stable command identifier

Use a canonical identifier such as `apply`, `config.validate`, or `package.add`.

Do not store the raw command line. Raw arguments may contain secrets, private paths, or unstable presentation details.

### `exitCode`

- Type: integer
- Required: always
- Meaning: actual process exit code

The value MUST match the process exit status.

### `dryRun`

- Type: boolean
- Required: always
- Meaning: whether the command executed in dry-run mode

Use `false` for commands that do not mutate files or when dry-run was not requested.

### `fileChanges`

- Type: array
- Required: always
- Meaning: planned or actual file-system state changes

Use an empty array when no file changes are relevant.

### `warnings`

- Type: array
- Required: always
- Meaning: warnings produced during execution

Use an empty array when no warnings occurred.

### `logs`

- Type: array
- Required: always
- Meaning: execution logs explicitly requested as part of CLI output

Use an empty array when logs were not requested or none were produced.

Do not treat unrestricted internal debug logs as part of this field by default.

## Status-Specific Fields

### Successful envelope

A successful envelope MUST contain `result`.

`result` is a command-specific object. Use an empty object when the command has no additional result data.

A successful envelope MUST NOT contain `error`.

### Failed envelope

A failed envelope MUST contain `error`.

A failed envelope SHOULD omit `result`. Do not place partial success data in `result`; represent partial file mutations in `fileChanges` and other partial outcomes in explicitly named error or metadata fields.

## Error Shape

```json
{
  "code": "CONFIG_SCHEMA_INVALID",
  "category": "input",
  "message": "Configuration validation failed.",
  "recoverable": true,
  "recovery": "Fix the invalid field and run the command again.",
  "causes": []
}
```

Required error fields:

- `code`
- `category`
- `message`
- `recoverable`
- `causes`

`recovery` is required when `recoverable` is `true`.

When `recoverable` is `false`, a next action such as reporting a bug MAY still be included, but it must not falsely imply that the user can directly correct the cause.

## Cause Shape

A cause identifies a more specific reason or location.

```json
{
  "message": "revision must be a 40-character commit hash.",
  "path": "enozunu.consumer.kdl",
  "line": 12,
  "column": 5,
  "field": "source.revision"
}
```

A cause SHOULD contain only applicable fields. Possible fields include:

- `code`
- `message`
- `path`
- `line`
- `column`
- `endLine`
- `endColumn`
- `field`
- `key`
- `entry`

Do not include invalid secret values merely to make a cause more specific.

## Warning Shape

```json
{
  "code": "DEPRECATED_FIELD",
  "message": "The field is deprecated.",
  "path": "enozunu.consumer.kdl",
  "line": 8,
  "column": 3,
  "recovery": "Replace branch with revision."
}
```

Recommended warning fields:

- `code`
- `message`
- `recovery`, when action is recommended
- location fields, when applicable

Warning codes SHOULD be stable if callers may inspect them.

## Log Shape

```json
{
  "level": "info",
  "stage": "resolve",
  "message": "Resolved 12 entries."
}
```

Recommended fields:

- `level`
- `message`
- `stage`, when useful
- `path` or another related identifier, when useful

Logs remain subject to sensitive-data redaction.

## File Change Shape

```json
{
  "action": "modify",
  "path": "README.md",
  "state": "completed"
}
```

Required fields:

- `action`: `create`, `modify`, or `delete`
- `path`
- `state`: `planned`, `completed`, `rolledBack`, or `rollbackFailed`

Additional project-specific fields MAY be added.

## Success Example

```json
{
  "schemaVersion": "1",
  "status": "success",
  "command": "apply",
  "exitCode": 0,
  "dryRun": false,
  "result": {
    "applied": 2
  },
  "fileChanges": [
    {
      "action": "create",
      "path": ".claude/skills/cli-output-design/SKILL.md",
      "state": "completed"
    },
    {
      "action": "modify",
      "path": "README.md",
      "state": "completed"
    }
  ],
  "warnings": [],
  "logs": []
}
```

This envelope is written to stdout.

## Dry-Run Example

```json
{
  "schemaVersion": "1",
  "status": "success",
  "command": "apply",
  "exitCode": 0,
  "dryRun": true,
  "result": {
    "applied": 0
  },
  "fileChanges": [
    {
      "action": "create",
      "path": ".claude/skills/cli-output-design/SKILL.md",
      "state": "planned"
    }
  ],
  "warnings": [],
  "logs": []
}
```

## Failure Example

```json
{
  "schemaVersion": "1",
  "status": "error",
  "command": "apply",
  "exitCode": 10,
  "dryRun": false,
  "error": {
    "code": "CONFIG_SCHEMA_INVALID",
    "category": "input",
    "message": "Configuration validation failed.",
    "recoverable": true,
    "recovery": "Fix the invalid field and run the command again.",
    "causes": [
      {
        "message": "revision must be a 40-character commit hash.",
        "path": "enozunu.consumer.kdl",
        "line": 12,
        "column": 5,
        "field": "source.revision"
      }
    ]
  },
  "fileChanges": [],
  "warnings": [],
  "logs": []
}
```

This envelope is written to stderr. Stdout remains empty.

## Failure After Partial Mutation

```json
{
  "schemaVersion": "1",
  "status": "error",
  "command": "apply",
  "exitCode": 20,
  "dryRun": false,
  "error": {
    "code": "FILE_REPLACE_FAILED",
    "category": "filesystem",
    "message": "The operation stopped after partially updating files.",
    "recoverable": true,
    "recovery": "Check file permissions, inspect the listed changes, and restore unwanted changes from version control before retrying.",
    "causes": [
      {
        "message": "Permission denied while replacing the target file.",
        "path": "docs/generated.md"
      }
    ]
  },
  "fileChanges": [
    {
      "action": "modify",
      "path": "README.md",
      "state": "completed"
    }
  ],
  "warnings": [],
  "logs": []
}
```

## Schema Extension Rules

- Add command-specific output under `result`.
- Add optional common fields only when their semantics apply across commands.
- Do not overload an existing field with command-specific meaning.
- Do not require consumers to parse `message` to determine status, category, recovery, file changes, or locations.
- Document enum values and compatibility expectations.
- Preserve unknown fields when implementing envelope proxies or wrappers where practical.
