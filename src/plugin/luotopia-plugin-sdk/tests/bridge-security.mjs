import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';

// Execute the actual shipped bridge, so the regression follows runtime changes.
const source = fs.readFileSync(new URL('../../../Luotopia-app/lib/features/plugins/runtime/plugin_engine.dart', import.meta.url), 'utf8');
const match = /const _bridgeSource = r'''([\s\S]*?)''';/.exec(source);
assert.ok(match, 'runtime bridge source must exist');
const bridge = match[1];
const makeContext = () => {
  const context = vm.createContext({}, { microtaskMode: 'afterEvaluate' });
  vm.runInContext(bridge, context, { timeout: 500 });
  return context;
};
const run = (context, script) => vm.runInContext(script, context, { timeout: 500 });
const poll = context => JSON.parse(run(context, '__luo.poll()'));

{
  const context = makeContext();
  run(context, `
    globalThis.blocked = 0;
    for (const target of [Object.prototype, Array.prototype]) {
      try {
        Object.defineProperty(target, 'toJSON', {value:function(){
          if (Object.prototype.hasOwnProperty.call(this, 'host')) {
            return {host:Array.from({length:1000},(_,i)=>({id:i,method:'storage.get',args:['forged']})),done:true,value:null,error:null};
          }
          return this;
        }});
      } catch (_) { blocked++; }
    }
  `);
  assert.equal(run(context, 'blocked'), 2, 'bridge prototypes must reject the original toJSON exploit');
  assert.equal(poll(context).host.length, 0, 'prototype tampering cannot create host packets');
}

{
  const context = makeContext();
  run(context, `
    globalThis.rejected = 0;
    globalThis.luotopiaPlugin = {
      apiVersion:1,
      render(request, context) { globalThis.boundContext = context; return new Promise(() => {}); },
      onAction() { return null; }
    };
    __luo.start({method:'render',payload:{state:null},context:{pluginId:'org.example.study-time',contributionId:'tab',viewId:'main',config:{}}});
  `);
  run(context, `
    (() => { 'use strict';
      for (const [key,value] of [['pluginId','org.attacker.other'],['contributionId','settings'],['viewId','preferences']]) {
        try { boundContext[key] = value; } catch (_) {}
      }
      try { boundContext.host.storage.get = () => Promise.resolve('stolen'); } catch (_) {}
    })();
    for (let i=0;i<1000;i++) boundContext.host.storage.get('key'+i).catch(() => { rejected++; });
  `);
  const packet = poll(context);
  assert.equal(packet.host.length, 16, '1000 calls must create only 16 pending host requests');
  assert.equal(run(context, 'rejected'), 984, 'excess calls must reject without unhandled promises');
  assert.deepEqual(JSON.parse(run(context, 'JSON.stringify([boundContext.pluginId,boundContext.contributionId,boundContext.viewId])')), ['org.example.study-time', 'tab', 'main']);
  for (const [index, request] of packet.host.entries()) {
    assert.deepEqual(Object.keys(request).sort(), ['args', 'id', 'method']);
    assert.equal(request.method, 'storage.get');
    assert.deepEqual(request.args, ['key' + index]);
    run(context, `__luo.reply({id:${request.id},value:null})`);
  }
  assert.equal(poll(context).host.length, 0, 'draining the queue must not replay requests');
  run(context, `boundContext.host.storage.get('after-limit').catch(() => { rejected++; });`);
  assert.equal(poll(context).host.length, 0, 'replying cannot reset the per-request call budget');
}

{
  const context = makeContext();
  run(context, `
    globalThis.luotopiaPlugin = {
      apiVersion:1,
      render() { return {state:null,view:{title:'x',nodes:[]},toJSON(){return {host:[{method:'storage.set',args:['x','bad']}]};}}; },
      onAction() { return null; }
    };
    __luo.start({method:'render',payload:{state:null},context:{pluginId:'org.example.study-time',contributionId:'tab',viewId:'main',config:{}}});
  `);
  const packet = poll(context);
  assert.equal(packet.done, true);
  assert.equal(packet.error, 'INVALID_VIEW', 'plugin-defined toJSON must be rejected');
  assert.equal(packet.host.length, 0);
}

console.log('bridge security: PASS (prototype tampering, pending budget, bound identity, toJSON rejection)');
