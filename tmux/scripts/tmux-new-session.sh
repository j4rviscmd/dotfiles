#!/usr/bin/env bash
# tmux セッション起動スクリプト（Windows Terminal / VSCode/Coderm ターミナルプロファイル用）
#
# Why: tmux terminal profile 使用時、セッション名を指定しないと tmux が数字の
#      デフォルト名（1, 2, 53...）を付けてしまう。{base名}-N の連番セッション名を
#      生成してアタッチする。
# How: 第1引数に base 名（WT は main、VSCode系は ${workspaceFolderBasename}）を受け取り、
#      セッション名を正規化して空き番号を採番し、new-session -d で作成後 attach する。
#
# NOTE: Windows Terminal の "Ubuntu (tmux)" プロファイルから共用（base名 main で呼出）。
#       status line は常に表示（tmux.conf / statusline.conf の設定に従う）。
# Why: -e を外している。has-session の存在確認（非0でループを抜ける）や kill-session の
#      失敗を 2>/dev/null / || true で個別に握りつぶす箇所が多用されており、-e があると
#      それらで即終了してしまうため。エラーは各コマンド単位で明示的にハンドリングする。
set -uo pipefail

# tmux コマンドを確実に見つける（PATH 補強）
# Why: Coderm を GUI 起動し terminal.integrated.inheritEnv=false の環境では、
#      profile 起動スクリプトの PATH に /opt/homebrew/bin 等が含まれず、
#      tmux が command not found になり new-session が延々失敗する。
if ! command -v tmux &>/dev/null; then
  for _p in /opt/homebrew/bin /usr/local/bin; do
    if [[ -x "$_p/tmux" ]]; then
      export PATH="$_p:$PATH"
      break
    fi
  done
fi
unset _p 2>/dev/null || true
if ! command -v tmux &>/dev/null; then
  echo "tmux-new-session: tmux not found in PATH (PATH=$PATH)" >&2
  exit 1
fi

# 第1引数: ワークスペース名（${workspaceFolderBasename}）
base_raw="${1:-}"

# tmux のセッション名として使いやすい形へ正規化
# - 英数字/アンダースコア/ハイフン以外は '_' に置換
# - 連続する区切りは1つにまとめる
# - 先頭/末尾の '_' は除去
base="$(printf '%s' "$base_raw" \
  | tr -cs '[:alnum:]_-' '_' \
  | sed -e 's/^_//' -e 's/_$//')"
base="${base:-workspace}"

# Why: 本スクリプトは起動のたびに新規セッションを作る設計のため、前回の未アタッチ
#      セッションを放置するとゴミが蓄積する（tmux/README.md scripts/節の設計記述）。
#      tmux サーバーは WT(main) と Coderm の他ワークスペースと共用のため、
#      同一 base の連番セッションのみを破棄対象にする
# クライアントなしのゾンビセッション（同一 base のもの）を破棄
sessions_raw="$(tmux list-sessions -F '#{session_name} #{session_attached}' 2>/dev/null || true)"
while IFS=' ' read -r s s_attached; do
  [[ -z "$s" ]] && continue
  [[ "$s" =~ ^${base}-[0-9]+$ ]] || continue
  (( s_attached == 0 )) && tmux kill-session -t "=$s" 2>/dev/null || true
done <<< "$sessions_raw"

# Note: -t "=名前" は tmux target-session の完全一致指定。'=' 無しでは 'main-1' が
#       接頭辞一致で 'main-10' にも合致する仕様（tmux(1) man）のため、採番・破棄・
#       attach で別セッションを誤参照する恐れがある。全箇所で '=' を付ける
# 空き番号を採番
n=0
while tmux has-session -t "=${base}-${n}" 2>/dev/null; do
  n=$((n + 1))
done

# 同時起動の衝突確率を下げるランダムジッター (0-99ms)
sleep "0.0$(( RANDOM % 100 ))" 2>/dev/null || true

# セッション作成（衝突時は番号をインクリメントしてリトライ）
session="${base}-${n}"
retry=0
while ! tmux new-session -d -s "$session" 2>/dev/null; do
  retry=$((retry + 1))
  # Constraint: リトライ上限 9（旧 .zshrc VSCode用自動起動ブロックと同じ値。参照元は削除済み）
  if (( retry > 9 )); then
    echo "tmux-new-session: failed to create '$session' after $retry retries (tmux=$(command -v tmux))" >&2
    exit 1
  fi
  session="${base}-$((n + retry))"
done

# アタッチ（フォアグラウンド）
exec tmux attach -t "=$session"
