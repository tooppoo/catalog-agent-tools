---
name: review-sized-implementation
description: Implement software changes in small, independently reviewable units. Use for Issue implementation, feature work, refactoring, review fixes, or any task that may contain multiple independently reviewable decisions.
---

# Review-Sized Implementation

## Purpose

Minimize the amount of information a human must review and understand at one time.

Prefer additional review rounds over a large change set. Do not optimize for completing the entire Issue in a single implementation pass.

A review unit is defined by the human judgment it requires, not by its number of files or changed lines.

## Core rule

Implement exactly one independently reviewable unit at a time.

A review unit must have one primary question that a human reviewer can answer.

Examples:

- Is this public interface appropriate?
- Does this refactoring preserve the existing behavior?
- Is this error-handling policy correct?
- Does this implementation satisfy the selected requirement?

If the change requires multiple independent answers, split it into multiple review units.

Stop when the current unit is implemented, tested, and ready for review. Do not begin the next unit without explicit approval.

## Workflow

### 1. Inspect the task

Read the Issue, Issue comments, relevant documentation, ADRs, tests, and existing implementation.

Distinguish between:

- requirements directly established by existing sources;
- implementation details that follow mechanically from those requirements;
- decisions that require interpretation or human judgment.

Do not silently resolve unclear product, architecture, compatibility, persistence, security, or behavioral decisions.

### 2. Decompose the work

Identify the independently reviewable units required to complete the task.

Separate units when they can be judged independently, especially when the work contains:

- public API or contract changes;
- behavioral changes;
- schema, configuration, or persistence changes;
- mechanical refactoring;
- error-handling policy;
- compatibility or migration behavior;
- test responsibility changes;
- documentation or ADR changes;
- unrelated cleanup or generalization.

Do not split tightly coupled changes when doing so would create an invalid, unsafe, misleading, or untestable intermediate state.

Changed-line count and file count are secondary signals only. A broad mechanical change may be one unit, while a small diff containing several policy decisions may require multiple units.

### 3. Select one unit

Choose the smallest unit that:

- has one primary review question;
- produces a coherent and valid repository state;
- can be tested meaningfully;
- does not require implementing later units to justify its correctness;
- does not introduce a known unsafe or destructive intermediate state.

State the selected review question before implementation.

Do not implement the remaining units.

### 4. Implement only the selected unit

Keep the change strictly within the selected scope.

Do not perform:

- opportunistic cleanup;
- unrelated formatting;
- speculative abstraction;
- premature generalization;
- adjacent feature work;
- refactoring that is not required by the selected unit;
- fixes for unrelated problems discovered during implementation.

Record unrelated findings for later work instead of modifying them.

When behavior changes and mechanical refactoring can be reviewed separately, do not combine them.

When a prerequisite refactoring is necessary, implement the prerequisite as its own review unit unless separating it would make the intermediate state invalid or misleading.

### 5. Handle unexpected scope

Stop expanding the implementation when any of the following occurs:

- a new independent design decision is required;
- the selected unit no longer has one primary review question;
- the change affects a public contract not covered by the task;
- compatibility or migration behavior becomes unclear;
- an unrelated defect must be fixed first;
- the implementation requires substantial additional refactoring;
- the repository cannot remain valid without adding another independent change.

Do not choose a consequential answer merely to continue implementation.

If human judgment is required, stop and present:

- the decision that is required;
- the available options;
- the relevant trade-offs;
- the recommended option, when one can be justified;
- the impact on the current and later review units.

### 6. Validate the unit

Run the smallest sufficient set of checks that establishes the claim of the current review unit.

Add or update tests required to verify the unit.

Do not add broad test coverage for later units.

The repository should, where reasonably possible:

- build successfully;
- pass relevant tests;
- preserve unrelated behavior;
- remain usable between review units.

Do not omit security, integrity, or data-loss protections merely to reduce the diff.

### 7. Stop for review

After the selected unit is ready, stop.

Do not continue to the next review unit, even when:

- the next change is obvious;
- the remaining work is small;
- completing it would close the Issue;
- the next unit uses the same files;
- continuing would be more efficient for the agent.

Human review is an intentional synchronization point.

## Review handoff

Report only the information needed to review the current unit:

### Review question

One sentence describing the primary judgment required from the reviewer.

### Implemented

A concise description of what changed.

### Not implemented

Changes intentionally deferred to later review units.

### Validation

Tests and checks performed, including any relevant limitations.

### Unexpected findings

New decisions, risks, or unrelated problems discovered during implementation. Write `None` when there are none.

### Next review unit

The next independently reviewable unit, without implementing it.

## Completion criteria

The skill is followed correctly when:

- the current change has one primary review question;
- independently reviewable concerns are not combined;
- deferred work is explicit;
- the repository is left in a coherent state;
- the agent stops before implementing the next unit.

Completing the full Issue is not a completion criterion for a single invocation of this skill.
