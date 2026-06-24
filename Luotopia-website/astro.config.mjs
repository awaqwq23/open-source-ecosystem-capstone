// @ts-check
import { defineConfig } from 'astro/config';

// 纯静态输出，无 SSR / 无集成；图片走 astro:assets 内置优化
export default defineConfig({
  site: 'https://luotopia.cn',
  output: 'static',
  devToolbar: { enabled: false },
  build: {
    inlineStylesheets: 'auto',
  },
});
