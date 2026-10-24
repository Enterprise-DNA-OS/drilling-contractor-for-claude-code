#!/usr/bin/env node
// drilling-contractor-for-claude-code: the one CLI. The slash commands call this; so can you.
//
//   node scripts/drill.mjs <command> [args] [--flags] [--json]
//   npm run drill -- <command> ...
//
// Run with no arguments (or `help`) for the command list.
//
// This records what an exploration and water bore drilling contractor runs on: contracts and
// their schedules of rates, rigs, crew, holes, the plod for every rig and shift (activities,
// metres, crew hours, consumables), client sign-off, prestarts, services, bits, incidents and the
// monthly progress claim. It sends nothing and talks to no other system: claims, plod sheets and
// letters are drafted here, a person sends them.

import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import path from 'node:path';
import { getDb, REPO_ROOT } from './lib/db.mjs';
import { parseCsv, pick } from './lib/csv.mjs';
import { table, money, price, isoDate, truncate, heading, hours } from './lib/format.mjs';

// ---------------------------------------------------------------- settings

// Fatigue limits. Set these to your own fatigue management plan; the defaults are a common
// starting point for 12 hour rosters, not a legal limit.
const MAX_SHIFT_MIN = 12 * 60;
const MAX_7DAY_MIN = 84 * 60;
// Days after a hole is finished before it should be capped and rehabilitated. Your programme of
// work conditions set the real number.
const REHAB_DAYS = 30;
// A programme of work this close to expiry is flagged.
const POW_WARN_DAYS = 30;
// Approved work older than this, not on any claim, is flagged.
const UNCLAIMED_DAYS = 14;

const ACTIVITIES = ['drilling', 'rig-move', 'rig-up', 'standby-client', 'standby-contractor', 'breakdown', 'survey', 'development', 'safety', 'meal'];

// ---------------------------------------------------------------- arguments

const BOOL_FLAGS = new Set(['json', 'help', 'all', 'dry-run', 'save', 'open', 'notifiable', 'failed']);

function parseArgv(argv) {
  const args = [];
  const flags = {};
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a === '-h') { flags.help = true; continue; }
    if (a.startsWith('--')) {
      const eq = a.indexOf('=');
      let name, value;
      if (eq > -1) { name = a.slice(2, eq); value = a.slice(eq + 1); }
      else {
        name = a.slice(2);
        const next = argv[i + 1];
        if (BOOL_FLAGS.has(name) || next === undefined || next.startsWith('--')) value = true;
        else value = argv[++i];
      }
      flags[name] = value;
    } else args.push(a);
  }
  return { args, flags };
}

class CliError extends Error {
  constructor(message, code = 1) { super(message); this.code = code; }
}

const n = (v) => Number(v ?? 0);
const str = (v) => (v === true || v === undefined || v === null ? '' : String(v));
const m1 = (v) => n(v).toFixed(1).replace(/\.0$/, '');
const aud = (cents, currency = 'AUD') => money(cents, currency);

function today() {
  const d = new Date();
  const pad = (x) => String(x).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
}

function parseDate(v, what = 'date') {
  if (!v || v === true) return null;
  const s = String(v).trim();
  if (/^\d{4}-\d{2}-\d{2}$/.test(s)) return s;
  if (s.toLowerCase() === 'today') return today();
  if (s.toLowerCase() === 'yesterday') { const d = new Date(); d.setDate(d.getDate() - 1); return isoDate(d); }
  // AU and NZ exports write DD/MM/YYYY.
  const m = s.match(/^(\d{1,2})[/.-](\d{1,2})[/.-](\d{2,4})/);
  if (m) {
    const year = m[3].length === 2 ? `20${m[3]}` : m[3];
    return `${year}-${m[2].padStart(2, '0')}-${m[1].padStart(2, '0')}`;
  }
  throw new CliError(`"${v}" is not a ${what}. Use YYYY-MM-DD.`);
}

function parseMoney(v) {
  if (v === undefined || v === null || v === '' || v === true) return null;
  const x = Number(String(v).replace(/[^0-9.-]/g, ''));
  if (Number.isNaN(x)) throw new CliError(`"${v}" is not an amount.`);
  return Math.round(x * 100);
}

function parseHours(v, what = 'hours') {
  if (v === undefined || v === true || v === '') return null;
  const s = String(v).trim();
  const hm = s.match(/^(\d+):(\d{2})$/);
  if (hm) return Number(hm[1]) * 60 + Number(hm[2]);
  const x = Number(s.replace(/h$/i, ''));
  if (!Number.isFinite(x) || x < 0) throw new CliError(`"${v}" is not a number of ${what}. Use 1.5 or 1:30.`);
  return Math.round(x * 60);
}

// ---------------------------------------------------------------- lookups

let db;
let JSON_OUT = false;

function ambiguous(what, rows, label) {
  return new CliError(`More than one ${what} matches. Be more specific:\n${rows.map((r) => `  ${label(r)}`).join('\n')}`);
}

async function findContract(ref) {
  if (!ref || ref === true) throw new CliError('Which contract? Give its code or part of its name or the client.');
  const sql = `select k.*, c.name as client from contracts k join clients c on c.id = k.client_id`;
  const exact = await db.query(`${sql} where lower(k.code) = lower($1) or lower(coalesce(k.external_ref,'')) = lower($1) or k.id::text = $1`, [ref]);
  if (exact.length === 1) return exact[0];
  const fuzzy = await db.query(`${sql} where k.code ilike $1 or k.name ilike $1 or c.name ilike $1 or k.id::text like $2 order by k.code`, [`%${ref}%`, `${ref}%`]);
  if (fuzzy.length === 1) return fuzzy[0];
  if (!fuzzy.length) throw new CliError(`No contract matches "${ref}". Run: drill contracts --all`);
  throw ambiguous('contract', fuzzy, (r) => `${r.code}  ${r.name} (${r.client})`);
}

async function findRig(ref) {
  if (!ref || ref === true) throw new CliError('Which rig? Give its code, for example RC01.');
  const rows = await db.query(`select r.*, k.code as contract from rigs r left join contracts k on k.id = r.contract_id where lower(r.code) = lower($1) or r.code ilike $2 or r.make_model ilike $2 order by r.code`, [ref, `%${ref}%`]);
  const exact = rows.filter((r) => r.code.toLowerCase() === String(ref).toLowerCase());
  if (exact.length === 1) return exact[0];
  if (rows.length === 1) return rows[0];
  if (!rows.length) throw new CliError(`No rig "${ref}". Run: drill rigs`);
  throw ambiguous('rig', rows, (r) => `${r.code}  ${r.make_model}`);
}

async function findStaff(ref) {
  if (!ref || ref === true) throw new CliError('Who? Give a crew code or name.');
  const rows = await db.query(`select * from staff where lower(code) = lower($1) or lower(full_name) = lower($1) or full_name ilike $2 order by full_name`, [ref, `%${ref}%`]);
  const exact = rows.filter((r) => r.code.toLowerCase() === String(ref).toLowerCase() || r.full_name.toLowerCase() === String(ref).toLowerCase());
  if (exact.length === 1) return exact[0];
  if (rows.length === 1) return rows[0];
  if (!rows.length) throw new CliError(`No one called "${ref}". Run: drill staff`);
  throw ambiguous('person', rows, (r) => `${r.code}  ${r.full_name} (${r.role})`);
}

async function findPlod(ref) {
  if (!ref || ref === true) throw new CliError('Which plod? Give its number (P-10042), or a rig and date: RC01 2026-10-20 night.');
  const rows = await db.query(`select * from v_plod_summary where lower(number) = lower($1) or number ilike $2 or id::text like $3 order by number`, [ref, `%${ref}`, `${ref}%`]);
  if (rows.length === 1) return rows[0];
  if (!rows.length) throw new CliError(`No plod "${ref}". Run: drill plods`);
  throw ambiguous('plod', rows.slice(0, 15), (r) => `${r.number}  ${r.rig} ${isoDate(r.plod_date)} ${r.shift}`);
}

async function findHole(contractId, ref) {
  const rows = await db.query(`select * from holes where contract_id = $1 and (lower(hole_id) = lower($2) or hole_id ilike $3) order by hole_id`, [contractId, ref, `%${ref}%`]);
  const exact = rows.filter((r) => r.hole_id.toLowerCase() === String(ref).toLowerCase());
  if (exact.length === 1) return exact[0];
  if (rows.length === 1) return rows[0];
  if (!rows.length) return null;
  throw ambiguous('hole', rows, (r) => r.hole_id);
}

// ---------------------------------------------------------------- output

function out(data, text) {
  if (JSON_OUT) console.log(JSON.stringify(data, null, 2));
  else console.log(typeof text === 'function' ? text() : text);
}

// ---------------------------------------------------------------- overview

async function stats() {
  const [s] = await db.query(`
    select (select count(*) from contracts where status = 'active') as active_contracts,
           (select count(*) from rigs where status = 'working') as rigs_working,
           (select coalesce(sum(metres),0) from v_plod_summary where plod_date >= current_date - 7) as metres_7d,
           (select count(*) from plods where status = 'submitted') as awaiting_signoff,
           (select count(*) from plods where status = 'rejected') as rejected,
           (select coalesce(sum(charge_cents),0) from v_plod_summary where status = 'approved' and claim_id is null) as approved_unclaimed_cents,
           (select coalesce(sum(charge_cents),0) from v_plod_summary where status = 'submitted') as awaiting_signoff_cents,
           (select coalesce(sum(amount_cents),0) from claims where status = 'submitted') as claims_out_cents,
           (select count(*) from incidents where closed_on is null) as open_incidents`);
  const r = Object.fromEntries(Object.entries(s).map(([k, v]) => [k, n(v)]));
  out(r, () => [
    heading('Ironbark at a glance'),
    `  ${r.active_contracts} active contracts, ${r.rigs_working} rigs working, ${m1(r.metres_7d)} m drilled in the last 7 days.`,
    `  ${r.awaiting_signoff} plods waiting for client sign-off (${aud(r.awaiting_signoff_cents)}), ${r.rejected} rejected and not fixed.`,
    `  ${aud(r.approved_unclaimed_cents)} signed off and not yet claimed. ${aud(r.claims_out_cents)} in claims submitted and unpaid.`,
    `  ${r.open_incidents} incidents open.`,
  ].join('\n'));
}

// ---------------------------------------------------------------- contracts

async function contracts(flags) {
  const rows = await db.query(`
    select k.code, k.name, c.name as client, k.status, k.tenement, k.pow_expires_on,
           (select count(*) from holes h where h.contract_id = k.id) as holes,
           (select coalesce(sum(metres),0) from v_plod_summary v where v.contract_id = k.id) as metres,
           (select coalesce(sum(charge_cents),0) from v_plod_summary v where v.contract_id = k.id and v.status = 'approved' and v.claim_id is null) as unclaimed_cents,
           (select coalesce(sum(charge_cents),0) from v_plod_summary v where v.contract_id = k.id and v.status in ('submitted','rejected')) as unsigned_cents,
           (select string_agg(r.code, ', ' order by r.code) from rigs r where r.contract_id = k.id and k.status = 'active') as rigs
    from contracts k join clients c on c.id = k.client_id
    ${flags.all ? '' : "where k.status = 'active'"} order by k.code`);
  out(rows, () => heading('Contracts') + '\n' + table(rows, [
    { key: 'code', label: 'Code' }, { key: 'name', label: 'Contract', width: 30 }, { key: 'client', label: 'Client', width: 26 },
    { key: 'rigs', label: 'Rigs' }, { key: 'holes', label: 'Holes', align: 'right' }, { key: 'metres', label: 'Metres', align: 'right', format: m1 },
    { key: 'unsigned_cents', label: 'Not signed off', align: 'right', format: (v) => aud(v) },
    { key: 'unclaimed_cents', label: 'Unclaimed', align: 'right', format: (v) => aud(v) },
    { key: 'pow_expires_on', label: 'PoW expires', format: isoDate },
  ]));
}

async function contract(args) {
  const k = await findContract(args[0]);
  const rates = await rateRows(k.id);
  const rigs = await db.query(`select code, make_model, status from rigs where contract_id = $1 order by code`, [k.id]);
  const holes = await db.query(`select stage, count(*) as holes, coalesce(sum(depth_m),0) as metres from v_hole_status where contract_id = $1 group by stage order by stage`, [k.id]);
  const money_ = (await db.query(`
    select coalesce(sum(charge_cents) filter (where status = 'approved' and claim_id is null),0) as unclaimed,
           coalesce(sum(charge_cents) filter (where status in ('submitted','rejected')),0) as unsigned,
           coalesce(sum(charge_cents) filter (where claim_id is not null),0) as claimed
    from v_plod_summary where contract_id = $1`, [k.id]))[0];
  const claims = await db.query(`select number, period_end, amount_cents, status, submitted_on, paid_on from claims where contract_id = $1 order by period_end`, [k.id]);
  const notes = await db.query(`select created_at, author, body from notes where contract_id = $1 order by created_at desc limit 5`, [k.id]);
  const data = { contract: k, rates, rigs, holes, money: money_, claims, notes };
  out(data, () => [
    heading(`${k.code}  ${k.name}`),
    `  Client ${k.client}. Site ${k.site || '-'}. Tenement ${k.tenement || '-'}. ${k.status}.`,
    `  Programme of work ${k.pow_ref || 'none recorded'}${k.pow_expires_on ? ', expires ' + isoDate(k.pow_expires_on) : ''}. Water licence ${k.water_licence_ref || '-'}.`,
    `  Sign-off within ${k.signoff_days} days of a plod. Payment ${k.terms_days} days from claim.`,
    `  Rigs: ${rigs.map((r) => `${r.code} (${r.status})`).join(', ') || 'none'}.`,
    `  Holes: ${holes.map((h) => `${h.holes} ${h.stage}`).join(', ') || 'none'}; ${m1(holes.reduce((s, h) => s + n(h.metres), 0))} m drilled.`,
    `  Money: ${aud(money_.claimed)} claimed, ${aud(money_.unclaimed)} signed off and unclaimed, ${aud(money_.unsigned)} not signed off.`,
    '\nSchedule of rates',
    table(rates, rateCols),
    '\nClaims',
    table(claims, [{ key: 'number', label: 'Claim' }, { key: 'period_end', label: 'To', format: isoDate }, { key: 'amount_cents', label: 'Amount', align: 'right', format: (v) => aud(v) }, { key: 'status', label: 'Status' }, { key: 'submitted_on', label: 'Submitted', format: isoDate }, { key: 'paid_on', label: 'Paid', format: isoDate }]),
    notes.length ? '\nRecent notes\n' + notes.map((x) => `  ${isoDate(x.created_at)} ${x.author || ''}: ${x.body}`).join('\n') : '',
  ].join('\n'));
}

const rateCols = [
  { key: 'code', label: 'Code' }, { key: 'description', label: 'Item', width: 34 }, { key: 'unit', label: 'Unit' },
  { key: 'basis', label: 'Applies to', width: 26 }, { key: 'rate_cents', label: 'Rate', align: 'right', format: (v) => price(v, 'AUD') },
];
async function rateRows(contractId) {
  const rows = await db.query(`select code, description, unit, method, depth_from, depth_to, activity, rate_cents from rate_items where contract_id = $1 order by unit, method nulls last, depth_from nulls last, code`, [contractId]);
  return rows.map((r) => ({ ...r, basis: r.method ? `${r.method} ${m1(r.depth_from)} to ${m1(r.depth_to)} m` : r.activity ? `activity: ${r.activity}` : 'item used' }));
}

async function rates(args) {
  const k = await findContract(args[0]);
  const rows = await rateRows(k.id);
  out(rows, () => heading(`Schedule of rates, ${k.code} ${k.name}`) + '\n' + table(rows, rateCols) + '\n\n  Activities with no rate (breakdown, standby on us, safety, meals) earn nothing.');
}

// ---------------------------------------------------------------- plods

const plodCols = [
  { key: 'number', label: 'Plod' }, { key: 'plod_date', label: 'Date', format: isoDate }, { key: 'shift', label: 'Shift' },
  { key: 'rig', label: 'Rig' }, { key: 'contract', label: 'Contract' }, { key: 'driller', label: 'Driller', width: 14 },
  { key: 'metres', label: 'Metres', align: 'right', format: m1 }, { key: 'drilling_min', label: 'Drilling', align: 'right', format: hours },
  { key: 'standby_client_min', label: 'Standby', align: 'right', format: hours }, { key: 'lost_min', label: 'Lost', align: 'right', format: hours },
  { key: 'charge_cents', label: 'Charges', align: 'right', format: (v) => aud(v) }, { key: 'status', label: 'Status' },
];

async function plods(flags) {
  const where = ['plod_date >= current_date - $1::int'];
  const params = [Number(flags.days || 7)];
  if (flags.contract) { const k = await findContract(flags.contract); params.push(k.id); where.push(`contract_id = $${params.length}`); }
  if (flags.rig) { const r = await findRig(flags.rig); params.push(r.id); where.push(`rig_id = $${params.length}`); }
  if (flags.status) { params.push(String(flags.status)); where.push(`status = $${params.length}`); }
  const rows = await db.query(`select * from v_plod_summary where ${where.join(' and ')} order by plod_date desc, rig, shift`, params);
  out(rows, () => heading(`Plods, last ${params[0]} days`) + '\n' + table(rows, plodCols));
}

async function plod(args) {
  const p = await findPlod(args[0]);
  const acts = await db.query(`select a.line, a.activity, h.hole_id, a.minutes, a.from_m, a.to_m, a.bit_serial, a.notes from plod_activities a left join holes h on h.id = a.hole_id where a.plod_id = $1 order by a.line`, [p.id]);
  const crew = await db.query(`select s.code, s.full_name, s.role, c.minutes from plod_crew c join staff s on s.id = c.staff_id where c.plod_id = $1 order by s.role, s.code`, [p.id]);
  const cons = await db.query(`select item, qty from plod_consumables where plod_id = $1 order by item`, [p.id]);
  const charges = await db.query(`select rate_code, description, unit, sum(qty) as qty, rate_cents, sum(amount_cents) as amount_cents from v_plod_charges where plod_id = $1 group by rate_code, description, unit, rate_cents order by rate_code`, [p.id]);
  const [pre] = await db.query(`select ok, defects, s.full_name as by from prestarts x left join staff s on s.id = x.done_by where x.rig_id = $1 and x.done_on = $2 and x.shift = $3`, [p.rig_id, p.plod_date, p.shift]);
  const [extra] = await db.query(`select comments, approved_by, engine_hours_end from plods where id = $1`, [p.id]);
  const data = { plod: { ...p, ...extra }, activities: acts, crew, consumables: cons, charges, prestart: pre || null };
  out(data, () => [
    heading(`${p.number}  ${p.rig} ${isoDate(p.plod_date)} ${p.shift} shift, ${p.contract}`),
    `  Driller ${p.driller || '-'}. ${p.status}${p.approved_on ? ' ' + isoDate(p.approved_on) + ' by ' + extra.approved_by : ''}${p.reject_reason ? ': ' + p.reject_reason : ''}.`,
    `  Prestart: ${pre ? (pre.ok ? 'done' : 'FAILED: ' + pre.defects) + ' (' + (pre.by || '-') + ')' : 'NONE RECORDED'}. Engine hours at end ${extra.engine_hours_end ?? '-'}.`,
    extra.comments ? `  Comments: ${extra.comments}` : '',
    '\nActivities',
    table(acts, [{ key: 'line', label: '#', align: 'right' }, { key: 'activity', label: 'Activity' }, { key: 'hole_id', label: 'Hole' }, { key: 'minutes', label: 'Time', align: 'right', format: hours }, { key: 'from_m', label: 'From', align: 'right', format: (v) => (v == null ? '' : m1(v)) }, { key: 'to_m', label: 'To', align: 'right', format: (v) => (v == null ? '' : m1(v)) }, { key: 'bit_serial', label: 'Bit' }, { key: 'notes', label: 'Notes', width: 40 }]),
    '\nCrew',
    table(crew, [{ key: 'code', label: 'Code' }, { key: 'full_name', label: 'Name' }, { key: 'role', label: 'Role' }, { key: 'minutes', label: 'Hours', align: 'right', format: hours }]),
    cons.length ? '\nConsumables\n' + table(cons, [{ key: 'item', label: 'Item' }, { key: 'qty', label: 'Qty', align: 'right', format: m1 }]) : '',
    '\nCharges from the schedule of rates',
    table(charges, [{ key: 'rate_code', label: 'Code' }, { key: 'description', label: 'Item', width: 32 }, { key: 'qty', label: 'Qty', align: 'right', format: m1 }, { key: 'unit', label: 'Unit' }, { key: 'rate_cents', label: 'Rate', align: 'right', format: (v) => price(v, 'AUD') }, { key: 'amount_cents', label: 'Amount', align: 'right', format: (v) => aud(v) }]),
    `  Total ${aud(p.charge_cents)}`,
  ].filter(Boolean).join('\n'));
}

async function pendingRows() {
  return db.query(`
    select v.number, v.rig, v.contract, v.plod_date, v.shift, v.status, v.submitted_on, v.reject_reason, v.charge_cents, k.signoff_days,
           (current_date - v.submitted_on) as days_waiting, c.name as client, c.contact_name, c.contact_email,
           (v.status = 'submitted' and current_date - v.submitted_on > k.signoff_days) as overdue
    from v_plod_summary v join contracts k on k.id = v.contract_id join clients c on c.id = k.client_id
    where v.status in ('submitted', 'rejected') order by v.status desc, v.submitted_on, v.rig, v.shift`);
}

async function pending() {
  const rows = await pendingRows();
  out(rows, () => heading('Plods waiting on the client') + '\n' + table(rows, [
    { key: 'number', label: 'Plod' }, { key: 'contract', label: 'Contract' }, { key: 'rig', label: 'Rig' }, { key: 'plod_date', label: 'Date', format: isoDate }, { key: 'shift', label: 'Shift' },
    { key: 'status', label: 'Status' }, { key: 'days_waiting', label: 'Days', align: 'right' }, { key: 'overdue', label: 'Past window', format: (v) => (v ? 'YES' : '') },
    { key: 'charge_cents', label: 'Charges', align: 'right', format: (v) => aud(v) }, { key: 'reject_reason', label: 'Rejected because', width: 50 },
  ]) + `\n\n  ${aud(rows.reduce((s, r) => s + n(r.charge_cents), 0))} cannot be claimed until these are signed off.`);
}

async function nextNumber(tableName, prefix) {
  const [r] = await db.query(`select max(number) as last from ${tableName} where number like $1`, [`${prefix}%`]);
  const last = r.last ? Number(String(r.last).slice(prefix.length)) : 10000;
  return `${prefix}${last + 1}`;
}

async function plodNew(args, flags) {
  const rig = await findRig(args[0]);
  const k = flags.contract ? await findContract(flags.contract) : rig.contract_id ? await findContract(rig.contract) : null;
  if (!k) throw new CliError(`${rig.code} is not on a contract. Add --contract=<code>.`);
  const date = parseDate(flags.date || 'today');
  const shift = str(flags.shift) || 'day';
  if (!['day', 'night'].includes(shift)) throw new CliError('--shift is day or night.');
  const driller = flags.driller ? await findStaff(flags.driller) : null;
  const dup = await db.query(`select number from plods where rig_id = $1 and plod_date = $2 and shift = $3`, [rig.id, date, shift]);
  if (dup.length) throw new CliError(`${rig.code} already has a ${shift} plod for ${date}: ${dup[0].number}`);
  const number = await nextNumber('plods', 'P-');
  await db.query(`insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, engine_hours_end, comments) values ($1,$2,$3,$4,$5,$6,$7,$8)`,
    [number, k.id, rig.id, date, shift, driller?.id || null, flags['engine-hours'] ? Number(flags['engine-hours']) : null, str(flags.comments) || null]);
  if (driller) await db.query(`insert into plod_crew (plod_id, staff_id, minutes) select id, $2, 0 from plods where number = $1 on conflict do nothing`, [number, driller.id]);
  out({ number, rig: rig.code, contract: k.code, date, shift }, () => `  ${number} opened: ${rig.code} ${date} ${shift} shift on ${k.code}. Add lines with: drill activity ${number} drilling --hole=.. --from=.. --to=.. --hours=..`);
}

async function editablePlod(ref) {
  const p = await findPlod(ref);
  if (p.status === 'approved') throw new CliError(`${p.number} is signed off by the client. Changing it means asking them to sign again: drill reopen ${p.number}`);
  return p;
}

async function activity(args, flags) {
  const p = await editablePlod(args[0]);
  const act = String(args[1] || '').toLowerCase();
  if (!ACTIVITIES.includes(act)) throw new CliError(`Activity is one of: ${ACTIVITIES.join(', ')}`);
  let hole = null;
  if (flags.hole) {
    hole = await findHole(p.contract_id, flags.hole);
    if (!hole) {
      const method = str(flags.method).toUpperCase();
      if (!method) throw new CliError(`No hole "${flags.hole}" on ${p.contract}. Add --method=RC|DD|AC|RAB|WB to create it.`);
      [hole] = await db.query(`insert into holes (contract_id, hole_id, method, planned_depth, started_on) values ($1,$2,$3,$4,$5) returning *`, [p.contract_id, flags.hole, method, flags.planned ? Number(flags.planned) : null, p.plod_date]);
    }
  }
  const from = flags.from !== undefined ? Number(flags.from) : null;
  const to = flags.to !== undefined ? Number(flags.to) : null;
  if (act === 'drilling') {
    if (!hole) throw new CliError('Drilling needs a hole: --hole=<id>');
    if (from === null || to === null || to < from) throw new CliError('Drilling needs --from and --to in metres, to at or past from.');
  }
  const minutes = parseHours(flags.hours) ?? 0;
  const [{ line }] = await db.query(`select coalesce(max(line),0) + 1 as line from plod_activities where plod_id = $1`, [p.id]);
  await db.query(`insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes) values ($1,$2,$3,$4,$5,$6,$7,$8,$9)`,
    [p.id, line, act, hole?.id || null, minutes, from, to, str(flags.bit) || null, str(flags.notes) || null]);
  if (hole && !hole.started_on) await db.query(`update holes set started_on = $2 where id = $1`, [hole.id, p.plod_date]);
  if (flags.complete && hole) await db.query(`update holes set completed_on = $2 where id = $1`, [hole.id, p.plod_date]);
  out({ plod: p.number, line, activity: act, hole: hole?.hole_id, minutes, from, to }, () => `  ${p.number} line ${line}: ${act}${hole ? ' on ' + hole.hole_id : ''}${act === 'drilling' ? ` ${m1(from)} to ${m1(to)} m` : ''}, ${hours(minutes)}.`);
}

async function crewCmd(args, flags) {
  const p = await editablePlod(args[0]);
  const s = await findStaff(args[1]);
  const minutes = parseHours(flags.hours);
  if (minutes === null) throw new CliError('How long? --hours=12');
  await db.query(`insert into plod_crew (plod_id, staff_id, minutes) values ($1,$2,$3) on conflict (plod_id, staff_id) do update set minutes = excluded.minutes`, [p.id, s.id, minutes]);
  out({ plod: p.number, staff: s.code, minutes }, () => `  ${p.number}: ${s.full_name} ${hours(minutes)}.`);
}

async function consume(args, flags) {
  const p = await editablePlod(args[0]);
  const item = str(args[1]);
  const qty = Number(flags.qty);
  if (!item || !Number.isFinite(qty)) throw new CliError('Usage: drill consume <plod> <item> --qty=N');
  await db.query(`insert into plod_consumables (plod_id, item, qty) values ($1,$2,$3) on conflict (plod_id, item) do update set qty = excluded.qty`, [p.id, item, qty]);
  const [rate] = await db.query(`select code from rate_items where contract_id = $1 and code = $2`, [p.contract_id, item]);
  out({ plod: p.number, item, qty, chargeable: !!rate }, () => `  ${p.number}: ${m1(qty)} ${item}${rate ? '' : ' (not on the schedule of rates: recorded as a cost, not charged)'}.`);
}

async function submit(args) {
  const p = await editablePlod(args[0]);
  const problems = [];
  if (!p.total_min) problems.push('no activities');
  const [crewN] = await db.query(`select count(*) as c, coalesce(sum(minutes),0) as m from plod_crew where plod_id = $1`, [p.id]);
  if (!n(crewN.c) || !n(crewN.m)) problems.push('no crew hours');
  const [pre] = await db.query(`select 1 from prestarts where rig_id = $1 and done_on = $2 and shift = $3`, [p.rig_id, p.plod_date, p.shift]);
  if (!pre) problems.push('no prestart recorded for this rig and shift');
  if (problems.length) throw new CliError(`${p.number} is not ready to send: ${problems.join('; ')}.`);
  await db.query(`update plods set status = 'submitted', submitted_on = current_date, reject_reason = null where id = $1`, [p.id]);
  out({ plod: p.number, status: 'submitted' }, () => `  ${p.number} marked as sent to the client for sign-off. Render the sheet with: npm run docs -- plod`);
}

async function approve(args, flags) {
  const p = await findPlod(args[0]);
  if (p.status !== 'submitted') throw new CliError(`${p.number} is ${p.status}; only a submitted plod can be signed off.`);
  const by = str(flags.by);
  if (!by) throw new CliError('Who signed it off for the client? --by="Name (Company)"');
  const on = parseDate(flags.on || 'today');
  await db.query(`update plods set status = 'approved', approved_on = $2, approved_by = $3 where id = $1`, [p.id, on, by]);
  out({ plod: p.number, status: 'approved', by, on }, () => `  ${p.number} signed off by ${by} on ${on}. ${aud(p.charge_cents)} is now claimable.`);
}

async function reject(args, flags) {
  const p = await findPlod(args[0]);
  const reason = str(flags.reason);
  if (!reason) throw new CliError('Why did the client reject it? --reason=".."');
  await db.query(`update plods set status = 'rejected', reject_reason = $2, approved_on = null, approved_by = null where id = $1`, [p.id, reason]);
  out({ plod: p.number, status: 'rejected', reason }, () => `  ${p.number} rejected: ${reason}. Fix the lines, then: drill submit ${p.number}`);
}

async function reopen(args) {
  const p = await findPlod(args[0]);
  if (p.claim_id) throw new CliError(`${p.number} is already on a claim. Credit it on the next claim instead.`);
  await db.query(`update plods set status = 'draft', approved_on = null, approved_by = null where id = $1`, [p.id]);
  out({ plod: p.number, status: 'draft' }, () => `  ${p.number} is back to draft. It needs the client's sign-off again.`);
}

// ---------------------------------------------------------------- money

async function chargeRows(contractId, from, to, statuses) {
  return db.query(`
    select rate_code, description, unit, rate_cents, sum(qty) as qty, sum(amount_cents) as amount_cents, count(distinct plod_id) as plods
    from v_plod_charges where contract_id = $1 and plod_date between $2 and $3 and status = any($4)
    group by rate_code, description, unit, rate_cents order by rate_code`, [contractId, from, to, statuses]);
}

async function charges(args, flags) {
  const k = await findContract(args[0]);
  const from = parseDate(flags.from) || isoDate(k.starts_on) || '2000-01-01';
  const to = parseDate(flags.to) || today();
  const approved = await chargeRows(k.id, from, to, ['approved']);
  const unsigned = await chargeRows(k.id, from, to, ['submitted', 'rejected', 'draft']);
  const tot = (rows) => rows.reduce((s, r) => s + n(r.amount_cents), 0);
  const data = { contract: k.code, from, to, approved, unsigned, approved_cents: tot(approved), unsigned_cents: tot(unsigned) };
  const cols = [{ key: 'rate_code', label: 'Code' }, { key: 'description', label: 'Item', width: 34 }, { key: 'qty', label: 'Qty', align: 'right', format: m1 }, { key: 'unit', label: 'Unit' }, { key: 'rate_cents', label: 'Rate', align: 'right', format: (v) => price(v, 'AUD') }, { key: 'amount_cents', label: 'Amount', align: 'right', format: (v) => aud(v) }, { key: 'plods', label: 'Plods', align: 'right' }];
  out(data, () => [
    heading(`Charges, ${k.code} ${k.name}, ${from} to ${to}`),
    'Signed off by the client', table(approved, cols), `  ${aud(data.approved_cents)}`,
    '\nNot signed off yet', table(unsigned, cols), `  ${aud(data.unsigned_cents)}`,
  ].join('\n'));
}

async function claim(args, flags) {
  const k = await findContract(args[0]);
  const periodEnd = parseDate(flags['period-end']) || today();
  const lines = await db.query(`
    select rate_code, description, unit, rate_cents, sum(qty) as qty, sum(amount_cents) as amount_cents
    from v_plod_charges where contract_id = $1 and status = 'approved' and claim_id is null and plod_date <= $2
    group by rate_code, description, unit, rate_cents order by rate_code`, [k.id, periodEnd]);
  const plodsIn = await db.query(`select number, rig, plod_date, shift, charge_cents from v_plod_summary where contract_id = $1 and status = 'approved' and claim_id is null and plod_date <= $2 order by plod_date, rig, shift`, [k.id, periodEnd]);
  const held = await db.query(`select number, rig, plod_date, shift, status, charge_cents from v_plod_summary where contract_id = $1 and status in ('submitted','rejected','draft') and plod_date <= $2 order by plod_date`, [k.id, periodEnd]);
  const amount = lines.reduce((s, r) => s + n(r.amount_cents), 0);
  let number = null;
  if (flags.save) {
    if (!plodsIn.length) throw new CliError(`Nothing signed off and unclaimed on ${k.code} up to ${periodEnd}.`);
    number = await nextNumber('claims', `CL-${k.code.replace(/\D/g, '')}`);
    await db.exec('BEGIN');
    try {
      const [c] = await db.query(`insert into claims (contract_id, number, period_end, amount_cents, status) values ($1,$2,$3,$4,'draft') returning id`, [k.id, number, periodEnd, amount]);
      await db.query(`update plods set claim_id = $1 where contract_id = $2 and status = 'approved' and claim_id is null and plod_date <= $3`, [c.id, k.id, periodEnd]);
      await db.exec('COMMIT');
    } catch (e) { await db.exec('ROLLBACK'); throw e; }
  }
  const data = { contract: k.code, period_end: periodEnd, number, amount_cents: amount, lines, plods: plodsIn, held_back: held };
  out(data, () => [
    heading(`${number ? 'Claim ' + number : 'Draft claim'}: ${k.code} ${k.name}, work to ${periodEnd}`),
    `  ${k.client}. ${plodsIn.length} signed-off plods.`,
    table(lines, [{ key: 'rate_code', label: 'Code' }, { key: 'description', label: 'Item', width: 34 }, { key: 'qty', label: 'Qty', align: 'right', format: m1 }, { key: 'unit', label: 'Unit' }, { key: 'rate_cents', label: 'Rate', align: 'right', format: (v) => price(v, 'AUD') }, { key: 'amount_cents', label: 'Amount', align: 'right', format: (v) => aud(v) }]),
    `  Total excl. GST ${aud(amount)}`,
    held.length ? `\n  Held back, not signed off: ${held.map((h) => `${h.number} ${h.rig} ${isoDate(h.plod_date)} ${h.shift} (${h.status}, ${aud(h.charge_cents)})`).join('; ')}` : '',
    number ? `\n  Saved as draft. Render it with: npm run docs -- claim. When it goes out: drill claim-status ${number} --submitted=today` : '\n  Not saved. Add --save to lock these plods onto a claim.',
  ].filter(Boolean).join('\n'));
}

async function claimRows(open) {
  return db.query(`
    select c.number, k.code as contract, cl.name as client, c.period_end, c.amount_cents, c.status, c.submitted_on, c.paid_on, k.terms_days,
           (c.submitted_on + k.terms_days) as due_on,
           case when c.status = 'submitted' then current_date - (c.submitted_on + k.terms_days) end as days_overdue
    from claims c join contracts k on k.id = c.contract_id join clients cl on cl.id = k.client_id
    ${open ? "where c.status in ('draft','submitted','disputed')" : ''} order by c.period_end`);
}

async function claims(flags) {
  const rows = await claimRows(flags.open);
  out(rows, () => heading('Claims') + '\n' + table(rows, [
    { key: 'number', label: 'Claim' }, { key: 'contract', label: 'Contract' }, { key: 'client', label: 'Client', width: 26 }, { key: 'period_end', label: 'Work to', format: isoDate },
    { key: 'amount_cents', label: 'Amount', align: 'right', format: (v) => aud(v) }, { key: 'status', label: 'Status' }, { key: 'submitted_on', label: 'Sent', format: isoDate },
    { key: 'due_on', label: 'Due', format: isoDate }, { key: 'days_overdue', label: 'Overdue', align: 'right', format: (v) => (n(v) > 0 ? `${v} days` : '') },
  ]));
}

async function claimStatus(args, flags) {
  const [c] = await db.query(`select * from claims where lower(number) = lower($1)`, [args[0] || '']);
  if (!c) throw new CliError(`No claim "${args[0]}". Run: drill claims`);
  if (flags.submitted) await db.query(`update claims set status = 'submitted', submitted_on = $2 where id = $1`, [c.id, parseDate(flags.submitted)]);
  if (flags.paid) await db.query(`update claims set status = 'paid', paid_on = $2, paid_cents = coalesce($3, amount_cents) where id = $1`, [c.id, parseDate(flags.paid), parseMoney(flags.amount)]);
  if (flags.disputed) await db.query(`update claims set status = 'disputed' where id = $1`, [c.id]);
  const [u] = await db.query(`select number, status, submitted_on, paid_on, amount_cents, paid_cents from claims where id = $1`, [c.id]);
  out(u, () => `  ${u.number}: ${u.status}${u.submitted_on ? ', sent ' + isoDate(u.submitted_on) : ''}${u.paid_on ? ', paid ' + isoDate(u.paid_on) + ' ' + aud(u.paid_cents) : ''}.`);
}

// ---------------------------------------------------------------- rigs

async function rigRows() {
  return db.query(`
    select r.id, r.code, r.make_model, r.kind, r.status, k.code as contract, r.next_service_hours,
           (select max(engine_hours_end) from plods p where p.rig_id = r.id) as engine_hours,
           (select max(plod_date) from plods p where p.rig_id = r.id) as last_plod,
           (select coalesce(sum(metres),0) from v_plod_summary v where v.rig_id = r.id and v.plod_date >= current_date - 7) as metres_7d,
           (select serial from bits b where b.rig_id = r.id and b.retired_on is null order by fitted_on desc limit 1) as bit
    from rigs r left join contracts k on k.id = r.contract_id where r.status <> 'sold' order by r.code`);
}

async function rigs() {
  const rows = (await rigRows()).map((r) => ({ ...r, service_due_in: r.next_service_hours == null || r.engine_hours == null ? null : +(n(r.next_service_hours) - n(r.engine_hours)).toFixed(1) }));
  out(rows, () => heading('Rigs') + '\n' + table(rows, [
    { key: 'code', label: 'Rig' }, { key: 'make_model', label: 'Make', width: 22 }, { key: 'status', label: 'Status' }, { key: 'contract', label: 'On' },
    { key: 'metres_7d', label: 'Metres 7d', align: 'right', format: m1 }, { key: 'last_plod', label: 'Last plod', format: isoDate },
    { key: 'engine_hours', label: 'Engine h', align: 'right' }, { key: 'service_due_in', label: 'Service in', align: 'right', format: (v) => (v == null ? '' : v <= 0 ? `OVERDUE ${-v}h` : `${v}h`) },
    { key: 'bit', label: 'Bit on' },
  ]));
}

async function rig(args) {
  const r = await findRig(args[0]);
  const recent = await db.query(`select * from v_plod_summary where rig_id = $1 order by plod_date desc, shift limit 10`, [r.id]);
  const services = await db.query(`select serviced_on, engine_hours, kind, notes from rig_services where rig_id = $1 order by serviced_on desc limit 5`, [r.id]);
  const prestarts = await db.query(`select done_on, shift, ok, defects from prestarts where rig_id = $1 and (ok = false or done_on >= current_date - 7) order by done_on desc, shift limit 20`, [r.id]);
  const bitsOn = await db.query(`select serial, kind, metres, expected_m, fitted_on, retired_on, retired_reason from v_bit_life where rig_id = $1 order by fitted_on desc limit 6`, [r.id]);
  out({ rig: r, plods: recent, services, prestarts, bits: bitsOn }, () => [
    heading(`${r.code}  ${r.make_model}`),
    `  ${r.kind} rig, ${r.status}${r.contract ? ' on ' + r.contract : ''}. Next service at ${r.next_service_hours ?? '-'} engine hours.`,
    '\nLast plods', table(recent, plodCols),
    '\nServices', table(services, [{ key: 'serviced_on', label: 'Date', format: isoDate }, { key: 'engine_hours', label: 'Hours', align: 'right' }, { key: 'kind', label: 'Kind' }, { key: 'notes', label: 'Notes' }]),
    '\nBits', table(bitsOn, [{ key: 'serial', label: 'Bit' }, { key: 'kind', label: 'Kind' }, { key: 'metres', label: 'Metres', align: 'right', format: m1 }, { key: 'expected_m', label: 'Expected', align: 'right', format: m1 }, { key: 'fitted_on', label: 'Fitted', format: isoDate }, { key: 'retired_on', label: 'Off', format: isoDate }, { key: 'retired_reason', label: 'Why' }]),
  ].join('\n'));
}

async function utilisationRows(days) {
  return db.query(`
    select rg.code as rig, rg.contract_id, k.code as contract,
           count(p.id) as shifts,
           coalesce(sum(v.total_min),0) as total_min, coalesce(sum(v.drilling_min),0) as drilling_min,
           coalesce(sum(v.standby_client_min),0) as standby_client_min, coalesce(sum(v.lost_min),0) as lost_min,
           coalesce(sum(v.metres),0) as metres, coalesce(sum(v.charge_cents),0) as charge_cents,
           (select count(*) from generate_series(current_date - $1::int, current_date - 1, interval '1 day') g(d)
             where not exists (select 1 from plods x where x.rig_id = rg.id and x.plod_date = g.d::date)) as days_without_plod
    from rigs rg left join contracts k on k.id = rg.contract_id
    left join plods p on p.rig_id = rg.id and p.plod_date >= current_date - $1::int and p.plod_date < current_date
    left join v_plod_summary v on v.id = p.id
    where rg.status <> 'sold' group by rg.id, rg.code, rg.contract_id, k.code order by rg.code`, [days]);
}

async function utilisation(flags) {
  const days = Number(flags.days || 7);
  const rows = (await utilisationRows(days)).map((r) => ({
    ...r,
    drilling_pct: n(r.total_min) ? Math.round((n(r.drilling_min) / n(r.total_min)) * 100) : 0,
    metres_per_drill_hour: n(r.drilling_min) ? +(n(r.metres) / (n(r.drilling_min) / 60)).toFixed(1) : 0,
    revenue_per_shift_cents: n(r.shifts) ? Math.round(n(r.charge_cents) / n(r.shifts)) : 0,
  }));
  out(rows, () => heading(`Rig utilisation, last ${days} days`) + '\n' + table(rows, [
    { key: 'rig', label: 'Rig' }, { key: 'contract', label: 'On' }, { key: 'shifts', label: 'Shifts', align: 'right' }, { key: 'metres', label: 'Metres', align: 'right', format: m1 },
    { key: 'drilling_pct', label: 'Drilling %', align: 'right', format: (v) => `${v}%` }, { key: 'metres_per_drill_hour', label: 'm/drill h', align: 'right' },
    { key: 'standby_client_min', label: 'Standby (client)', align: 'right', format: hours }, { key: 'lost_min', label: 'Lost (ours)', align: 'right', format: hours },
    { key: 'revenue_per_shift_cents', label: 'Per shift', align: 'right', format: (v) => aud(v) }, { key: 'days_without_plod', label: 'Days no plod', align: 'right' },
  ]) + '\n\n  Standby on the client is billable; lost time (breakdown, standby on us) is not.');
}

async function prestart(args, flags) {
  const r = await findRig(args[0]);
  const on = parseDate(flags.date || 'today');
  const shift = str(flags.shift) || 'day';
  const by = flags.by ? await findStaff(flags.by) : null;
  const defects = str(flags.defects) || null;
  const ok = !flags.failed;
  await db.query(`insert into prestarts (rig_id, done_on, shift, done_by, ok, defects) values ($1,$2,$3,$4,$5,$6)
    on conflict (rig_id, done_on, shift) do update set done_by = excluded.done_by, ok = excluded.ok, defects = excluded.defects`, [r.id, on, shift, by?.id || null, ok, defects]);
  out({ rig: r.code, on, shift, ok, defects }, () => `  ${r.code} prestart ${on} ${shift}: ${ok ? 'passed' : 'FAILED'}${defects ? ', ' + defects : ''}.${ok ? '' : ' Tag the rig out until the defect is fixed.'}`);
}

async function service(args, flags) {
  const r = await findRig(args[0]);
  const hrs = Number(flags.hours);
  if (!Number.isFinite(hrs)) throw new CliError('Engine hours at the service? --hours=12510');
  const on = parseDate(flags.date || 'today');
  const interval = Number(flags.interval || 250);
  await db.query(`insert into rig_services (rig_id, serviced_on, engine_hours, kind, notes) values ($1,$2,$3,$4,$5) on conflict (rig_id, serviced_on, kind) do update set engine_hours = excluded.engine_hours, notes = excluded.notes`, [r.id, on, hrs, str(flags.kind) || 'service', str(flags.notes) || null]);
  await db.query(`update rigs set next_service_hours = $2 where id = $1`, [r.id, hrs + interval]);
  out({ rig: r.code, on, engine_hours: hrs, next_service_hours: hrs + interval }, () => `  ${r.code} serviced ${on} at ${hrs} h. Next due at ${hrs + interval} h.`);
}

// ---------------------------------------------------------------- holes, crew, bits

async function holes(flags) {
  const where = [];
  const params = [];
  if (flags.contract) { const k = await findContract(flags.contract); params.push(k.id); where.push(`contract_id = $${params.length}`); }
  else where.push(`contract_id in (select id from contracts where status = 'active')`);
  if (flags.stage) { params.push(String(flags.stage)); where.push(`stage = $${params.length}`); }
  const rows = await db.query(`select contract, hole_id, method, planned_depth, depth_m, stage, started_on, completed_on, rehab_on, last_plod_on from v_hole_status where ${where.join(' and ')} order by contract, hole_id`, params);
  out(rows, () => heading('Holes') + '\n' + table(rows, [
    { key: 'contract', label: 'Contract' }, { key: 'hole_id', label: 'Hole' }, { key: 'method', label: 'Method' }, { key: 'planned_depth', label: 'Planned', align: 'right', format: m1 },
    { key: 'depth_m', label: 'Depth', align: 'right', format: m1 }, { key: 'stage', label: 'Stage' }, { key: 'started_on', label: 'Started', format: isoDate },
    { key: 'completed_on', label: 'Finished', format: isoDate }, { key: 'rehab_on', label: 'Rehab', format: isoDate },
  ]));
}

async function staffList() {
  const rows = await db.query(`select code, full_name, role, licence_class, licence_expires_on, competency, competency_expires_on from staff where active order by role, code`);
  out(rows, () => heading('Crew') + '\n' + table(rows, [
    { key: 'code', label: 'Code' }, { key: 'full_name', label: 'Name' }, { key: 'role', label: 'Role' }, { key: 'licence_class', label: 'Water licence' },
    { key: 'licence_expires_on', label: 'Licence to', format: isoDate }, { key: 'competency', label: 'Competency', width: 38 }, { key: 'competency_expires_on', label: 'Review due', format: isoDate },
  ]));
}

async function fatigueRows(days = 7) {
  const shifts = await db.query(`
    select s.code, s.full_name, p.number, p.plod_date, p.shift, r.code as rig, c.minutes
    from plod_crew c join staff s on s.id = c.staff_id join plods p on p.id = c.plod_id join rigs r on r.id = p.rig_id
    where p.plod_date >= current_date - 30 and c.minutes > $1 order by p.plod_date desc`, [MAX_SHIFT_MIN]);
  const weeks = await db.query(`
    select s.code, s.full_name, coalesce(sum(c.minutes),0) as minutes, count(distinct p.plod_date) as days_worked
    from plod_crew c join staff s on s.id = c.staff_id join plods p on p.id = c.plod_id
    where p.plod_date >= current_date - $1::int and c.minutes > 0 group by s.code, s.full_name order by minutes desc`, [days]);
  return { long_shifts: shifts, week: weeks.map((w) => ({ ...w, over: n(w.minutes) > MAX_7DAY_MIN })) };
}

async function crewHours(flags) {
  const days = Number(flags.days || 7);
  const r = await fatigueRows(days);
  out(r, () => [
    heading(`Crew hours, last ${days} days`),
    table(r.week, [{ key: 'code', label: 'Code' }, { key: 'full_name', label: 'Name' }, { key: 'days_worked', label: 'Days', align: 'right' }, { key: 'minutes', label: 'Hours', align: 'right', format: hours }, { key: 'over', label: `Over ${MAX_7DAY_MIN / 60}h`, format: (v) => (v ? 'YES' : '') }]),
    `\nShifts over ${MAX_SHIFT_MIN / 60} hours in the last 30 days`,
    table(r.long_shifts, [{ key: 'plod_date', label: 'Date', format: isoDate }, { key: 'shift', label: 'Shift' }, { key: 'rig', label: 'Rig' }, { key: 'full_name', label: 'Name' }, { key: 'minutes', label: 'Hours', align: 'right', format: hours }, { key: 'number', label: 'Plod' }]),
    `\n  Limits are set at the top of scripts/drill.mjs. Set them to your fatigue management plan.`,
  ].join('\n'));
}

async function drillers(flags) {
  const days = Number(flags.days || 14);
  const rows = await db.query(`
    select v.driller_code as code, v.driller, h.method, count(distinct v.id) as shifts,
           sum(a.to_m - a.from_m) as metres, sum(a.minutes) as drilling_min
    from v_plod_summary v join plod_activities a on a.plod_id = v.id and a.activity = 'drilling' join holes h on h.id = a.hole_id
    where v.plod_date >= current_date - $1::int group by v.driller_code, v.driller, h.method order by h.method, metres desc`, [days]);
  const withRates = rows.map((r) => ({ ...r, per_shift: +(n(r.metres) / n(r.shifts)).toFixed(1), per_hour: n(r.drilling_min) ? +(n(r.metres) / (n(r.drilling_min) / 60)).toFixed(1) : 0 }));
  out(withRates, () => heading(`Driller performance, last ${days} days`) + '\n' + table(withRates, [
    { key: 'driller', label: 'Driller' }, { key: 'method', label: 'Method' }, { key: 'shifts', label: 'Shifts', align: 'right' }, { key: 'metres', label: 'Metres', align: 'right', format: m1 },
    { key: 'per_shift', label: 'm/shift', align: 'right' }, { key: 'per_hour', label: 'm/drill h', align: 'right' },
  ]) + '\n\n  Compare drillers on the same method and ground only. Diamond and RC metres are not the same work.');
}

async function bitRows() {
  const rows = await db.query(`select serial, kind, size, rig, cost_cents, expected_m, metres, fitted_on, retired_on, retired_reason from v_bit_life order by retired_on nulls first, fitted_on desc`);
  return rows.map((b) => {
    const pct = n(b.expected_m) ? Math.round((n(b.metres) / n(b.expected_m)) * 100) : null;
    let flag = '';
    if (b.retired_on && pct !== null && pct < 60) flag = 'early failure';
    else if (!b.retired_on && pct !== null && pct >= 100) flag = 'past expected life';
    return { ...b, life_pct: pct, cost_per_m_cents: n(b.metres) ? Math.round(n(b.cost_cents) / n(b.metres)) : null, flag };
  });
}

async function bits() {
  const rows = await bitRows();
  out(rows, () => heading('Bits') + '\n' + table(rows, [
    { key: 'serial', label: 'Bit' }, { key: 'kind', label: 'Kind' }, { key: 'rig', label: 'Rig' }, { key: 'metres', label: 'Metres', align: 'right', format: m1 },
    { key: 'life_pct', label: 'Life', align: 'right', format: (v) => (v == null ? '' : `${v}%`) }, { key: 'cost_per_m_cents', label: 'Cost/m', align: 'right', format: (v) => (v == null ? '' : price(v, 'AUD')) },
    { key: 'retired_on', label: 'Off', format: isoDate }, { key: 'retired_reason', label: 'Why', width: 28 }, { key: 'flag', label: 'Flag' },
  ]));
}

// ---------------------------------------------------------------- incidents

async function incidents(flags) {
  const rows = await db.query(`select i.number, i.occurred_on, i.kind, r.code as rig, k.code as contract, i.notifiable, i.notified_on, i.closed_on, i.description from incidents i left join rigs r on r.id = i.rig_id left join contracts k on k.id = i.contract_id ${flags.open ? 'where i.closed_on is null' : ''} order by i.occurred_on desc`);
  out(rows, () => heading('Incidents') + '\n' + table(rows, [
    { key: 'number', label: 'No.' }, { key: 'occurred_on', label: 'Date', format: isoDate }, { key: 'kind', label: 'Kind' }, { key: 'rig', label: 'Rig' },
    { key: 'notifiable', label: 'Notifiable', format: (v) => (v ? 'YES' : '') }, { key: 'notified_on', label: 'Notified', format: isoDate }, { key: 'closed_on', label: 'Closed', format: isoDate },
    { key: 'description', label: 'What happened', width: 60 },
  ]));
}

async function incident(args, flags) {
  const r = args[0] ? await findRig(args[0]) : null;
  const desc = str(flags.description);
  if (!desc) throw new CliError('What happened? --description=".."');
  const [{ last }] = await db.query(`select coalesce(max(substring(number from 4)::int), 0) as last from incidents where number ~ '^IN-[0-9]+$'`);
  const num = `IN-${String(n(last) + 1).padStart(3, '0')}`;
  await db.query(`insert into incidents (number, occurred_on, contract_id, rig_id, kind, description, notifiable) values ($1,$2,$3,$4,$5,$6,$7)`,
    [num, parseDate(flags.date || 'today'), r?.contract_id || null, r?.id || null, str(flags.kind) || 'near-miss', desc, !!flags.notifiable]);
  out({ number: num, notifiable: !!flags.notifiable }, () => `  ${num} recorded.${flags.notifiable ? ' Notifiable: the regulator must be told immediately. Record it with: drill notify ' + num + ' --ref=..' : ''}`);
}

async function notify(args, flags) {
  const [i] = await db.query(`select * from incidents where lower(number) = lower($1)`, [args[0] || '']);
  if (!i) throw new CliError(`No incident "${args[0]}". Run: drill incidents`);
  await db.query(`update incidents set notified_on = $2, notified_ref = $3 where id = $1`, [i.id, parseDate(flags.on || 'today'), str(flags.ref) || null]);
  out({ number: i.number, notified: true }, () => `  ${i.number} notification recorded${flags.ref ? ', reference ' + flags.ref : ''}.`);
}

// ---------------------------------------------------------------- compliance and attention

async function complianceRows() {
  const checks = [];
  const add = (id, rule, source, rows, fmt) => checks.push({ id, rule, source, count: rows.length, items: rows.map(fmt), rows });

  add('R1', 'A prestart inspection is recorded for every rig shift', 'Work Health and Safety (General) Regulations 2022 (WA) r 213 (maintenance and inspection of plant), and your plant inspection procedure',
    await db.query(`select p.number, r.code as rig, p.plod_date, p.shift from plods p join rigs r on r.id = p.rig_id
      where p.plod_date >= current_date - 30 and not exists (select 1 from prestarts x where x.rig_id = p.rig_id and x.done_on = p.plod_date and x.shift = p.shift) order by p.plod_date`),
    (r) => `${r.rig} ${isoDate(r.plod_date)} ${r.shift} shift (${r.number}): worked with no prestart recorded`);

  const svc = (await rigRows()).filter((r) => r.next_service_hours != null && r.engine_hours != null && n(r.engine_hours) >= n(r.next_service_hours));
  add('R2', 'Rigs are serviced at the interval the manufacturer sets', 'Work Health and Safety (General) Regulations 2022 (WA) r 213, and the manufacturer\'s service schedule',
    svc, (r) => `${r.code} at ${r.engine_hours} engine hours, service was due at ${r.next_service_hours} (${(n(r.engine_hours) - n(r.next_service_hours)).toFixed(0)} h over)`);

  add('R3', 'Water bores are drilled under a driller holding a current water well driller licence', 'Minimum Construction Requirements for Water Bores in Australia (National Uniform Drillers Licensing Committee), and the conditions of the licence to construct the well',
    await db.query(`select coalesce(s.full_name, 'not recorded') as full_name, s.licence_expires_on, count(distinct p.id) as shifts,
        string_agg(distinct h.hole_id, ', ') as holes, min(p.plod_date) as first_on, max(p.plod_date) as last_on
      from plods p join plod_activities a on a.plod_id = p.id and a.activity = 'drilling' join holes h on h.id = a.hole_id and h.method = 'WB'
      left join staff s on s.id = p.driller_id
      where s.id is null or s.licence_class is null or s.licence_expires_on is null or s.licence_expires_on < p.plod_date
      group by s.full_name, s.licence_expires_on order by min(p.plod_date)`),
    (r) => `${r.full_name} drilled ${r.holes} on ${r.shifts} shifts, ${isoDate(r.first_on)} to ${isoDate(r.last_on)}, ${r.licence_expires_on ? 'licence expired ' + isoDate(r.licence_expires_on) : 'no licence on file'}`);

  add('R4', 'A licence to construct the well is recorded before a water bore is drilled', 'Rights in Water and Irrigation Act 1914 (WA) s 26D',
    await db.query(`select distinct k.code, k.name from contracts k join holes h on h.contract_id = k.id and h.method = 'WB' where coalesce(k.water_licence_ref, '') = ''`),
    (r) => `${r.code} ${r.name}: water bores on the contract, no 26D licence recorded`);

  const pow = await db.query(`
    select k.code, k.name, k.pow_ref, k.pow_expires_on, (k.pow_expires_on - current_date) as days_left,
           (select count(*) from plods p join plod_activities a on a.plod_id = p.id and a.activity = 'drilling' join holes h on h.id = a.hole_id and h.method <> 'WB'
             where p.contract_id = k.id and (k.pow_ref is null or k.pow_expires_on is null or p.plod_date > k.pow_expires_on)) as drilled_outside
    from contracts k where k.status = 'active' and exists (select 1 from holes h where h.contract_id = k.id and h.method <> 'WB')`);
  add('R5', 'Exploration drilling happens only under an approved, current programme of work', 'Mining Act 1978 (WA), programme of work approval for ground-disturbing exploration (DEMIRS)',
    pow.filter((r) => n(r.drilled_outside) > 0), (r) => `${r.code} ${r.name}: ${r.drilled_outside} drilling lines with no current programme of work`);

  add('R6', 'Everyone on a rig shift has a current competency record for the work', 'Work Health and Safety Act 2020 (WA) s 19(3)(f) (information, training and supervision), and your training and competency procedure',
    await db.query(`select s.code, s.full_name, s.competency_expires_on, count(*) as shifts, max(p.plod_date) as last_shift
      from plod_crew c join staff s on s.id = c.staff_id join plods p on p.id = c.plod_id
      where s.competency_expires_on is null or s.competency_expires_on < p.plod_date group by s.code, s.full_name, s.competency_expires_on`),
    (r) => `${r.full_name}: ${r.shifts} shifts since the competency review was due ${isoDate(r.competency_expires_on) || '(none on file)'}, last ${isoDate(r.last_shift)}`);

  const f = await fatigueRows(7);
  add('R7', `No shift longer than ${MAX_SHIFT_MIN / 60} hours and no more than ${MAX_7DAY_MIN / 60} hours in 7 days, or as your fatigue plan says`, 'Work Health and Safety (Mines) Regulations 2022 (WA), fatigue managed as a hazard in the safety management system; DEMIRS code of practice on working hours',
    [...f.long_shifts.map((r) => ({ ...r, kind: 'shift' })), ...f.week.filter((w) => w.over).map((r) => ({ ...r, kind: 'week' }))],
    (r) => (r.kind === 'shift' ? `${r.full_name} worked ${hours(r.minutes)} on ${r.rig} ${isoDate(r.plod_date)} ${r.shift} (${r.number})` : `${r.full_name} worked ${hours(r.minutes)} in the last 7 days`));

  add('R8', 'A notifiable incident is reported to the regulator immediately', 'Work Health and Safety Act 2020 (WA) s 38',
    await db.query(`select number, occurred_on, kind, description, (current_date - occurred_on) as days from incidents where notifiable and notified_on is null order by occurred_on`),
    (r) => `${r.number} ${r.kind} ${isoDate(r.occurred_on)}, ${r.days} days ago, not notified: ${truncate(r.description, 70)}`);

  add('R9', `Finished exploration holes are capped and rehabilitated within ${REHAB_DAYS} days, or as the programme of work conditions say`, 'Mining Act 1978 (WA), programme of work conditions on drill hole capping and rehabilitation (DEMIRS)',
    await db.query(`select contract, hole_id, completed_on, (current_date - completed_on) as days from v_hole_status where method <> 'WB' and completed_on is not null and rehab_on is null and completed_on < current_date - $1::int order by completed_on`, [REHAB_DAYS]),
    (r) => `${r.contract} ${r.hole_id}: finished ${isoDate(r.completed_on)}, ${r.days} days, not capped or rehabilitated`);

  return { checks, pow };
}

async function compliance() {
  const { checks } = await complianceRows();
  out(checks, () => [heading('Compliance'), ...checks.map((c) => `\n${c.id}  ${c.count ? 'BREACH ' + c.count : 'clean'}  ${c.rule}\n    Source: ${c.source}${c.items.length ? '\n' + c.items.map((i) => `    - ${i}`).join('\n') : ''}`), '\n  The rules and why each matters: docs/compliance.md. This is a records check, not legal or safety advice.'].join('\n'));
}

async function attention() {
  const items = [];
  const push = (rank, area, what, action) => items.push({ rank, area, what, action });
  const { checks, pow } = await complianceRows();
  const by = Object.fromEntries(checks.map((c) => [c.id, c]));

  for (const i of by.R8.items) push(1, 'safety', i, 'Notify the regulator now, then record it: drill notify <incident> --ref=..');
  for (const i of by.R3.items) push(1, 'licensing', i, 'Stop water bore work under this driller until the licence is renewed; tell the client and the licence holder');
  for (const i of by.R6.items) push(1, 'competency', i, 'Do the competency review before their next shift');
  for (const i of by.R7.items) push(1, 'fatigue', i, 'Check the roster against the fatigue plan; give the rest break before the next shift');
  for (const i of by.R1.items) push(2, 'plant', i, 'Find out why no prestart was done; remind the crew it comes before the first rod');
  for (const i of by.R2.items) push(2, 'plant', i, 'Book the service; the longer it runs over, the bigger the breakdown');
  const failed = await db.query(`select r.code, x.done_on, x.shift, x.defects from prestarts x join rigs r on r.id = x.rig_id where not x.ok and x.done_on >= current_date - 7 order by x.done_on`);
  for (const p of failed) push(2, 'plant', `${p.code} failed its prestart ${isoDate(p.done_on)} ${p.shift}: ${p.defects}`, 'Confirm the defect was fixed and signed off before the rig ran');
  for (const r of pow) if (r.pow_expires_on && n(r.days_left) >= 0 && n(r.days_left) <= POW_WARN_DAYS) push(2, 'approvals', `${r.code} ${r.name}: programme of work ${r.pow_ref} expires ${isoDate(r.pow_expires_on)}, in ${r.days_left} days`, 'Ask the client whether the extension is lodged; no drilling the day after it expires');
  for (const i of by.R5.items) push(1, 'approvals', i, 'Stop drilling until the client confirms a current programme of work');
  for (const i of by.R9.items) push(3, 'rehab', i, 'Cap and rehabilitate, record it on the hole, and tell the client');

  const pend = await pendingRows();
  for (const p of pend.filter((x) => x.status === 'rejected')) push(3, 'sign-off', `${p.number} ${p.rig} ${isoDate(p.plod_date)} ${p.shift} rejected by ${p.client}: ${p.reject_reason} (${aud(p.charge_cents)} held)`, `Fix it with the driller and resubmit: drill submit ${p.number}`);
  const late = pend.filter((x) => x.overdue);
  const lateBy = {};
  for (const p of late) (lateBy[p.contract] ||= []).push(p);
  for (const [code, list] of Object.entries(lateBy)) push(3, 'sign-off', `${code}: ${list.length} plods past the ${list[0].signoff_days} day sign-off window (${list.map((x) => x.number).join(', ')}), ${aud(list.reduce((s, x) => s + n(x.charge_cents), 0))} waiting`, `Chase ${list[0].contact_name || list[0].client}: /draft-signoff-chase ${code}`);
  const drafts = await db.query(`select number, rig, plod_date, shift from v_plod_summary where status = 'draft' and plod_date < current_date order by plod_date`);
  for (const d of drafts) push(3, 'plods', `${d.number} ${d.rig} ${isoDate(d.plod_date)} ${d.shift} still a draft`, 'Finish and submit it');
  const util = await utilisationRows(3);
  const rigInfo = Object.fromEntries((await rigRows()).map((r) => [r.code, r]));
  for (const u of util) if (rigInfo[u.rig]?.status === 'working' && u.contract_id && n(u.days_without_plod) > 0) push(3, 'plods', `${u.rig} on ${u.contract}: no plod for ${u.days_without_plod} of the last 3 days (last ${isoDate(rigInfo[u.rig].last_plod)})`, 'If it worked, get the plod in today. If it is in the workshop, set its status: drill rig-status ' + u.rig + ' workshop');

  const cl = await claimRows(true);
  for (const c of cl.filter((x) => n(x.days_overdue) > 0)) push(4, 'money', `${c.number} ${c.client} ${aud(c.amount_cents)}: due ${isoDate(c.due_on)}, ${c.days_overdue} days overdue`, `Chase payment: /draft-overdue-claim ${c.number}`);
  const unclaimed = await db.query(`
    select k.code, k.name, sum(v.charge_cents) as cents, min(v.plod_date) as oldest
    from v_plod_summary v join contracts k on k.id = v.contract_id
    where v.status = 'approved' and v.claim_id is null group by k.code, k.name having min(v.plod_date) < current_date - $1::int order by k.code`, [UNCLAIMED_DAYS]);
  for (const u of unclaimed) push(4, 'money', `${u.code} ${u.name}: ${aud(u.cents)} signed off and not claimed, oldest plod ${isoDate(u.oldest)}`, `Draft the claim: drill claim ${u.code} --save`);
  for (const b of (await bitRows()).filter((x) => x.flag)) push(5, 'bits', `${b.serial} ${b.kind} on ${b.rig}: ${b.flag} (${m1(b.metres)} m of ${m1(b.expected_m)} expected${b.retired_reason ? ', ' + b.retired_reason : ''})`, b.flag === 'early failure' ? 'Check ground conditions, pressures and the batch; claim warranty if it is the bit' : 'Plan the change before it fails in the hole');

  items.sort((a, b) => a.rank - b.rank);
  out(items, () => heading('Needs attention, worst first') + '\n' + (items.length ? items.map((i, k) => `${String(k + 1).padStart(3)}. [${i.area}] ${i.what}\n       -> ${i.action}`).join('\n') : '  Nothing. Safety, plods and money are all in order.'));
}

async function rigStatus(args) {
  const r = await findRig(args[0]);
  const status = String(args[1] || '');
  if (!['working', 'standby', 'workshop', 'sold'].includes(status)) throw new CliError('Status is working, standby, workshop or sold.');
  await db.query(`update rigs set status = $2 where id = $1`, [r.id, status]);
  out({ rig: r.code, status }, () => `  ${r.code} is now ${status}.`);
}

// ---------------------------------------------------------------- import and export

// CorePlan exports plods to CSV, one row per activity line. Columns are matched by name,
// case-insensitive, with the common variants of each header. Run with --dry-run first.
async function importCmd(args, flags) {
  const source = String(args[0] || '').toLowerCase();
  if (!['coreplan', 'csv', 'plods'].includes(source)) throw new CliError('Usage: drill import coreplan <plods.csv> [--contract=code] [--dry-run]');
  const file = args[1];
  if (!file || !existsSync(file)) throw new CliError(`No file at "${file}".`);
  const fallback = flags.contract ? await findContract(flags.contract) : null;
  const rows = parseCsv(readFileSync(file, 'utf8'));
  const problems = [];
  const groups = new Map();
  for (const [i, r] of rows.entries()) {
    const rigCode = pick(r, 'Rig', 'Rig Name', 'Rig ID', 'Rig Number');
    const date = pick(r, 'Date', 'Shift Date', 'Plod Date');
    const shift = (pick(r, 'Shift', 'Shift Type') || 'day').toLowerCase().startsWith('n') ? 'night' : 'day';
    if (!rigCode || !date) { problems.push(`row ${i + 2}: no rig or date`); continue; }
    let d;
    try { d = parseDate(date); } catch { problems.push(`row ${i + 2}: date "${date}" not understood`); continue; }
    const key = `${rigCode}|${d}|${shift}`;
    if (!groups.has(key)) groups.set(key, { rigCode, date: d, shift, ref: pick(r, 'Plod ID', 'Plod Number', 'Plod No', 'DDR Number', 'ID'), contract: pick(r, 'Contract', 'Project', 'Job', 'Project Code'), driller: pick(r, 'Driller', 'Driller Name'), status: pick(r, 'Status', 'Approval Status'), lines: [] });
    const fromM = pick(r, 'From (m)', 'From', 'Depth From', 'From Depth');
    const toM = pick(r, 'To (m)', 'To', 'Depth To', 'To Depth');
    const hrs = pick(r, 'Hours', 'Duration (hrs)', 'Duration', 'Time (hrs)');
    groups.get(key).lines.push({
      activity: mapActivity(pick(r, 'Activity', 'Activity Type', 'Task', 'Code')),
      hole: pick(r, 'Hole ID', 'Hole', 'Hole Name', 'Drillhole'), method: (pick(r, 'Drill Type', 'Method', 'Drilling Type') || '').toUpperCase().slice(0, 3),
      from: fromM === '' ? null : Number(fromM), to: toM === '' ? null : Number(toM), minutes: hrs === '' ? 0 : Math.round(Number(hrs) * 60),
      bit: pick(r, 'Bit Serial', 'Bit', 'Bit ID') || null, notes: pick(r, 'Comments', 'Notes', 'Description') || null,
    });
  }
  const summary = { rows: rows.length, plods: groups.size, lines: [...groups.values()].reduce((s, g) => s + g.lines.length, 0), created: 0, skipped_existing: 0, problems };
  if (!flags['dry-run']) {
    await db.exec('BEGIN');
    try {
      for (const g of groups.values()) {
        const [rig] = await db.query(`select * from rigs where lower(code) = lower($1)`, [g.rigCode]);
        if (!rig) { problems.push(`${g.rigCode} ${g.date}: rig not in the system (add it first)`); continue; }
        let k = fallback;
        if (g.contract) [k] = (await db.query(`select * from contracts where lower(code) = lower($1) or lower(name) = lower($1) or lower(coalesce(external_ref,'')) = lower($1)`, [g.contract])).concat(fallback ? [fallback] : []);
        if (!k) { problems.push(`${g.rigCode} ${g.date}: no contract matched "${g.contract}" (pass --contract)`); continue; }
        const exists = await db.query(`select 1 from plods where rig_id = $1 and plod_date = $2 and shift = $3`, [rig.id, g.date, g.shift]);
        if (exists.length) { summary.skipped_existing++; continue; }
        const [driller] = g.driller ? await db.query(`select id from staff where lower(full_name) = lower($1) or lower(code) = lower($1)`, [g.driller]) : [];
        const status = /approv/i.test(g.status) ? 'approved' : /reject/i.test(g.status) ? 'rejected' : /submit|pending|review/i.test(g.status) ? 'submitted' : 'draft';
        const number = await nextNumber('plods', 'P-');
        const [p] = await db.query(`insert into plods (number, contract_id, rig_id, plod_date, shift, driller_id, status, submitted_on, approved_on, approved_by, external_ref)
          values ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11) returning id`, [number, k.id, rig.id, g.date, g.shift, driller?.id || null, status, status === 'draft' ? null : g.date, status === 'approved' ? g.date : null, status === 'approved' ? 'imported from CorePlan' : null, g.ref || null]);
        let line = 0;
        for (const l of g.lines) {
          let holeId = null;
          if (l.hole) {
            const [h] = await db.query(`insert into holes (contract_id, hole_id, method, started_on) values ($1,$2,$3,$4) on conflict (contract_id, hole_id) do update set hole_id = excluded.hole_id returning id`, [k.id, l.hole, ['RC', 'DD', 'AC', 'RAB', 'WB'].includes(l.method) ? l.method : rig.kind === 'multi' ? 'RC' : rig.kind, g.date]);
            holeId = h.id;
          }
          await db.query(`insert into plod_activities (plod_id, line, activity, hole_id, minutes, from_m, to_m, bit_serial, notes) values ($1,$2,$3,$4,$5,$6,$7,$8,$9)`,
            [p.id, ++line, l.activity, holeId, Number.isFinite(l.minutes) ? l.minutes : 0, l.activity === 'drilling' ? l.from : null, l.activity === 'drilling' ? l.to : null, l.bit, l.notes]);
        }
        summary.created++;
      }
      await db.exec('COMMIT');
    } catch (e) { await db.exec('ROLLBACK'); throw e; }
  }
  out(summary, () => [
    `  ${flags['dry-run'] ? 'Dry run: would import' : 'Imported'} ${summary.plods} plods (${summary.lines} activity lines) from ${summary.rows} rows.${flags['dry-run'] ? '' : ` ${summary.created} new, ${summary.skipped_existing} already here.`}`,
    problems.length ? '  Not imported:\n' + problems.map((x) => `    - ${x}`).join('\n') : '',
    flags['dry-run'] ? '' : '  Check the charges against your last CorePlan claim: drill charges <contract>',
  ].filter(Boolean).join('\n'));
}

function mapActivity(raw) {
  const s = String(raw || '').toLowerCase();
  if (/standby|wait/.test(s)) return /contractor|our|internal/.test(s) ? 'standby-contractor' : 'standby-client';
  if (/break ?down|repair|mechanical/.test(s)) return 'breakdown';
  if (/move|relocat|mob/.test(s)) return 'rig-move';
  if (/rig ?up|set ?up|pull ?down|rig ?down/.test(s)) return 'rig-up';
  if (/survey/.test(s)) return 'survey';
  if (/develop|airlift|pump test/.test(s)) return 'development';
  if (/safety|toolbox|pre ?start|meeting/.test(s)) return 'safety';
  if (/meal|crib|lunch/.test(s)) return 'meal';
  return 'drilling';
}

function csvCell(v) {
  if (v === null || v === undefined) return '';
  const s = v instanceof Date ? v.toISOString() : typeof v === 'object' ? JSON.stringify(v) : String(v);
  return /[",\r\n]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
}

async function exportCmd(flags) {
  const dir = path.resolve(REPO_ROOT, str(flags.out) || 'exports');
  mkdirSync(dir, { recursive: true });
  const tables = ['clients', 'contracts', 'rate_items', 'rigs', 'staff', 'holes', 'claims', 'plods', 'plod_activities', 'plod_crew', 'plod_consumables',
    'bits', 'prestarts', 'rig_services', 'incidents', 'notes'];
  const counts = {};
  for (const t of tables) {
    const rows = await db.query(`select * from ${t} order by created_at`);
    const cols = rows.length ? Object.keys(rows[0]) : [];
    writeFileSync(path.join(dir, `${t}.csv`), [cols.join(','), ...rows.map((r) => cols.map((c) => csvCell(r[c])).join(','))].join('\n') + '\n');
    counts[t] = rows.length;
  }
  out({ dir, counts }, () => `  Exported ${tables.length} tables to ${path.relative(REPO_ROOT, dir) || dir}: ${Object.entries(counts).map(([k, v]) => `${k} ${v}`).join(', ')}`);
}

async function log(args, flags) {
  const k = await findContract(args[0]);
  const body = args.slice(1).join(' ').trim();
  if (!body) throw new CliError('What happened? drill log <contract> "note text"');
  const r = flags.rig ? await findRig(flags.rig) : null;
  await db.query(`insert into notes (contract_id, rig_id, body, author) values ($1,$2,$3,$4)`, [k.id, r?.id || null, body, str(flags.by) || null]);
  out({ contract: k.code, body }, () => `  Noted on ${k.code}.`);
}

// ---------------------------------------------------------------- dispatch table

const HELP = `drill: the drilling contractor CLI. Add --json to any read for machine output.

  Overview      stats | attention | compliance | utilisation [--days=7]
  Contracts     contracts [--all] | contract <c> | rates <c> | log <c> "note" [--rig=RC01]
  Plods         plods [--days=7] [--contract=c] [--rig=r] [--status=..] | plod <number> | pending
                plod-new <rig> [--date=..] [--shift=day|night] [--driller=code] [--engine-hours=N]
                activity <plod> <${ACTIVITIES.join('|')}> [--hole=id] [--method=RC] [--from=m --to=m] [--hours=h] [--bit=serial] [--complete]
                crew <plod> <staff> --hours=12 | consume <plod> <item> --qty=N | submit <plod>
                approve <plod> --by="Name (Client)" [--on=date] | reject <plod> --reason=".." | reopen <plod>
  Money         charges <c> [--from=date] [--to=date] | claim <c> [--period-end=date] [--save]
                claims [--open] | claim-status <claim> --submitted=date | --paid=date [--amount=..] | --disputed
  Rigs          rigs | rig <r> | rig-status <r> <working|standby|workshop|sold> | prestart <r> [--shift] [--by] [--failed --defects=".."]
                service <r> --hours=N [--interval=250]
  Holes & crew  holes [--contract=c] [--stage=..] | staff | crew-hours [--days=7] | drillers [--days=14] | bits
  Safety        incidents [--open] | incident <rig> --kind=.. --description=".." [--notifiable] | notify <IN-nnn> --ref=..
  Data          import coreplan <plods.csv> [--contract=c] [--dry-run] | export [--out=dir]`;

const COMMANDS = {
  stats: () => stats(), contracts: (a, f) => contracts(f), contract: (a) => contract(a), rates: (a) => rates(a), log: (a, f) => log(a, f),
  plods: (a, f) => plods(f), plod: (a) => plod(a), pending: () => pending(), 'plod-new': (a, f) => plodNew(a, f), activity: (a, f) => activity(a, f),
  crew: (a, f) => crewCmd(a, f), consume: (a, f) => consume(a, f), submit: (a) => submit(a), approve: (a, f) => approve(a, f), reject: (a, f) => reject(a, f),
  reopen: (a) => reopen(a), charges: (a, f) => charges(a, f), claim: (a, f) => claim(a, f), claims: (a, f) => claims(f), 'claim-status': (a, f) => claimStatus(a, f),
  rigs: () => rigs(), rig: (a) => rig(a), 'rig-status': (a) => rigStatus(a), utilisation: (a, f) => utilisation(f), prestart: (a, f) => prestart(a, f),
  service: (a, f) => service(a, f), holes: (a, f) => holes(f), staff: () => staffList(), 'crew-hours': (a, f) => crewHours(f), drillers: (a, f) => drillers(f),
  bits: () => bits(), incidents: (a, f) => incidents(f), incident: (a, f) => incident(a, f), notify: (a, f) => notify(a, f),
  attention: () => attention(), compliance: () => compliance(), import: (a, f) => importCmd(a, f), export: (a, f) => exportCmd(f),
};

const { args, flags } = parseArgv(process.argv.slice(2));
JSON_OUT = !!flags.json;
const cmd = args.shift();
if (!cmd || cmd === 'help' || flags.help || !COMMANDS[cmd]) {
  console.log(HELP);
  process.exit(cmd && cmd !== 'help' && !COMMANDS[cmd] ? 1 : 0);
}
db = await getDb();
try {
  await COMMANDS[cmd](args, flags);
} catch (e) {
  if (e instanceof CliError) { console.error(e.message); process.exitCode = e.code; }
  else { console.error(e.stack || e.message); process.exitCode = 2; }
} finally {
  await db.close();
}
