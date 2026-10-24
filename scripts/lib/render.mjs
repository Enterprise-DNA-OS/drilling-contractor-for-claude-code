// Shared HTML rendering for `npm run view` and `npm run docs`.
// One brand.json, one page shell, tables from rows. No framework, no build step.
import { readFileSync, mkdirSync, writeFileSync, existsSync, chmodSync } from 'node:fs';
import path from 'node:path';
import { REPO_ROOT } from './db.mjs';

export function loadBrand() {
  const file = path.join(REPO_ROOT, 'brand.json');
  const brand = existsSync(file) ? JSON.parse(readFileSync(file, 'utf8')) : {};
  return {
    business_name: 'Your Business', primary: '#6654f5', accent: '#ca5a8b', ink: '#0b0c18', paper: '#ffffff',
    logo_path: '', footer_line: '', ...brand,
  };
}

export function esc(v) {
  return String(v ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
}

export function table(rows, columns = null) {
  if (!rows || !rows.length) return '<p class="empty">Nothing here.</p>';
  const cols = columns || Object.keys(rows[0]);
  const head = cols.map((c) => `<th>${esc(c.replace(/_cents$/, '').replace(/_bps$/, ' %').replace(/_/g, ' '))}</th>`).join('');
  const body = rows.map((r) => `<tr>${cols.map((c) => `<td${/^\d{4}-\d{2}-\d{2}$/.test(String(r[c])) ? ' class="date-cell"' : ''}>${esc(fmt(r[c], c, r))}</td>`).join('')}</tr>`).join('');
  return `<div class="table-scroll"><table><thead><tr>${head}</tr></thead><tbody>${body}</tbody></table></div>`;
}

function fmt(v, key, row) {
  if (v === null || v === undefined) return /(?:_amount|_cents|_bps)$/.test(key) ? 'unknown' : '';
  if (typeof v === 'boolean') return v ? 'Yes' : 'No';
  if (v instanceof Date) return v.toISOString().replace('T', ' ').replace('.000Z', ' UTC');
  if (key.endsWith('_amount')) return Number(v).toLocaleString('en-NZ', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  if (key.endsWith('_bps')) return `${(Number(v) / 100).toFixed(2)}%`;
  // Thousands separators; a *_base_cents column is already in the group's base currency, so it takes no row currency.
  if (key.endsWith('_cents')) {
    const amount = (Number(v) / 100).toLocaleString('en-NZ', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
    return key.endsWith('_base_cents') ? amount : `${row.currency || ''} ${amount}`.trim();
  }
  if (typeof v === 'object') return JSON.stringify(v);
  if (typeof v === 'number' && !Number.isInteger(v)) return v.toFixed(2);
  return v;
}

export function page({ title, subtitle = '', sections = [], brand = loadBrand() }) {
  const logo = brand.logo_path ? `<img src="${esc(brand.logo_path)}" alt="" class="logo">` : '';
  const blocks = sections.map((s) => `<section><h2>${esc(s.title)}</h2>${s.note ? `<p class="note">${esc(s.note)}</p>` : ''}${s.html}</section>`).join('\n');
  return `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>${esc(title)} · ${esc(brand.business_name)}</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap">
<style>
:root{--p:${brand.primary};--a:${brand.accent};--ink:${brand.ink};--paper:${brand.paper}}
*{box-sizing:border-box}body{margin:0;font:15px/1.5 system-ui,-apple-system,Segoe UI,Roboto,sans-serif;color:var(--ink);background:#f6f6f9}
header{background:var(--ink);color:#fff;padding:20px 28px;display:flex;align-items:center;gap:16px;border-bottom:4px solid var(--p)}
header .logo{height:36px}header h1{margin:0;font-size:20px}header .sub{color:#c9c9d6;font-size:13px}header .biz{margin-left:auto;font-weight:600}
h1,h2,.biz{font-family:Poppins,system-ui,sans-serif}
main{max-width:1100px;margin:0 auto;padding:24px 20px 60px}
section{background:var(--paper);border-radius:14px;padding:18px 20px;margin:0 0 18px;box-shadow:0 1px 3px rgba(0,0,0,.06)}
h2{margin:0 0 8px;font-size:16px;color:var(--p);text-transform:uppercase;letter-spacing:.08em}.note{margin:0 0 10px;color:#555}
.table-scroll{max-width:100%;overflow-x:auto}.table-scroll{overflow-x:auto;max-width:100%}table{width:100%;border-collapse:collapse;font-size:14px}th{text-align:left;font-weight:600;color:#666;border-bottom:2px solid #eee;padding:8px 10px;white-space:normal}
td.date-cell{white-space:nowrap}td{padding:8px 10px;border-bottom:1px solid #f0f0f4;vertical-align:top}tr:hover td{background:#faf9ff}.empty{color:#888;margin:0}
footer{text-align:center;color:#888;font-size:12px;padding:20px}
@media(max-width:600px){header{flex-wrap:wrap;padding:18px}header .biz{margin-left:0}main{padding:16px 10px}section{padding:14px}th,td{padding:7px}}
@media print{.table-scroll{overflow:visible}table{font-size:10px}th,td{padding:4px;white-space:normal;overflow-wrap:anywhere}body{background:#fff}section{box-shadow:none;border:1px solid #eee;break-inside:avoid}}
</style></head><body>
<header>${logo}<div><h1>${esc(title)}</h1><div class="sub">${esc(subtitle)}</div></div><div class="biz">${esc(brand.business_name)}</div></header>
<main>${blocks}</main>
<footer>${esc(brand.footer_line)} Generated ${new Date().toISOString().slice(0, 16).replace('T', ' ')}</footer>
</body></html>`;
}

export function writeOut(dir, name, html) {
  const out = path.resolve(process.env.OUTPUT_DIR || REPO_ROOT, dir);
  mkdirSync(out, { recursive: true, mode: 0o700 });
  const file = path.join(out, `${name}.html`);
  writeFileSync(file, html, { mode: 0o600 });
  chmodSync(file, 0o600); // Generated reports may contain private business or personnel records.
  return file;
}
