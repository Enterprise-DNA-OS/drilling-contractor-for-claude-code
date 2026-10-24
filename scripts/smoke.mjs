#!/usr/bin/env node
// End-to-end smoke test on a throwaway embedded database: migrate, seed, then every command
// that matters, asserting on the JSON. Passes on Windows and Linux. No network, no Postgres install.
// TEST_DATABASE_URL runs the same test against a real Postgres (CI does this).

import { spawnSync } from 'node:child_process';
import { mkdtempSync, rmSync, existsSync, writeFileSync, readdirSync } from 'node:fs';
import { tmpdir } from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const dataDir = mkdtempSync(path.join(tmpdir(), 'drill-smoke-'));
const exportDir = path.join(dataDir, 'export');
const env = { ...process.env, DATA_DIR: dataDir };
delete env.DATABASE_URL;
if (process.env.TEST_DATABASE_URL) env.DATABASE_URL = process.env.TEST_DATABASE_URL;

let step = 0;
function run(label, args, { json = true, expectFail = false } = {}) {
  step++;
  const argv = [path.join(root, 'scripts', args[0]), ...args.slice(1), ...(json ? ['--json'] : [])];
  const res = spawnSync(process.execPath, argv, { cwd: root, env, encoding: 'utf8' });
  const ok = expectFail ? res.status !== 0 : res.status === 0;
  if (!ok) {
    console.error(`\nFAIL step ${step} (${label}): exit ${res.status}\n--- stdout\n${res.stdout}\n--- stderr\n${res.stderr}`);
    process.exit(1);
  }
  console.log(`  ok  ${String(step).padStart(2)}  ${label}`);
  if (!json || expectFail) return { stdout: res.stdout, stderr: res.stderr };
  try { return JSON.parse(res.stdout); } catch {
    console.error(`\nFAIL step ${step} (${label}): output is not JSON\n${res.stdout}\n${res.stderr}`);
    process.exit(1);
  }
}
function assert(cond, msg) { if (!cond) { console.error(`\nFAIL assertion: ${msg}`); process.exit(1); } }
const n = (v) => Number(v ?? 0);
const D = (...a) => ['drill.mjs', ...a];
const day = (offset) => { const d = new Date(); d.setDate(d.getDate() + offset); const p = (x) => String(x).padStart(2, '0'); return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}`; };

console.log(`smoke: ${env.DATABASE_URL ? 'Postgres' : 'embedded database in ' + dataDir}`);
try {
  run('migrate', ['migrate.mjs'], { json: false });
  run('migrate again (idempotent)', ['migrate.mjs'], { json: false });
  run('seed', ['seed.mjs'], { json: false });
  run('seed again (idempotent)', ['seed.mjs'], { json: false });

  // ---- the overview
  const stats = run('stats', D('stats'));
  assert(stats.active_contracts === 3 && stats.rigs_working === 4, `three active contracts, four rigs (${stats.active_contracts}, ${stats.rigs_working})`);
  assert(stats.awaiting_signoff === 16 && stats.rejected === 1, `16 plods waiting, 1 rejected (${stats.awaiting_signoff}, ${stats.rejected})`);
  assert(stats.open_incidents === 1, 'one open incident');

  const contracts = run('contracts', D('contracts'));
  assert(contracts.length === 3, 'active contracts only by default');
  assert(run('contracts --all', D('contracts', '--all')).length === 4, 'the finished contract shows with --all');
  const card = run('contract by client name', D('contract', 'kurrawang'));
  assert(card.contract.code === 'C-102' && card.rates.length === 6, 'fuzzy contract lookup and its rates');
  run('ambiguous contract lists and exits 1', D('contract', 'C-10'), { json: false, expectFail: true });

  // ---- charges from the schedule of rates
  const rates = run('rates', D('rates', 'C-101'));
  assert(rates.some((r) => r.code === 'RC-0200' && n(r.depth_from) === 100), 'depth bands on the schedule');
  const p27 = run('one plod', D('plod', 'P-10027'));
  const bands = Object.fromEntries(p27.charges.map((c) => [c.rate_code, n(c.qty)]));
  assert(bands['RC-0100'] === 100 && bands['RC-0200'] === 22 && bands['RC-0300'] === 20, `a drilling run split across depth bands (${JSON.stringify(bands)})`);
  assert(p27.charges.reduce((s, c) => s + n(c.amount_cents), 0) === 1530040, 'plod charges add to $15,300.40');
  assert(p27.crew.find((c) => c.code === 'O01').minutes === 810, 'Ben Ross 13.5 hours on P-10027');

  const ch = run('charges for a contract', D('charges', 'C-102'));
  assert(ch.approved_cents === 31344600, `C-102 signed-off charges $313,446 (${ch.approved_cents})`);
  assert(ch.unsigned.length > 0, 'unsigned work listed separately');

  // ---- sign-off
  const pend = run('pending', D('pending'));
  assert(pend.filter((p) => p.overdue).length === 3, `three plods past the sign-off window (${pend.filter((p) => p.overdue).length})`);
  assert(pend.some((p) => p.number === 'P-10071' && p.status === 'rejected'), 'the rejected diamond plod');

  // ---- rigs
  const rigs = run('rigs', D('rigs'));
  const rc01 = rigs.find((r) => r.code === 'RC01');
  assert(rc01.service_due_in < 0, 'RC01 past its service');
  const util = run('utilisation', D('utilisation'));
  assert(n(util.find((u) => u.rig === 'RC02').days_without_plod) === 2, 'RC02 two days with no plod');
  assert(n(util.find((u) => u.rig === 'RC02').lost_min) === 480, 'RC02 eight hours lost to the breakdown');
  run('one rig', D('rig', 'dd01'));

  // ---- holes, crew, bits
  const holes = run('holes', D('holes', '--contract=C-099'));
  assert(holes.length === 6 && holes.filter((h) => !h.rehab_on).length === 2, 'two Lefroy holes not rehabilitated');
  const crew = run('crew hours', D('crew-hours'));
  assert(crew.week.filter((w) => w.over).map((w) => w.code).join() === 'O01', 'only Ben Ross over 84 hours');
  assert(crew.long_shifts.length === 1, 'one long shift');
  const drillers = run('drillers', D('drillers'));
  assert(drillers.some((d) => d.method === 'DD') && drillers.some((d) => d.method === 'WB'), 'driller performance by method');
  const bitsOut = run('bits', D('bits'));
  assert(bitsOut.filter((b) => b.flag === 'early failure').length === 2, 'two early bit failures');
  assert(bitsOut.find((b) => b.serial === 'B-RC-4411').flag === 'past expected life', 'RC01 bit past its life');
  run('staff', D('staff'));

  // ---- compliance and attention
  const comp = run('compliance', D('compliance'));
  const c = Object.fromEntries(comp.map((x) => [x.id, x.count]));
  assert(c.R1 === 2 && c.R2 === 1 && c.R3 === 1 && c.R4 === 0 && c.R5 === 0 && c.R6 === 1 && c.R7 === 2 && c.R8 === 1 && c.R9 === 2, `compliance counts ${JSON.stringify(c)}`);
  const att = run('attention', D('attention'));
  assert(att[0].area === 'safety' && /IN-032/.test(att[0].what), 'the unreported dangerous incident leads');
  assert(att.some((a) => a.area === 'approvals' && /expires/.test(a.what)), 'programme of work expiring');
  assert(att.some((a) => a.area === 'money' && /CL-0992/.test(a.what)), 'overdue claim');
  assert(att.some((a) => a.area === 'money' && /C-102/.test(a.what)), 'unclaimed diamond work');
  assert(att.some((a) => a.area === 'plods' && /RC02/.test(a.what)), 'RC02 missing plods');

  // ---- a shift, start to claim
  const np = run('open a plod', D('plod-new', 'RC02', '--date=today', '--shift=day', '--driller=D06', '--engine-hours=9622'));
  run('a duplicate plod is refused', D('plod-new', 'RC02', '--date=today', '--shift=day'), { json: false, expectFail: true });
  run('submit with nothing in it is refused', D('submit', np.number), { json: false, expectFail: true });
  run('activity: safety', D('activity', np.number, 'safety', '--hours=0.5'));
  run('activity: drilling across a band', D('activity', np.number, 'drilling', '--hole=MHRC014', '--from=130', '--to=150', '--hours=1.5', '--bit=B-RC-4413', '--complete'));
  run('activity: new hole created on the fly', D('activity', np.number, 'drilling', '--hole=MHRC042', '--method=RC', '--planned=180', '--from=0', '--to=96', '--hours=6.5', '--bit=B-RC-4413'));
  run('activity: client standby', D('activity', np.number, 'standby-client', '--hours=2', '--notes=Waiting on geologist'));
  run('drilling without depths is refused', D('activity', np.number, 'drilling', '--hole=MHRC042', '--hours=1'), { json: false, expectFail: true });
  run('crew', D('crew', np.number, 'O06', '--hours=12'));
  run('crew driller hours', D('crew', np.number, 'D06', '--hours=12'));
  run('consumables', D('consume', np.number, 'sample-bags', '--qty=116'));
  run('submit without a prestart is refused', D('submit', np.number), { json: false, expectFail: true });
  run('prestart', D('prestart', 'RC02', '--shift=day', '--by=D06'));
  run('submit', D('submit', np.number));
  const mine = run('the new plod', D('plod', np.number));
  const total = mine.charges.reduce((s, x) => s + n(x.amount_cents), 0);
  // 20 m at $110 + 96 m at $95 + 2 h standby at $380 + 116 bags at $1.20
  assert(total === 2200_00 + 9120_00 + 760_00 + 139_20, `new plod charges ${total}`);
  run('approve without a name is refused', D('approve', np.number), { json: false, expectFail: true });
  run('approve', D('approve', np.number, '--by=Hannah Moss (Red Dune)'));
  run('editing a signed-off plod is refused', D('activity', np.number, 'meal', '--hours=0.5'), { json: false, expectFail: true });
  run('reject and fix the diamond plod', D('reject', 'P-10071', '--reason=Core loss note missing'));

  const draft = run('draft claim', D('claim', 'C-101'));
  assert(draft.number === null && draft.held_back.length >= 9, 'draft claim holds back unsigned plods');
  const saved = run('save claim', D('claim', 'C-101', '--save'));
  assert(saved.number === 'CL-1012' && saved.amount_cents === draft.amount_cents && saved.amount_cents > 0, `claim saved ${saved.number}`);
  const again = run('nothing left to claim', D('claim', 'C-101'));
  assert(again.amount_cents === 0, 'claimed plods are not claimed twice');
  run('claim sent', D('claim-status', 'CL-1012', `--submitted=${day(0)}`));
  run('old claim paid', D('claim-status', 'CL-0992', `--paid=${day(0)}`));
  const open = run('open claims', D('claims', '--open'));
  assert(open.some((x) => x.number === 'CL-1012' && x.status === 'submitted') && !open.some((x) => x.number === 'CL-0992'), 'claim statuses');

  // ---- safety writes
  run('notify the incident', D('notify', 'IN-032', '--ref=DEMIRS 2026-55120'));
  const inc = run('new incident', D('incident', 'WB01', '--kind=near-miss', '--description=Drop object from mast, exclusion zone held'));
  assert(inc.number === 'IN-033', 'incident numbering');
  run('service', D('service', 'RC01', '--hours=12520'));
  run('rig status', D('rig-status', 'RC02', 'workshop'));
  const comp2 = run('compliance after fixes', D('compliance'));
  assert(comp2.find((x) => x.id === 'R8').count === 0 && comp2.find((x) => x.id === 'R2').count === 0, 'notified and serviced');

  // ---- import from CorePlan
  const csv = path.join(dataDir, 'coreplan.csv');
  writeFileSync(csv, [
    'Plod ID,Date,Shift,Rig,Project,Driller,Status,Hole ID,Drill Type,Activity,From (m),To (m),Hours,Bit Serial,Comments',
    `CP-5501,${day(-30).split('-').reverse().join('/')},Day,DD01,C-102,Luke Brennan,Approved,KND000,DD,Safety meeting,,,0.5,,`,
    `CP-5501,${day(-30).split('-').reverse().join('/')},Day,DD01,C-102,Luke Brennan,Approved,KND000,DD,Drilling HQ,0,42,10.5,B-HQ-2101,`,
    `CP-5501,${day(-30).split('-').reverse().join('/')},Day,DD01,C-102,Luke Brennan,Approved,,,Crib,,,0.5,,`,
    `CP-5502,${day(-30).split('-').reverse().join('/')},Night,DD01,C-102,Ana Silva,Pending Review,KND000,DD,Drilling HQ,42,80,9,B-HQ-2101,`,
    `CP-5502,${day(-30).split('-').reverse().join('/')},Night,DD01,C-102,Ana Silva,Pending Review,KND000,DD,Standby - client,,,2,,Waiting on geo`,
    `CP-5503,${day(-30).split('-').reverse().join('/')},Day,XX99,C-102,,Approved,KND000,DD,Drilling,80,90,2,,`,
  ].join('\n'));
  const dry = run('import dry run', D('import', 'coreplan', csv, '--dry-run'));
  assert(dry.plods === 3 && dry.lines === 6 && dry.created === 0, 'dry run counts and writes nothing');
  const imp = run('import', D('import', 'coreplan', csv));
  assert(imp.created === 2 && imp.problems.some((p) => /XX99/.test(p)), `two plods in, unknown rig reported (${JSON.stringify(imp)})`);
  const imp2 = run('import again (idempotent)', D('import', 'coreplan', csv));
  assert(imp2.created === 0 && imp2.skipped_existing === 2, 'import twice is harmless');
  const ip = run('imported plods', D('plods', '--days=31', '--contract=C-102', '--status=submitted'));
  const night = ip.find((p) => p.plod_date === day(-30));
  assert(night && n(night.standby_client_min) === 120 && n(night.metres) === 38, 'standby and metres mapped from CorePlan activities');

  // ---- export, views, docs
  const exp = run('export', D('export', `--out=${exportDir}`));
  assert(exp.counts.plods >= 94 && existsSync(path.join(exportDir, 'plod_activities.csv')), 'export writes every table');
  run('views', ['view.mjs'], { json: false });
  run('documents', ['docs.mjs'], { json: false });
  assert(readdirSync(path.join(root, 'docs-out', 'claim')).some((f) => f.includes('CL-1012')), 'the new claim renders');

  // ---- the log
  run('log a note', D('log', 'C-103', 'Rosie wants a fifth bore quoted', '--by=Priya'));
  run('help', ['drill.mjs', 'help'], { json: false });
  run('unknown command exits 1', ['drill.mjs', 'nonsense'], { json: false, expectFail: true });

  console.log(`\nPASS: ${step} steps`);
} finally {
  rmSync(dataDir, { recursive: true, force: true });
}
