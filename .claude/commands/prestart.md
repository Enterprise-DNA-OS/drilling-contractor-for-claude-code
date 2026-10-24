---
description: Record a rig's prestart for a shift, passed or failed with the defect.
---

1. Passed: `npm run drill -- prestart <rig> --date=<date> --shift=day|night --by=<code>`.
2. Failed: add `--failed --defects="what was found"`. Say the rig stays tagged out until the defect is fixed and recorded.
3. Missing prestarts show in `/compliance` (R1).
