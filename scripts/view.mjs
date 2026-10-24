#!/usr/bin/env node
// `npm run view` renders read-only HTML dashboards from the SQL views, in your
// brand (brand.json), into ./views/. No server, no front end to maintain. Open
// the file, print it, or ask Claude Code for a new one with /new-view.
//
// Views are declared in views.json:
//   [{ "name": "week", "title": "This week", "sections": [{ "title": "...", "sql": "select ...", "note": "..." }] }]
//
//   npm run view            # every view in views.json
//   npm run view -- week    # one view
import { readFileSync } from 'node:fs';
import path from 'node:path';
import { getDb, REPO_ROOT } from './lib/db.mjs';
import { page, table, writeOut } from './lib/render.mjs';

const only = process.argv[2];
const spec = JSON.parse(readFileSync(path.join(REPO_ROOT, 'views.json'), 'utf8'));
const db = await getDb();
try {
  await db.exec("BEGIN READ ONLY");
  for (const v of spec) {
    if (only && v.name !== only) continue;
    const sections = [];
    for (const s of v.sections) {
      const rows = await db.query(s.sql);
      sections.push({ title: s.title, note: s.note, html: table(rows, s.columns) });
    }
    const file = writeOut('views', v.name, page({ title: v.title, subtitle: v.subtitle || '', sections }));
    console.log(`view: ${path.relative(REPO_ROOT, file)}`);
  }
} finally {
  await db.exec("ROLLBACK");
  await db.close();
}
