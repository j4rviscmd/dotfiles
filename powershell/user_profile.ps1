# ENV
# プロファイルは $PROFILE のシンボリックリンク経由で読み込まれるため、$PSScriptRoot は
# リンク側(~/Documents/PowerShell)に解決され実体を指さない。実体(= dotfiles)のディレクトリを
# 解決して repo直下の .env を参照する。
# Why: $PSScriptRoot ではシンボリックリンクの実体が追えず、.env が見つからない回帰になる。
$script:DotfilesPsDir = if ($MyInvocation.MyCommand.Path) {
    $item = Get-Item $MyInvocation.MyCommand.Path -ErrorAction SilentlyContinue
    if ($item.Target) { Split-Path $item.Target -Parent } else { Split-Path $item.FullName -Parent }
} else { $PSScriptRoot }

$env:XDG_CONFIG_HOME = "$HOME/.config"
$env:Path = "$env:USERPROFILE\.local\bin;$env:USERPROFILE\.bun\bin;$env:Path"
# シークレットは repo直下 .env (Git管理外, zsh/bashとSSOT) から一括読込
# Note: ANTHROPIC 関連は ~\.claude\settings.json でも冗長管理されている
# Note: Get-Content の行読み込みで改行(CRLF)は既に落ちるため、Trimの役目は空白・引用符除去のみ
# Note: macと形式共通のため "export KEY=value" の export プレフィックス・二重引用符・行末コメントを許容
$envFile = Join-Path $DotfilesPsDir "..\.env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match '^\s*(?:export\s+)?([A-Za-z0-9_]+)=(.*)$') {
            # Why: 行末コメントはsh語彙と同じ「空白+#」以降のみ剥がす(値内の#誤爆防止)。引用符は外側空白を先に剥がしてから除去
            Set-Item "Env:$($Matches[1])" (($Matches[2] -replace '\s+#.*$','').Trim().Trim('"').Trim())
        }
    }
} else {
    Write-Warning ".env not found: $envFile"
}

# fnm
fnm env --use-on-cd --shell powershell | Out-String | Invoke-Expression

# Prompt
Invoke-Expression (&starship init powershell)

# zoxide - スマートcd (zsh側と同じ。z <keyword> で履歴からディレクトリジャンプ)
Invoke-Expression (& { (zoxide init powershell | Out-String) })

# Terminal-Icons: lazy load after prompt appears
Register-EngineEvent -SourceIdentifier PowerShell.OnIdle -MaxTriggerCount 1 -Action {
    Import-Module Terminal-Icons
} | Out-Null

# Auto suggestions
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineKeyHandler -Key "Ctrl+f" -Function ForwardWord
Set-PSReadLineOption -EditMode Emacs

# Alias
Set-Alias grep findstr

# bash を WSL ではなく Git Bash(Windows側)に向ける。
# Why: Windows側の cargo/gh などを使うため。WSL 側にはこれらが無く release.sh が失敗するため。
# Note: WSL の bash が必要な場合は `wsl` コマンドを使う。
function bash { & "C:\Program Files\Git\bin\bash.exe" @args }
function code { coderm @args }
function ll {
    eza -lag --icons --ignore-glob=".DS_Store|.localized" --sort=type --time-style=long-iso --no-permissions $args
}

# vi/vim を Neovim に向ける（Git 付属 vi/vim でなく Neovim を使うため）
function vi { nvim @args }
function vim { nvim @args }

# Linux-like rm: accepts -r/-f/-rf/-fr flags (ignored, always force+recurse)
Remove-Item Alias:rm -Force -ErrorAction SilentlyContinue
function rm {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments)]
        [string[]]$Paths
    )
    # Filter out Linux-style flags (-r, -f, -rf, -fr, etc.)
    $items = $Paths | Where-Object { $_ -notmatch '^-([rf]+)$' }
    foreach ($p in $items) {
        try {
            Remove-Item $p -Force -Recurse -ErrorAction Stop
        } catch [System.IO.IOException] {
            if (Test-Path $p -PathType Container) {
                Write-Warning "Fallback to cmd rmdir: $p"
                cmd /c "rmdir /s /q `"$p`""
            } else { throw }
        }
    }
}

# claude wrapper: add --effort max unless explicitly given.
# psmux ペインでは --teammate-mode tmux も付与（CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 時）。
# 注: psmux 側の自動ラッパー注入は psmux.conf で claude-code-fix-tty off に設定済み。
function claude {
    $hasEffort = $false
    $hasTeammate = $false
    foreach ($a in $args) {
        if ($a -match '^--effort') { $hasEffort = $true }
        if ($a -match '^--teammate-mode') { $hasTeammate = $true }
    }
    $newArgs = @()
    if (-not $hasEffort) { $newArgs += @('--effort', 'max') }
    if (-not $hasTeammate -and $env:CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS) {
        $newArgs += @('--teammate-mode', 'tmux')
    }
    $newArgs += $args
    & claude.exe @newArgs
}

# psmux/tmux wrapper: WezTerm配下では TERM_PROGRAM/WEZTERM_PANE をクリアし、
# psmux を native input path(INPUT_RECORD) に強制する。
# Why: WezTerm を検出すると psmux は VT input path に振り分け、そこでキー処理が壊れ
#      Ctrl+J(LF) 等が子プロセスに届かなくなる(psmux/psmux#508 系)。native path なら問題ない。
#      Windows Terminal は元々 native path なので本ラッパーの影響を受けない。
# Note: VT mouse は失われるが psmux でマウスは基本使わないため許容。
function psmux {
    $old = @{ TERM_PROGRAM = $env:TERM_PROGRAM; WEZTERM_PANE = $env:WEZTERM_PANE }
    $env:TERM_PROGRAM = $null
    $env:WEZTERM_PANE = $null
    try {
        & psmux.exe @args
    } finally {
        $env:TERM_PROGRAM = $old.TERM_PROGRAM
        $env:WEZTERM_PANE = $old.WEZTERM_PANE
    }
}
# Why: cargo install で tmux.exe も PATH(~/.cargo/bin, psmux.exe と同一バイナリ)に存在し(memory: psmux-overview)、
#      直接起動すると env クリアをバイパスして WezTerm 配下の VT input バグ(Ctrl+J 不達)を引く。
#      PowerShell 関数は PATH の exe より優先されるため本関数で上書きし、クリア付き psmux 関数へ委譲する。
# Caution: 委譲先を psmux.exe に変えると env クリアが効かず、WezTerm 配下でキー処理が壊れる。
function tmux { psmux @args }

# 起動時のディレクトリ (VS Codeターミナルではワークスペースパスを優先)
# Note: psmux 内(TMUX設定済み)ではスキップし、pane_current_path の引き継ぎを優先する
if ($env:TERM_PROGRAM -ne 'vscode' -and $env:TERM_PROGRAM -ne 'coderm' -and -not $env:TMUX) {
    Set-Location E:\work
}

# psmux auto-start: デタッチ作成(ロック内) → アタッチ(ロック外)
# Why: runCommands で複数ターミナルを連続生成すると、独立した PowerShell プロセスがほぼ
#      同時に本プロファイルを実行する。psmux の next_session_name(src/session.rs) はロックを
#      持たない read-only スキャンで最小空き番号を採番するため check-then-use の race が発生し、
#      同一セッションにつながる。名前付きMutex で採番処理を直列化して防止する。
#      各ターミナルエディタは独立した PowerShell プロセス（coderm の createTerminal が毎回
#      新規シェルプロセスを起動するため）。プロセス共有説は誤り。
# Why: new-session（-d なし）はアタッチまで行い TUI でブロックする(src/main.rs の attach path)。
#      Mutex クリティカルセクション内で呼ぶとMutexを保持したまま返らず、後続プロセスが
#      30秒タイムアウトしてしまう。そのため new-session -d（デタッチ作成＝採番＋spawn のみ、
#      ブロックしない）をロック内で行い、attach-session（ブロック）をロック外で行う構成とする。
# Why: 従来の「attached=0 のゾンビセッションをkillして蓄積を防ぐ」処理は廃止した。
#      psmux の attached=0 は「クライアント未接続」だけで、真のゾンビ(死んでいる)と
#      同時起動兄弟の未attachセッション(生きている)を区別できない。同時起動時に他人の
#      未attachセッションを誤kill → 同番号再採番 → 同一セッションにつながる競合が起きる。
#      tmux のように「使用中か」を正確に判定できない以上、自動killは安全でない。
#      セッション蓄積は、重くなったら手動で psmux kill-session するか coderm 再起動で対応。
if (-not $env:TMUX) {
    $mutex = New-Object System.Threading.Mutex $false, 'Global\coderm-psmux-startup'
    $locked = $false
    $sessionName = ''
    try {
        # クリティカルセクション取得（最大30秒待機）
        # Why: 前のターミナルの採番＋spawn(~1秒)の完了を待つ。30秒はスタック検出用の余裕。
        try {
            $locked = $mutex.WaitOne(30000)
        } catch [System.Threading.AbandonedMutexException] {
            # Why: 前プロセスがMutex解放せずクラッシュ等で終了した場合、.NET のセマンティクスで
            #      例外スロー時点で所有権が本プロセスへ移転済みとなる。release 責任を持つため locked=true。
            $locked = $true
        }
        # 空き番号を採番し、即デタッチ作成して port file を立てる（非ブロック）。
        # Why: 採番だけしてMutex解放すると、後続プロセスが list-sessions で自分のセッションを
        #      認識できず同番号を採番してしまう（new-session -s の port file 作成が遅いため）。
        #      採番直後に -d -s で port file を即作れば、後続プロセスの採番に反映される。
        $existing = @(psmux list-sessions -F '#{session_name}' 2>$null)
        $n = 0
        while ($existing -contains "$n") { $n++ }
        $sessionName = "$n"
        psmux new-session -d -s $sessionName 2>$null | Out-Null
    } finally {
        if ($locked) { [void]$mutex.ReleaseMutex() }
        $mutex.Dispose()
    }
    # ロック外で、作成済みセッションにアタッチ。-A で既存ならアタッチ（なければ作成）。
    # Why: attach-session -t は psmux 側で last_session(0) にフォールバックする不具合があり
    #      使えない。new-session -A -s は自前採番名で確実に自分のセッションにアタッチできる。
    psmux new-session -A -s $sessionName
}
