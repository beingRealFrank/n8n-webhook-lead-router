#!/usr/bin/env bash
# Structure + code tests (no Docker needed): checks workflow.json wiring and unit-tests the Code node's JS.
set -euo pipefail
cd "$(dirname "$0")"
python3 - <<'PY'
import json
wf = json.load(open('workflow.json'))
names = {n['name']: n for n in wf['nodes']}
types = [n['type'] for n in wf['nodes']]
assert types.count('n8n-nodes-base.webhook') == 1, 'one webhook'
assert names['Webhook']['parameters']['path'] == 'lead' and names['Webhook']['parameters']['httpMethod'] == 'POST'
for src, c in wf['connections'].items():
    assert src in names
    for outs in c['main']:
        for t in outs: assert t['node'] in names, f'dangling {t["node"]}'
codes = {r['parameters']['options']['responseCode'] for n, r in names.items() if n.startswith('Respond')}
assert codes == {200, 400}, codes
assert len(wf['connections']['Valid?']['main']) == 2, 'IF has true and false branches'
print('structure ok')
PY
node - <<'JS'
const assert = require('assert');
const { normalise } = require('./code_node.js');
let r = normalise({ name: '  Jane   Example ', email: ' JANE@Example.COM ', phone: '1 (555) 010-2000', source: ' Web ' });
assert.deepStrictEqual(r, { valid: true, lead: { name: 'Jane Example', email: 'jane@example.com', phone: '5550102000', source: 'web' } });
r = normalise({ name: 'No Email', email: 'nope' }); assert.strictEqual(r.valid, false);
r = normalise({ name: '', email: 'a@b.co' }); assert.strictEqual(r.valid, false);
r = normalise({ name: 'X', email: 'x@y.io', phone: '123' }); assert.strictEqual(r.lead.phone, '');
// the workflow's embedded Code node must match code_node.js
const wf = require('./workflow.json');
const embedded = wf.nodes.find(n => n.name === 'Validate + normalise').parameters.jsCode;
const src = require('fs').readFileSync('./code_node.js', 'utf8').split('if (typeof module')[0].trim();
assert(embedded.startsWith(src), 'embedded code drifted from code_node.js');
console.log('code ok');
JS
echo "ALL PASS"
