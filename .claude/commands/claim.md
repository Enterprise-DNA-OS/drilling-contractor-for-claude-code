---
description: Build the progress claim for a contract: every signed-off, unclaimed plod to a date, totalled by rate line, with the plods held back named. --save locks them onto the claim.
---

1. Run `npm run drill -- claim <contract> --period-end=<date>` first and show it. Name the plods held back because they are not signed off.
2. On a yes, run it again with `--save`. That creates the claim (as a draft) and marks those plods as claimed so they are never claimed twice.
3. Render it: `npm run docs -- claim`. The file is in `docs-out/claim/`.
4. When the office sends it: `npm run drill -- claim-status <claim> --submitted=<date>`. When it is paid: `--paid=<date> [--amount=..]`.
5. Offer `/draft-claim-cover <claim>` for the cover email. Never send it from here.
