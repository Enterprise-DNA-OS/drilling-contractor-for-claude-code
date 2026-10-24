# Moving off CorePlan

A day's work for one office person, done in this order. Keep CorePlan running until the first claim out of this system matches the last one out of CorePlan.

## 1. Set up what CorePlan holds as settings

These are short lists, quicker to enter by asking Claude Code than to export:

- **Clients and contracts.** Code, name, client, tenement, programme of work reference and expiry, water licence for water bore jobs, the client's sign-off days and payment terms.
- **The schedule of rates** for each contract. Metres by method and depth band (RC 0 to 100 m, 100 to 200 m), hourly items (standby at client request, rig moves, rig up, surveys, bore development) and the consumables the client pays for (sample bags, core trays, casing). Copy them from the contract, not from CorePlan, so the contract is the source.
- **Rigs** with their next service hours, and **crew** with their water driller licence and competency review dates.

Ask in plain words: "add a contract C-104 for Red Dune, Mulga Hill stage 2, PoW 113520 expiring 30 June, sign-off 3 days, 30 day terms" and Claude Code writes the rows.

## 2. Export your plods

CorePlan exports plods as PDF or CSV (its help centre covers both). Export the CSV for each contract for the period you want to bring across: at least everything not yet claimed, and ideally the whole programme so the hole depths are complete.

## 3. Import

```
npm run drill -- import coreplan plods.csv --contract=C-101 --dry-run
npm run drill -- import coreplan plods.csv --contract=C-101
```

The dry run writes nothing and reports anything it could not read. Running the import twice is harmless: a rig, date and shift already here is skipped.

### What maps

The import reads one row per activity line and groups rows into one plod per rig, date and shift. Columns are matched by name, ignoring case, with the common variants of each header:

| This system | Column names it looks for |
|---|---|
| Rig | Rig, Rig Name, Rig ID, Rig Number |
| Date | Date, Shift Date, Plod Date (YYYY-MM-DD or DD/MM/YYYY) |
| Shift | Shift, Shift Type (anything starting with N is night) |
| Contract | Contract, Project, Job, Project Code (or `--contract`) |
| Driller | Driller, Driller Name (matched to your crew by name or code) |
| Status | Status, Approval Status (approved, rejected, submitted or pending review, else draft) |
| Hole | Hole ID, Hole, Hole Name, Drillhole (new holes are created) |
| Method | Drill Type, Method, Drilling Type (RC, DD, AC, RAB, WB) |
| Activity | Activity, Activity Type, Task, Code (standby, breakdown, move, rig up, survey, development, safety, crib or meal; anything else is drilling) |
| Depths | From (m), From, Depth From; To (m), To, Depth To |
| Time | Hours, Duration (hrs), Duration, Time (hrs) |
| Bit | Bit Serial, Bit, Bit ID |
| Notes | Comments, Notes, Description |

`examples/coreplan-plods.csv` shows the shape. Your CorePlan export may name columns differently, or carry custom plod fields: open it next to this table, and if a column is not matched, ask Claude Code to map it in `scripts/drill.mjs` (the `importCmd` function) and add the case to `scripts/smoke.mjs`.

### What does not carry over

- **Crew hours and consumables per plod**, unless your export has them as columns. Add them to the import, or enter them for the open plods only.
- **Prestarts, forms, inspections and timesheets** from CorePlan's forms add-on. Keep the PDFs for the record; new ones are recorded here from day one.
- **Approval history.** An imported approved plod is marked "imported from CorePlan" as the approver. The original sign-off stays in CorePlan's PDFs.
- **Sensor data** from measure-while-drilling.

## 4. Check, then switch

1. `npm run drill -- charges <contract>` for the last claim period and compare it with the last CorePlan claim, line by line.
2. If a line differs, it is almost always a rate band or an activity that mapped to the wrong code. Fix the rate or the mapping, re-import into a fresh database, and check again.
3. When they match, the next claim comes out of here: `/claim`.
