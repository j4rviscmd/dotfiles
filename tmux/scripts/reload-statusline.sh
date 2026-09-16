#!/usr/bin/env bash
# tmux client-attached フックから呼ばれる statusline 再読込スクリプト
#
# Why 存在するか: statusline.conf の再読込は set -g status-right を上書きし、
#   tmux-continuum が autosave 用に status-right へ prepend した #(...) フックを
#   消してしまう (continuum README Known Issues 参照)。本スクリプトは再読込後に
#   continuum 本体と同一文字列のフックを冪等に再埋込して autosave 継続を担保する
set -euo pipefail

tmux source-file "${HOME}/.config/tmux/statusline.conf"

# continuum 本体 (continuum.tmux の add_resurrect_save_interpolation) と同一の
# interpolation 文字列 (絶対パス) を prepend する
save_hook="#(${HOME}/.local/share/tmux/plugins/tmux-continuum/scripts/continuum_save.sh)"
current="$(tmux show-option -gv status-right)"
if [[ "$current" != *"continuum_save.sh"* ]]; then
  tmux set-option -g status-right "${save_hook}${current}"
fi
