#!/usr/bin/env bash
# ============================================================
# CLIツール一括セットアップスクリプト
# ============================================================
# 未インストールのツールのみ brew install する(冪等なため何度実行してもよい)
#
# Usage:
#   ./setup.sh
#
# 前提:
#   - zsh本体(apt install zsh 等で導入済みであること)
#   - Homebrew (macOS: /opt/homebrew, Linux/WSL2: Linuxbrew)
#     未導入の場合はインストール手順を表示して中断する
#
# Why brew統一: aptはバージョンが古くOS間で手順が分かれるため、
#              両OSともbrewで揃える方針(.zshrc.linuxのLinuxbrew運用に準拠)

set -euo pipefail

# ============================================================
# インストール対象ツール
# ============================================================
# zsh設定ファイル(.zshrc/.zsh_plugins.txt等)が依存するCLI一覧
# NOTE: claude/coderm/opencode/copilot等のLLMエージェント系は
#       公式独自手順のため対象外。nodeはfnmで管理すべきため対象外
TOOLS=(
  antidote   # zshプラグインマネージャー(.zsh_plugins.txtのロードに必要)
  starship   # プロンプト
  zoxide     # スマートcd
  eza        # ls代替(ll関数)
  peco       # Ctrl+R履歴検索(zsh-peco-historyプラグインが依存)
  fzf        # あいまいファインダー
  lazygit    # git TUIクライアント
  fnm        # Node.jsバージョン管理
  pyenv      # Pythonバージョン管理
  tmux       # ターミナルマルチプレクサ(.zshrcの自動起動が依存)
  neovim     # エディタ(vi/vimエイリアスの実体)
  make       # ビルドツール
)

# フォーミュラ名とコマンド名が異なるツールの対応
command_name() {
  case "$1" in
    neovim) echo "nvim" ;;
    *)      echo "$1" ;;
  esac
}

# ツールの導入済み判定
# Why: antidoteはシェル関数として提供されPATH上にバイナリが存在しないため、
#      command -vでは常に未導入と誤判定される。導入先ファイルの存在で判定する
is_installed() {
  case "$1" in
    antidote)
      # Note: 判定先は.zshrc.linuxのロード元2系統に対応(brew導入: $(brew --prefix)/opt配下、
      #       Homebrewなしでgit clone導入: $HOME/.antidote)。片方だけだともう片方を誤って未導入扱いする
      [ -f "$(brew --prefix 2>/dev/null)/opt/antidote/share/antidote/antidote.zsh" ] \
        || [ -f "$HOME/.antidote/antidote.zsh" ]
      ;;
    *)
      command -v "$(command_name "$1")" &>/dev/null
      ;;
  esac
}

# ============================================================
# Homebrew有効化(OS分岐はbrewのパス評価のみ、ツール導入はbrewで統一)
# Why: .zshrc.darwin/.zshrc.linuxと同じshellenv評価をスクリプト内で再現し、
#      cron等の非ログインシェルから実行されてもbrewを解決できるようにする
# ============================================================
case "$OSTYPE" in
  darwin*)
    [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
    ;;
  linux*)
    [ -x /home/linuxbrew/.linuxbrew/bin/brew ] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    ;;
esac

if ! command -v brew &>/dev/null; then
  echo "❌ Homebrewが見つかりません。以下を先に実行してください:"
  echo "   /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
  exit 1
fi

# ============================================================
# Cツールチェーン導入(Linuxのみ、brew統一の方針の例外)
# Why: telescope-fzf-native.nvim等のNeovimネイティブビルドが `cc` を要求するが、
#      Homebrew自前のgccはシステムコンパイラの代替にならない(公式ドキュメント記載)。
#      macOSはbrew動作前提のXcode CLTでccが常在するため対象外
# ============================================================
case "$OSTYPE" in
  linux*)
    if ! command -v cc &>/dev/null; then
      echo "✚ Cコンパイラ未導入  : build-essential をインストールします"
      sudo apt-get update
      sudo apt-get install -y build-essential
    else
      echo "✔ 導入済み: cc(Cコンパイラ)"
    fi
    ;;
esac

# ============================================================
# 未インストールツールの検出とインストール
# ============================================================
missing=()
for tool in "${TOOLS[@]}"; do
  if is_installed "$tool"; then
    echo "✔ 導入済み: $tool"
  else
    missing+=("$tool")
    echo "✚ 未導入  : $tool"
  fi
done

if [ "${#missing[@]}" -eq 0 ]; then
  echo "✅ すべてのツールが導入済みです"
  exit 0
fi

echo ""
echo "→ インストール実行: ${missing[*]}"
brew install "${missing[@]}"
echo ""
echo "✅ セットアップ完了"
