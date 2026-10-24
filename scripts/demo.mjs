#!/usr/bin/env node
// `npm run demo`: migrate, seed, then show the three answers a drilling contractor asks for first.
import { spawnSync } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const run = (...args) => {
  const r = spawnSync(process.execPath, args.map((a, i) => (i === 0 ? path.join(root, 'scripts', a) : a)), { cwd: root, stdio: 'inherit' });
  if (r.status !== 0) process.exit(r.status ?? 1);
};
run('migrate.mjs');
run('seed.mjs');
run('drill.mjs', 'pending');
run('drill.mjs', 'utilisation');
run('drill.mjs', 'attention');
console.log('\nNext: open this folder in Claude Code and type /attention, or ask "what can I claim from Kurrawang this month?"');
