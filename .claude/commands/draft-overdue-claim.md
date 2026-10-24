---
description: Draft a payment follow-up for a claim past its due date: claim number, amount, the date it was due, and the plods behind it.
---

1. Run `npm run drill -- claims --open --json` and find the claim.
2. Write to `drafts/overdue-<claim>.md`: the claim, amount, date sent, due date, days overdue, and a request for a payment date. Firm and polite.
3. Attach the rendered claim from `docs-out/claim/`. Never send it from here.
