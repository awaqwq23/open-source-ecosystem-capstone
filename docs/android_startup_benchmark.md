# Android 冷启动证据采集（Release 基准）

本文档用于复现 `android_to_main`、`main_to_target` 等冷启动指标，并输出可比较的统计结果。

## 1. 前置条件

- 已安装 `adb`，并可在终端直接调用。
- 目标设备已连接并授权（`adb devices` 可见）。
- 设备中已安装待测包（建议 `Release` 包）。
- App 内保留 `StartupPerfProbe` 打点（本项目已接入）。

## 2. 采样脚本

脚本路径：`tools/startup_benchmark.ps1`

默认行为：
- 执行 20 轮冷启动（`force-stop -> start`）。
- 每轮等待 9 秒采集日志。
- 自动解析 `[STARTUP]` JSON 打点，抽取 `startup_summary` 所属 session。
- 输出每轮明细和 P50/P90/均值/标准差。

## 3. 使用方式

在项目根目录执行：

```powershell
pwsh -File .\tools\startup_benchmark.ps1 `
  -PackageName com.example.huajuan_agenda `
  -ActivityName .MainActivity `
  -DeviceId 6d68fbe1 `
  -Iterations 20 `
  -StartupWaitSeconds 9
```

常用可选参数：
- `-OutputDir build/startup-benchmark`：输出根目录
- `-KeepFullLogcat`：保留每轮完整 logcat（用于排错）

## 4. 输出文件

每次执行会创建时间戳目录，包含：
- `meta.json`：设备与采样参数
- `runs.json` / `runs.csv`：每轮明细
- `stats.json` / `stats.csv`：聚合统计

关键字段（`runs.*`）：
- `android_to_main_ms`
- `main_to_target_ms`
- `total_from_android_start_ms`
- `shared_preferences_get_instance_ms`
- `android_bridge_bootstrap_ms`
- `main_bootstrap_ms`
- `home_window_storage_load_ms`
- `run_app_to_app_shell_first_ms`
- `first_frame_total_span_ms`

## 5. 建议判定口径

- 用 `P50` 判断典型体验，用 `P90` 判断尾部抖动。
- 连续两次采样对比时，优先比较：
  1. `android_to_main_ms`（冷启动前段）
  2. `main_to_target_ms`（Flutter 主链路）
  3. `shared_preferences_get_instance_ms` 与 `home_window_storage_load_ms`（已知大头）
- 若 `android_to_main_ms` 改善 < 8%，不建议进入高复杂架构改造；若 >= 15% 且方差显著下降，可继续推进优化方案。

## 6. 注意事项

- 采样前尽量保持设备温度、电量和后台状态一致。
- 采样期间避免人工操作设备，减少噪声。
- Debug/Profile 的数值可用于趋势观察，但是否值得优化应以 Release 为准。
