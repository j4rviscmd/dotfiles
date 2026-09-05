#!/usr/bin/env bash
# tmuxセッション切替スクリプト (bind s / display-popup から呼ばれる)
# Why: tmux標準の choose-tree (prefix s のデフォルト) は各セッションの作業ディレクトリが
#      分からないため、pane_current_path を表示して fzf で切替先を選択できるようにしている
# Note: .zshrc の ts 関数(commit 4eebfa5)をキーバインドへ移設したもの。zshrc側のts関数は
#       本変更で削除済みのため、zshrcへ再実装しないこと
set -uo pipefail

# Why: fzf未導入環境ではポップアップが一瞬で閉じて何も分からなくなるため、
#      bind r の "Reloaded!" と同じ status line メッセージ領域へ案内を出す
if ! command -v fzf >/dev/null 2>&1; then
  tmux display-message -c "#{client_name}" "fzf not installed. brew install fzf"
  exit 1
fi

# Why: awk -v s={1} は {1} を非クォート位置に置く意図的設計。fzfはプレースホルダを
#      'セッション名' のようにシングルクォート付きで置換するため、そのクォートをそのまま
#      shのクォートとして機能させている（"s={1}" と囲むとクォート文字が awk の s に混入して
#      不一致→プレビューが空になる。置換仕様は man fzf の PLACEHOLDERS 参照）
# Why: awk の "\$1==s" の \$ は、fzfプレビューが sh -c で実行されるため $1 のシェル展開を
#      防ぐ意図的エスケープ
# Why: Windows(psmux)ではfzfのpreview実行シェルが SHELL 環境変数依存で cmd に解決される
#      ことがあり、その場合 sh 用エスケープ(\$)とプレースホルダのシングルクォートが
#      解釈されず awk が壊れる。--with-shell で Git Bash を強制し sh 実行に統一する。
#      パスは strings.Fields で分割されるためスペース不可 → 8.3短縮パス (PROGRA~1) を使う。
#      psmux.conf側の bin\bash.exe がshimなのに対し、ここは実体の usr\bin 側を直接指定
if [[ "$(uname -s)" =~ ^(MINGW|MSYS) ]]; then
  fzf_opts=(--with-shell 'C:\PROGRA~1\Git\usr\bin\bash.exe -c')
fi
# Why: Mac標準bash 3.2は set -u 下での空配列展開 "${fzf_opts[@]}" を unbound variable
#      エラーにする(4.4で修正)ため、空時は展開自体をスキップする旧来のイディオムを使う
selected="$(tmux list-sessions -F '#{session_name}|#{pane_current_path}' \
  | sed "s|$HOME|~|" \
  | fzf --prompt='tmux> ' --layout=reverse --exit-0 --delimiter='|' --with-nth=2 ${fzf_opts[@]+"${fzf_opts[@]}"} \
        --preview 'tmux list-panes -a -F "#{session_name}|#{pane_current_path}" | awk -F"|" -v s={1} "\$1==s" | sed "s|$HOME|~|" | sort' \
        --preview-window=down,50% \
  | cut -d'|' -f1)"

[[ -z "$selected" ]] && exit 0
tmux switch-client -t "$selected"
