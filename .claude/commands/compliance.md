---
description: Check the records against the rules this industry lives under (the ones listed in docs/compliance.md) and report what is missing, late, or about to breach, with the rule cited.
---

1. Read `docs/compliance.md`. Each rule has a name, the source it comes from, what a breach looks like in the data, and the SQL or command that finds it.
2. Run each check. Use the CLI's `--json` output or a direct query through `scripts/lib/db.mjs`.
3. Report as a table: rule, count, the worst example (name and days), the source. Order by severity: breached first, then due within 7 days, then clean.
4. For anything breached, draft the fix the operator can approve: the record to update, the notice to send (draft to `drafts/`, never send), or the task to add.
5. If a rule in `docs/compliance.md` is out of date, say so and stop. Do not guess at law. The operator confirms the rule, then you update the doc and the check together.

Nothing here is legal advice. The doc records the rules the operator has told the system to enforce, with sources, and this command checks the data against them.
