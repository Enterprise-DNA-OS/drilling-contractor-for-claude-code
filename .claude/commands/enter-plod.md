---
description: Enter a shift's plod from what the driller sends (a paper plod photo, a text, a spreadsheet row): activities, depths, hours, crew, consumables, then submit.
---

The operator gives you the shift: rig, date, day or night, driller, and the lines. Read a photo of a paper plod carefully; if a number is unclear, ask, do not guess.

1. `npm run drill -- plod-new <rig> --date=<date> --shift=day|night --driller=<code> --engine-hours=<n>`
2. One `activity` per line, in order:
   `npm run drill -- activity <plod> drilling --hole=<id> --from=<m> --to=<m> --hours=<h> --bit=<serial>`
   `npm run drill -- activity <plod> standby-client --hours=<h> --notes="why"`
   Activity is one of: drilling, rig-move, rig-up, standby-client, standby-contractor, breakdown, survey, development, safety, meal. A new hole needs `--method=RC|DD|AC|RAB|WB`. Add `--complete` on the line that finishes a hole.
3. Crew: `npm run drill -- crew <plod> <staff> --hours=12` for each person.
4. Consumables: `npm run drill -- consume <plod> <item> --qty=<n>`. Items that match a code on the schedule of rates are charged; anything else is recorded as a cost.
5. Prestart, if not already in: `npm run drill -- prestart <rig> --date=<date> --shift=<shift> --by=<code>` (add `--failed --defects=".."` when it failed).
6. Show `npm run drill -- plod <plod>` and check: hours add to the shift, depths follow on from the last plod for that hole, the charges look right.
7. On a yes: `npm run drill -- submit <plod>`. It refuses a plod with no activities, no crew hours or no prestart.
