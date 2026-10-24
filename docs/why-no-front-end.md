# Why there is no front end

CorePlan is a database with a subscription. The records underneath it are ordinary: contracts, a schedule of rates, rigs, holes, crew, and the plod for every rig and shift. What you pay for is the layer on top: plod forms, approval screens, dashboards, and a charge calculator that multiplies metres by rates.

That layer used to be the whole product, because talking to a database was hard. It is not hard any more. Open this folder in Claude Code and ask "what can I claim from Kurrawang to the end of the month?" or "which driller gets the most metres per drilling hour on RC?" and it runs the query and gives you the answer. Ask something the dashboard never had a chart for and you still get an answer.

## What you gain

- **Better answers.** A dashboard shows what the vendor decided to chart. Here you ask your own question, against your own plods, and get it answered.
- **No per-rig or per-plod bill.** Add a rig, run a night shift, take on a second contract: the cost does not move.
- **Your data in your Postgres.** Plain tables. Back them up, query them from anything, leave any time.
- **Your rules.** Your fatigue limits, your rehab window, your client's sign-off days, your rate bands. Change them by asking.

## What a screen gives that this does not

Said honestly, so you can decide:

- **An offline tablet app at the rig.** CorePlan's drillers fill the plod on a tablet with no signal. Here, the driller sends a photo of the paper plod or a spreadsheet at the end of the shift and the office enters it by asking Claude Code (`/enter-plod`). If your drillers need a form on a phone that works offline, Enterprise DNA builds one into your version.
- **A client portal.** CorePlan lets the client's geologist sign off plods in a browser. Here the plod sheet is rendered as a document (`npm run docs -- plod`), sent by email, and the sign-off is recorded when it comes back. A sign-off page is a customisation.
- **Live sensor feeds.** Measure-while-drilling data from rig sensors needs an integration. This version records what the plod records.
- **A vendor help desk.** This is open source. Enterprise DNA supports the installed version for contractors that want someone to call.

## Who this fits

Drilling contractors and explorers with one to twenty rigs whose office already re-keys plods, builds the claim in a spreadsheet, and wants the answers more than the screens. If every driller needs a tablet app on day one, start with the customised version.

Installed and run for you: https://enterprisedna.co/omni/instead-of/coreplan
