# Compliance: the rules this system checks

`/compliance` (or `npm run drill -- compliance`) checks the records against the rules below and reports every breach with the rule and its source. The rules are written for a Western Australian exploration and water bore contractor, because that is where most Australian exploration drilling happens. A contractor working under another state's law changes the sources and limits here and in `scripts/drill.mjs` (`complianceRows`) together.

This is a records check. It finds what the records say happened. It is not legal or safety advice, and it does not replace your safety management system, your safety adviser or the regulator. Confirm each rule against the current version of its source before you rely on it, and when the law or your plan changes, change the rule here and in the check in the same edit.

| Rule | What a breach looks like in the data | Source |
|---|---|---|
| R1 Prestart every shift | A plod for a rig, date and shift with no prestart recorded | Work Health and Safety (General) Regulations 2022 (WA) r 213, maintenance and inspection of plant; your plant inspection procedure |
| R2 Service on time | A rig's latest engine hours at or past its next service hours | WHS (General) Regulations 2022 (WA) r 213; the manufacturer's service schedule |
| R3 Licensed driller on water bores | Drilling on a water bore (method WB) by a driller with no water well driller licence on file, or one that had expired on the day | Minimum Construction Requirements for Water Bores in Australia (National Uniform Drillers Licensing Committee); the conditions of the licence to construct the well, which can require a licensed driller of a stated class |
| R4 Licence to construct the well | A contract with water bores and no licence reference recorded | Rights in Water and Irrigation Act 1914 (WA) s 26D |
| R5 Current programme of work | Exploration drilling on a contract with no programme of work recorded, or after it expired | Mining Act 1978 (WA): approval of a programme of work before ground-disturbing exploration, administered by the Department of Energy, Mines, Industry Regulation and Safety (DEMIRS) |
| R6 Competent crew | Someone on a plod after their competency review date, or with none on file | Work Health and Safety Act 2020 (WA) s 19(3)(f), information, training, instruction and supervision; your training and competency procedure |
| R7 Fatigue | A shift over the shift limit, or more than the weekly limit in 7 days (defaults 12 and 84 hours, set at the top of `scripts/drill.mjs`) | Work Health and Safety (Mines) Regulations 2022 (WA): fatigue is a hazard your safety management system must manage; the WA code of practice on working hours. Your own fatigue management plan sets the numbers |
| R8 Notify notifiable incidents | An incident marked notifiable with no notification date | Work Health and Safety Act 2020 (WA) s 38: the regulator is notified immediately after the person becomes aware of a notifiable incident |
| R9 Cap and rehabilitate holes | An exploration hole finished more than 30 days ago (set at the top of `scripts/drill.mjs`) with no capping or rehabilitation date | Mining Act 1978 (WA) programme of work conditions on drill hole capping and rehabilitation; DEMIRS guidance for mineral exploration |

## Why each one matters

- **R1 and R2.** A rig is heavy plant under pressure. The prestart and the service record are the first things an inspector asks for after an incident, and the first things a client's safety team audits.
- **R3 and R4.** A water bore drilled without the licence, or by an unlicensed driller where the licence requires one, can mean the bore is not accepted and the work is not paid.
- **R5 and R9.** The programme of work is the explorer's approval, but the contractor is the one on the ground. Drilling a day past expiry, or leaving holes open, puts the client's tenement standing at risk, and that comes back to the contractor.
- **R6 and R7.** Competency and fatigue are where most rig incidents start. The plod already records who was on the rig and for how long; this check reads it.
- **R8.** "Immediately" means the day it happens. The check shows the days since.

## Not checked here

- Commercial terms (sign-off windows, payment terms) are in `/attention`, not here, because they come from your contract, not the law.
- Dust, noise and health monitoring, hazardous chemicals registers, and site inductions are not in the base. They are a `/customise` away if you keep those records.
