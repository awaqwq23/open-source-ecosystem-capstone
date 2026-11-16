# WebView 页面调用规范

本文说明应用内 WebView 页面的统一接入方式。新增 WebView 页面应优先使用
`AppWebViewPage`，不要在业务页面里重复编写加载层、错误层、返回和刷新逻辑。

## 框架边界

`AppWebViewPage` 只负责通用 WebView 页面生命周期：

- 创建并持有 `WebViewController`。
- 启用 `JavaScriptMode.unrestricted`。
- Android 端统一设置 `setUseWideViewPort(true)` 和 `setTextZoom(100)`。
- 渲染统一标题栏、返回按钮、刷新按钮、加载层、进度条和主框架错误层。
- 处理返回：WebView 能后退时先 `goBack()`，否则退出页面。
- 提供导航拦截和带 headers 重新加载的机制。

`AppWebViewPage` 不处理具体业务：

- 不判断武大账号是否登录。
- 不调用 `whuAuthProvider`。
- 不完成 CAS 登录。
- 不解析业务 URL、Cookie 或 JS 消息。
- 不注入业务 JS。

这些逻辑应留在业务页面中，通过回调接入。

## 基本页面

最小接入只需要标题和首个请求：

```dart
return AppWebViewPage(
  title: '页面标题',
  initialRequest: (_) {
    return AppWebViewRequest(uri: Uri.parse('https://example.com'));
  },
);
```

如果页面不需要刷新按钮，传入 `showRefresh: false`。

## 需要登录或会话准备的页面

登录检查、Cookie 注入、服务授权等都放在 `initialRequest` 中完成。未满足条件时返回
`null`，并用页面自己的状态配合 `overlayBuilder` 展示业务提示。

```dart
return AppWebViewPage(
  title: '校园应用',
  preparingMessage: '正在准备校园应用...',
  loadingMessage: '正在加载校园应用...',
  initialRequest: (controller) async {
    if (!isAuthenticated) {
      setState(() => needsLogin = true);
      return null;
    }

    await authNotifier.primeCasCookiesForWebView();
    return AppWebViewRequest(uri: entryUri);
  },
  overlayBuilder: (context, state, controller) {
    if (!needsLogin) {
      return null;
    }
    return LoginRequiredOverlay(onLogin: openLoginPage);
  },
);
```

## 需要指定 Headers 的页面

某些学校页面要求模拟宿主 WebView 的 UA、`X-Requested-With` 或 `Referer`。这些规则仍由业务页面定义，通用层只负责避免重复拦截循环。

```dart
return AppWebViewPage(
  title: '珞珈 E 卡',
  initialRequest: (controller) async {
    await controller.setUserAgent(smartCampusUserAgent);
    return AppWebViewRequest(
      uri: entryUri,
      headers: smartCampusHeaders(entryUri),
    );
  },
  onNavigationRequest: (request, controller) {
    final uri = Uri.tryParse(request.url);
    if (uri == null || uri.scheme != 'https') {
      return const AppWebViewNavigationAction.prevent();
    }
    if (shouldReloadWithHeaders(uri)) {
      return AppWebViewNavigationAction.reloadWithHeaders(
        uri,
        smartCampusHeaders(uri),
      );
    }
    return const AppWebViewNavigationAction.navigate();
  },
);
```

## 需要 JS Bridge 的页面

JS channel 和 JS 注入属于业务逻辑。页面应在 `onControllerCreated` 里注册 channel，在
`onPageFinished` 里注入脚本。

```dart
return AppWebViewPage(
  title: '自习预约',
  enableZoom: false,
  initialRequest: buildSeatReservationRequest,
  onControllerCreated: (controller) {
    controller.addJavaScriptChannel(
      'SeatReservationBridge',
      onMessageReceived: handleBridgeMessage,
    );
  },
  onPageFinished: (url, controller) async {
    await controller.runJavaScript(seatReservationBridgeScript);
  },
);
```

JS bridge 回调里可以展示确认弹窗、写入本地仓储或弹出 SnackBar，但不要把这些业务规则放进
`AppWebViewPage`。

## 新页面自查

新增或迁移 WebView 页面时检查：

- 除 `AppWebViewPage` 外，不直接创建 `WebViewController()`。
- 不复制加载层、错误层、返回键和刷新按钮样板。
- 认证、Header、JS bridge 等业务规则只通过回调接入。
- 敏感 Cookie、token、学号、姓名和设备指纹不写入代码或可提交文档。
- 如果页面需要武大统一认证，优先复用 `whu_auth`，不要在页面层拼接 Cookie。
