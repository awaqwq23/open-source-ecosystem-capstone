import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import {fileURLToPath} from 'node:url';
const root = path.dirname(fileURLToPath(import.meta.url));
const dirs = fs.readdirSync(root).filter(name => fs.statSync(path.join(root, name)).isDirectory());
assert.equal(dirs.length, 9);
for (const dir of dirs) {
  const source = fs.readFileSync(path.join(root, dir, 'main.js'), 'utf8');
  const manifest = JSON.parse(fs.readFileSync(path.join(root, dir, 'manifest.json'), 'utf8'));
  const context = vm.createContext({});
  vm.runInContext(source, context, {timeout: 500});
  const provider = context.luotopiaPlugin;
  const first = provider.render({state: null}, {});
  assert.equal(first.view.title, manifest.name);
  assert.equal(first.state.expanded, false);
  const next = provider.onAction({actionId: 'details', input: {}, state: first.state}, {});
  assert.equal(next.state.expanded, true);
  assert.equal(provider.onAction({actionId: 'details', input: {}, state: next.state}, {}).state.expanded, false);
  assert.throws(() => provider.onAction({actionId: 'unknown', state: {}}, {}), /INVALID_INPUT/);
}
console.log('9 independent bundled providers passed render/action checks');
