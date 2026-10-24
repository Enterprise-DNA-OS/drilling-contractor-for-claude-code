#!/usr/bin/env node
// `npm run docs` renders the paperwork this industry has to produce (statements,
// notices, letters, claims, reports) from the data, in your brand, into ./docs-out/.
// One HTML file per record. Print to PDF from the browser, or attach as is.
//
// Documents are declared in documents.json:
//   [{ "name": "owner-statement", "title": "Owner statement", "for_each": "select id, name from owners",
//      "file": "name",                                  // column of for_each used in the file name
//      "sections": [{ "title": "Rent received", "sql": "select ... where owner_id = $1" }] }]
// Every section query gets the record's `id` as $1.
//
//   npm run docs                       # every document, every record
//   npm run docs -- owner-statement    # one document type
//   npm run docs -- owner-statement <id-prefix>
import { readFileSync } from 'node:fs';
import path from 'node:path';
import { getDb, REPO_ROOT } from './lib/db.mjs';
import { page, table, writeOut } from './lib/render.mjs';

const [only, idPrefix] = process.argv.slice(2);
const spec = JSON.parse(readFileSync(path.join(REPO_ROOT, 'documents.json'), 'utf8'));
const slug = (s) => String(s).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
const db = await getDb();
let count = 0;
try {
  await db.exec("BEGIN READ ONLY");
  for (const d of spec) {
    if (only && d.name !== only) continue;
    const records = await db.query(d.for_each);
    for (const r of records) {
      if (idPrefix && !String(r.id).startsWith(idPrefix)) continue;
      const sections = [];
      for (const s of d.sections) {
        const rows = await db.query(s.sql, [r.id]);
        sections.push({ title: s.title, note: s.note, html: table(rows, s.columns) });
      }
      const label = r[d.file || 'id'];
      const file = writeOut(path.join('docs-out', d.name), `${slug(label) || 'record'}-${r.id}`, page({ title: d.title, subtitle: String(label), sections }));
      console.log(`doc: ${path.relative(REPO_ROOT, file)}`);
      count++;
    }
  }
  console.log(`${count} document(s) rendered`);
} finally {
  await db.exec("ROLLBACK");
  await db.close();
}
