# Format-Independent Output Model

## Purpose

This document defines the language-independent boundary between command execution and output rendering.

The requirement is not that text and JSON use identical rendering code. The requirement is that command behavior and diagnostic generation do not change according to the selected format.

## Required Separation

Separate these responsibilities:

1. **Command execution**
   - performs validation and application work
   - produces results, warnings, logs, file changes, or errors
   - does not know whether the selected format is text or JSON

2. **Output collection**
   - receives structured records
   - preserves the information needed for the final result
   - applies output safety and redaction rules

3. **Output rendering**
   - converts structured records to text or JSON
   - selects stdout or stderr
   - controls immediate or deferred flushing

4. **CLI composition**
   - parses `--format`
   - selects the output implementation
   - invokes the command through the format-independent boundary

Format selection SHOULD occur near the CLI adapter or composition root, not inside domain or application logic.

## Structured Records

The implementation SHOULD represent output as typed or otherwise distinguishable records. Typical record kinds are:

- result
- warning
- log
- file change
- error

The exact representation is language-specific. Acceptable implementations include:

- return-value objects
- discriminated unions or enums
- result types
- output collectors
- observers or callbacks
- channels
- event sinks
- application service response objects

Do not require an event system when a simple return object is sufficient. The architectural boundary matters more than the implementation pattern.

## Forbidden Pattern

Do not scatter format checks through command execution:

```text
if format == json:
    build a warning object
else:
    print warning text
```

This couples diagnostic generation to presentation and makes text and JSON behavior diverge.

## Preferred Pattern

Command execution reports a structured warning without deciding how it is presented:

```text
output.warning(
    code = "DEPRECATED_FIELD",
    message = "The field is deprecated.",
    location = ...
)
```

The selected output implementation handles the record:

```text
text output:
    render and flush warning to stderr

json output:
    append warning to envelope.warnings
```

The pseudocode is illustrative. Do not require these method names or object shapes.

## Text Rendering Policy

Text rendering MAY be incremental.

- Warnings MAY be written when reported.
- Requested execution logs MAY be written when reported.
- Progress output MAY be incremental when the command supports it.
- Final results are written when available.
- Errors are written to stderr.

Incremental text output MUST still obey sensitive-data rules.

## JSON Rendering Policy

JSON rendering MUST be deferred.

- Do not write warnings when they are reported.
- Do not write requested logs when they are reported.
- Do not write progress messages, spinners, or terminal control sequences.
- Accumulate all requested output in memory or another bounded intermediate representation.
- Emit exactly one final JSON envelope.
- Write a successful envelope to stdout.
- Write a failed envelope to stderr.

If an implementation imposes collection limits, it MUST report truncation explicitly. It MUST NOT silently omit requested logs or diagnostics.

## External Commands and Libraries

A subprocess or library may write directly to stdout or stderr. This can corrupt JSON output and leak secrets.

When JSON output is selected:

- capture subprocess stdout and stderr instead of inheriting the parent streams
- convert relevant content into structured logs or error causes
- redact sensitive values before storing or rendering the content
- avoid including irrelevant subprocess noise
- do not allow third-party progress output to bypass the output boundary

When text output is selected, direct streaming MAY be acceptable only if it still follows stream and redaction policy.

Prefer using the same capture path for both formats when practical. A text renderer can replay captured lines incrementally, while a JSON renderer retains them for the envelope.

## Early Failures

Some failures occur before normal command execution, such as argument parsing, formatter creation, or configuration bootstrap.

The top-level CLI boundary SHOULD convert handled early failures into the same error model whenever the requested format can be determined reliably.

Examples:

- an unknown subcommand with `--format json` should produce an error envelope when the parser permits it
- an invalid value for `--format` may use text output because no valid requested format exists
- an unexpected panic or process abort may prevent contract-compliant output, but a top-level error boundary SHOULD convert unexpected exceptions when safe

Do not expose stack traces, raw exception objects, or panic payloads by default.

## Logs

Logs included in the public CLI contract are not the same as unrestricted internal debug logs.

A requested execution log SHOULD be represented as structured data with fields such as:

- level
- message
- stage
- timestamp, when meaningful
- related path or item

Do not require timestamps when they reduce determinism or testability without adding value.

Internal debug logs SHOULD remain separate unless the command explicitly exposes them. Exposed debug output remains subject to redaction.

## Determinism

JSON output SHOULD be deterministic where practical.

- use stable field names
- use stable ordering for arrays when order is not semantically significant
- avoid nondeterministic timestamps or identifiers unless needed
- do not rely on localized text for machine interpretation

Human-readable messages MAY change. Automation SHOULD rely on schema fields, stable error codes, and documented enums.

## Design Review Questions

- Can command execution be tested without selecting an output format?
- Can the same structured warning be rendered as immediate text and deferred JSON?
- Can a subprocess write around the output abstraction?
- Does JSON mode emit exactly one value?
- Are requested logs preserved without corrupting JSON?
- Are truncation and unexpected failures represented explicitly?
- Is format selection confined to the CLI/output boundary?
