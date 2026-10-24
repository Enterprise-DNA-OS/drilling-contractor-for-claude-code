---
description: Everything that wants a decision, worst first: unreported incidents, licences and competency, fatigue, prestarts and services, programme of work dates, rehab, rejected and late plods, rigs with no plod, overdue claims, unclaimed work, bits.
---

1. Run `npm run drill -- attention`.
2. It is ordered by what costs most if it is wrong. Read it in that order:
   - **Safety and licensing** first. An unreported notifiable incident, a water bore drilled under a lapsed driller licence, someone on a rig past their competency review, a shift past the fatigue limit. These are the questions an inspector asks.
   - **Plant.** Shifts with no prestart, a failed prestart, a rig past its service hours.
   - **Approvals and rehab.** A programme of work about to expire, holes finished and not capped.
   - **Sign-off.** Rejected plods and plods past the client's sign-off window. Unsigned plods cannot be claimed.
   - **Plods.** Drafts not finished, working rigs with no plod.
   - **Money.** Claims past their due date and signed-off work not yet claimed.
   - **Bits.** Early failures and bits past their expected life.
3. For each item give the one action and who owns it (driller, supervisor, safety adviser, workshop, office).
4. Anything that needs a letter or email is drafted to `drafts/`, never sent.

If the operator asks "what should I do today", pick the top three and say why those three.
