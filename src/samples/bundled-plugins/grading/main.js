"use strict";
function page(expanded) {
  return {state: {expanded: expanded}, view: {title: "课程给分", nodes: [
    {type: "text", id: "intro", text: "课程给分独立页面；当前为功能说明，不提供尚未接入的校园服务。"},
    {type: "text", id: "status", text: expanded ? "此页面由随应用分发的独立 JavaScript 插件提供。可在插件管理中停用、卸载或恢复；当前未连接校园业务服务。" : "当前为功能说明页面，尚未接入业务服务。", tone: "muted"},
    {type: "button", id: "details", label: expanded ? "收起说明" : "查看说明", actionId: "details", style: "secondary"}
  ]}};
}
globalThis.luotopiaPlugin = {
  apiVersion: 1,
  render: function(request) { return page(Boolean(request.state && request.state.expanded === true)); },
  onAction: function(request) {
    if (request.actionId !== "details") throw new Error("INVALID_INPUT");
    return page(!(request.state && request.state.expanded === true));
  }
};
