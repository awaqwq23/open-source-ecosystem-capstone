import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
const context = vm.createContext({});
vm.runInContext(fs.readFileSync(new URL('./main.js', import.meta.url), 'utf8'), context);
const plugin = context.luotopiaPlugin;
assert.equal(plugin.render().view.nodes.some(n => n.type === 'button'), true);
const loggedOut = await plugin.onAction({input:{}}, {host:{schoolTimetable:{listTimetables: async () => {throw Error('AUTH_REQUIRED');}}}});
assert.match(loggedOut.view.nodes[0].text, /请先.*登录/);
const result = await plugin.onAction({input:{}}, {host:{schoolTimetable:{
  listTimetables: async () => [{id:'whu',name:'我的课表'}],
  getCourses: async query => {assert.equal(query.timetableId,'whu'); return {total:1,items:[{id:'course',title:'数学',startAt:'2026-11-23T08:00:00',location:'教室',instructor:'教师'}]};}
}}});
assert.equal(result.view.nodes.find(n => n.type === 'list').items[0].title, '数学');
console.log('school timetable demo: PASS (render, login guidance, snapshot display)');
