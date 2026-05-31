# Luotopia-website

luotopia.cn 主站静态文件。采用纯 HTML/CSS/JS，武大文雅大气设计风格。

## 目录结构

```
├── index.html          # 主页面
├── download/
│   └── index.html      # 下载页面
├── about/
│   └── index.html      # 关于我们
├── assets/
│   ├── css/style.css   # 全局样式
│   ├── js/main.js      # 交互脚本
│   └── images/
│       ├── hero-bg.jpg         # 首屏背景图（需自行准备）
│       ├── favicon.svg         # 网站图标
│       └── screenshots/       # App 截图（需自行准备）
│           ├── home.png
│           ├── ai.png
│           ├── campus.png
│           └── forum.png
└── README.md
```

## 需要准备的图片资源

| 文件 | 说明 | 建议尺寸 |
|------|------|----------|
| `hero-bg.jpg` | 首屏背景（武大风光） | ≥ 1920×1080 |
| `screenshots/home.png` | 应用首页截图 | ≥ 320×680 |
| `screenshots/ai.png` | AI 助手截图 | ≥ 320×680 |
| `screenshots/campus.png` | 校园功能截图 | ≥ 320×680 |
| `screenshots/forum.png` | 社区截图 | ≥ 320×680 |
| `about-whu.jpg` | 关于页武大图片 | ≥ 800×600 |

## 下载链接

下载页使用 jsDelivr CDN 分发安装包。链接格式：

```
https://cdn.jsdelivr.net/gh/openwhu/luotopia@v{版本号}/luotopia-{平台}.{后缀}
```

当 GitHub Actions 发布新 Release 后，jsDelivr 会自动拾取产物。

## 本地预览

直接在浏览器中打开 `index.html` 即可预览。
