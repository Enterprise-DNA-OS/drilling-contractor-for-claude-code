---
description: Hours each person worked in the last N days, and every shift over the fatigue limit, against the limits in your fatigue plan.
---

1. Run `npm run drill -- crew-hours --days=7`.
2. Name anyone over the weekly limit or with a long shift, and when their next rest should be.
3. The limits live at the top of `scripts/drill.mjs`. If the operator's fatigue plan says something else, change them there (`/customise`).
