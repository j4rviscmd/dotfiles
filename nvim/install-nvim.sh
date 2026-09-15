#!/usr/bin/env bash
# ============================================================
# Neovim公式stable tarballインストーラ(Linux/WSL2用)
# ============================================================
# Why: Ubuntu公式リポジトリのneovimは0.11系で止まり、本repoのnvim設定は
#      0.12前提のため、公式stable tarballを~/.local/opt配下へ展開して運用する。
#      apt版(/usr/bin/nvim)とはPATH優先で共存(zsh/.zshrc.linuxが優先設定を担当)
#
# Usage:
#   ./install-nvim.sh    # stable最新を導入(導入済みならスキップする冪等構成)
#
# 前提:
#   - curl / tar / awk
#   - x86_64環境(arm64版WSLは未想定)
# TODO: stable最新タグの取得にGitHub匿名APIを使うためレート制限(60回/h)に
#       達すると常に再展開される。問題が出たらgh api等の認証付き取得へ切り替える

set -euo pipefail

# Note: "nvim-linux-x86_64" はGitHub Releasesのアセット名・tarball展開ディレクトリ名という上游命名。
#       本スクリプト・zsh/.zshrc.linux・zsh/setup.shの3箇所が同名に依存する。
#       変更時注意: 上游がアセットをリネームしたら3箇所の同期変更が必要
#       (2026-09-15時点のstable v0.12.5でアセット名・展開ディレクトリ名を確認)
INSTALL_ROOT="$HOME/.local/opt"
INSTALL_DIR="$INSTALL_ROOT/nvim-linux-x86_64"
TARBALL_URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
API_URL="https://api.github.com/repos/neovim/neovim/releases/latest"

# 展開一時域を導入先と同じファイルシステム上に取り、置換mvを原子化する
mkdir -p "$INSTALL_ROOT"
TMP_DIR=$(mktemp -d "$INSTALL_ROOT/.nvim-install.XXXXXX")
trap 'rm -rf "$TMP_DIR"' EXIT

# stable最新タグ取得(失敗時はunknownとし、スキップ判定と検証を無効化して続行)
latest=$(curl -sfL "$API_URL" | awk -F'"' '/"tag_name"/ {print $4; exit}' || true)
[ -n "$latest" ] || latest="unknown"

# 冪等: 導入済みバージョンと同一なら何もしない
if [ -x "$INSTALL_DIR/bin/nvim" ]; then
  current=$("$INSTALL_DIR/bin/nvim" --version | awk 'NR==1 {print $2}')
  if [ "$current" = "$latest" ]; then
    echo "✔ 導入済み: Neovim $current (stable最新)"
    exit 0
  fi
  echo "✚ 更新: $current → $latest"
else
  echo "✚ 新規導入: stable ($latest)"
fi

# tarball取得・展開
echo "→ ダウンロード: $TARBALL_URL"
curl -fL "$TARBALL_URL" -o "$TMP_DIR/nvim.tar.gz"
tar -xzf "$TMP_DIR/nvim.tar.gz" -C "$TMP_DIR"

extracted="$TMP_DIR/nvim-linux-x86_64/bin/nvim"
[ -x "$extracted" ] || { echo "❌ 展開結果にbin/nvimが存在しません"; exit 1; }

# 展開物のバージョン検証(API失敗時は検証できないため省略)
installed_ver=$("$extracted" --version | awk 'NR==1 {print $2}')
if [ "$latest" != "unknown" ] && [ "$installed_ver" != "$latest" ]; then
  echo "❌ バージョン不一致: 展開物=$installed_ver 期待=$latest"
  exit 1
fi

# 旧導入分を退避してから置換し、最後に退避分を破棄
if [ -d "$INSTALL_DIR" ]; then
  rm -rf "$INSTALL_DIR.old"
  mv "$INSTALL_DIR" "$INSTALL_DIR.old"
fi
mv "$TMP_DIR/nvim-linux-x86_64" "$INSTALL_DIR"
rm -rf "$INSTALL_DIR.old"

echo "✅ 導入完了: Neovim $installed_ver → $INSTALL_DIR/bin/nvim"
echo "   実行バイナリは .zshrc.linux のPATH設定でapt版(/usr/bin/nvim)より優先される"
