# Luotopia 网站前端（luotopia.cn）

武汉大学校园服务项目 **Luotopia** 的对外展示站。以武大风景美图为视觉主体，配项目介绍、产品下载、团队介绍。

纯静态 Astro 站点，无 SSR、无集成。

## 开发

```bash
npm install
npm run dev      # 本地预览 http://localhost:4321
npm run build    # 产出到 dist/
npm run preview  # 托管 dist/ 预览生产态
```

将 `dist/` 上传到任意静态服务器/对象存储，绑定 `luotopia.cn` 即可。

## 设计

- **配色**：武汉大学标准色卡（珞珈蓝 `#002554`、珞珈绿 `#115740` 等），见仓库 `../docs/前端网页设计/用色.md`。
- **字体**：Cormorant Garamond / Inter / Noto Serif SC / Noto Sans SC（自托管，按需字重）。
- **图片**：`src/assets/scenery/` 下的武大风景照均来自 Wikimedia Commons 开放授权，本地化存放；来源、作者、许见根目录 `ATTRIBUTION.md`（线上由页脚「图片来源与许可」链接）。

## 目录

```
index.html  -> src/pages/index.astro
布局        src/layouts/Layout.astro
组件        src/components/{Nav,Hero,Intro,Marquee,Gallery,Download,Team,Footer}.astro
样式        src/styles/global.css
图片        src/assets/scenery/
图片元数据  src/data/images.ts
署名        ATTRIBUTION.md（同时置于 public/ 供托管）
```
