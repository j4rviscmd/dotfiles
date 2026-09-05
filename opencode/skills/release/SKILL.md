---
name: release
description: >-
  このスキルは、ユーザーが「リリースして」「リリース作成」「バージョンアップ」
  「新規リリース」「リリース準備」「CHANGELOG更新」「バージョン更新」と言った場合、または
  セマンティックバージョニングに基づくリリース作業について話している場合に使用される。
  最新リリースとorigin/mainの差分を把握し、対話的にsemverを決定して
  バージョン管理ファイルとCHANGELOG.mdを更新し、release/{version}ブランチでmainへのPRを作成する。
model: github-copilot/claude-sonnet-4.6
---

# Release 作成

## スキル概要

最新リリースとorigin/mainの差分を分析し、対話的にセマンティックバージョニング（semver）を決定して
バージョン管理ファイルとCHANGELOG.mdを更新し、リリース用PRを作成します。

**基本原則:** 差分把握 → 対話的なsemver決定 → バージョンファイル/CHANGELOG更新 → release/{version}ブランチ作成 → PR作成

**前提条件:**
- origin/main にマージ済みの変更があること
- リモートリポジトリが設定されていること

## ガードレール（絶対に守ること）

| ルール | 理由 |
| ------ | ---- |
| **PR作成は`/create-pr`スキルで実行** | ラベル自動設定・CI監視が含まれるため |
| **CI監視は`/monitor-pr-ci`スキルで実行** | 30秒ポーリング・15分タイムアウトが実装済みのため |
| **GitHub Release作成・タグプッシュは絶対禁止** | タグ生成・Releaseページ作成はCI/CDパイプラインが担当する。AIが手動で実行すると二重実行・競合が発生する |
| **PRマージ後のbranchは必ず削除** | リモート・ローカル両方削除してリポジトリを整理する |

## コンテキスト情報

- 現在のブランチ: !`git branch --show-current`
- デフォルトブランチ: !`git remote show origin 2>/dev/null | grep "HEAD branch" | cut -d: -f2 | xargs || echo "main"`
- 最新リリースタグ: !`git describe --tags --abbrev=0 2>/dev/null || echo "（リリースなし）"`
- origin/mainからの差分コミット: !`git log $(git remote show origin 2>/dev/null | grep "HEAD branch" | cut -d: -f2 | xargs || echo "main")..HEAD --oneline 2>/dev/null | head -20 || echo "差分なし"`

## 手順

### Step 0: タスク管理の開始

**重要:** 以下の10のタスクを順番に作成してください。

**実行手順:**
1. 最初にタスク1（前提条件チェック）を作成
2. タスク1の作成完了後、タスク1のIDを確認
3. タスク2を作成し、`addBlockedBy`にタスク1のIDを指定
4. タスク2〜10についても同様に、前のタスクのIDを指定して作成
5. タスクは要約せず、記載通りに個別に作成すること

```bash
# タスク1: 前提条件チェック
TaskCreate:
- subject: 前提条件チェック
- description: |
  リモート設定、ブランチ確認、最新状態確認を実施
  - git remote get-url origin でリモート未設定の場合はエラー
  - git branch --show-current でデフォルトブランチにいるか確認
  - git fetch origin && git status で同期状態を確認
- activeForm: 前提条件をチェック中

# タスク2: 最新リリースと差分の把握
# 注: addBlockedByにタスク1のIDを指定すること
TaskCreate:
- subject: 最新リリースと差分の把握
- description: |
  最新リリースタグを取得し、origin/mainとの差分を分析
  - git describe --tags --abbrev=0 で最新タグ取得
  - git log で変更コミットを一覧（Step 3の対話で使用するため記録すること）
  - Conventional Commitsから変更タイプを集計（feat, fix, BREAKING CHANGE等）
  - 変更タイプの集計結果を記録（Step 3の対話で使用）
- activeForm: 差分を把握中
- addBlockedBy: [タスク1の実際のID]

# タスク3: 対話的なsemver決定
# 注: addBlockedByにタスク2のIDを指定すること
TaskCreate:
- subject: 対話的なsemver決定
- description: |
  コミット履歴からsemver更新タイプを推定し、ユーザーに確認
  - BREAKING CHANGE → major
  - feat → minor
  - fix → patch
  - AskUserQuestionでユーザーに推定結果を提示
- activeForm: semverを決定中
- addBlockedBy: [タスク2の実際のID]

# タスク4: バージョン管理ファイルとCHANGELOGの更新
# 注: addBlockedByにタスク3のIDを指定すること
TaskCreate:
- subject: バージョン管理ファイルとCHANGELOGの更新
- description: |
  バージョン管理ファイル（tauri.conf.jsonまたはpackage.json）とCHANGELOG.mdを更新
  - sedコマンドで正規表現を使用してバージョンを置換
  - CHANGELOG.mdが存在する場合のみ、Keep a Changelog形式で更新
  - Conventional Commitsから変更タイプ別に分類（Added/Changed/Fixed等）
  - git diff で更新内容を確認
- activeForm: バージョンファイルとCHANGELOGを更新中
- addBlockedBy: [タスク3の実際のID]

# タスク5: releaseブランチの作成
# 注: addBlockedByにタスク4のIDを指定すること
TaskCreate:
- subject: releaseブランチの作成
- description: |
  release/{version} ブランチを作成
  - git checkout -b release/{version}
  - 既存ブランチがある場合は削除確認
- activeForm: releaseブランチを作成中
- addBlockedBy: [タスク4の実際のID]

# タスク6: 変更のコミット
# 注: addBlockedByにタスク5のIDを指定すること
TaskCreate:
- subject: 変更のコミット
- description: |
  バージョンファイルとCHANGELOGの変更をコミット
  - README.mdから言語判定を実施（英語60%以上→英語、日本語60%以上→日本語）
  - git add でバージョンファイルをステージング
  - CHANGELOG.mdが更新されている場合は併せてステージング
  - git commit で "chore: release v{version}" をコミット
- activeForm: 変更をコミット中
- addBlockedBy: [タスク5の実際のID]

# タスク7: push
# 注: addBlockedByにタスク6のIDを指定すること
TaskCreate:
- subject: push
- description: |
  releaseブランチをリモートにプッシュ
  - git push -u origin release/{version}
- activeForm: push中
- addBlockedBy: [タスク6の実際のID]

# タスク8: PRの作成
# 注: addBlockedByにタスク7のIDを指定すること
TaskCreate:
- subject: PRの作成
- description: |
  /create-pr スキルを呼び出してリリース用PRを作成
  - Skill toolで create-pr を呼び出す
  - ラベル自動設定・言語判定はcreate-prスキルが担当
- activeForm: PRを作成中
- addBlockedBy: [タスク7の実際のID]

# タスク9: CI監視
# 注: addBlockedByにタスク8のIDを指定すること
TaskCreate:
- subject: CI監視
- description: |
  GitHub ActionsのCIが成功するまで監視
  - Skill toolで monitor-pr-ci を呼び出す（pr_numberを引数として渡す）
  - CI成功 → タスク完了
  - CI失敗 → AskUserQuestionで修正/再試行/スキップ/中断を確認
- activeForm: CIを監視中
- addBlockedBy: [タスク8の実際のID]

# タスク10: 次アクションの確認
# 注: addBlockedByにタスク9のIDを指定すること
TaskCreate:
- subject: 次アクションの確認
- description: |
  AskUserQuestionでユーザーに次のアクションを提案
  - 選択肢: PRのマージ / 後でマージ（手動対応）
  - PRのマージ選択時: gh pr merge {pr_number} --squash --delete-branch
    → git checkout {default_branch} && git pull origin {default_branch}
  - 【絶対禁止】GitHub Release作成・タグプッシュはCI/CDが担当するため実行しない
- activeForm: 次のアクションを確認中
- addBlockedBy: [タスク9の実際のID]
```

各ステップ完了後にTaskUpdateでstatusをcompletedに更新してください。

### Step 1: 前提条件チェック

1. **リモート確認**: `git remote get-url origin 2>/dev/null` - リモート未設定の場合はエラー終了
2. **ブランチ確認**: `git branch --show-current` - デフォルトブランチにいない場合は切り替え
3. **最新状態確認**: `git fetch origin && git status` - 「Your branch is behind」の場合はpullを促す

### Step 2: 最新リリースと差分の把握

```bash
# 最新リリースタグの取得
#
# git describe --tags --abbrev=0:
# - 最新のタグを取得
# --abbrev=0: タグ名のみを返し、ハッシュを含めない
# - タグがない場合は空文字を返す（2>/dev/nullでエラーを非表示）
latest_tag=$(git describe --tags --abbrev=0 2>/dev/null)
default_branch=$(git remote show origin 2>/dev/null | grep "HEAD branch" | cut -d: -f2 | xargs || echo "main")

if [ -z "$latest_tag" ]; then
  echo "リリースタグがありません。初回リリースとして処理します。"
  latest_tag=$(git rev-list --max-parents=0 HEAD)
  initial_release=true
  commits=$(git log --oneline --no-merges | head -50)
  changed_files=$(git ls-tree -r --name-only ${default_branch})
else
  echo "最新リリース: $latest_tag"
  initial_release=false
  commits=$(git log ${latest_tag}..${default_branch} --oneline --no-merges)
  changed_files=$(git diff --name-only ${latest_tag} ${default_branch})
fi

echo "変更コミット:"
echo "$commits"
echo ""
echo "変更ファイル:"
echo "$changed_files" | head -30

# Conventional Commits から変更タイプを集計
feat_count=$(echo "$commits" | grep -c "^feat:" || echo "0")
fix_count=$(echo "$commits" | grep -c "^fix:" || echo "0")
refactor_count=$(echo "$commits" | grep -c "^refactor:" || echo "0")
docs_count=$(echo "$commits" | grep -c "^docs:" || echo "0")
chore_count=$(echo "$commits" | grep -c "^chore:" || echo "0")
test_count=$(echo "$commits" | grep -c "^test:" || echo "0")
breaking_count=$(echo "$commits" | grep -c "BREAKING CHANGE" || echo "0")

echo ""
echo "変更タイプ集計:"
echo "  feat: $feat_count"
echo "  fix: $fix_count"
echo "  refactor: $refactor_count"
echo "  docs: $docs_count"
echo "  chore: $chore_count"
echo "  test: $test_count"
echo "  BREAKING CHANGE: $breaking_count"
```

### Step 3: 対話的なsemver決定

#### 3-1: 現在バージョンの取得

```bash
# プロジェクトタイプ判定と現在バージョンの取得
if [ -f "tauri.conf.json" ]; then
  version_file="tauri.conf.json"
elif [ -f "src-tauri/tauri.conf.json" ]; then
  version_file="src-tauri/tauri.conf.json"
elif [ -f "package.json" ]; then
  version_file="package.json"
else
  echo "エラー: バージョン管理ファイルが見つかりません (期待: tauri.conf.json, package.json)"
  exit 1
fi

current_version=$(grep -o '"version"\s*:\s*"[^"]*"' "$version_file" | head -1 | sed 's/.*: "\(.*\)".*/\1/')
echo ""
echo "バージョンファイル: $version_file"
echo "現在のバージョン: $current_version"
```

#### 3-2: semver の推定と次期バージョンの計算

**推定ロジック:**
1. BREAKING CHANGE が含まれる → major
2. feat: が含まれる → minor
3. fix: のみ → patch
4. それ以外（docs, chore等） → patch

この推定ロジックはSemantic Versioning 2.0.0の仕様に準拠しており、
Conventional Commits形式のコミットメッセージから自動的にバージョン更新タイプを判定します。

```bash
# semver を推定
#
# 優先順位: major > minor > patch
# - major: 後方互換性のない変更（BREAKING CHANGE）
# - minor: 後方互換性のある新機能追加（feat:）
# - patch: バグ修正（fix:）またはその他の変更
if [ "$breaking_count" -gt 0 ]; then
  suggested_bump="major"
  reason="BREAKING CHANGE が $breaking_count 件含まれています"
elif [ "$feat_count" -gt 0 ]; then
  suggested_bump="minor"
  reason="新機能（feat:）が $feat_count 件含まれています"
elif [ "$fix_count" -gt 0 ]; then
  suggested_bump="patch"
  reason="バグ修正（fix:）が $fix_count 件含まれています"
else
  suggested_bump="patch"
  reason="ドキュメント・リファクタリング等の変更です"
fi

echo ""
echo "推定されるバージョン更新: $suggested_bump"
echo "理由: $reason"

# 現在バージョンを分解
major=$(echo "$current_version" | cut -d. -f1 | sed 's/^v//')
minor=$(echo "$current_version" | cut -d. -f2)
patch=$(echo "$current_version" | cut -d. -f3)

# 次期バージョンを計算
case "$suggested_bump" in
  major)
    next_version="$((major + 1)).0.0"
    ;;
  minor)
    next_version="${major}.$((minor + 1)).0"
    ;;
  patch)
    next_version="${major}.${minor}.$((patch + 1))"
    ;;
esac

echo "推定される次期バージョン: v$next_version"
```

#### 3-3: 対話的な確認

AskUserQuestionツールでユーザーに確認します。

**重要:** 以下の形式で差分要約と推奨バージョンを明確に表示してください。

```text
質問: 推定されたバージョン更新で正しいですか？

## 変更内容の要約
{Step 2で取得した変更コミットリストを表示（最大10件まで）}

## 変更タイプ集計
- feat: {feat_count} 件
- fix: {fix_count} 件
- BREAKING CHANGE: {breaking_count} 件
- その他: {refactor_count + docs_count + chore_count + test_count} 件

## 推奨バージョン
v{next_version}

推奨理由: {reason}
バージョン更新タイプ: {suggested_bump} (major/minor/patch)

選択肢:
1. はい - v{next_version} でリリース
2. いいえ - 別のバージョンを指定
```

**表示のポイント:**
- 変更コミットは、最近のものから最大10件までリスト表示
- Conventional Commitsのタイプ別集計を明示
- 推奨バージョン（v{next_version}）を太字で強調
- 推奨理由を簡潔に説明（例: "新機能が5件含まれています"）

初回リリースの場合は対話をスキップして `v1.0.0` を使用します。

```bash
if [ "$initial_release" = true ]; then
  next_version="1.0.0"
  echo "初回リリースのため、バージョン v1.0.0 を使用します"
fi
```

### Step 4: バージョン管理ファイルとCHANGELOGの更新

#### 4-1: バージョンファイルの更新

```bash
# バージョンを更新（Tauri/npm共通）
#
# sedコマンドで正規表現を使用し、バージョンフィールドを一括更新します。
# 対応フォーマット:
# - Tauri: tauri.conf.json, src-tauri/tauri.conf.json
# - npm: package.json
#
# 正規表現パターン: "version": "X.Y.Z" 形式を検索し、
# 次期バージョン（next_version）に置換します。
sed -i '' -E 's/"version"\s*:\s*"[0-9]+\.[0-9]+\.[0-9]+"/"version": "'"$next_version"'"/' "$version_file"

echo ""
echo "バージョンを更新: $version_file"
echo "  $current_version → $next_version"
```

#### 4-2: CHANGELOG.mdの更新

**重要:** CHANGELOG.mdが存在しない場合はスキップします。

```bash
# CHANGELOG.mdの存在確認
if [ ! -f "CHANGELOG.md" ]; then
  echo "CHANGELOG.mdが存在しないため、スキップします"
  skip_changelog=true
else
  skip_changelog=false

  # Conventional Commitsから変更タイプ別に分類
  #
  # Keep a Changelog形式のカテゴリにマッピング:
  # - feat: → Added（新機能）
  # - fix: → Fixed（バグ修正）
  # - refactor: → Changed（変更）
  # - docs: → Changed（ドキュメント更新）
  # - chore: → Changed（その他）
  # - test: → Changed（テスト）
  # - BREAKING CHANGE: → Changed（破壊的変更として注記）

  # 各カテゴリのコミットを抽出
  added_commits=$(echo "$commits" | grep "^feat:" || echo "")
  fixed_commits=$(echo "$commits" | grep "^fix:" || echo "")
  changed_commits=$(echo "$commits" | grep -E "^(refactor:|docs:|chore:|test:)" || echo "")
  breaking_commits=$(echo "$commits" | grep "BREAKING CHANGE" || echo "")

  # 今日の日付を取得（YYYY-MM-DD形式）
  release_date=$(date +%Y-%m-%d)

  echo "CHANGELOG.mdを更新します"
fi
```

**Keep a Changelog形式のエントリ生成:**

```markdown
## [v{next_version}] - {release_date}

{breaking_commitsがある場合}
### ⚠️ Breaking Changes
{breaking_commitsをリスト形式で表示}
{各コミットから「BREAKING CHANGE:」以降の内容を抽出}

{added_commitsがある場合}
### Added
{added_commitsをリスト形式で表示}
{各コミットから「feat:」を削除した内容を表示}

{fixed_commitsがある場合}
### Fixed
{fixed_commitsをリスト形式で表示}
{各コミットから「fix:」を削除した内容を表示}

{changed_commitsがある場合}
### Changed
{changed_commitsをリスト形式で表示}
{各コミットから「refactor:」「docs:」「chore:」「test:」を削除した内容を表示}
```

**CHANGELOG更新の実行手順:**

1. CHANGELOG.mdの先頭行を確認（`# Changelog` または `# CHANGELOG`）
2. ヘッダー行の直後に新しいバージョンセクションを挿入
3. 空のカテゴリは表示しない
4. 各コミットは簡潔な説明に変換（例: `feat: ユーザー認証を追加` → `- ユーザー認証を追加`）

```bash
if [ "$skip_changelog" = false ]; then
  # 新しいエントリを作成
  new_entry="## [v$next_version] - $release_date\n"

  # Breaking Changes
  if [ -n "$breaking_commits" ]; then
    new_entry+="\n### ⚠️ Breaking Changes\n"
    while IFS= read -r commit; do
      if [ -n "$commit" ]; then
        # コミットハッシュとBREAKING CHANGE内容を抽出
        message=$(echo "$commit" | sed 's/^[a-f0-9]* BREAKING CHANGE: /- /' | sed 's/^[a-f0-9]* .*BREAKING CHANGE: /- /')
        new_entry+="$message\n"
      fi
    done <<< "$breaking_commits"
  fi

  # Added
  if [ -n "$added_commits" ]; then
    new_entry+="\n### Added\n"
    while IFS= read -r commit; do
      if [ -n "$commit" ]; then
        message=$(echo "$commit" | sed 's/^[a-f0-9]* feat: /- /' | sed 's/^feat: /- /')
        new_entry+="$message\n"
      fi
    done <<< "$added_commits"
  fi

  # Fixed
  if [ -n "$fixed_commits" ]; then
    new_entry+="\n### Fixed\n"
    while IFS= read -r commit; do
      if [ -n "$commit" ]; then
        message=$(echo "$commit" | sed 's/^[a-f0-9]* fix: /- /' | sed 's/^fix: /- /')
        new_entry+="$message\n"
      fi
    done <<< "$fixed_commits"
  fi

  # Changed
  if [ -n "$changed_commits" ]; then
    new_entry+="\n### Changed\n"
    while IFS= read -r commit; do
      if [ -n "$commit" ]; then
        message=$(echo "$commit" | sed 's/^[a-f0-9]* \(refactor\|docs\|chore\|test\): /- /' | sed 's/^\(refactor\|docs\|chore\|test\): /- /')
        new_entry+="$message\n"
      fi
    done <<< "$changed_commits"
  fi

  # CHANGELOG.mdのヘッダー行の後に新しいエントリを挿入
  # 注: macOSのsedは-i ''が必要
  if grep -q "^# Changelog" CHANGELOG.md; then
    # ヘッダー行の後に挿入
    sed -i '' "/^# Changelog/a\\
\\
$new_entry
" CHANGELOG.md
  elif grep -q "^# CHANGELOG" CHANGELOG.md; then
    sed -i '' "/^# CHANGELOG/a\\
\\
$new_entry
" CHANGELOG.md
  else
    # ヘッダーがない場合は先頭に追加
    echo -e "# Changelog\n\n$new_entry$(cat CHANGELOG.md)" > CHANGELOG.md
  fi

  echo "CHANGELOG.mdを更新しました"
fi

echo ""
echo "更新内容:"
git diff "$version_file"
if [ "$skip_changelog" = false ]; then
  git diff CHANGELOG.md
fi
```

### Step 5: releaseブランチの作成

```bash
branch_name="release/$next_version"

# 既存ブランチのチェック
#
# git show-ref --verify: 参照が存在する場合のみ成功
# refs/heads/{branch}: ローカルブランチの完全な参照名
# -quiet: 標準出力を抑制
if git show-ref --verify --quiet refs/heads/"$branch_name"; then
  echo "警告: ブランチ $branch_name は既に存在します"
  echo "既存のブランチを削除して作り直しますか？ [y/n]"
  read -r response
  if [ "$response" = "y" ]; then
    git branch -D "$branch_name"
  else
    echo "処理を中断します"
    exit 1
  fi
fi

git checkout -b "$branch_name"
echo "ブランチを作成: $branch_name"
```

### Step 6: 変更のコミット

```bash
# 言語判定（README.md から）
#
# CLAUDE.mdのドキュメント言語ルールに従ってコミットメッセージの言語を判定します。
#
# 判定ロジック:
# 1. README.mdの最初の100行を読み込み
# 2. 英語([a-zA-Z])と日本語([ひらがなカタカナ漢])の文字数を比較
# 3. 英語が60%以上 → 英語
# 4. 日本語が60%以上 → 日本語
# 5. どちらも60%未満 → 英語（デフォルト）
#
# 注: この判定はコミットメッセージとPR本文の言語決定に使用されます
lang="en"
if [ -f "README.md" ]; then
  en_chars=$(head -n 100 README.md | grep -o "[a-zA-Z]" | wc -l)
  ja_chars=$(head -n 100 README.md | grep -o "[ひらがなカタカナ漢]" | wc -l)
  total_chars=$((en_chars + ja_chars))

  if [ "$total_chars" -gt 0 ]; then
    en_ratio=$((en_chars * 100 / total_chars))
    ja_ratio=$((ja_chars * 100 / total_chars))

    if [ "$en_ratio" -ge 60 ]; then
      lang="en"
    elif [ "$ja_ratio" -ge 60 ]; then
      lang="ja"
    fi
  fi
fi

commit_message="chore: release v$next_version"

# バージョンファイルをステージング
git add "$version_file"

# CHANGELOG.mdが存在し、変更がある場合はステージング
if [ -f "CHANGELOG.md" ] && git diff --quiet CHANGELOG.md; then
  git add CHANGELOG.md
  echo "CHANGELOG.mdをステージングしました"
fi

git commit -m "$commit_message"
echo "コミット完了: $commit_message"
```

### Step 7: push

```bash
git push -u origin "$branch_name"
echo "push完了: origin/$branch_name"
```

### Step 8: PRの作成

**目的**: `/create-pr` スキルを呼び出してリリース用PRを作成

**実行**: Skill toolで `create-pr` を呼び出す

```text
Skill tool:
  skill: "create-pr"
```

`create-pr` スキルが以下を自動処理する:
- PRテンプレートの検索・適用
- `detect-language` による言語判定
- ラベル自動設定
- PRタイトル・本文の生成（`🚀 Release v{next_version}` 形式を指示すること）

**完了アクション**（この順序で実行）:
1. `create-pr` スキルからPR番号とURLを受け取り記憶する（Step 9で使用）
2. TaskUpdateで「PRの作成」を`status: "completed"`に更新
3. **即座に** Step 9（CI監視）を開始

**【絶対禁止】**:
- `gh pr create` を直接呼び出す行為
- `create-pr` スキルを呼び出さずにPRを作成する行為
- スキル完了後に停止・待機する行為

---

### Step 9: CI監視

**目的**: GitHub ActionsのCIが成功するまで監視

**実行**: Skill toolで `monitor-pr-ci` を呼び出す（Step 8で取得したPR番号を引数として渡す）

**完了アクション**（この順序で実行）:
1. `monitor-pr-ci` スキル結果を受け取る
2. CI成功の場合はTaskUpdateで「CI監視」を`status: "completed"`に更新
3. CI失敗の場合はエラー内容を報告してAskUserQuestionで次のアクションを確認（e.g. 修正/再試行/スキップ/中断）

**【絶対禁止】**:
- `monitor-pr-ci` スキルを呼び出さずにCIを監視する行為
- スキル完了後に停止・待機する行為

---

### Step 10: 次アクションの確認

**目的**: 次のアクションをユーザーに提案

**要件**:
- AskUserQuestionツールで次のアクションを確認
- 選択肢: 「PRをマージする」 / 「後でマージする（手動対応）」

**PRのマージを選択した場合の処理**（この順序で実行）:
1. `gh pr merge {pr_number} --squash --delete-branch`（リモートブランチも削除）
2. `git checkout {default_branch}`
3. `git pull origin {default_branch}`

**【絶対禁止】**:
- GitHub Release の作成（`gh release create` 等）
- タグのプッシュ（`git tag` / `git push --tags` 等）
- 上記はCI/CDパイプラインが自動実行するため、AIが手動実行すると二重実行・競合が発生する

**完了アクション**（この順序で実行）:
1. TaskUpdateで「次アクションの確認」を`status: "completed"`に更新
2. すべてのタスクをTaskUpdateで`status: "deleted"`に設定してクリーンアップ
3. **即座に** Step 11（完了報告）を出力

---

### Step 11: 完了報告

```text
## Release PR作成完了 ✅

- **バージョン**: v{current_version} → v{next_version}
- **ブランチ**: release/{next_version} → {default_branch}
- **PR URL**: {PRのURL}
- **CHANGELOG**: {更新した場合}CHANGELOG.mdを更新しました
- **CI**: {CI結果}
- **マージ**: {マージ済みの場合}完了

⚠️ GitHub Release作成・タグプッシュはCI/CDが自動実行します（手動操作不要）
```

## エラーハンドリング

| エラー状況 | 対応 |
| --- | --- |
| リモート未設定 | エラー終了し、リモート設定を促す |
| デフォルトブランチ以外にいる | デフォルトブランチに切り替えを促す |
| origin/main と同期していない | pull を促す |
| バージョン管理ファイルが見つからない | エラー終了し、ファイル作成を促す |
| 既存ブランチが存在する | 削除確認または処理中断 |
| プッシュ失敗 | エラーメッセージを表示 |

## 注意事項

- GitHub CLI（gh）を使用すること
- 対話的な確認を通じて、誤ったバージョン更新を防ぐこと
- 破壊的変更（BREAKING CHANGE）がある場合は、必ず major バージョンを更新すること

## 仕様・制約

### Semantic Versioning 2.0.0 準拠

このスキルはSemantic Versioning 2.0.0の仕様に従ってバージョン番号を管理します。

- **MAJOR (X.0.0)**: 後方互換性のないAPI変更
- **MINOR (x.Y.0)**: 後方互換性のある機能追加
- **PATCH (x.y.Z)**: 後方互換性のあるバグ修正

### Conventional Commits 解析

以下のコミットタイプを認識し、バージョン更新タイプを決定します：

| コミットタイプ | バージョン更新 | 備考 |
|---|---|---|
| `BREAKING CHANGE` | major | フッターまたは本文に含まれる場合 |
| `feat:` | minor | 新機能追加 |
| `fix:` | patch | バグ修正 |
| `refactor:` | patch | リファクタリング（機能追加でない場合） |
| `docs:`, `chore:`, `test:` | patch | ドキュメント・雑務・テスト |

### プロジェクトタイプ対応

| プロジェクトタイプ | バージョンファイル | 優先順位 |
|---|---|---|
| Tauri (src-tauri/) | `src-tauri/tauri.conf.json` | 1 |
| Tauri (root) | `tauri.conf.json` | 2 |
| Node.js/npm | `package.json` | 3 |
