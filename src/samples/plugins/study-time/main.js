// @ts-check
/** @type {import('../../../plugin/luotopia-plugin-sdk/index').LuotopiaPlugin} */
globalThis.luotopiaPlugin = {
  apiVersion: 1,
  render(request, context) {
    if (context.viewId === 'preferences') {
      return { state: null, view: { title: '学习统计设置', nodes: [
        { type: 'text', id: 'target', text: '当前目标：' + context.config.targetMinutes + ' 分钟' },
        { type: 'text', id: 'hint', text: '请在插件管理的配置中修改目标分钟数。', tone: 'muted' }
      ] } };
    }
    if (context.viewId !== 'main') throw new Error('INVALID_INPUT');
    return makeView('', '请输入用逗号分隔的分钟数，例如30,45');
  },
  onAction(request, context) {
    if (context.viewId !== 'main' || request.actionId !== 'sum') throw new Error('INVALID_INPUT');
    const raw = request.input.minutes;
    if (typeof raw !== 'string' || raw.length > 500) {
      return makeView(typeof raw === 'string' ? raw : '', '每项必须是0到1440的整数，最多100项、500字符。');
    }
    const parts = raw.split(',').map(value => value.trim());
    if (parts.length > 100 || !parts.every(value => /^\d{1,4}$/.test(value) && Number(value) <= 1440)) {
      return makeView(raw, '每项必须是0到1440的整数，最多100项、500字符。');
    }
    const total = parts.reduce((sum, value) => sum + Number(value), 0);
    return makeView(raw, '合计 ' + total + ' 分钟；目标 ' + context.config.targetMinutes + ' 分钟');
  }
};

/** @param {string} value @param {string} message @returns {import('../../../plugin/luotopia-plugin-sdk/index').PluginResult} */
function makeView(value, message) {
  return { state: null, view: { title: '学习时长统计', nodes: [
    { type: 'input', id: 'minutes', label: '分钟数', value, maxLength: 500 },
    { type: 'button', id: 'calculate', label: '计算', actionId: 'sum' },
    { type: 'text', id: 'result', text: message }
  ] } };
}
