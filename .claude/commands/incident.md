---
description: Record an incident or near miss, and record the notification to the regulator.
---

1. `npm run drill -- incident <rig> --kind=injury|near-miss|dangerous-incident|environmental|property --description=".." [--notifiable]`.
2. If it could be notifiable, say so and say the regulator must be told immediately. Whether it is notifiable is the operator's or safety adviser's call, not yours.
3. Once notified: `npm run drill -- notify <IN-nnn> --ref=<regulator reference> [--on=date]`.
4. A written incident report for the client is drafted to `drafts/`.
