---
name: file-boundary-review
description: Review file boundaries using design responsibilities, layers, and Git change history.
---

# File Boundary Review

When reviewing file organization:

1. Prefer boundaries based on **responsibility** and **architectural layer**.
2. Use Git change history as supporting evidence for boundaries within those constraints.
3. Treat each merge commit and its first-parent diff as one logical change unit. Do not analyze every individual commit.
4. If multiple files repeatedly change together, consider whether they should be combined.
5. If semantic regions within one file repeatedly change independently, consider whether they should be split into separate files.
6. Treat change history as evidence, not as a rule that overrides responsibility or layer boundaries.
7. If strong historical coupling conflicts with responsibility or layer boundaries, keep the design boundary and consider whether the underlying responsibility or architecture itself should be reviewed.
8. Do not apply history-based analysis when the repository does not use merge commits as meaningful integration units.

Do not use fixed thresholds for change frequency. Look for repeated patterns across multiple merged changes.
