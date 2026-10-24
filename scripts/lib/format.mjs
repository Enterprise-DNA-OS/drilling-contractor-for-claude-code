// Text output helpers: aligned tables, money, hours, dates.

export function money(cents, currency = 'NZD') {
  // table() hands formatters (value, row); a non-string second arg is not a currency.
  if (typeof currency !== 'string') currency = 'NZD';
  const n = Number(cents || 0) / 100;
  try {
    return new Intl.NumberFormat('en-NZ', {
      style: 'currency',
      currency,
      currencyDisplay: 'narrowSymbol',
      maximumFractionDigits: 0,
    }).format(n);
  } catch {
    return `${currency} ${n.toFixed(0)}`;
  }
}

// $19.99, not $20. Shelf prices, unit prices and anything a person reads off a ticket.
export function price(cents, currency = 'NZD') {
  if (typeof currency !== 'string') currency = 'NZD';
  if (cents === null || cents === undefined || cents === '') return '';
  const n = Number(cents) / 100;
  try {
    return new Intl.NumberFormat('en-NZ', {
      style: 'currency',
      currency,
      currencyDisplay: 'narrowSymbol',
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    }).format(n);
  } catch {
    return `${currency} ${n.toFixed(2)}`;
  }
}

// 135 -> "2.25h". Minutes are the storage unit; hours are how people talk.
export function hours(minutes) {
  const m = Number(minutes || 0);
  if (!m) return '0h';
  return `${(m / 60).toFixed(2).replace(/\.?0+$/, '')}h`;
}

// 135 -> "2:15", the shape a timesheet row is read in.
export function clock(minutes) {
  const m = Math.max(0, Math.round(Number(minutes || 0)));
  return `${Math.floor(m / 60)}:${String(m % 60).padStart(2, '0')}`;
}

export function isoDate(v) {
  if (!v) return '';
  if (v instanceof Date) {
    const pad = (n) => String(n).padStart(2, '0');
    return `${v.getFullYear()}-${pad(v.getMonth() + 1)}-${pad(v.getDate())}`;
  }
  return String(v).slice(0, 10);
}

export function dateTime(v) {
  if (!v) return '';
  const d = v instanceof Date ? v : new Date(v);
  if (Number.isNaN(d.getTime())) return String(v);
  const pad = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`;
}

export function daysAgo(v) {
  if (!v) return '';
  const d = v instanceof Date ? v : new Date(v);
  const days = Math.floor((Date.now() - d.getTime()) / 86400000);
  if (days <= 0) return 'today';
  if (days === 1) return '1 day ago';
  return `${days} days ago`;
}

export function weekday(v) {
  const d = v instanceof Date ? v : new Date(`${String(v).slice(0, 10)}T00:00:00`);
  if (Number.isNaN(d.getTime())) return '';
  return ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][d.getDay()];
}

export function short(id) {
  return String(id || '').slice(0, 8);
}

export function truncate(s, n = 60) {
  s = String(s ?? '').replace(/\s+/g, ' ').trim();
  return s.length > n ? s.slice(0, n - 1) + '...' : s;
}

// columns: [{ key, label, align: 'left'|'right', width?, format? }]
export function table(rows, columns) {
  if (!rows.length) return '  (none)';
  const cells = rows.map((r) =>
    columns.map((c) => {
      const raw = c.format ? c.format(r[c.key], r) : r[c.key];
      return raw === null || raw === undefined ? '' : String(raw);
    }),
  );
  const widths = columns.map((c, i) => {
    const w = Math.max(c.label.length, ...cells.map((row) => row[i].length));
    return c.width ? Math.min(w, c.width) : w;
  });
  const fit = (s, i) => {
    const w = widths[i];
    if (s.length > w) s = s.slice(0, w - 3) + '...';
    return columns[i].align === 'right' ? s.padStart(w) : s.padEnd(w);
  };
  const line = (arr) => '  ' + arr.map((s, i) => fit(s, i)).join('  ');
  const out = [line(columns.map((c) => c.label)), '  ' + widths.map((w) => '-'.repeat(w)).join('  ')];
  for (const row of cells) out.push(line(row));
  return out.join('\n');
}

export function heading(text) {
  return `\n${text}\n${'='.repeat(text.length)}`;
}

export function bar(pct, width = 10) {
  const p = Math.max(0, Math.min(150, Number(pct || 0)));
  const filled = Math.min(width, Math.round((p / 100) * width));
  return '#'.repeat(filled) + '.'.repeat(Math.max(0, width - filled));
}
