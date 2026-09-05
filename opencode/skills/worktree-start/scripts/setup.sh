#!/usr/bin/env bash
# worktree-start setup.sh
# Usage: setup.sh <worktree_name> [repo_root]
#
# worktree作成・設定ファイルコピー・依存インストールを一括実行する。
# AIはこのスクリプトを1回呼び出すだけでセットアップが完了する。
#
# 終了コード:
#   0: 成功
#   1: .gitignore検証失敗
#   2: worktree作成失敗
#   4: 依存インストール失敗
#   5: 引数エラー

set -euo pipefail

# === 引数チェック ===
WORKTREE_NAME="${1:-}"
REPO_ROOT="${2:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"

if [[ -z "$WORKTREE_NAME" ]]; then
  echo "[ERROR: args] worktree名が指定されていません"
  echo "Usage: setup.sh <worktree_name> [repo_root]"
  exit 5
fi

WORKTREE_DIR="$REPO_ROOT/.worktrees/$WORKTREE_NAME"

# === Stage 1: .gitignore検証 ===
echo "[STAGE: validate] .gitignore検証を開始"

if [[ ! -f "$REPO_ROOT/.gitignore" ]]; then
  echo "[ERROR: validate] .gitignoreファイルが存在しません"
  echo "[ACTION: validate] .gitignoreを作成し、.worktrees/ を追加してコミットしてください"
  exit 1
fi

if ! grep -qE '^\\.worktrees/?$|^\.worktrees/' "$REPO_ROOT/.gitignore" 2>/dev/null; then
  echo "[ERROR: validate] .worktrees/ が .gitignore に含まれていません"
  echo "[ACTION: validate] .gitignore に .worktrees/ を追加してコミットしてください"
  exit 1
fi
echo "[OK: validate] .gitignore検証完了"

# === Stage 2: デフォルトブランチ検出 ===
echo "[STAGE: detect-branch] デフォルトブランチを検出"

DEFAULT_BRANCH=""
if git symbolic-ref refs/remotes/origin/HEAD &>/dev/null; then
  DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD | sed 's|refs/remotes/origin/||')
elif git rev-parse --verify origin/main &>/dev/null; then
  DEFAULT_BRANCH="main"
elif git rev-parse --verify origin/master &>/dev/null; then
  DEFAULT_BRANCH="master"
else
  echo "[ERROR: detect-branch] デフォルトブランチを検出できません"
  echo "[ACTION: detect-branch] git fetch origin を実行してリモートブランチを取得してください"
  exit 2
fi
echo "[OK: detect-branch] デフォルトブランチ: $DEFAULT_BRANCH"

# === Stage 3: worktree作成 ===
echo "[STAGE: create] worktreeを作成中: $WORKTREE_DIR"

if [[ -d "$WORKTREE_DIR" ]]; then
  echo "[WARN: create] 既存のworktreeが見つかりました。削除して再作成します"
  git worktree remove "$WORKTREE_DIR" --force 2>/dev/null || rm -rf "$WORKTREE_DIR"
fi

if ! git worktree add --detach "$WORKTREE_DIR" "origin/$DEFAULT_BRANCH" 2>&1; then
  echo "[ERROR: create] worktreeの作成に失敗しました"
  exit 2
fi
echo "[OK: create] worktree作成完了: $WORKTREE_DIR"

# === Stage 4: 環境設定ファイルのコピー ===
echo "[STAGE: copy-env] 環境設定ファイルをコピー中"

ENV_COUNT=0

# .env* ファイルのコピー（深さ制限なし、モノレポ対応）
while IFS= read -r -d '' envfile; do
  rel_path="${envfile#"$REPO_ROOT"/}"
  dest="$WORKTREE_DIR/$rel_path"
  mkdir -p "$(dirname "$dest")"
  cp "$envfile" "$dest"
  ENV_COUNT=$((ENV_COUNT + 1))
  echo "  コピー: $rel_path"
done < <(find "$REPO_ROOT" -name '.env*' \
  -not -path '*/.worktrees/*' \
  -not -path '*/node_modules/*' \
  -not -path '*/.git/*' \
  -not -path '*/.venv/*' \
  -not -path '*/venv/*' \
  -not -path '*/__pycache__/*' \
  -not -name '.env.example' \
  -not -name '.env.sample' \
  -not -name '.env.template' \
  -print0 2>/dev/null)

# .envrc ファイルのコピー（direnv対応）
while IFS= read -r -d '' envrcfile; do
  rel_path="${envrcfile#"$REPO_ROOT"/}"
  dest="$WORKTREE_DIR/$rel_path"
  mkdir -p "$(dirname "$dest")"
  cp "$envrcfile" "$dest"
  ENV_COUNT=$((ENV_COUNT + 1))
  echo "  コピー: $rel_path"
done < <(find "$REPO_ROOT" -name '.envrc' \
  -not -path '*/.worktrees/*' \
  -not -path '*/node_modules/*' \
  -not -path '*/.git/*' \
  -print0 2>/dev/null)

echo "[OK: copy-env] ${ENV_COUNT}件の環境設定ファイルをコピー"

# === Stage 5: 依存関係のインストール ===
echo "[STAGE: setup-deps] 依存関係をインストール中"

DEPS_INSTALLED=false

# Node.js
if [[ -f "$WORKTREE_DIR/package.json" ]]; then
  echo "  検出: package.json"
  if [[ -f "$WORKTREE_DIR/bun.lockb" ]] || [[ -f "$WORKTREE_DIR/bun.lock" ]]; then
    echo "  実行: bun install"
    if ! (cd "$WORKTREE_DIR" && bun install 2>&1); then
      echo "[ERROR: setup-deps] bun installが失敗しました"
      exit 4
    fi
  elif [[ -f "$WORKTREE_DIR/pnpm-lock.yaml" ]]; then
    echo "  実行: pnpm install"
    if ! (cd "$WORKTREE_DIR" && pnpm install 2>&1); then
      echo "[ERROR: setup-deps] pnpm installが失敗しました"
      exit 4
    fi
  elif [[ -f "$WORKTREE_DIR/yarn.lock" ]]; then
    echo "  実行: yarn install"
    if ! (cd "$WORKTREE_DIR" && yarn install 2>&1); then
      echo "[ERROR: setup-deps] yarn installが失敗しました"
      exit 4
    fi
  else
    echo "  実行: npm install"
    if ! (cd "$WORKTREE_DIR" && npm install 2>&1); then
      echo "[ERROR: setup-deps] npm installが失敗しました"
      exit 4
    fi
  fi
  DEPS_INSTALLED=true
fi

# Rust
if [[ -f "$WORKTREE_DIR/Cargo.toml" ]]; then
  echo "  検出: Cargo.toml"
  echo "  実行: cargo build"
  if ! (cd "$WORKTREE_DIR" && cargo build 2>&1); then
    echo "[ERROR: setup-deps] cargo buildが失敗しました"
    exit 4
  fi
  DEPS_INSTALLED=true
fi

# Python (requirements.txt)
if [[ -f "$WORKTREE_DIR/requirements.txt" ]]; then
  echo "  検出: requirements.txt"
  echo "  実行: pip install -r requirements.txt"
  if ! (cd "$WORKTREE_DIR" && pip install -r requirements.txt 2>&1); then
    echo "[ERROR: setup-deps] pip installが失敗しました"
    exit 4
  fi
  DEPS_INSTALLED=true
fi

# Python (pyproject.toml) — requirements.txtがない場合のみ
if [[ -f "$WORKTREE_DIR/pyproject.toml" ]] && ! [[ -f "$WORKTREE_DIR/requirements.txt" ]]; then
  echo "  検出: pyproject.toml"
  if grep -q '\[tool\.poetry\]' "$WORKTREE_DIR/pyproject.toml" 2>/dev/null; then
    echo "  実行: poetry install"
    if ! (cd "$WORKTREE_DIR" && poetry install 2>&1); then
      echo "[ERROR: setup-deps] poetry installが失敗しました"
      exit 4
    fi
  elif grep -q '\[tool\.uv\]' "$WORKTREE_DIR/pyproject.toml" 2>/dev/null || [[ -f "$WORKTREE_DIR/uv.lock" ]]; then
    echo "  実行: uv sync"
    if ! (cd "$WORKTREE_DIR" && uv sync 2>&1); then
      echo "[ERROR: setup-deps] uv syncが失敗しました"
      exit 4
    fi
  else
    echo "  実行: pip install -e ."
    if ! (cd "$WORKTREE_DIR" && pip install -e . 2>&1); then
      echo "[ERROR: setup-deps] pip install -e . が失敗しました"
      exit 4
    fi
  fi
  DEPS_INSTALLED=true
fi

# Go
if [[ -f "$WORKTREE_DIR/go.mod" ]]; then
  echo "  検出: go.mod"
  echo "  実行: go mod download"
  if ! (cd "$WORKTREE_DIR" && go mod download 2>&1); then
    echo "[ERROR: setup-deps] go mod downloadが失敗しました"
    exit 4
  fi
  DEPS_INSTALLED=true
fi

# Ruby
if [[ -f "$WORKTREE_DIR/Gemfile" ]]; then
  echo "  検出: Gemfile"
  echo "  実行: bundle install"
  if ! (cd "$WORKTREE_DIR" && bundle install 2>&1); then
    echo "[ERROR: setup-deps] bundle installが失敗しました"
    exit 4
  fi
  DEPS_INSTALLED=true
fi

# PHP
if [[ -f "$WORKTREE_DIR/composer.json" ]]; then
  echo "  検出: composer.json"
  echo "  実行: composer install"
  if ! (cd "$WORKTREE_DIR" && composer install 2>&1); then
    echo "[ERROR: setup-deps] composer installが失敗しました"
    exit 4
  fi
  DEPS_INSTALLED=true
fi

if [[ "$DEPS_INSTALLED" == false ]]; then
  echo "[OK: setup-deps] 依存管理ファイルが見つからないためスキップ"
else
  echo "[OK: setup-deps] 依存関係のインストール完了"
fi

# === 完了 ===
echo ""
echo "[DONE] worktreeセットアップ完了"
echo "  worktree名: $WORKTREE_NAME"
echo "  パス: $WORKTREE_DIR"
echo "  ベース: origin/$DEFAULT_BRANCH"
