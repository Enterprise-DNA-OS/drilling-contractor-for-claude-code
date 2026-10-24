---
description: A contract's schedule of rates: metres by method and depth band, hourly items, consumables the client pays for.
---

1. Run `npm run drill -- rates <contract>`.
2. Present the table. If the operator wants to change a rate or add a band, that is `/customise` territory only for new columns; a new rate line is a plain insert into `rate_items` for that contract. Show the insert, run it on a yes, then re-run `rates` to confirm.
