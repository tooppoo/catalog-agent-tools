# Instructions

## Worktree

- When making file changes, always use the `git-kura` skill unless the user explicitly instructs otherwise.
- Follow the workflow defined by the `git-kura` skill. Do not duplicate or reinterpret that workflow in this file.

## Pull Request

- Use `.github/pull_request_template.md` as template.

## Review-sized implementation

In implementation, priority is given to minimizing the amount of information a human reviews at one time over completing the entire issue.

Implement only a single, minimum unit of review that can be judged independently, and stop as soon as it becomes ready for review. Do not proceed to subsequent units before approval is granted.

Divide multiple major decisions, behavioral changes, mechanical refactorings, and peripheral cleanups if they can be reviewed independently.
