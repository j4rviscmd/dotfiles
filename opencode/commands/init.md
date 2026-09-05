---
description: AGENTS.mdの作成/更新コマンド(`/init`コマンドの拡張)
agent: build
model: github-copilot/gpt-5.2
---

# Create AGENTS.md

## 作成のルール

1. 作成場所は`{project_root}/AGENTS.md`とすること。
2. 日本語で作成すること。
3. 末尾の`最終更新`を現在の日付に更新すること。
4. 既存の`AGENTS.md`が存在する場合は上書きすること。
    - プロジェクト固有ルールセクションの内容を再精査し、必要に応じて更新すること。
5. プロジェクト共通ルールに存在するルールはプロジェクト固有ルールセクションに含めないこと。
6. 以下のテンプレートを踏襲すること。

```markdown
# AGENTS.md

## プロジェクト固有ルール

<!-- プロジェクト固有なルールを記載すること
フォーマットは以下とする。
### <ルール番号>. <ルールタイトル>
- <ルール内容>

e.g.
### 1. 状態管理
- 状態管理には Redux Toolkit を使用すること。
- `RootState`、`AppDispatch` をエクスポート。`store.ts` の型付き `useSelector` / `useDispatch` を使用すること。
-->

<!-- BEGIN PROJECT RULES (auto-generated from /init) -->
<!-- この領域は /init 拡張が上書きします。手動編集は次回実行で失われます -->
<!-- END PROJECT RULES -->

---

## プロジェクト共通ルール

<!-- プロジェクト共通ルールは固定値です。/initコマンドにて編集・削除しないこと -->

## **Language Policy (最優先ルール)**

- 本プロジェクトにおけるすべてのエージェントおよびサブエージェントとの
  **あらゆるコミュニケーションは、日本語のみを使用することを絶対的な最優先ルールとする。**
- タスク実行、意思決定、ログ、コメント、回答、会話の全てにおいて日本語を徹底する。
- 外部ツールや API の仕様上英語が必要な場面がある場合でも、
  エージェント間およびユーザーとのやり取りは日本語で行う。
- APIが英語を返却する場合は、必ず日本語で翻訳してからエージェントに伝えること。

### 1. 承認 / 権限

- すべてのコード変更は事前に Issue / PR 上で合意。口頭のみ不可。
- "ユーザの許諾" = 対象リポジトリのメンテナ(OWNER もしくは CODEOWNERS 該当者) の GitHub Review "Approved"。
- 緊急 hotfix: Issue に `hotfix` ラベル + 原因 / 暫定対策 / 恒久対策案記載。マージ後 24h 以内に事後レビュー。
- Self-merge 禁止 (hotfix 例外時も事後レビュー必須)。

### 2. ブランチ戦略

- `main`: 常にデプロイ可能。直接 push 禁止。保護設定。
- 機能: `feature/<短い-kebab-case>`。
- バグ修正: `fix/<issue番号-概要>`。
- リリース調整: `release/<version>` (必要時)。
- 緊急: `hotfix/<issue番号>`。

### 3. コミット規約 (Conventional Commits)

- 型: `feat`, `fix`, `docs`, `style` (フォーマットのみ), `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`。
- 先頭は型 + オプション範囲: `feat(api): ...`。
- 目的を簡潔に (WHY に近い WHAT)。
- 破壊的変更はフッターに `BREAKING CHANGE: <内容>`。
- 生成物/ビルド成果物 (`dist`, `coverage`, `.DS_Store`, `build`, ローカル設定) 非コミット。
- コミット前に `lint` & `format` 失敗した場合はコミット中断し修正。
    - `test` はユーザ指示があった場合のみ実行。

### 4. CI 成功基準

- 必須ジョブ: Lint / Build / (設定あれば) Security Scan / Type Check。
- すべて成功かつレビュー承認後のみ `main` へマージ。
- CI 失敗を無視したマージ禁止 (hotfix でも最低限ビルドと該当テストが通ること)。
- Unit Test はユーザ指示があった場合のみ必須。

### 5. テストポリシー

- ユーザからの指示があった場合のみ適用。
- 新規 / 変更ロジックは最低 1 つの自動テスト (単体 or 統合)。
- ステートフル/副作用コードはテストで可観測性を確保 (モックか外部接続分離)。
- カバレッジ目標: Statements 80% / Branches 70% を下回る PR は改善コメント付与。
- 例外 (PoC / 実験) は Issue に理由を明記し後続タスク化。

### 6. 提案プロセス

- ベストプラクティスに基づく提案は Issue で: 背景 / 目的 / 代替案 / コスト / リスク / 影響範囲。
- 採用可否はメンテナがコメントで明確化。曖昧な保留状態を避ける。

### 7. コミュニケーション言語

- 会話 / レビュー / Issue / PR / コード中コメントアウトは日本語を徹底する。
- 例外: 外部 OSS 連携・英語のみドキュメント参照時。英語使用箇所は要約を日本語追記。

### 8. セキュリティ / Secrets

- Secrets / APIキーはコード直書き禁止。`.env*` は Git 追跡外 + サンプル `env.example` を提供。
- 誤って漏洩コミットした場合: 直ちにキー再発行し該当コミットを history から除去 (可能なら) + 事後報告 Issue。
- PII/機密をログ/エラーメッセージへ出力禁止。出力していない旨を `README`に明記。

### 9. 依存パッケージ更新

- 定期 (毎月初) に脆弱性スキャンと minor/patch 更新。
- 重大 CVE は即日更新。PR 説明に CVE ID、影響、テスト結果記載。
- Renovate / Dependabot 導入時は自動生成 PR のレビュー必須。

### 10. バージョニング & リリース

- SemVer 準拠: MAJOR(破壊) / MINOR(後方互換追加) / PATCH(修正)。
- リリース時: Tag `v<version>` + CHANGELOG 更新 (Conventional Commits から自動生成推奨)。
    - リリースノートに変更点の要約を必ず含めること。日本語と英語の両方で記載すること。
- BREAKING CHANGE ある場合は移行手順を CHANGELOG に明記。

### 11. コメント / TODO ライフサイクル

- 未解決タスク: `TODO(#<issue>): 説明` / `FIXME(#<issue>):` 形式で必ず Issue 紐付け。
- 解決後: 該当 Issue Close → コメント削除 OK。履歴の誤認を避けるため紐付けないコメントは禁止。
- 自動整形やリファクタでも未解決コメントは削除/改変不可。

### 12. ドキュメント更新 (公開 API)

- 公開 API を追加/変更/廃止する PR は `README.md` も更新し、利用例と影響を記載。
    - 互換性/移行手順についてはユーザからの指示があった場合に限り記載すること。
- ドキュメント未更新のAPI変更はコミット/プッシュ/マージ不可。

### 13. 作業ログ / 再現性

- 手動手順 (環境構築/移行) を実施した場合は Issue/PR に手順を書き残す。CI 化可能性を検討。

### 14. 遵守違反への対応

- 初回: レビューコメントで是正要求。
- 再発 / 重大: メンテナがガイド再周知 → 必要なら改善 Issue化。

### 15. MCP利用ポリシー

- ドキュメントを検索する時は、`context7` ツールを利用すること。
- 何かを実行する方法がわからない場合は、`gh_grep` を使用して GitHub からコード例を検索すること。
- GitHub 上のリポジトリを操作する場合は、`github` MCP を利用し、必ず Pull Request ベースで変更を提案すること。
    - ファイル構造の確認や軽微な修正も、GitHub MCP 経由で行うこと。
    - 直接 GitHub 上で編集することは禁止する。
    - PRは日本語で作成すること。
- ローカル環境の Git 操作用：`git` MCP（git-mcp-server）
    - `.env`などの機密情報を含むファイルや、未コミットのローカル資材をコミットしないこと。
    - ローカルの Git 操作は **すべて `git` MCP を使用する**。
        - 例：`git status` / `git diff` / `git add` / `git commit` / `git switch` / `git stash`
    - ローカルワークツリーの変更は、手動作業と AI 操作が混在しないよう **`git` MCP で統一**する。
    - ローカルの機密ファイルや未コミット資材に GitHub MCP を触れさせないため、 **ローカル操作は `git` MCP に限定すること**。
        - ローカルで “Git 操作” を行う場合は `git` MCP を使用し、GitHub MCP がローカル資材に触れないようにすること。
        - `git` MCP はあくまで Git 操作専用であり、ローカルファイル編集の代替ではない。
            - 例：fs_read / fs_write / ファイル修正・生成・削除は filesystem MCP を利用すること。
    - `git` MCP はローカル専用であり、`git push` / `git pull` などのリモート操作は行わない。
        - リモート操作や PR 作成は `github` MCP が担当する。

### 16. 🔄 ローカル → GitHub の作業フロー

1. `git` MCP でローカルブランチ作成
2. `git` MCP で作業・コミット
3. `github` MCP を使って PR 化
4. レビュー後にマージ

### 17. 記憶の活用ポリシー

- 本プロジェクトは `local-memory` MCPを長期記憶として使用する
- セッション開始時に必ず、過去の重要な決定事項や設定内容を `local-memory` MCP から取得し、現在のコンテキストに反映させること
- 会話履歴や過去のログを参照する場合は、`local-memory` MCP を利用すること。
    - ストレージはデータはローカル PC 内に保存される
- `local-memory` MCP を使用して保存されたデータは、プロジェクトの進行に伴い継続的に蓄積される
- 定期的に `local-memory` MCP の内容をレビューし、不要なデータは削除すること

#### **local-memory MCP: メモリ読み取り手順（必須）**

「いまのメモリ内容を教えて」「保存されているメモリ一覧」等の依頼では、検索に頼らず以下の順で読むこと。
（検索は絞り込み用途。全件一覧は analysis を優先）

1. まず件数を確認（stats）

- local-memory MCP の `local-memory_stats(stats_type='session')` を呼ぶ
- `total_memories == 0` なら「保存メモリなし」で終了

2. どのセッションにあるか特定（sessions）

- `local-memory_sessions(sessions_type='list')` を呼ぶ
- `memory_count > 0` の `session_id` を確認する
- stats では件数があるのに sessions の表示が不整合でも、次の手順へ進む（検索に固執しない）

3. メモリ本文の取得（analysis を最優先）

- 全件一覧・現状確認は必ずこれを使う：
    - `local-memory_analysis(analysis_type='summarize', timeframe='all', response_template='full_context')`
- 出力の `sources[]`（id/content/tags/session_id 等）が「実体の一覧」なので、これを読み取り結果として提示する

4. search は「絞り込み」用途のみ

- キーワード検索：
    - `local-memory_search(search_type='semantic', query='<空でない文字列>')`
- タグ検索：
    - `local-memory_search(search_type='tags', tags=['tag1','tag2'])`
- 併用（必要時）：
    - `local-memory_search(search_type='hybrid', query='<空でない文字列>', tags=[...])`

5. UUID が分かっている場合は直取得（最も確実）

- `local-memory_get_memory_by_id(id='<uuid>')`
  local-memory MCP: よくある失敗と回避策
- `search_type='hybrid'` は **`query` または `tags` が必須**。`query=''` のような空指定はエラーになるため禁止。
- `query='*'` のようなワイルドカード前提で「全件取得」しようとしない（期待通り動かないことがある）。
    - 全件一覧は必ず `analysis(...full_context...)` を使う。
- `stats` で件数があるのに `search` が 0 件の場合：
    - `sessions(list)` → `analysis(full_context)` にフォールバックし、search の再試行を続けない。

#### **記憶に書き込むタイミング（重要）**

- タスク完了時
    - 決定事項 / 方針 / 設定を local-memory に書き込む
- 新しいコンテキストが確定したとき
    - 例：設定変更、選択したプラン、決定したルールなど
- ユーザーから明示的に “覚えて” と依頼されたとき
    - 例：
        - 「今後はこの処理ルールでお願いします」
        - 「この設定をデフォルトとして覚えて」
- 一時的情報（ログ / URL / 確認用の一時データ）は保存しない
- 消去ルール
    - ユーザーが「忘れて」と言った場合は、当該キー/内容だけを削除
- 記憶の更新を行った際には、必ずログに「記憶を更新しました」と出力すること

### 18. サブエージェント活用ポリシー

- **すべての調査・実装・検証作業はサブエージェントに委譲すること**
- プライマリエージェントはオーケストレーション（タスク分割、役割分担、進捗管理、成果の統合、最終レビュー）として振る舞うこと。
- サブエージェントの出力はそのまま採用せず、必要に応じて根拠・差分・再現手順を確認してから統合すること。

---

<!-- /initコマンド実行毎に更新すること -->

最終更新: YYYY-MM-DD
```
