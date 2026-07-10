# Errors, Warnings, and Exit Codes

## Purpose

This document defines how failures and warnings remain actionable for humans and stable for automation.

## Exit-Code Principle

Exit codes identify broad failure categories. They do not encode every detailed cause.

A CLI MUST NOT use exit code `1` for every failure when known failures can be grouped into meaningful categories.

A project MAY reserve exit code `1` for uncategorized or unexpected failures.

## Suggested Categories

A project may use categories such as:

| Category | Typical failures |
| --- | --- |
| `usage` | unknown option, missing argument, invalid command combination |
| `input` | malformed configuration, schema violation, invalid user input |
| `filesystem` | permission failure, write failure, missing required file |
| `environment` | missing executable, unsupported platform, unavailable runtime capability |
| `external` | network failure, remote API failure, dependency command failure |
| `conflict` | existing target, lock conflict, incompatible repository state |
| `internal` | violated invariant, unexpected implementation failure |

The exact taxonomy and numeric mapping are project decisions.

The project MUST:

- document the mapping
- keep the mapping stable within its compatibility policy
- ensure JSON `error.category` agrees with the process exit code
- test representative errors in each category

## Detailed Error Codes

Each handled error MUST have a stable detailed error code.

Examples:

- `UNKNOWN_OPTION`
- `CONFIG_NOT_FOUND`
- `CONFIG_PARSE_FAILED`
- `CONFIG_SCHEMA_INVALID`
- `FILE_PERMISSION_DENIED`
- `TARGET_ALREADY_EXISTS`
- `DEPENDENCY_NOT_FOUND`
- `REMOTE_UNAVAILABLE`
- `INTERNAL_INVARIANT_VIOLATION`

Use identifiers rather than localized text. Human-readable messages may evolve; automation should rely on the code.

Do not create a distinct process exit code for every detailed error code. Map related error codes to a broad exit category.

## Required Error Information

Every handled error must answer:

1. What broad kind of failure occurred?
2. What stable detailed error occurred?
3. What happened, in concise human-readable language?
4. Can the user recover from it?
5. If yes, what exactly should the user do?
6. Did a specific file cause it?
7. Can the relevant location within that file be identified?
8. Did the command already change any files?

## Recoverability

Represent user recoverability explicitly.

Do not infer recoverability only from prose such as “try again” or “contact support.”

Examples of user-recoverable failures:

- invalid configuration the user can edit
- missing file the user can create or restore
- permission issue the user can correct
- temporary external failure the user can retry
- state conflict the user can resolve

Examples that may not be directly user-recoverable:

- violated internal invariant
- corrupted internal data with no supported repair path
- implementation defect

When `recoverable` is true, recovery guidance MUST be concrete.

Weak:

```text
Fix the problem and try again.
```

Better:

```text
Replace `source.branch` with a 40-character `source.revision` value in enozunu.consumer.kdl, then rerun the command.
```

Do not suggest destructive recovery actions without explaining their effects.

## File and Location Diagnostics

When a specific file caused an error, include its path.

Prefer a project-relative path when it identifies the file unambiguously. Use a normalized display-safe path for files outside the project.

When available, include one or more of:

- line and column
- start and end range
- field or key name
- section name
- array index or entry identifier
- document pointer
- source span

Do not fabricate precision. If only the file is known, provide only the file.

Do not echo a sensitive invalid value. Identify its field and location instead.

## Multiple Causes

A command MAY report multiple causes in one failure when this helps the user correct all detected problems.

Examples:

- schema validation findings
- multiple missing files
- several conflicting entries

The top-level error code and category describe the overall failure. Individual causes MAY have their own codes.

Keep cause ordering deterministic where possible, such as source order or normalized path order.

## Warnings

Warning support is optional.

A warning indicates that the command can complete successfully but the user should know about a risk, deprecated behavior, fallback, or future incompatibility.

Do not use warnings for normal informational output.

When warnings exist:

- default execution normally exits with `0`
- text format writes warnings to stderr
- JSON format includes warnings in `warnings[]`
- JSON format does not separately write warning text to stderr
- warnings should use stable codes when callers may inspect them
- actionable warnings should include remediation guidance

## Strict-Equivalent Behavior

A CLI that emits warnings MUST provide a documented mechanism that treats warnings as failures.

The mechanism may be:

- `--strict`
- a configuration value
- a CI policy mode
- another explicit setting

The mechanism name is project-specific. The behavior is required.

When a warning is promoted:

- the command exits non-zero
- the failure uses a documented broad category
- the JSON envelope has `status: "error"`
- the promoted warning remains identifiable by stable code
- the error explains that strict policy caused the failure

Avoid performing irreversible mutations before a warning that may be promoted to an error is evaluated. Validate and collect promotable warnings before committing changes where practical.

## Usage Errors and Help

Usage errors should identify the invalid argument or combination and show the smallest relevant correction.

Do not print an entire help document for every usage error unless the CLI's conventions require it. A concise message plus a help hint is usually clearer.

JSON usage errors MUST still use the error envelope when `--format json` can be determined.

## Internal Errors

Internal errors should:

- use an internal category
- state that the failure is not expected user input behavior
- avoid claiming the user can repair an implementation defect
- provide a safe next action, such as reporting a bug
- include a non-sensitive correlation identifier only when the application supports one
- avoid raw stack traces by default

Debug modes do not exempt stack traces and exception messages from redaction requirements.

## Review Questions

- Are broad categories meaningful to shell scripts and CI?
- Is exit code `1` used only as a justified fallback?
- Does every handled error have a stable code?
- Does every error state recoverability explicitly?
- Is recovery guidance concrete and safe?
- Are available file paths and locations included?
- Are warnings genuinely non-fatal?
- Can warnings be promoted through a strict-equivalent setting?
- Does strict mode fail before irreversible mutation where practical?
- Are internal errors distinct from user-correctable errors?
