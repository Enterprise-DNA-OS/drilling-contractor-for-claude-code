# Drilling Contractor for Claude Code: operating instructions

This file is the brain. Claude Code reads it at the start of every session. It says who this is for, how work gets done, and the one right way to do each recurring job.

## Who this is for

- **Business:** [YOUR BUSINESS]
- **Operator:** [YOUR NAME], [your role]
- **What matters most:** [the one or two outcomes you care about]

Fill this in once. A worker with context knows. A worker without it guesses.

## How to work

1. **Take a brief, not a script.** The operator describes the outcome. You run the right command and present the answer.
2. **Read before you write.** Before drafting anything about a record, read its full history first.
3. **Plain language.** Short sentences. No filler. Numbers in tables.
4. **Silent success, loud problems.** No play-by-play. Say what broke and what you did about it.
5. **Stop at the line.** Anything that sends, deletes, or faces a customer waits for a yes in this session.

## Routing table: one right way for each recurring job

| When the operator asks for... | Use this |
|---|---|
| What needs doing, what is wrong, what is late | `/attention` |
| The Monday review | `/weekly-review` |
| A quick picture of the business | `/stats` |
| Contracts, one contract, its rates | `/contracts`, `/contract`, `/rates` |
| A driller's plod to enter (photo, text, spreadsheet) | `/enter-plod` |
| Plods for a period, or one plod | `/plods`, `/plod` |
| What the client has not signed off | `/pending` |
| The client signed off or rejected a plod | `/sign-off` |
| What a contract has earned | `/charges` |
| This month's claim | `/claim` |
| Claims and who owes us | `/claims` |
| Rigs, utilisation, prestarts, services | `/rigs`, `/utilisation`, `/prestart`, `/service` |
| Holes and rehabilitation | `/holes` |
| Crew hours and fatigue | `/crew-hours` |
| Driller metres | `/drillers` |
| Bits | `/bits` |
| Incidents and notifications | `/incidents`, `/incident` |
| Is everything in order with the rules | `/compliance` |
| Plod sheets, claims, programme summaries | `/documents` |
| Printable dashboards, or a new one | `/view`, `/new-view` |
| Chase a sign-off, an overdue claim, a claim cover note | `/draft-signoff-chase`, `/draft-overdue-claim`, `/draft-claim-cover` |
| Bring data across from CorePlan | `/import` |
| Get the data out | `/export` |
| A note on a contract | `/log` |
| Change a field, a rule, a limit | `/customise` |

If an ask fits nothing here, run the CLI directly (`npm run drill -- help`) and then propose a new command for it.

## Hard rules

- Never send email or messages from here. Draft to `drafts/`, a person sends.
- Never delete records without an explicit yes in this session. Prefer marking closed or archived.
- Never invent a record. If a name is ambiguous, list the candidates and ask.
- The database is the source of truth. If the answer is not in it, say so.
- Never guess a number off a plod photo. If a depth, time or quantity is unclear, ask.
- A signed-off plod is the client's record. Change it only through `reopen`, which sends it back for sign-off.
- Money is calculated from the contract's schedule of rates, never typed in. If a charge looks wrong, fix the rate or the plod.
- Whether an incident is notifiable is a person's call. Say when it might be, and that the regulator is told immediately.

## Where things live

- `scripts/` the CLI. `scripts/lib/db.mjs` picks `DATABASE_URL` (Postgres, Supabase) or the embedded database in `.data/`.
- `supabase/migrations/` the schema, plain SQL. `npm run migrate` applies it.
- `.claude/commands/` the slash commands. Add one every time the same ask comes twice.
- `docs/` the thesis and the guide for moving off CorePlan.

Built by Enterprise DNA. Installed and run for you as part of Omni: https://enterprisedna.co/omni/instead-of/coreplan
