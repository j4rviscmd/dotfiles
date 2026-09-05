# プロジェクトタイプ別コマンド

worktree-start / worktree-code 実行時に自動検出するコマンドの一覧。

## セットアップコマンド（setup.shで自動実行）

> セットアップコマンドは `scripts/setup.sh` が自動検出・実行します。
> AIが個別にBash呼び出しする必要はありません。

### 環境設定ファイルのコピー

| 対象 | 除外条件 |
| ---- | -------- |
| `.env*` ファイル（全階層） | `.env.example`, `.env.sample`, `.env.template` は除外 |
| `.envrc` ファイル（direnv） | — |

除外パス: `.worktrees/`, `node_modules/`, `.git/`, `.venv/`, `venv/`, `__pycache__/`

### 依存インストール

| ファイル | コマンド | 検出条件 |
| -------- | -------- | -------- |
| package.json + bun.lock/bun.lockb | `bun install` | bun.lockまたはbun.lockbが存在 |
| package.json + pnpm-lock.yaml | `pnpm install` | pnpm-lock.yamlが存在 |
| package.json + yarn.lock | `yarn install` | yarn.lockが存在 |
| package.json (その他) | `npm install` | 上記いずれにも該当しない場合 |
| Cargo.toml | `cargo build` | Rust |
| requirements.txt | `pip install -r requirements.txt` | Python |
| pyproject.toml (poetry) | `poetry install` | `[tool.poetry]`セクションが存在 |
| pyproject.toml (uv) | `uv sync` | `[tool.uv]`セクションまたはuv.lockが存在 |
| pyproject.toml (その他) | `pip install -e .` | 上記いずれにも該当しない場合 |
| go.mod | `go mod download` | Go |
| Gemfile | `bundle install` | Ruby |
| composer.json | `composer install` | PHP |

## ビルド/linterコマンド

### Node.js / TypeScript

| 種別 | コマンド | 条件 |
| ---- | -------- | ---- |
| ビルド | `npm run build` | package.jsonのscriptsにbuildがある場合 |
| Lint | `npm run lint` | package.jsonのscriptsにlintがある場合 |
| 型チェック | `npm run typecheck` | package.jsonのscriptsにtypecheckがある場合 |

### Rust

| 種別 | コマンド |
| ---- | -------- |
| ビルド | `cargo build` |
| Lint | `cargo clippy` |
| フォーマット | `cargo fmt --check` |

### Python

| 種別 | コマンド | 条件 |
| ---- | -------- | ---- |
| Lint | `ruff check` | ruffがインストールされている場合 |
| Lint | `flake8` | flake8がインストールされている場合 |
| 型チェック | `mypy .` | mypyがインストールされている場合 |

### Go

| 種別 | コマンド |
| ---- | -------- |
| ビルド | `go build ./...` |
| Lint | `golangci-lint run` |

## devコマンド（動作確認用）

### Node.js / TypeScript

| プロジェクト | コマンド | 条件 |
| ------------ | -------- | ---- |
| Next.js | `npm run dev` | next.config.*がある場合 |
| Vite | `npm run dev` | vite.config.*がある場合 |
| Nuxt | `npm run dev` | nuxt.config.*がある場合 |
| React | `npm start` | Create React App |
| Express | `npm run dev` または `npm start` | |

### Rust

| プロジェクト | コマンド |
| ------------ | -------- |
| CLIアプリ | `cargo run` |
| Webサーバー | `cargo run` |

### Python

| プロジェクト | コマンド | 条件 |
| ------------ | -------- | ---- |
| Flask | `flask run` | app.pyまたはFLASK_APPが設定されている場合 |
| Django | `python manage.py runserver` | manage.pyがある場合 |
| FastAPI | `uvicorn main:app --reload` | FastAPI使用時 |
| CLI/スクリプト | `python main.py` | エントリーポイントに応じて |

### Go

| プロジェクト | コマンド |
| ------------ | -------- |
| Webサーバー | `go run main.go` |
| CLIアプリ | `go run main.go` |

## 自動検出の優先順位

1. package.jsonのscriptsを確認（dev, start, serve等）
2. プロジェクトタイプ特有のファイルを確認
3. デフォルトのコマンドを使用

## 注意事項

- 該当ファイルがない場合はスキップ
- コマンドが失敗した場合はエラー内容を表示して修正を促す
- プロジェクト固有の設定がある場合は適切に判断すること
