#!/usr/bin/env node
// Régénère db/seed.sql à partir des tableaux MASTERS/SCHOLARSHIPS de prototype/route-du-futur.html.
// À relancer après chaque mise à jour des données Masters/Bourses dans le prototype
// (ex. après une nouvelle passe d'extraction Claude for Chrome).
// Usage : node db/generate-seed.js   (depuis la racine du dépôt)

const fs = require('fs');
const path = require('path');

const repoRoot = path.resolve(__dirname, '..');
const htmlPath = path.join(repoRoot, 'prototype/route-du-futur.html');
const outPath = path.join(repoRoot, 'db/seed.sql');

const html = fs.readFileSync(htmlPath, 'utf8');
const scriptMatch = html.match(/<script>([\s\S]*)<\/script>/);
if (!scriptMatch) throw new Error('Impossible de trouver le <script> dans ' + htmlPath);
const script = scriptMatch[1];

function extractArray(varName) {
  const re = new RegExp(`const ${varName} = (\\[[\\s\\S]*?\\n\\]);`);
  const m = script.match(re);
  if (!m) throw new Error('Tableau introuvable : ' + varName);
  // eslint-disable-next-line no-eval
  return eval(m[1]);
}

const MASTERS = extractArray('MASTERS');
const SCHOLARSHIPS = extractArray('SCHOLARSHIPS');

function slug(s) {
  return s.toLowerCase()
    .normalize('NFD').replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
}
function sqlStr(v) {
  if (v === null || v === undefined) return 'NULL';
  return `'${String(v).replace(/'/g, "''")}'`;
}
function sqlNum(v) {
  return (v === null || v === undefined) ? 'NULL' : String(v);
}
function sqlArr(arr) {
  if (!arr || !arr.length) return "'{}'";
  const escaped = arr.map(x => `"${String(x).replace(/"/g, '\\"').replace(/'/g, "''")}"`);
  return `'{${escaped.join(',')}}'`;
}

const uniMap = new Map();
MASTERS.forEach(m => {
  const id = slug(m.uni);
  if (!uniMap.has(id)) uniMap.set(id, { name: m.uni, country: m.country });
});

const out = [];
out.push('-- Seed de données réelles — régénéré automatiquement par db/generate-seed.js');
out.push('-- Source : docs/criteres-admission.md et docs/criteres-bourses.md');
out.push('-- Ne pas éditer à la main : relancer `node db/generate-seed.js` après toute mise à jour des données.');
out.push('');

out.push('insert into universities (id, name, country) values');
out.push([...uniMap.entries()].map(([id, u]) =>
  `  (${sqlStr(id)}, ${sqlStr(u.name)}, ${sqlStr(u.country)})`
).join(',\n') + ';');
out.push('');

out.push('insert into masters_programs (id, university_id, program_name, tags, req_avg, req_label, req_ielts, english_note, cost, deadline, other_pieces, excluded, exclusion_note, source_confidence) values');
out.push(MASTERS.map(m => {
  const uniId = slug(m.uni);
  const thirdParty = typeof m.cost === 'string' && m.cost.includes('Estimation non officielle');
  const conf = thirdParty ? 'websearch_thirdparty' : 'official_page';
  return `  (${sqlStr(m.id)}, ${sqlStr(uniId)}, ${sqlStr(m.program)}, ${sqlArr(m.tags)}, ${sqlNum(m.reqAvg)}, ${sqlStr(m.reqLabel)}, ${sqlNum(m.reqIelts)}, ${sqlStr(m.englishNote)}, ${sqlStr(m.cost)}, ${sqlStr(m.deadline)}, ${sqlArr(m.other)}, false, NULL, '${conf}')`;
}).join(',\n') + ';');
out.push('');

out.push('insert into scholarships (id, name, coverage, applies, deadline, eligibility_note, source_confidence) values');
out.push(SCHOLARSHIPS.map(s =>
  `  (${sqlStr(s.id)}, ${sqlStr(s.name)}, ${sqlStr(s.coverage)}, ${sqlStr(s.applies)}, ${sqlStr(s.deadline)}, ${sqlStr(s.missing)}, 'websearch_official')`
).join(',\n') + ';');
out.push('');

fs.writeFileSync(outPath, out.join('\n'));
console.log(`OK — ${uniMap.size} universités, ${MASTERS.length} Masters, ${SCHOLARSHIPS.length} bourses -> ${outPath}`);
