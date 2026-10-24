#!/usr/bin/env node
// Applies supabase/migrations/*.sql in filename order. Tracks what ran in schema_migrations.
// Safe to run any number of times.

import { readdirSync, readFileSync } from 'node:fs';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { getDb, REPO_ROOT } from './lib/db.mjs';

export async function migrate(db) {
  await db.exec(`
    create table if not exists schema_migrations (
      name text primary key,
      applied_at timestamptz not null default now()
    );
    alter table schema_migrations enable row level security;
    revoke all on schema_migrations from public;
  `);
  const applied = new Set((await db.query('select name from schema_migrations')).map((r) => r.name));
  const dir = path.join(REPO_ROOT, 'supabase', 'migrations');
  const files = readdirSync(dir).filter((f) => f.endsWith('.sql')).sort();
  const ran = [];
  for (const file of files) {
    if (applied.has(file)) continue;
    const sql = readFileSync(path.join(dir, file), 'utf8');
    await db.exec('BEGIN');
    try {
      await db.exec(sql);
      await db.query('insert into schema_migrations (name) values ($1)', [file]);
      await db.exec('COMMIT');
    } catch (error) {
      await db.exec('ROLLBACK');
      throw error;
    }
    ran.push(file);
  }
  return { ran, skipped: files.length - ran.length };
}

const isMain = process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href;
if (isMain) {
  const db = await getDb();
  try {
    const { ran, skipped } = await migrate(db);
    for (const f of ran) console.log(`applied  ${f}`);
    console.log(`migrate: ${ran.length} applied, ${skipped} already there (${db.mode}${db.dir ? ', ' + db.dir : ''})`);
  } finally {
    await db.close();
  }
}
