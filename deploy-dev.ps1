[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Server,

    [string]$User = "",

    [string]$RemotePath = "/home/projects/Luotopia",

    [string]$Branch = "main",

    [ValidateSet("Go", "Docker")]
    [string]$Mode = "Go",

    [int]$HealthTimeoutSeconds = 60,

    [switch]$SkipPush
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Invoke-Git {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    & git @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') 执行失败，退出码：$LASTEXITCODE"
    }
}

function Assert-SafeRemoteValue {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$Value,

        [Parameter(Mandatory = $true)]
        [string]$Pattern
    )

    if ($Value -notmatch $Pattern) {
        throw "$Name 包含脚本未支持的字符：$Value"
    }
}

Assert-SafeRemoteValue -Name "Branch" -Value $Branch -Pattern "^[A-Za-z0-9._/-]+$"
Assert-SafeRemoteValue -Name "RemotePath" -Value $RemotePath -Pattern "^/[A-Za-z0-9._/-]+$"

$insideWorkTree = (& git rev-parse --is-inside-work-tree).Trim()
if ($LASTEXITCODE -ne 0 -or $insideWorkTree -ne "true") {
    throw "请在 Luotopia 仓库根目录运行此脚本。"
}

if (-not $SkipPush) {
    $dirtyFiles = & git status --porcelain
    if ($LASTEXITCODE -ne 0) {
        throw "无法检查本地 Git 状态。"
    }
    if ($dirtyFiles) {
        throw "本地还有未提交改动。请先提交，或确认不需要推送后使用 -SkipPush。"
    }

    Write-Host "推送当前 HEAD 到 origin/$Branch ..."
    Invoke-Git -Arguments @("push", "origin", "HEAD:$Branch")
}

if ([string]::IsNullOrWhiteSpace($User)) {
    $target = $Server
}
else {
    $target = "${User}@${Server}"
}

$remoteScript = @"
set -euo pipefail

cd "$RemotePath"

if [ -f "Luotopia-server/docker-compose.dev.yml" ]; then
  cd "Luotopia-server"
  docker compose -f docker-compose.dev.yml --profile app stop server migrate || true
  cd ..
fi

git fetch origin "$Branch"
git checkout "$Branch"
git pull --ff-only origin "$Branch"

cd "Luotopia-server"

case "$Mode" in
  Go)
    STATE_DIR="/tmp/luotopia-deploy"
    PID_FILE="`$STATE_DIR/luotopia-server.pid"
    LOG_FILE="`$STATE_DIR/luotopia-server.log"

    mkdir -p "`$STATE_DIR"
    if [ -f "`$PID_FILE" ]; then
      existing_pid="`$(cat "`$PID_FILE")"
      if [ -n "`$existing_pid" ] && kill -0 "`$existing_pid" 2>/dev/null; then
        kill "`$existing_pid"
        for _ in `$(seq 1 10); do
          if ! kill -0 "`$existing_pid" 2>/dev/null; then
            break
          fi
          sleep 1
        done
      fi
      rm -f "`$PID_FILE"
    fi

    docker compose -f docker-compose.dev.yml up -d postgres redis
    go run ./cmd/migrate
    nohup go run ./cmd/server > "`$LOG_FILE" 2>&1 &
    echo `$! > "`$PID_FILE"
    docker compose -f docker-compose.dev.yml ps
    ;;
  Docker)
    docker compose -f docker-compose.dev.yml --profile app up -d --build --force-recreate
    docker compose -f docker-compose.dev.yml --profile app ps
    ;;
esac

for _ in `$(seq 1 $HealthTimeoutSeconds); do
  if curl -fsS http://127.0.0.1:8080/healthz; then
    echo
    echo "healthz ok"
    exit 0
  fi
  sleep 1
done

if [ "$Mode" = "Go" ]; then
  tail -n 120 /tmp/luotopia-deploy/luotopia-server.log
else
  docker compose -f docker-compose.dev.yml --profile app logs --tail=120 server
fi
exit 1
"@

Write-Host "连接 $target 并以 $Mode 模式部署 $Branch ..."
$remoteScript | ssh $target "bash -s"
if ($LASTEXITCODE -ne 0) {
    throw "远端部署失败，退出码：$LASTEXITCODE"
}

Write-Host "部署完成。"
