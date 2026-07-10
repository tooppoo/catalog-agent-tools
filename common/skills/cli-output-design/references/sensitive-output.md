# Sensitive Output and Redaction

## Purpose

CLI output often enters terminals, logs, CI systems, issue reports, chat systems, and AI prompts. A value printed once may be copied or retained far beyond the original process.

Sensitive-data protection applies to successful output, failures, warnings, logs, debug output, dry-run, subprocess output, and JSON envelopes.

## Sensitive Values

Treat at least these values as sensitive unless the project explicitly proves otherwise:

- passwords and passphrases
- access and refresh tokens
- API keys
- private keys and key material
- authorization headers
- cookies and session identifiers
- secret environment variables
- credential-bearing URLs
- signed URLs
- database connection strings containing credentials
- private registry credentials
- secret command arguments
- sensitive configuration values
- subprocess output containing any of the above

Project-specific sensitive fields must be added to this list.

## Primary Rule

Do not output a sensitive value merely because it caused an error.

Prefer:

```text
Invalid token in field `registry.token` at config.kdl:12:5.
```

Do not output:

```text
Invalid token `ghp_...` at config.kdl:12:5.
```

The field, source, path, and location usually provide sufficient diagnosis.

## Redaction

When a sensitive value must be represented, replace it with a stable non-secret marker such as:

- `[REDACTED]`
- `***`
- a project-defined masked form

Do not reveal a prefix or suffix unless the identification benefit is necessary and the project's security policy permits it.

Do not rely on a fixed list of token prefixes. Secrets may not follow recognizable formats.

## Redaction Boundaries

Apply protection at more than one boundary where practical:

1. avoid constructing messages containing raw secrets
2. mark sensitive structured fields so renderers cannot emit them directly
3. redact captured subprocess output
4. apply a final defensive redaction pass before rendering

A final regex-based pass alone is not sufficient. It may miss unknown formats and may also over-redact harmless content.

## Command Lines and Arguments

Do not echo the raw command line by default.

Arguments may contain:

- tokens
- passwords
- signed URLs
- private file paths
- sensitive search terms

Use a stable command identifier in the JSON envelope instead of raw argv.

When showing a reproducible recovery command, reconstruct only known-safe arguments and replace sensitive values with placeholders.

Example:

```text
Run: tool login --token <TOKEN>
```

## Environment Variables

Do not print secret environment-variable values.

It is usually safe to identify the variable name:

```text
Environment variable GITHUB_TOKEN is missing.
```

When the variable is present but invalid, state that without showing its value.

## URLs

URLs may contain credentials or signed query parameters.

Before outputting a URL:

- remove user-info credentials
- remove or redact secret query parameters
- avoid printing fragments that contain tokens
- prefer origin and path when query data is unnecessary

Do not assume HTTPS makes a URL safe to print.

## File Paths

File paths are diagnostically important and must be included when a file caused an error.

Use the least-sensitive path that remains unambiguous:

- project-relative path inside the project
- `~`-normalized path inside the user's home directory when appropriate
- normalized absolute path when required for recovery

Do not remove the path entirely merely because it contains a user name. Normalize sensitive or unstable prefixes where possible.

A file name or path component may itself contain sensitive data. Redact only the sensitive component while preserving enough structure for identification.

## File Content and Invalid Values

Do not quote an entire source line when it may contain a secret.

Prefer:

- line and column
- field name
- key name
- source span without raw content
- expected type or format

When a safe excerpt is genuinely useful, extract only the minimum and pass it through redaction.

## Subprocesses

Subprocesses may print credentials, request headers, remote URLs, or environment details.

- capture output when JSON mode is active
- avoid forwarding raw output by default
- select only relevant lines
- redact before inclusion in logs or errors
- avoid enabling verbose third-party output automatically

If a subprocess cannot be safely controlled, describe the limitation and do not claim that the command satisfies the output contract.

## Errors and Exceptions

Raw exception messages may include:

- file content
- connection strings
- URLs
- library request details
- environment values

Map exceptions to safe application errors. Do not expose raw exception text without review and redaction.

Stack traces are not safe by default. Debug modes remain subject to redaction.

## JSON

JSON output is not safer merely because it is structured.

- do not add hidden or internal secret fields
- do not include raw argv
- do not include unrestricted environment snapshots
- do not include full subprocess transcripts without filtering
- keep masked values masked in nested causes, logs, warnings, and results

## Testing

Add tests with representative synthetic secrets in:

- normal results
- error messages
- warnings
- requested logs
- raw exception messages
- subprocess stdout and stderr
- URLs
- configuration validation errors
- dry-run output
- JSON nested objects

Tests should assert that the complete text and JSON outputs do not contain the synthetic secret.

## Review Questions

- Can any raw user value reach a message template?
- Can raw argv reach output?
- Can a subprocess bypass redaction?
- Can verbose or debug mode reveal more than normal mode?
- Are paths preserved while sensitive components are normalized?
- Are error locations reported without quoting secret content?
- Are nested JSON fields tested for leakage?
- Does dry-run use the same redaction path as normal execution?
