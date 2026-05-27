const tokenKey = "luotopia.admin.token";
const state = {
  token: localStorage.getItem(tokenKey) || "",
  view: "dashboard",
};

const titles = {
  dashboard: ["Dashboard", "仪表盘"],
  notifications: ["Announcements", "通知"],
  weather: ["Weather", "天气"],
  scripts: ["Hot Update", "热更新脚本"],
  sync: ["Sync", "同步白名单"],
  users: ["Users", "用户"],
};

const $ = (id) => document.getElementById(id);

function showMessage(text, danger = false) {
  const el = $("message");
  el.textContent = text;
  el.classList.remove("hidden");
  el.style.background = danger ? "#f6e7e7" : "#e6f2ee";
  el.style.color = danger ? "#8b2525" : "#0d4f43";
}

function clearMessage() {
  $("message").classList.add("hidden");
}

async function api(path, options = {}) {
  const response = await fetch(path, {
    ...options,
    headers: {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": `Bearer ${state.token}`,
      ...(options.headers || {}),
    },
  });
  const data = await response.json().catch(() => ({}));
  if (!response.ok) {
    const message = data?.error?.message || `请求失败（${response.status}）`;
    throw new Error(message);
  }
  return data;
}

async function login(username, password) {
  const response = await fetch("/admin/api/v1/auth/login", {
    method: "POST",
    headers: {"Accept": "application/json", "Content-Type": "application/json"},
    body: JSON.stringify({username, password}),
  });
  const data = await response.json().catch(() => ({}));
  if (!response.ok) {
    throw new Error(data?.error?.message || "登录失败");
  }
  state.token = data?.tokens?.access_token || "";
  if (!state.token) {
    throw new Error("服务端未返回访问令牌");
  }
  localStorage.setItem(tokenKey, state.token);
}

function boot() {
  $("login").classList.toggle("hidden", Boolean(state.token));
  $("app").classList.toggle("hidden", !state.token);
  if (state.token) render();
}

function setView(view) {
  state.view = view;
  for (const button of document.querySelectorAll("#nav button")) {
    button.classList.toggle("active", button.dataset.view === view);
  }
  render();
}

async function render() {
  clearMessage();
  const [kicker, title] = titles[state.view];
  $("view-kicker").textContent = kicker;
  $("view-title").textContent = title;
  try {
    if (state.view === "dashboard") await renderDashboard();
    if (state.view === "notifications") await renderNotifications();
    if (state.view === "weather") await renderWeather();
    if (state.view === "scripts") await renderScripts();
    if (state.view === "sync") await renderSync();
    if (state.view === "users") await renderUsers();
  } catch (error) {
    showMessage(error.message, true);
    if (error.message.includes("登录") || error.message.includes("管理员")) {
      localStorage.removeItem(tokenKey);
    }
  }
}

async function renderDashboard() {
  const [dashboard, users, allowlist, weather] = await Promise.all([
    api("/admin/api/v1/dashboard"),
    api("/admin/api/v1/users?limit=1"),
    api("/admin/api/v1/sync/allowlist"),
    api("/admin/api/v1/weather/status"),
  ]);
  $("content").innerHTML = `
    <div class="grid">
      <section class="panel"><h3>服务版本</h3><div class="metric">${escapeHtml(dashboard.version)}</div><p class="muted">已运行 ${formatDuration(dashboard.uptime)}</p></section>
      <section class="panel"><h3>用户数量</h3><div class="metric">${users.total || 0}</div><p class="muted">账号系统当前记录</p></section>
      <section class="panel"><h3>同步白名单</h3><div class="metric">${allowlist.items?.length || 0}</div><p class="muted">允许跨设备同步的用户</p></section>
      <section class="panel"><h3>天气缓存</h3><div class="metric">${weather.enabled ? "启用" : "关闭"}</div><p class="muted">${weather.cached_at ? formatDate(weather.cached_at) : "暂无缓存"}</p></section>
    </div>
  `;
}

async function renderNotifications() {
  const data = await api("/admin/api/v1/notifications?limit=50");
  $("content").innerHTML = `
    <section class="panel">
      <h3>创建通知</h3>
      <form id="notification-form" class="form-grid">
        <div class="form-inline">
          <label>标题<input name="title" required /></label>
          <label>图标<select name="icon">${notificationIconOptions("campaign")}</select></label>
          <label>显示顺序<input name="display_order" type="number" value="0" /></label>
        </div>
        <label>正文<textarea name="content"></textarea></label>
        <button class="primary" type="submit">创建草稿</button>
      </form>
    </section>
    <section class="table-panel">
      ${table(["通知", "状态", "顺序", "发布时间", "操作"], (data.items || []).map((item) => [
        `<form id="notification-${item.id}" class="compact-form">
          <label>标题<input name="title" required value="${escapeHtml(item.title)}" /></label>
          <label>图标<select name="icon">${notificationIconOptions(item.icon || "campaign")}</select></label>
          <label>正文<textarea name="content">${escapeHtml(item.content || "")}</textarea></label>
        </form>`,
        badge(item.status),
        `<input form="notification-${item.id}" name="display_order" type="number" value="${Number(item.display_order || 0)}" />`,
        item.published_at ? formatDate(item.published_at) : "未发布",
        actions([
          button("保存", `updateNotification('${item.id}')`),
          item.status !== "published" ? button("发布", `publishNotification('${item.id}')`) : "",
          button("删除", `deleteNotification('${item.id}')`, "danger"),
        ]),
      ]))}
    </section>
  `;
  $("notification-form").addEventListener("submit", createNotification);
}

async function createNotification(event) {
  event.preventDefault();
  const form = new FormData(event.currentTarget);
  await api("/admin/api/v1/notifications", {
    method: "POST",
    body: JSON.stringify(notificationPayload(form)),
  });
  showMessage("通知草稿已创建");
  renderNotifications();
}

async function updateNotification(id) {
  const form = document.getElementById(`notification-${id}`);
  if (!form) return;
  await api(`/admin/api/v1/notifications/${id}`, {
    method: "PUT",
    body: JSON.stringify(notificationPayload(new FormData(form))),
  });
  showMessage("通知已保存");
  renderNotifications();
}

async function publishNotification(id) {
  await api(`/admin/api/v1/notifications/${id}/publish`, {method: "PUT"});
  showMessage("通知已发布");
  renderNotifications();
}

async function deleteNotification(id) {
  await api(`/admin/api/v1/notifications/${id}`, {method: "DELETE"});
  showMessage("通知已删除");
  renderNotifications();
}

function notificationPayload(form) {
  return {
    title: String(form.get("title") || ""),
    content: String(form.get("content") || ""),
    icon: String(form.get("icon") || "campaign"),
    display_order: Number(form.get("display_order") || 0),
  };
}

function notificationIconOptions(selected) {
  const icons = [
    ["campaign", "公告"],
    ["info", "信息"],
    ["event", "日程"],
    ["school", "校园"],
    ["warning", "提醒"],
    ["update", "更新"],
  ];
  return icons.map(([value, label]) => `<option value="${value}" ${value === selected ? "selected" : ""}>${label}</option>`).join("");
}

async function renderWeather() {
  const weather = await api("/admin/api/v1/weather/status");
  const data = weather.data || {};
  $("content").innerHTML = `
    <div class="toolbar"><button class="primary" onclick="refreshWeather()">手动刷新天气</button></div>
    <div class="grid">
      <section class="panel"><h3>状态</h3><div class="metric">${weather.enabled ? "启用" : "关闭"}</div><p class="muted">刷新间隔 ${weather.cache_ttl || 0} 秒</p></section>
      <section class="panel"><h3>当前天气</h3><div class="metric">${data.temperature ?? "--"}°</div><p class="muted">${escapeHtml(data.condition || "暂无数据")}，体感 ${data.feels_like ?? "--"}°</p></section>
      <section class="panel"><h3>今日温度</h3><div class="metric">${data.temp_low ?? "--"}° / ${data.temp_high ?? "--"}°</div><p class="muted">湿度 ${data.humidity ?? "--"}%，风速 ${data.wind_speed ?? "--"}</p></section>
      <section class="panel"><h3>空气质量</h3><div class="metric">${data.aqi || "--"}</div><p class="muted">缓存 ${weather.cached_at ? formatDate(weather.cached_at) : "暂无"}</p></section>
    </div>
    <section class="panel"><h3>最近错误</h3><pre>${escapeHtml(weather.last_error || "无")}</pre></section>
  `;
}

async function refreshWeather() {
  try {
    await api("/admin/api/v1/weather/refresh", {method: "POST"});
    showMessage("天气已刷新");
  } catch (error) {
    showMessage(error.message, true);
  }
  renderWeather();
}

async function renderScripts() {
  const data = await api("/admin/api/v1/hot-update/scripts");
  $("content").innerHTML = `
    <section class="panel">
      <h3>创建脚本</h3>
      <form id="script-form" class="form-inline">
        <label>名称<input name="name" required placeholder="score_service" /></label>
        <label>频道<input name="channel" placeholder="stable" /></label>
        <label>说明<input name="description" /></label>
        <button class="primary" type="submit">创建</button>
      </form>
    </section>
    <section class="panel">
      <h3>发布版本</h3>
      <form id="release-form" class="form-grid">
        <label>脚本 ID<input name="script_id" required /></label>
        <label>发布说明<input name="release_notes" /></label>
        <label>JS 内容<textarea name="content" required></textarea></label>
        <button class="primary" type="submit">发布新版本</button>
      </form>
    </section>
    <section class="table-panel">
      ${table(["名称", "频道", "状态", "版本", "操作"], (data.items || []).map((item) => [
        `<strong>${escapeHtml(item.name)}</strong><pre>${escapeHtml(item.description || item.id)}</pre>`,
        escapeHtml(item.channel || "stable"),
        badge(item.enabled ? "enabled" : "disabled"),
        item.latest_version || 0,
        actions([button(item.enabled ? "停用" : "启用", `toggleScript('${item.id}')`)]),
      ]))}
    </section>
  `;
  $("script-form").addEventListener("submit", createScript);
  $("release-form").addEventListener("submit", publishRelease);
}

async function createScript(event) {
  event.preventDefault();
  const form = new FormData(event.currentTarget);
  await api("/admin/api/v1/hot-update/scripts", {
    method: "POST",
    body: JSON.stringify(Object.fromEntries(form.entries())),
  });
  showMessage("脚本已创建");
  renderScripts();
}

async function publishRelease(event) {
  event.preventDefault();
  const form = new FormData(event.currentTarget);
  const scriptID = form.get("script_id");
  await api(`/admin/api/v1/hot-update/scripts/${scriptID}/releases`, {
    method: "POST",
    body: JSON.stringify({content: form.get("content"), release_notes: form.get("release_notes")}),
  });
  showMessage("脚本版本已发布");
  renderScripts();
}

async function toggleScript(id) {
  await api(`/admin/api/v1/hot-update/scripts/${id}/toggle`, {method: "PUT"});
  showMessage("脚本状态已更新");
  renderScripts();
}

async function renderSync() {
  const data = await api("/admin/api/v1/sync/allowlist");
  $("content").innerHTML = `
    <section class="panel">
      <h3>添加同步白名单</h3>
      <form id="allowlist-form" class="form-inline">
        <label>用户 ID<input name="user_id" required /></label>
        <button class="primary" type="submit">添加</button>
      </form>
    </section>
    <section class="table-panel">
      ${table(["用户 ID", "状态", "更新时间", "操作"], (data.items || []).map((item) => [
        escapeHtml(item.user_id),
        badge(item.enabled ? "enabled" : "disabled"),
        formatDate(item.updated_at),
        actions([button("移除", `removeAllowlist('${item.user_id}')`, "danger")]),
      ]))}
    </section>
  `;
  $("allowlist-form").addEventListener("submit", addAllowlist);
}

async function addAllowlist(event) {
  event.preventDefault();
  const form = new FormData(event.currentTarget);
  await api("/admin/api/v1/sync/allowlist", {
    method: "POST",
    body: JSON.stringify({user_id: form.get("user_id")}),
  });
  showMessage("白名单已添加");
  renderSync();
}

async function removeAllowlist(id) {
  await api(`/admin/api/v1/sync/allowlist/${id}`, {method: "DELETE"});
  showMessage("白名单已移除");
  renderSync();
}

async function renderUsers() {
  const data = await api("/admin/api/v1/users?limit=50");
  $("content").innerHTML = `
    <section class="table-panel">
      ${table(["用户 ID", "状态", "手机号", "邮箱", "会话", "创建时间"], (data.items || []).map((item) => [
        escapeHtml(item.id),
        escapeHtml(item.status),
        escapeHtml(item.phone || ""),
        escapeHtml(item.email || ""),
        item.session_cnt || 0,
        formatDate(item.created_at),
      ]))}
    </section>
  `;
}

function table(headers, rows) {
  if (!rows.length) return `<div class="panel"><p class="muted">暂无数据</p></div>`;
  return `<table><thead><tr>${headers.map((h) => `<th>${h}</th>`).join("")}</tr></thead><tbody>${rows.map((row) => `<tr>${row.map((cell) => `<td>${cell}</td>`).join("")}</tr>`).join("")}</tbody></table>`;
}

function actions(items) {
  return `<div class="actions">${items.filter(Boolean).join("")}</div>`;
}

function button(label, action, kind = "secondary") {
  return `<button class="${kind}" onclick="${action}">${label}</button>`;
}

function badge(value) {
  const label = {published: "已发布", draft: "草稿", enabled: "启用", disabled: "停用"}[value] || value;
  return `<span class="badge ${value}">${label}</span>`;
}

function formatDate(value) {
  if (!value) return "";
  return new Date(value).toLocaleString("zh-CN", {hour12: false});
}

function formatDuration(seconds) {
  const value = Number(seconds || 0);
  if (value < 60) return `${value} 秒`;
  if (value < 3600) return `${Math.floor(value / 60)} 分钟`;
  return `${Math.floor(value / 3600)} 小时`;
}

function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

for (const button of document.querySelectorAll("#nav button")) {
  button.addEventListener("click", () => setView(button.dataset.view));
}

$("refresh").addEventListener("click", render);
$("logout").addEventListener("click", () => {
  localStorage.removeItem(tokenKey);
  state.token = "";
  boot();
});

$("login-form").addEventListener("submit", async (event) => {
  event.preventDefault();
  try {
    await login($("login-identifier").value.trim(), $("login-password").value);
    boot();
  } catch (error) {
    alert(error.message);
  }
});

Object.assign(window, {
  updateNotification,
  publishNotification,
  deleteNotification,
  refreshWeather,
  toggleScript,
  removeAllowlist,
});

boot();
