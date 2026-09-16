#!/usr/bin/env bash
# ============================================================
# tmux plugin セットアップスクリプト
# ============================================================
# tmux-resurrect / tmux-continuum を冪等にインストールする
# (未導入ならclone、導入済みなら最新化)
#
# Usage:
#   ./setup.sh
#
# Why repo外 (~/.local/share/tmux/plugins): ~/.config は本dotfiles repoの
#   実体へのsymlinkのため、~/.config/tmux/plugins へ置くと nested git repo
#   (tpm/plugins各々の.git) が repo 内に出来てしまう
# Why clone方式: プラグインは2つのみでTPMを入れる管理要素が過剰なため。
#   更新は本スクリプト再実行 (git pull)

set -euo pipefail

PLUGIN_DIR="${HOME}/.local/share/tmux/plugins"

clone_or_pull() {
  local repo_url="$1" dest="$2"
  if [[ -d "${dest}/.git" ]]; then
    echo "Updating ${dest##*/} ..."
    git -C "$dest" pull --ff-only
  else
    mkdir -p "$PLUGIN_DIR"
    echo "Cloning ${dest##*/} ..."
    git clone "$repo_url" "$dest"
  fi
}

clone_or_pull https://github.com/tmux-plugins/tmux-resurrect.git "${PLUGIN_DIR}/tmux-resurrect"
clone_or_pull https://github.com/tmux-plugins/tmux-continuum.git "${PLUGIN_DIR}/tmux-continuum"

echo "tmux plugins ready: ${PLUGIN_DIR}"
