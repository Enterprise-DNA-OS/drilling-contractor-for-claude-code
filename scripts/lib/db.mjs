// One database handle for the whole repo.
// DATABASE_URL set   -> node-postgres Client (Postgres, Supabase, Neon, anything Postgres-shaped).
// DATABASE_URL unset -> PGlite, an embedded Postgres persisted under ./.data/db (or DATA_DIR).
// Both return the same shape: { mode, query(sql, params) -> rows[], exec(sql), close() }.

import { existsSync, mkdirSync, readFileSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

export const REPO_ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');

// Read .env and .env.local if present. Existing process.env values win.
export function loadEnv() {
  for (const name of ['.env', '.env.local']) {
    const file = path.join(REPO_ROOT, name);
    if (!existsSync(file)) continue;
    for (const raw of readFileSync(file, 'utf8').split(/\r?\n/)) {
      const line = raw.trim();
      if (!line || line.startsWith('#')) continue;
      const eq = line.indexOf('=');
      if (eq < 0) continue;
      const key = line.slice(0, eq).trim();
      let value = line.slice(eq + 1).trim();
      if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
        value = value.slice(1, -1);
      }
      if (!(key in process.env)) process.env[key] = value;
    }
  }
}

export function dataDir() {
  return path.resolve(REPO_ROOT, process.env.DATA_DIR || './.data/db');
}

function wantsSsl(url) {
  if (/sslmode=disable/i.test(url)) return false;
  try {
    const host = new URL(url).hostname;
    return !(host === 'localhost' || host === '127.0.0.1' || host === '::1');
  } catch {
    return true;
  }
}

export async function getDb() {
  loadEnv();
  const url = process.env.DATABASE_URL;

  if (url) {
    const { default: pg } = await import('pg');
    // Keep DATE values as calendar strings; local midnight can shift a day in UTC.
    pg.types.setTypeParser(1082, (value) => value);
    // Same for TIMESTAMP (no zone): wall-clock times stay as written, whatever the machine's zone.
    pg.types.setTypeParser(1114, (value) => value);
    const pool = new pg.Client({
      connectionString: url,
      ssl: wantsSsl(url) ? { rejectUnauthorized: true } : undefined,
    });
    await pool.connect();
    await pool.query("SET TIME ZONE 'UTC'");
    return {
      mode: 'postgres',
      async query(sql, params = []) {
        const res = await pool.query(sql, params);
        return res.rows;
      },
      async exec(sql) {
        await pool.query(sql);
      },
      async close() {
        await pool.end();
      },
    };
  }

  const dir = dataDir();
  mkdirSync(dir, { recursive: true, mode: 0o700 }); // PGlite does not create parent folders
  const { PGlite } = await import('@electric-sql/pglite');
  const db = new PGlite(dir, { parsers: { 1082: (value) => value, 1114: (value) => value } });
  await db.waitReady;
  await db.exec("SET TIME ZONE 'UTC'");
  return {
    mode: 'pglite',
    dir,
    async query(sql, params = []) {
      const res = await db.query(sql, params);
      return res.rows;
    },
    async exec(sql) {
      await db.exec(sql);
    },
    async close() {
      await db.close();
    },
  };
}
