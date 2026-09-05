# ============================================================
# zsh設定ファイル
# ============================================================
# ctrl + d で終了しないように設定（10回連続で押すと終了）
export IGNOREEOF=10
# Claude Codeのツール検索を有効化
export ENABLE_TOOL_SEARCH=true
export ENABLE_EXPERIMENTAL_MCP_CLI=false
# export DISCORD_WEBHOOK_COMPLETE_INCLUDE_LAST_MESSAGE=0


# ============================================================
# OS固有設定の読み込み（Homebrew, antidote等）
# ============================================================
case "$OSTYPE" in
  darwin*)  [ -f ~/.zshrc.darwin ] && source ~/.zshrc.darwin ;;
  linux*)   [ -f ~/.zshrc.linux ] && source ~/.zshrc.linux ;;
esac

# ============================================================
# antidote プラグイン静的ロード（高速化）
# ============================================================
zsh_plugins=${ZDOTDIR:-~}/.zsh_plugins
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi
source ${zsh_plugins}.zsh

# ============================================================
# 補完: smartcase風の大文字小文字マッチ
# Why: 小文字入力は大文字始まりファイルにもマッチ、大文字入力は
#      厳格一致にする(nvimのsmartcaseと同じ挙動)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ============================================================
# zoxide - スマートcd
# ============================================================
zsh-defer eval "$(zoxide init zsh)"

# ============================================================
# Starship プロンプト（プロンプト定義のため即時eval必須）
# ============================================================
eval "$(starship init zsh)"

# ============================================================
# ターミナルウィンドウタイトル設定
# ============================================================
function set_win_title(){
    # プロジェクト名(非gitの場合は、ディレクトリ名)をタイトルに設定
    # echo -ne "\033]0; $(basename $(git rev-parse --show-toplevel 2>/dev/null || echo $PWD)) \007"
    # null文字
    echo -ne "\033]0;\007"
}
precmd_functions+=(set_win_title)

# ============================================================
# Ghostty shell integration (OSC 7 送出)
# Why: ghostty-integration は Ghostty が直接起動したシェルでしか自動読み込み
#      されず、tmux 内では動かない。GHOSTTY_RESOURCES_DIR は tmux 配下にも
#      伝播するため、公式ドキュメント推奨の手動 source で対応する。
#      OSC 7 (kitty-shell-cwd://) の CWD 報告により、tmux の
#      pane_current_path も解決される。
# NOTE: Ghostty 起動外のシェルでは GHOSTTY_RESOURCES_DIR が空のため何もしない
#      (Linux も Ghostty が同変数を設定するため OS 分岐不要)
if [[ -n "$GHOSTTY_RESOURCES_DIR" && -r "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration" ]]; then
  source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"
fi

# ============================================================
# 基本PATH設定
# ============================================================
export PATH="$HOME/.local/bin:$PATH"

# ============================================================
# エディタとXDG設定
# ============================================================
export EDITOR=code
export XDG_CONFIG_HOME="$HOME/.config"
# tmux 外でのみ TERM を設定（tmux 内は tmux.conf の tmux-256color を使用）
[[ -z "$TMUX" ]] && export TERM=xterm-256color

# ============================================================
# eza配色設定 (Solarized Dark)
# ============================================================
# Solarized Dark カラースキーム
# ディレクトリ=青(34)、実行ファイル=緑(32)、シンボリックリンク=シアン(36)
# アーカイブ=赤(31)、画像=マゼンタ(35)、音声/動画=マゼンタ(35)
export LS_COLORS="di=34:ln=36:so=35:pi=33:ex=32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43:*.tar=31:*.tgz=31:*.arc=31:*.arj=31:*.taz=31:*.lha=31:*.lz4=31:*.lzh=31:*.lzma=31:*.tlz=31:*.txz=31:*.tzo=31:*.t7z=31:*.zip=31:*.z=31:*.dz=31:*.gz=31:*.lrz=31:*.lz=31:*.lzo=31:*.xz=31:*.zst=31:*.tzst=31:*.bz2=31:*.bz=31:*.tbz=31:*.tbz2=31:*.tz=31:*.deb=31:*.rpm=31:*.jar=31:*.war=31:*.ear=31:*.sar=31:*.rar=31:*.alz=31:*.ace=31:*.zoo=31:*.cpio=31:*.7z=31:*.rz=31:*.cab=31:*.wim=31:*.swm=31:*.dwm=31:*.esd=31:*.jpg=35:*.jpeg=35:*.mjpg=35:*.mjpeg=35:*.gif=35:*.bmp=35:*.pbm=35:*.pgm=35:*.ppm=35:*.tga=35:*.xbm=35:*.xpm=35:*.tif=35:*.tiff=35:*.png=35:*.svg=35:*.svgz=35:*.mng=35:*.pcx=35:*.mov=35:*.mpg=35:*.mpeg=35:*.m2v=35:*.mkv=35:*.webm=35:*.webp=35:*.ogm=35:*.mp4=35:*.m4v=35:*.mp4v=35:*.vob=35:*.qt=35:*.nuv=35:*.wmv=35:*.asf=35:*.rm=35:*.rmvb=35:*.flc=35:*.avi=35:*.fli=35:*.flv=35:*.gl=35:*.dl=35:*.xcf=35:*.xwd=35:*.yuv=35:*.cgm=35:*.emf=35:*.ogv=35:*.ogx=35:*.aac=35:*.au=35:*.flac=35:*.m4a=35:*.mid=35:*.midi=35:*.mka=35:*.mp3=35:*.mpc=35:*.ogg=35:*.ra=35:*.wav=35:*.oga=35:*.opus=35:*.spx=35:*.xspf=35"

# ezaの各カラム用Solarized Dark配色
# uu=ユーザー名(yellow:136), gu=グループ名(orange:166), da=日付(cyan:37)
# sn=ファイルサイズ数値(green:64), sb=ファイルサイズ単位(green:64)
# ur/uw/ux=ユーザー権限(base1:245), gr/gw/gx=グループ権限(base0:244)
# tr/tw/tx=その他権限(base01:240), xx=区切り文字(base01:240)
export EZA_COLORS="$LS_COLORS:uu=38;5;136:gu=38;5;166:da=38;5;37:sn=38;5;64:sb=38;5;64:ur=38;5;245:uw=38;5;245:ux=38;5;245:ue=38;5;245:gr=38;5;244:gw=38;5;244:gx=38;5;244:tr=38;5;240:tw=38;5;240:tx=38;5;240:xx=38;5;240"

# ============================================================
# Flutter/Dart設定
# ============================================================
[[ -d "$HOME/work/software/flutter" ]] && export PATH="$HOME/work/software/flutter/bin:$HOME/work/software/flutter/.pub-cache/bin:$PATH"
[[ -d "$HOME/.pub-cache/bin" ]] && export PATH="$HOME/.pub-cache/bin:$PATH"

# ============================================================
# bun設定
# ============================================================
export PATH="$HOME/.bun/bin:$PATH"

# ============================================================
# Rust (Cargo)設定
# ============================================================
export PATH="$HOME/.cargo/bin:$PATH"

# ============================================================
# 認証情報・API Keys
# ============================================================
# 以下の環境変数は ~/.config/.env (repo直下.env) に記述してください
# 雛形: .env.sample
# export CONTEXT7_API_KEY="your_context7_api_key"
# export GH_MCP_TOKEN="your_github_token"

# ============================================================
# Discord Webhook設定
# ============================================================
# 以下の環境変数は ~/.config/.env (repo直下.env) に記述してください
# export DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/..."
# export DISCORD_WEBHOOK_COMPLETE_MENTION="@everyone"
# export DISCORD_WEBHOOK_PERMISSION_MENTION="@everyone"
# export DISCORD_WEBHOOK_FALLBACK_URL="https://discord.com/api/webhooks/..."
#
# ============================================================
# ClaudeCode設定
# ============================================================
# export ANTHROPIC_AUTH_TOKEN=your_anthropic_api_key_here
# export ANTHROPIC_BASE_URL=https://hoge.com
# export ANTHROPIC_MODEL=""
# export ANTHROPIC_DEFAULT_OPUS_MODEL=""
# export ANTHROPIC_DEFAULT_SONNET_MODEL=""
# export ANTHROPIC_DEFAULT_HAIKU_MODEL=""


# ============================================================
# エイリアス
# ============================================================
alias vi='nvim'
alias vim='nvim'
alias code='coderm'

# ============================================================
# カスタム関数
# ============================================================
# cc -> claude コマンドのエイリアス
# 【注意】コメントアウト中
# 理由: ccはUnix/macOSにおけるCコンパイラのコマンド名と衝突する
# ビルドツールが裏でccを呼ぶたびにClaude Codeが起動し、
# PCがハングする原因になる。参照: https://zenn.dev/owayo/articles/6190821ac1dd1e
# function cc() {
#   command claude "$@"
# }

# oc -> opencode コマンドのエイリアス
# 【注意】コメントアウト中
# 理由: ccエイリアスと統一するため（ccはCコンパイラと衝突するため無効化）
# oc自体は既存コマンドと衝突しないが、短縮エイリアス運用を中止
# function oc() {
#   command opencode "$@"
# }

# opencode - Ctrl+Fのzsh-autosuggestions競合を回避して起動
function opencode() {
  # Ctrl+Fのバインドを一時的に解除（zsh-autosuggestionsが使用）
  bindkey -r '^F' 2>/dev/null
  
  # opencode実行
  command opencode "$@"
  local exit_code=$?
  
  # Ctrl+Fのバインドを復元（forward-char = サジェスト受け入れ）
  bindkey '^F' forward-char 2>/dev/null
  
  return $exit_code
}

# claude - 常に --effort max を付与して起動
# ユーザーが明示的に --effort を指定した場合はそれを尊重
function claude() {
  if [[ " $* " == *" --effort "* || " $* " == *" --effort="* ]]; then
    command claude "$@"
  else
    command claude --effort max "$@"
  fi
}

# ll - ezaベースのlsコマンド
# Oh-My-Zshのllエイリアスを削除
unalias ll 2>/dev/null
function ll() {
  EXA_ICON_SPACING=2 eza -l -a -g --icons --ignore-glob=".DS_Store|.localized" --sort=type --time-style=long-iso --no-permissions "$@"
}

# clear - tmux内ではscrollback履歴もクリア
function clear() {
  command clear && command clear
  [[ -n "$TMUX" ]] && command tmux clear-history
}

# tmux - 引数なし: カレントディレクトリ名に基づくセッション選択メニューを表示
#         --all:   全セッションを最終アタッチ時刻順で表示
#         その他:  tmux コマンドをそのまま実行
# 選択肢1番目は New session、以降は既存セッション一覧
# 【注意】以下の関数はコメントアウト中（論理削除）
# 理由: セッション開始時の選択メニューと {ディレクトリ名}-N 採番を廃止し、
#       デフォルトtmuxの挙動（既存セッションへアタッチ、なければ0からの連番で
#       自動採番）へ戻すため。復元時は各行頭の # を外せば元に戻る。
# function tmux() {
#   local show_all=false
#   if [[ "$1" == "--all" ]]; then
#     show_all=true
#     shift
#   fi
#
#   # 引数があれば素通し
#   if [[ $# -gt 0 ]]; then
#     command tmux "$@"
#     return
#   fi
#
#   local base_name sanitized_dir base n new_session_name selected session_name key
#   local -a existing_sessions
#   local -A session_info_map  # name -> "Nw" display string
#
#   # カレントディレクトリのベース名を取得
#   base_name="$(basename -- "$PWD")"
#
#   # tmux のセッション名として使いやすい形へ正規化
#   # - 英数字/アンダースコア/ハイフン以外は '_' に置換
#   # - 連続する区切りは1つにまとめる
#   # - 先頭/末尾の '_' は除去
#   sanitized_dir="$(printf '%s' "$base_name" \
#     | tr -cs '[:alnum:]_-' '_' \
#     | sed -e 's/^_//' -e 's/_$//')"
#
#   base="${sanitized_dir:-workspace}"
#
#   # 既存セッションを収集
#   # --all: 全セッションを最終アタッチ時刻順（新しい順）で表示
#   # デフォルト: {base}-N セッションのみ（クライアントなしは自動破棄）
#   existing_sessions=()
#   local s s_attached s_last_attached elapsed ago now sessions_raw sorted_sessions
#   now=$(date +%s)
#   sessions_raw=$(command tmux list-sessions -F '#{session_name} #{session_attached} #{session_last_attached}' 2>/dev/null)
#   if $show_all; then
#     sorted_sessions=$(printf '%s\n' "$sessions_raw" | sort -k3 -rn)
#   else
#     sorted_sessions=$(printf '%s\n' "$sessions_raw" | grep -E "^${base}-[0-9]+ " | sort -t- -k2 -n)
#   fi
#   while IFS=' ' read -r s s_attached s_last_attached; do
#     [[ -z "$s" ]] && continue
#     if [[ "$s_attached" -gt 0 ]]; then
#       existing_sessions+=("$s")
#       # 最終アクティブからの経過時間
#       elapsed=$(( now - s_last_attached ))
#       if   (( elapsed < 60  )); then ago="${elapsed}s ago"
#       elif (( elapsed < 3600 )); then ago="$(( elapsed / 60 ))min ago"
#       else                          ago="$(( elapsed / 3600 ))h ago"
#       fi
#       session_info_map[$s]="${s_attached} client  ${ago}"
#     else
#       ! $show_all && command tmux kill-session -t "=$s" 2>/dev/null
#     fi
#   done <<< "$sorted_sessions"
#
#   # ゾンビ破棄後に次の空き番号を計算
#   n=0
#   while command tmux has-session -t "=${base}-${n}" 2>/dev/null; do
#     (( n++ ))
#   done
#   new_session_name="${base}-${n}"
#
#   # インタラクティブ選択
#   if command -v fzf &>/dev/null; then
#     # "key\tdisplay" 形式でfzfに渡し、--with-nth=2 で表示部分のみ見せる
#     local fzf_lines
#     fzf_lines="__new__\t  ✦  [New]  ${new_session_name}"
#     for s in "${existing_sessions[@]}"; do
#       fzf_lines+="\n${s}\t  ${s}    ${session_info_map[$s]}"
#     done
#     selected=$(printf "%b" "$fzf_lines" \
#       | fzf --prompt="tmux${show_all:+ (all)} > " --height=~12 --no-sort --layout=reverse \
#             --delimiter=$'\t' --with-nth=2)
#     key=$(printf '%s' "$selected" | cut -f1)
#   else
#     echo "Select tmux session:"
#     local -a menu_items=("[New] ${new_session_name}" "${existing_sessions[@]}")
#     select selected in "${menu_items[@]}"; do
#       [[ -n "$selected" ]] && break
#     done
#     # select uses display values directly
#     if [[ "$selected" == "[New]"* ]]; then
#       key="__new__"
#     else
#       key="$selected"
#     fi
#   fi
#
#   # キャンセル
#   [[ -z "$key" ]] && return 0
#
#   if [[ "$key" == "__new__" ]]; then
#     # 新規セッションをバックグラウンドで作成（競合時は番号をインクリメントしてリトライ）
#     session_name="$new_session_name"
#     local retry=0
#     while ! TMUX='' command tmux new-session -d -s "$session_name" 2>/dev/null; do
#       (( retry++ ))
#       if (( retry > 9 )); then
#         echo "🚨 tmux: could not create session after $retry retries" >&2
#         return 1
#       fi
#       session_name="${base}-$(( n + retry ))"
#     done
#   else
#     # 既存セッションへ接続
#     session_name="$key"
#   fi
#
#   # VSCode統合ターミナルではステータスラインを非表示
#   # attach前に設定（attachはブロッキングなため、後だと実行されない）
#   if [[ "${TERM_PROGRAM:-}" == "vscode" ]]; then
#     command tmux set-option -t "$session_name" status off 2>/dev/null
#   fi
#
#   # 接続
#   if [ -n "${TMUX:-}" ]; then
#     command tmux switch-client -t "=$session_name"
#   else
#     command tmux attach -t "=$session_name"
#   fi
# }

# ============================================================
# 秘匿環境変数（SSOT: repo直下 .env を~/.config symlink経由で読込）
# ============================================================
# .env に機密情報や環境固有の設定を記述（雛形: .env.sample）
[ -f ~/.config/.env ] && source ~/.config/.env
zsh-defer eval "$(fnm env --use-on-cd --version-file-strategy=recursive)"

# opencode は ~/.bun/bin/opencode としてインストール済み（PATH は bun 設定で追加済み）
# export PATH=/home/user/.opencode/bin:$PATH

# copilot: default to --yolo --model claude-opus-4.6 --resume when no args
copilot() {
  if [[ $# -eq 0 ]]; then
    # --no-alt-screen
    # --model claude-sonnet-4.6
    # --model claude-opus-4.6
    command copilot --banner --yolo --model claude-opus-4.6 --effort high --resume
  else
    command copilot "$@"
  fi
}

# ============================================================
# tmux 自動起動
# ============================================================
# Why: [[ -t 0 ]] (stdin の TTY チェック) は VSCode のシェル環境変数解決が
#      パイプ経由で実行されるため。このガードがないと非対話呼び出しでも tmux が
#      起動し、環境解決がブロックされていた（commit c4a4b84）
if [[ -z "$TMUX" ]] && [[ -t 0 ]] && command -v tmux &>/dev/null; then
  # Note: 判定対象は使用環境の VSCode 系ターミナルが設定する TERM_PROGRAM 値。
  #       Coderm は GUI アプリ側（commit 359656b）。vscodeee の由来は commit 7296ed8
  #       に説明がなく未確認
  if [[ "${TERM_PROGRAM:-}" == vscode || "${TERM_PROGRAM:-}" == vscodeee || "${TERM_PROGRAM:-}" == Coderm ]]; then
    # VSCode統合ターミナルでは常に新規セッションを自動作成
    # フォールバック: tmux profile 使用時は $TMUX が既にセット済みのため本ブロックは
    # スキップされ、代わりに tmux/scripts/vscode-new-session.sh が命名を担う。
    # tmux profile が機能せず zsh が直接起動された場合のみここへ到達する。
    _base_name="$(basename -- "$PWD")"
    _sanitized="$(printf '%s' "$_base_name" | tr -cs '[:alnum:]_-' '_' | sed -e 's/^_//' -e 's/_$//')"
    _base="${_sanitized:-workspace}"
    # クライアントなしのゾンビセッションを破棄
    _sessions_raw=$(command tmux list-sessions -F '#{session_name} #{session_attached}' 2>/dev/null)
    while IFS=' ' read -r _s _s_attached; do
      [[ -z "$_s" ]] && continue
      [[ "$_s" =~ ^${_base}-[0-9]+$ ]] || continue
      (( _s_attached == 0 )) && command tmux kill-session -t "=$_s" 2>/dev/null
    done <<< "$_sessions_raw"
    # 空き番号を採番
    _n=0
    while command tmux has-session -t "=${_base}-${_n}" 2>/dev/null; do
      (( _n++ ))
    done
    _session="${_base}-${_n}"
    # 同時起動の衝突確率を下げるランダムジッター (0-99ms)
    sleep "0.0$(( RANDOM % 100 ))"
    # new-session失敗時は番号をインクリメントしてリトライ
    _retry=0
    while ! command tmux new-session -d -s "$_session" 2>/dev/null; do
      (( _retry++ ))
      if (( _retry > 9 )); then
        echo "tmux: auto-start failed after $_retry retries" >&2
        return 1
      fi
      _session="${_base}-$(( _n + _retry ))"
    done
    # Why: VSCode統合ターミナルではステータスラインを非表示化する。tmux.conf の %if は
    #      サーバー起動時にしか評価されず共有サーバーでは信頼できないため、セッション単位で
    #      設定する方式にしている（commit c4a4b84）
    # Constraint: attach はブロッキングするため、この設定は必ず attach より前に実行すること
    #             （コメントアウト中の tmux 関数内の同名処理と同理由）
    command tmux set-option -t "$_session" status off 2>/dev/null
    command tmux attach -t "=$_session"
  else
    # 【注意】セッション選択メニュー(上記tmux関数)はコメントアウト中（論理削除）
    # 理由: セッション開始時の選択メニューと {ディレクトリ名}-N 採番を廃止し、
    #       デフォルトtmuxの挙動（既存セッションへアタッチ、なければ0からの
    #       連番で自動採番）へ戻すため。復元時は下のゾンビ破棄を削除して
    #       tmux のコメントを外し、tmux関数本体を復元すること。
    # ゾンビ破棄のみ現行仕様を継続: クライアントなしセッションを全て自動破棄
    # Why: tmuxセッションはサーバーのメモリ上にのみ存在しマシン再起動で消滅する運用
    #      （resurrect 等の永続化は不使用）のため、クライアントなしセッションを
    #      保持せず全破棄としている（本変更の設計判断）
    # Caution: デタッチ中のセッションで実行中のプロセスも kill される。
    #          永続化運用へ切り替える場合はこの破棄を削除すること
    _zombie_sessions=$(command tmux list-sessions -F '#{session_name} #{session_attached}' 2>/dev/null)
    while IFS=' ' read -r _zs _za; do
      [[ -z "$_zs" ]] && continue
      (( _za == 0 )) && command tmux kill-session -t "=$_zs" 2>/dev/null
    done <<< "$_zombie_sessions"
    # tmux
    command tmux
  fi
fi

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
