---
description: The plods for the last N days, filtered by contract, rig or status: metres, drilling hours, client standby, lost time, charges and status.
---

1. Run `npm run drill -- plods [--days=7] [--contract=..] [--rig=..] [--status=draft|submitted|approved|rejected]`.
2. Present the table, newest first. Sum metres and charges at the bottom.
3. Point out any shift with a lot of lost time (breakdown, standby on us) or client standby: one is our cost, the other is billable.
