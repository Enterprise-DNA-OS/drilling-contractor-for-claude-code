<h1 align="center">Drilling Contractor for Claude Code</h1>

<p align="center">
  <strong>The open-source drilling contractor system that is just a database and Claude Code.</strong>
</p>

<p align="center">
  Created by <a href="https://www.enterprisedna.co"><strong>Enterprise DNA</strong></a>. Free and open source. Works with Claude Code, Codex, OpenCode or Cursor.
</p>

<!-- three-doors -->
<table align="center">
  <tr>
    <td align="center"><strong>Do it yourself</strong><br/>Clone it, run it, own it. Free, MIT.<br/><a href="#quick-start">Quick start</a></td>
    <td align="center"><strong>We customise it</strong><br/>Your fields, your rules, your CorePlan data brought across.<br/><a href="https://enterprisedna.co/omni/book/?utm_source=github&utm_medium=readme&utm_campaign=coreplan">Book a call</a></td>
    <td align="center"><strong>We run it for you</strong><br/>Installed, connected and operated inside Omni. Setup fee, then a retainer.<br/><a href="https://enterprisedna.co/omni/instead-of/coreplan?utm_source=github&utm_medium=readme&utm_campaign=coreplan">How it works</a></td>
  </tr>
</table>

<p align="center">
  <a href="#what-is-this">What is this</a> &bull;
  <a href="#why-no-front-end">Why no front end</a> &bull;
  <a href="#quick-start">Quick start</a> &bull;
  <a href="#the-commands">Commands</a> &bull;
  <a href="#instead-of-coreplan">Instead of CorePlan</a> &bull;
  <a href="#want-it-installed-and-run-for-you">Installed for you</a> &bull;
  <a href="#license">License</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Node-20+-339933?style=flat-square" alt="Node 20+" />
  <img src="https://img.shields.io/badge/PostgreSQL-any-336791?style=flat-square" alt="PostgreSQL" />
  <img src="https://img.shields.io/badge/PGlite-embedded-3ecf8e?style=flat-square" alt="PGlite" />
  <img src="https://img.shields.io/badge/License-MIT-yellow?style=flat-square" alt="MIT License" />
</p>

---

## What is this

Drilling Contractor for Claude Code does the plod, sign-off, charging and claim side of the job you pay CorePlan for, as a Postgres database and a set of agent commands. There is no web front end. You open the folder in [Claude Code](https://claude.com/claude-code) (or Codex, OpenCode, Cursor: see `AGENTS.md`) and ask for what you want in plain language. It runs the right query, and it can answer questions the CorePlan dashboard cannot.

CorePlan's own pricing page for drilling contractors lists Basic at $750 a month for 1 to 3 rigs, with the 4 to 20 rig Professional plan and above quoted privately, and Forms from $550 a month and Staff Management from $500 a month on top ([coreplan.io/pricing/drilling](https://www.coreplan.io/pricing/drilling), checked 24 October 2026). On the explorer side, Discover is A$16,200 a year for juniors and small teams ([coreplan.io/pricing/exploration](https://www.coreplan.io/pricing/exploration)). This costs nothing, or a setup fee and a retainer if Enterprise DNA runs it for you.

Want the same thing with a web front end, or built on a different stack? That is a customisation, and it is exactly what Enterprise DNA does: [book a call](https://enterprisedna.co/omni/book/?utm_source=github&utm_medium=readme&utm_campaign=coreplan).

It is built for an exploration and water bore drilling contractor with one to twenty rigs: contracts and their schedule of rates (metres by method and depth band, hourly items, consumables), rigs and their service hours, crew with their water driller licences and competency reviews, holes, the plod for every rig and shift, client sign-off, prestarts, bits, incidents, and the monthly progress claim. The words are the words a drilling office already uses. An explorer that manages its own drilling contractors can run the same records from the other side.

**Nothing sends or talks to another system on its own.** Plod sheets, claims and chase notes are drafted here and a person sends them. The gates are real, though: a plod does not go to the client without activities, crew hours and a prestart, a signed-off plod cannot be edited, and a plod on a claim is never claimed twice.

```
/attention                 everything that wants a decision, worst first
/pending                   plods waiting on the client, past the window, or rejected
/enter-plod                a shift's plod from a photo or a spreadsheet, checked, then submitted
/charges                   what a contract has earned at its own rates, signed off or not
/claim                     this period's progress claim from the signed-off plods
/utilisation               metres, drilling share, billable standby and lost time by rig
/crew-hours                hours against your fatigue limits
/compliance                nine rules: prestarts, services, water bore licences, programme of work, competency, fatigue, notifiable incidents, rehab
/weekly-review             the Monday review, written from three commands
```

Every dollar reads one view, `v_plod_charges`: each drilling run split across the depth bands it crosses, each hourly activity at its rate, each consumable the schedule lists. The plod, the contract card, the claim and the attention list can never disagree about what a shift earned.

## Why no front end

- The front end was only ever there because the database was hard to talk to. That is no longer true.
- Your data sits in plain Postgres tables you own. Any tool can read them. No export, no lock-in.
- No seats, no tiers, no add-ons. Read [docs/why-no-front-end.md](docs/why-no-front-end.md) for the honest trade-offs too.

## Quick start

Sixty seconds, no database install (an embedded Postgres runs inside Node):

```bash
git clone https://github.com/Enterprise-DNA-OS/drilling-contractor-for-claude-code.git
cd drilling-contractor-for-claude-code
npm install
npm run demo
```

`npm run demo` creates the database and loads Ironbark Drilling (a demo Kalgoorlie contractor with four rigs on three live contracts: three RC plods past the client's three day sign-off window, a diamond plod rejected for an unexplained core loss, an RC rig with no plod for two days after a compressor failure, a rig 16 hours past its service, a shift worked with no prestart, water bores drilled under a driller whose licence lapsed on 4 October, an offsider past their competency review, a 13.5 hour shift that took one person over 84 hours for the week, a dangerous incident not yet notified, two holes from a finished programme not rehabilitated after 47 days, a claim 10 days overdue and $313,446 of signed-off diamond drilling not yet claimed), then prints the plods waiting on the client, rig utilisation and the attention list.

Then open the folder in Claude Code and type:

```
/attention
```

Try `/pending`, `/utilisation`, `/plod P-10027`, `/claim C-102`, `/crew-hours`, `/bits`. When you are ready for real data, delete `.data/` and start with `/import`.

Fill in the "Who this is for" block in [CLAUDE.md](CLAUDE.md), and put your name, logo and colours in [brand.json](brand.json) so the plod sheets and claims carry them.

## Your first hour: ten things to ask for

1. "What needs attention today?"
2. "Here is the photo of last night's plod for RC01. Enter it."
3. "Hannah signed off the RC01 plods for the 20th."
4. "What can I claim from Kurrawang to the end of the month?"
5. "Which rig lost the most hours to breakdowns this week?"
6. "Chase Red Dune for the plods past their sign-off window."
7. "Who is over 84 hours this week?"
8. "Bring in this CorePlan export for the Mulga Hill job."
9. "RC01 was serviced this morning at 12,520 hours."
10. "Draft the cover note for this month's claim and name the client standby."

## Ten questions answered from your own records

Every one is a real command or query on the demo data today.

1. Which plods are past the client's sign-off window, and how much money do they hold back? (`pending`)
2. What can I claim from each contract today, line by line at its own rates, and which plods are held back? (`claim <contract>`)
3. How many hours did each rig lose to breakdowns and standby on us this week, against billable standby on the client? (`utilisation`)
4. Which working rig has a day with no plod at all? (`utilisation`, `attention`)
5. Which drillers get the most metres per drilling hour, method by method? (`drillers`)
6. Which bits failed early, and what did each metre cost? (`bits`)
7. Who went over the fatigue limit this week, and which shift took them there? (`crew-hours`)
8. Which water bores were drilled under a driller whose licence had lapsed? (`compliance`, rule R3)
9. Which finished holes are still not capped, and whose programme of work expires this month? (`compliance` R9, `attention`)
10. Which rigs are past their service hours, and which shifts ran with no prestart? (`rigs`, `compliance` R1)

### Use it with your own Postgres or Supabase

Copy `.env.example` to `.env`, set `DATABASE_URL`, then `npm run migrate`. Same commands, shared data, no per-seat fee.

## The commands

| Command | What it does |
|---|---|
| `/attention` | Everything that wants a decision, worst first. |
| `/weekly-review` | The Monday review, written from three commands. |
| `/stats` | The business in five lines. |
| `/contracts` | Active contracts with rigs, holes, metres, unsigned and unclaimed money, programme of work expiry. |
| `/contract` | One contract in full: terms, approvals, rigs, holes, money, rates, claims, notes. |
| `/rates` | A contract's schedule of rates. |
| `/plods` | Plods for the last N days by contract, rig or status. |
| `/plod` | One plod: activities, crew, consumables, prestart and every charge. |
| `/enter-plod` | Enter a shift from a photo, a text or a spreadsheet row, check it, submit it. |
| `/pending` | Plods waiting on the client, past the window, or rejected. |
| `/sign-off` | Record the client's sign-off or rejection. |
| `/charges` | What a contract has earned at its own rates, signed off and not. |
| `/claim` | Build and save the progress claim from signed-off plods. |
| `/claims` | Every claim with due dates and days overdue. |
| `/rigs` | Every rig: where, metres, last plod, service hours, bit. |
| `/utilisation` | Metres, drilling share, billable standby, lost time and revenue per shift by rig. |
| `/prestart` | Record a prestart, passed or failed. |
| `/service` | Record a rig service and the next one due. |
| `/holes` | Holes by contract: depth, stage, dates, rehabilitation. |
| `/crew-hours` | Hours against your fatigue limits. |
| `/drillers` | Metres per shift and per drilling hour by driller and method. |
| `/bits` | Bit life, cost per metre, early failures. |
| `/incidents` | Incidents and near misses, and whether each was notified. |
| `/incident` | Record an incident and its notification. |
| `/compliance` | Nine rules checked against the records, each with its source. |
| `/documents` | Plod sheets, progress claims and programme summaries in your brand. |
| `/view` | The week, money, and safety dashboards as printable pages. |
| `/new-view` | Add a dashboard in plain language. |
| `/draft-signoff-chase` | Draft the sign-off chase to a client. |
| `/draft-overdue-claim` | Draft the payment follow-up for an overdue claim. |
| `/draft-claim-cover` | Draft the cover email for a progress claim. |
| `/import` | Bring plods across from CorePlan's CSV export. |
| `/export` | Every table to CSV. |
| `/log` | A dated note on a contract or rig. |
| `/customise` | Change a field, a rule or a limit in plain language. |

Every command is a short recipe over one CLI: `npm run drill -- help` lists it all.

## Instead of CorePlan

Set up your contracts, rates, rigs and crew by asking for them, export your plods from CorePlan as CSV, then:

```
npm run drill -- import coreplan plods.csv --contract=C-101 --dry-run
npm run drill -- import coreplan plods.csv --contract=C-101
```

Check the charges against your last CorePlan claim before you switch. The full guide, what maps and what does not: [docs/replace-coreplan.md](docs/replace-coreplan.md). The rules the compliance check uses, with sources: [docs/compliance.md](docs/compliance.md).

## Architecture

```
drilling-contractor-for-claude-code/
  CLAUDE.md                 how the operator wants this run (routing table + house rules)
  AGENTS.md                 the same, for Codex / OpenCode / Cursor / Gemini CLI
  .claude/commands/         the slash commands
  scripts/drill.mjs         the one CLI the commands drive
  scripts/lib/db.mjs        one adapter: DATABASE_URL (pg) or embedded PGlite
  supabase/migrations/      plain SQL schema
  supabase/seed.sql         demo data
  docs/                     the thesis, the compliance rules and the CorePlan guide
  documents.json, views.json  the paperwork and dashboards, as SQL
```

## Built for coding agents

The database, CLI and command recipes work with Claude Code, Codex, OpenCode or Cursor. Ask your coding agent for a new command and have it implement and test the change against the same records.

## Contributing

Issues and pull requests are welcome. Keep the shape: plain SQL, a small CLI, a slash command per recurring job, no front end.

## Want it installed and run for you?

Enterprise DNA installs Drilling Contractor for Claude Code for your business, migrates your CorePlan data, connects it to the rest of your tools, and runs it for you as part of **Omni**, our managed Command Center. One setup fee, then a monthly retainer.

- Book a call: [enterprisedna.co/omni/book](https://enterprisedna.co/omni/book/?offer=replace-software&utm_source=github&utm_medium=readme&utm_campaign=coreplan)
- Read more: [enterprisedna.co/omni/instead-of/coreplan](https://enterprisedna.co/omni/instead-of/coreplan?utm_source=github&utm_medium=readme&utm_campaign=coreplan)

## License

MIT. Copyright (c) 2026 Enterprise DNA.
