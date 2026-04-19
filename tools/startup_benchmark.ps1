param(
    [string]$PackageName = "com.example.huajuan_agenda",
    [string]$ActivityName = ".MainActivity",
    [string]$DeviceId = "",
    [int]$Iterations = 20,
    [int]$StartupWaitSeconds = 9,
    [string]$OutputDir = "build/startup-benchmark",
    [switch]$KeepFullLogcat
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Invoke-Adb {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Args
    )

    $prefix = @()
    if ($script:DeviceId -and $script:DeviceId.Trim().Length -gt 0) {
        $prefix = @("-s", $script:DeviceId)
    }
    $output = & adb @prefix @Args 2>&1
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        $joinedArgs = ($prefix + $Args) -join " "
        $message = if ($output) { ($output | Out-String).Trim() } else { "无输出" }
        throw "adb 命令失败: adb $joinedArgs`n$message"
    }
    return $output
}

function Remove-Ansi {
    param([string]$Text)
    return [regex]::Replace($Text, "`e\[[0-9;]*m", "")
}

function Parse-StartupEvents {
    param([string[]]$LogLines)

    $events = New-Object System.Collections.Generic.List[object]
    foreach ($line in $LogLines) {
        if ($line -notmatch "\[STARTUP\]") {
            continue
        }
        $clean = Remove-Ansi -Text $line
        $brace = $clean.IndexOf("{")
        if ($brace -lt 0) {
            continue
        }
        $json = $clean.Substring($brace)
        try {
            $obj = $json | ConvertFrom-Json
            $events.Add($obj)
        }
        catch {
            continue
        }
    }
    return $events
}

function To-Double {
    param($Value)
    if ($null -eq $Value) {
        return $null
    }
    return [double]::Parse($Value.ToString(), [System.Globalization.CultureInfo]::InvariantCulture)
}

function Get-StageDuration {
    param(
        [object[]]$Events,
        [string]$StageName
    )

    $match = $Events | Where-Object { $_.event -eq "stage_end" -and $_.stage -eq $StageName } | Select-Object -First 1
    if ($null -eq $match) {
        return $null
    }
    return To-Double -Value $match.duration_ms
}

function Get-EventTime {
    param(
        [object[]]$Events,
        [string]$EventName,
        [int]$Index = 0
    )

    $hits = $Events | Where-Object { $_.event -eq $EventName }
    if ($hits.Count -le $Index) {
        return $null
    }
    return To-Double -Value $hits[$Index].t_ms
}

function Get-DeltaMs {
    param(
        [object[]]$Events,
        [string]$StartEvent,
        [string]$EndEvent
    )
    $start = Get-EventTime -Events $Events -EventName $StartEvent
    $end = Get-EventTime -Events $Events -EventName $EndEvent
    if ($null -eq $start -or $null -eq $end) {
        return $null
    }
    return [math]::Round($end - $start, 3)
}

function Get-Stats {
    param(
        [string]$Name,
        [double[]]$Values
    )

    if ($Values.Count -eq 0) {
        return [pscustomobject]@{
            metric = $Name
            count = 0
            min = $null
            max = $null
            mean = $null
            p50 = $null
            p90 = $null
            stddev = $null
        }
    }

    $sorted = $Values | Sort-Object
    $count = $sorted.Count
    $sum = ($sorted | Measure-Object -Sum).Sum
    $mean = $sum / $count
    $varianceSum = 0.0
    foreach ($v in $sorted) {
        $varianceSum += [math]::Pow($v - $mean, 2)
    }
    $stddev = if ($count -gt 1) { [math]::Sqrt($varianceSum / ($count - 1)) } else { 0.0 }

    $p50Rank = [math]::Ceiling(0.50 * $count)
    $p90Rank = [math]::Ceiling(0.90 * $count)
    $p50 = $sorted[[math]::Max($p50Rank - 1, 0)]
    $p90 = $sorted[[math]::Max($p90Rank - 1, 0)]

    return [pscustomobject]@{
        metric = $Name
        count = $count
        min = [math]::Round($sorted[0], 3)
        max = [math]::Round($sorted[-1], 3)
        mean = [math]::Round($mean, 3)
        p50 = [math]::Round($p50, 3)
        p90 = [math]::Round($p90, 3)
        stddev = [math]::Round($stddev, 3)
    }
}

if ($Iterations -lt 1) {
    throw "Iterations 必须 >= 1"
}

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$runDir = Join-Path $OutputDir $timestamp
New-Item -ItemType Directory -Force -Path $runDir | Out-Null

$activityComponent = if ($ActivityName.StartsWith(".")) { "$PackageName/$ActivityName" } else { $ActivityName }

$deviceModelOutput = Invoke-Adb -Args @("shell", "getprop", "ro.product.model")
$deviceFingerprintOutput = Invoke-Adb -Args @("shell", "getprop", "ro.build.fingerprint")
$deviceModel = (($deviceModelOutput | Out-String).Trim())
$deviceFingerprint = (($deviceFingerprintOutput | Out-String).Trim())

$runs = New-Object System.Collections.Generic.List[object]

for ($i = 1; $i -le $Iterations; $i++) {
    Write-Host ("[{0}/{1}] 采样中..." -f $i, $Iterations)
    Invoke-Adb -Args @("logcat", "-c") | Out-Null
    Invoke-Adb -Args @("shell", "am", "force-stop", $PackageName) | Out-Null
    Invoke-Adb -Args @("shell", "am", "start", "-n", $activityComponent) | Out-Null
    Start-Sleep -Seconds $StartupWaitSeconds
    $logLines = Invoke-Adb -Args @("logcat", "-d")

    if ($KeepFullLogcat) {
        $logPath = Join-Path $runDir ("run-{0:D2}-logcat.txt" -f $i)
        $logLines | Set-Content -LiteralPath $logPath -Encoding UTF8
    }

    $events = Parse-StartupEvents -LogLines $logLines
    $summaries = $events | Where-Object { $_.event -eq "startup_summary" }
    if ($summaries.Count -eq 0) {
        Write-Warning ("第 {0} 轮未捕获到 startup_summary，已跳过" -f $i)
        continue
    }

    $session = $summaries[-1].session
    $sessionEvents = $events | Where-Object { $_.session -eq $session } | Sort-Object { To-Double -Value $_.t_ms }
    $summary = $sessionEvents | Where-Object { $_.event -eq "startup_summary" } | Select-Object -Last 1
    $firstFrameTiming = $sessionEvents | Where-Object { $_.event -eq "first_frame_timing" } | Select-Object -First 1

    $run = [pscustomobject]@{
        iteration = $i
        session = $session
        android_to_main_ms = To-Double -Value $summary.android_to_main_ms
        main_to_target_ms = To-Double -Value $summary.main_to_target_ms
        total_from_android_start_ms = To-Double -Value $summary.total_from_android_start_ms
        shared_preferences_get_instance_ms = Get-StageDuration -Events $sessionEvents -StageName "shared_preferences_get_instance"
        android_bridge_bootstrap_ms = Get-StageDuration -Events $sessionEvents -StageName "android_bridge_bootstrap"
        main_bootstrap_ms = Get-StageDuration -Events $sessionEvents -StageName "main_bootstrap"
        home_window_storage_load_ms = Get-DeltaMs -Events $sessionEvents -StartEvent "home_window_storage_load_start" -EndEvent "home_window_storage_load_end"
        run_app_to_app_shell_first_ms = Get-DeltaMs -Events $sessionEvents -StartEvent "run_app_called" -EndEvent "app_shell_build_first"
        first_frame_total_span_ms = To-Double -Value $firstFrameTiming.total_span_ms
        target_event = $summary.target_event
        startup_summary_t_ms = To-Double -Value $summary.t_ms
    }
    $runs.Add($run)
}

if ($runs.Count -eq 0) {
    throw "所有采样都失败，未收集到 startup_summary"
}

$metricNames = @(
    "android_to_main_ms",
    "main_to_target_ms",
    "total_from_android_start_ms",
    "shared_preferences_get_instance_ms",
    "android_bridge_bootstrap_ms",
    "main_bootstrap_ms",
    "home_window_storage_load_ms",
    "run_app_to_app_shell_first_ms",
    "first_frame_total_span_ms"
)

$stats = New-Object System.Collections.Generic.List[object]
foreach ($name in $metricNames) {
    $values = @(
        $runs |
            ForEach-Object { $_.$name } |
            Where-Object { $null -ne $_ } |
            ForEach-Object { [double]$_ }
    )
    $stats.Add((Get-Stats -Name $name -Values $values))
}

$meta = [pscustomobject]@{
    generated_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssK")
    package_name = $PackageName
    activity_name = $ActivityName
    activity_component = $activityComponent
    device_id = if ($DeviceId) { $DeviceId } else { "default" }
    device_model = $deviceModel
    device_fingerprint = $deviceFingerprint
    iterations_requested = $Iterations
    iterations_captured = $runs.Count
    startup_wait_seconds = $StartupWaitSeconds
}

$meta | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $runDir "meta.json") -Encoding UTF8
$runs | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $runDir "runs.json") -Encoding UTF8
$stats | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $runDir "stats.json") -Encoding UTF8
$runs | Export-Csv -LiteralPath (Join-Path $runDir "runs.csv") -NoTypeInformation -Encoding UTF8
$stats | Export-Csv -LiteralPath (Join-Path $runDir "stats.csv") -NoTypeInformation -Encoding UTF8

Write-Host ""
Write-Host "=== 启动采样统计（ms）==="
$stats | Format-Table metric, count, min, p50, p90, mean, max, stddev -AutoSize
Write-Host ""
Write-Host ("输出目录: {0}" -f $runDir)
