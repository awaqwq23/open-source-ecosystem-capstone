# 学习时长统计：独立 SPI v1 示例

本示例只依赖公开JSON协议，业务由main.js执行。三个贡献分别为tab/navigation、card/campusCard、settings/settingsRow；前两个共享main且各自allowedViews仅有main，settings仅允许preferences。无需网络或存储权限。

输入逗号分隔整数分钟（每项0..1440，最多100项、500字符），`30,45`得到75；错误输入保留原文并展示提示。preferences展示宿主config.targetMinutes（默认120、范围1..1440），请通过宿主插件配置修改。

运行 `node test.mjs`（本目录）验证真实脚本行为。发布时将manifest.json、main.js、LICENSE.txt复制到干净暂存目录，按 `src/plugin/luotopia-plugin-sdk/README.md` 使用pack.py生成包。test.mjs和README.md不得进入包。示例许可为MIT。

该例用于SPI接入验收，不代表其他成员已完成真实业务插件或App已完成导入验收。
