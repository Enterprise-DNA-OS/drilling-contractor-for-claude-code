---
description: The Monday review, written from three commands: metres and rigs, the safety and approvals position, the money, and the five things that matter this week.
---

Run these three and write the review from what they return. Nothing they do not support goes in.

```
npm run drill -- utilisation --days=7
npm run drill -- attention
npm run drill -- claims --open
```

Then, no more than a page:

1. **The week in one line.** From `npm run drill -- stats`: metres, rigs working, plods waiting, money unclaimed, claims unpaid.
2. **Rigs.** Metres, drilling share of the shift, client standby (billable) and lost time (ours) by rig. Name the rig that needs a look and why.
3. **Safety and licensing.** Anything here leads the actions.
4. **Approvals.** Programme of work dates, holes waiting on rehab.
5. **Sign-off.** Plods past the window, by client, and who to chase.
6. **Money.** Overdue claims, and signed-off work worth claiming now.
7. **Five things to do this week**, picked from the attention list, with why each made it.
8. **One thing to decide.** The single item that needs a person, not a process.

`npm run view -- week`, `npm run view -- money` and `npm run view -- safety` render the same numbers as printable pages for the Monday meeting.
