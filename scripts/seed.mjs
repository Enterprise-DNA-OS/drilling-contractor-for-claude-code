#!/usr/bin/env node
// Loads supabase/seed.sql: Ironbark Drilling Pty Ltd, a fictional Kalgoorlie exploration and water
// bore contractor with four rigs on three live contracts and one finished one, three weeks of
// plods, crew hours, prestarts, bits, incidents and claims. Dates are relative to today and every
// insert skips what is already there, so re-running it is harmless.

import { readFileSync } from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { getDb, REPO_ROOT } from './lib/db.mjs';

export async function seed(db) {
  await db.exec(readFileSync(path.join(REPO_ROOT, 'supabase', 'seed.sql'), 'utf8'));
  const [c] = await db.query(`
    select (select count(*) from contracts) as contracts, (select count(*) from rigs) as rigs,
           (select count(*) from staff) as staff, (select count(*) from holes) as holes,
           (select count(*) from plods) as plods, (select count(*) from plod_activities) as activities,
           (select count(*) from prestarts) as prestarts, (select count(*) from bits) as bits,
           (select count(*) from incidents) as incidents, (select count(*) from claims) as claims`);
  return Object.fromEntries(Object.entries(c).map(([k, v]) => [k, Number(v)]));
}

const isMain = process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href;
if (isMain) {
  const db = await getDb();
  try {
    const n = await seed(db);
    console.log(`seed: ${n.contracts} contracts, ${n.rigs} rigs, ${n.staff} crew, ${n.holes} holes, ${n.plods} plods (${n.activities} activity lines), ${n.prestarts} prestarts, ${n.bits} bits, ${n.incidents} incidents, ${n.claims} claims`);
  } finally {
    await db.close();
  }
}
