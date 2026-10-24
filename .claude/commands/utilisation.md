---
description: Rig by rig for the last N days: shifts, metres, drilling share of the shift, metres per drilling hour, client standby (billable), lost time (ours), revenue per shift, days with no plod.
---

1. Run `npm run drill -- utilisation --days=<n>` (default 7).
2. The two numbers that matter most: lost time (breakdowns and standby on us, which nobody pays for) and days with no plod. Explain both rig by rig.
3. Revenue per shift is the plod charges divided by shifts. Compare rigs on the same method only.
