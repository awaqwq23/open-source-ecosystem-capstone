# 独立 SDK 测试记录（2026-11-21）

测试先于实现创建，未使用源文本grep断言。环境：Windows，Python 3.12（Codex bundled runtime）、Node v24.22.3。

运行命令（仓库根目录）：

```text
python -m unittest discover -s src/plugin/luotopia-plugin-sdk/tests
node src/samples/plugins/study-time/test.mjs
```

RED：首次运行时manifest.json和main.js尚不存在，Python报FileNotFoundError，Node报ENOENT。补充样例后再次运行，Python正向包内容测试明确因pack.py不存在返回2而失败；Node VM脚本行为通过。这样确认打包成功路径不会被全拒绝实现蒙混通过。Windows上大小写等价文件名实际覆盖同一文件，曾导致该无效fixture预期错误；移除该不适用fixture，改测多余子目录，不把它记录成产品缺陷。

GREEN：实现pack.py后，首轮3个unittest测试方法全部通过，其中invalid_manifest运行11项独立CLI负例，bad_files_and_limits运行4项独立CLI负例；随后补充重复JSON键和禁止覆盖发行物两项验证，最终5个测试方法全部通过。Node VM行为测试通过。unittest使用临时真实目录、subprocess启动实际CLI，并用zipfile读取产物内容；VM载入实际main.js、调用provider并断言返回值及异常。具体覆盖：

- 正常三文件包和解压后的manifest身份。
- 保留/非法ID、未知API、布尔schema版本、前导零版本、非法entry、宿主字段、未知权限、越权allowedViews、重复贡献、越界配置默认值。
- 多余文件/目录、超2MiB脚本、非UTF-8许可。
- 重复JSON键明确拒绝，已有输出包保持原内容。
- `30,45→75`、0/1440边界、空项/负数/小数/科学计数/十六进制/超额/NaN/非字符串输入、超100项/500字符、未知action/view、preferences配置展示。

未做真机导入、宿主集成、Flutter构建、引擎硬限额/中断或设备视觉检查。打包预检不等于安全认证或发布验收。

随后与宿主manifest配置校验对齐：配置key仅允许字母开头的字母/数字/下划线，最长48字符；choice最多100项。补充非法配置key和101项choice的实际CLI负例，invalid_manifest现有13项负例，5个测试方法仍全部通过，Node行为测试通过。

## 完整预检边界与桥接回归补充

进一步先添加CLI测试：metadata/count/icon/color/DNS顶级域名/UTF16文本/选项和1MiB许可的18项负例，运行时均意外成功，得到18项RED；边界合法值测试通过。再实现对应打包校验，7个测试方法全部GREEN。另先添加BOM/Unicode空白脚本和许可两个CLI负例，得到2项RED；改为按Dart trim字符集判空后纳入最终测试。

最终命令：`python -B -m unittest discover -s src/plugin/luotopia-plugin-sdk/tests`（8个测试方法）；`node src/samples/plugins/study-time/test.mjs`；`node src/plugin/luotopia-plugin-sdk/tests/bridge-security.mjs`。

桥接测试执行App实际提取的_bridgeSource，断言Object/Array原型toJSON不能注入队列；1000个storage.get最多产生16个pending，其余984个Promise拒绝均被捕获；回复不会重置调用额度；绑定的pluginId/contributionId/viewId及host方法不能被替换；插件自定义toJSON结果作为INVALID_VIEW拒绝。此前只读漏洞复现曾实际产生1000条伪造host消息；宿主freeze原型等修复后，这一回归检查通过。该Node测试不执行Dart worker，也不证明native引擎资源释放。
