import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';

const sandbox = vm.createContext({});
vm.runInContext(fs.readFileSync(new URL('./main.js', import.meta.url), 'utf8'), sandbox, { timeout: 500 });
const plugin = sandbox.luotopiaPlugin;
const context = { pluginId: 'org.example.study-time', contributionId: 'tab', viewId: 'main', locale: 'zh', theme: 'light', config: { targetMinutes: 120 }, host: {} };
const resultText = result => result.view.nodes.find(node => node.id === 'result').text;
assert.equal(plugin.apiVersion, 1);
assert.match(resultText(plugin.render({ state: null }, context)), /请输入/);
assert.match(resultText(plugin.onAction({ actionId: 'sum', input: { minutes: '30,45' }, state: null }, context)), /合计 75 分钟/);
for (const minutes of ['', '30,', '-1', '1.5', '1e2', '0x10', '1441', 'NaN', '1,'.repeat(100) + '1', '1'.repeat(501), 30, null, {}, ['30']]) {
  const result = plugin.onAction({ actionId: 'sum', input: { minutes }, state: null }, context);
  assert.match(resultText(result), /每项必须/);
}
assert.match(resultText(plugin.onAction({ actionId: 'sum', input: { minutes: '0, 1440' }, state: null }, context)), /合计 1440 分钟/);
assert.throws(() => plugin.onAction({ actionId: 'evil', input: {}, state: null }, context), /INVALID_INPUT/);
assert.throws(() => plugin.render({ state: null }, { ...context, viewId: 'unknown' }), /INVALID_INPUT/);
const preferences = plugin.render({ state: null }, { ...context, contributionId: 'settings', viewId: 'preferences', config: { targetMinutes: 60 } });
assert.match(JSON.stringify(preferences), /60/);
console.log('study-time behavior: PASS');
