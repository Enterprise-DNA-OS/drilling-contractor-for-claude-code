---
description: Bring plods across from CorePlan's CSV export (or any plod spreadsheet): dry run first, then import.
---

1. Make sure the rigs and contracts exist first (`/rigs`, `/contracts`). The import adds holes it has not seen.
2. Dry run: `npm run drill -- import coreplan <file.csv> --contract=<code> --dry-run`. Show the counts and anything it could not read.
3. On a yes, run it without `--dry-run`. Running it twice is harmless: plods already here are skipped.
4. Check the charges against the operator's last CorePlan claim: `npm run drill -- charges <contract>`.
5. Column names and what maps: `docs/replace-coreplan.md`. If the operator's export has other columns, map them in `scripts/drill.mjs` (`importCmd`) and add the case to the smoke test.
