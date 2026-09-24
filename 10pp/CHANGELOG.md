# Changelog

## 0.9.4

- Restores compatibility with modern Perl by loading the legacy extender with the required `say` feature enabled.
- Validates wrapper arguments, input files, party sizes, and distinct input/output paths.
- Replaces fixed temporary filenames with collision-resistant temporary files.
- Removes shell command construction from diff generation and uses Perl's list-form process execution.
- Handles both `.d` and `.dlg` dialog filenames when creating comment-free diffs.
- Treats empty and intentionally skipped files as successful no-op conversions.
- Makes the regression suite runnable from any working directory.
- Compares test output exactly after line-ending normalization instead of deleting all line breaks.
- Returns a nonzero test-runner status when tests fail or no tests match.
- Uses the bundled Perl diff implementation instead of an external `diff` executable.
- Makes party sizes from 1 through 6 successful configuration-only installations.
- Adds duplicate protection for extended `OBJECT.IDS` names.
- Improves installer diagnostics and temporary-file cleanup.
- Adds automated GitHub Actions coverage for the complete Perl regression suite.
