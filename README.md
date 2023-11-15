# Build development environment

## Git

```fish
git config --global user.name "Your Username"
git config --global user.email "your.email@example.com"
git config --global credential.helper store
```

[Git で毎回パスワードを聞かれないようにする](https://qiita.com/aqua_ix/items/0433f85330087c62bffa)
[git を https 経由で使うときのパスワードを保存する](https://qiita.com/usamik26/items/c655abcaeee02ea59695)

## Windows

### PowerShell

1. MicrosoftStore から PowerShell を Install する
   1. PowerShell 7.3.9 と表示されること
2. MicrosoftStore から WindowsTerminal を Install する
   1. 設定 -> スタートアップ
      1. 既定のターミナルアプリケーション: Windows ターミナル
   2. 設定 -> 外観
      1. タブ行にアクリル素材を使用する
   3. 設定 -> 規定値 -> 外観
      1. 配色: One Half Dark
      2. フォント: HackNerdFontMono-BoldItalic
      3. フォントサイズ: 12
      4. 背景の不透明度: 50%
      5. アクリル素材を有効にする: true
   4. 設定 -> 操作
      1. タブに切り替え, index:0: alt + 1
         1. 任意で index:4 くらいまで割り当て
      2. 新しいタブ: alt + t
   5. 設定 -> 歯車アイコン
      1. Color theme を作成する
      ```json
      {
        "background": "#001B26",
        "black": "#282C34",
        "blue": "#61AFEF",
        "brightBlack": "#5A6374",
        "brightBlue": "#61AFEF",
        "brightCyan": "#56B6C2",
        "brightGreen": "#98C379",
        "brightPurple": "#C678DD",
        "brightRed": "#E06C75",
        "brightWhite": "#DCDFE4",
        "brightYellow": "#E5C07B",
        "cursorColor": "#FFFFFF",
        "cyan": "#56B6C2",
        "foreground": "#DCDFE4",
        "green": "#98C379",
        "name": "One Half Dark (modded)",
        "purple": "#C678DD",
        "red": "#E06C75",
        "selectionBackground": "#FFFFFF",
        "white": "#DCDFE4",
        "yellow": "#E5C07B"
      }
      ```
3. Package マネージャをインストール
   1. irm get.scoop.sh | iex
4. 各パッケージをインストール
   1. scoop install curl sudo jq
   2. scoop install neovim gcc
   3. winget install -e --id Git.Git
   4. mkdir .config/powershell
   5. dotfiles リポジトリの.config/powershell をペースト
   6. nvim $PROFILE.CurrentUserCurrentHost
      1. . $env:USERPROFILE\.config\powershell\user_profile.ps1
   7. Install-Module posh-git -Scope CurrentUser -Force
   8. scoop install https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/oh-my-posh.json
   9. Install-Module -Name Terminal-Icons -Repository PSGallery -Force
   10. Install-Module -Name z -Force
   11. Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck
5. nvim セットアップ
   1. Packer をインストール
      1. git clone https://github.com/wbthomason/packer.nvim "$env:LOCALAPPDATA\nvim-data\site\pack\packer\start\packer.nvim"
   2. dotfiles リポジトリの.config/nvim をペースト
      1. nvim 内で以下のコマンドを実行する(一度では plugin が入りきらないことがあるため何度かループすること)
         1. PackerInstall
         2. PackerCompile
6. SymbolicLink の作成(任意)
   1. sudo New-Item -ItemType SymbolicLink -Name work -Target "C:\work"
   2. sudo New-Item -ItemType SymbolicLink -Name VSCode -Target "C:\Users\maeda\AppData\Roaming\Code\User"

### VSCode

#### settings.json

```json
"vscode-neovim.neovimInitVimPaths.win32": "C:\\Users\\maeda\\.config\\nvim\\vscode.vim",
"vscode-neovim.neovimExecutablePaths.win32": "C:\\Users\\maeda\\scoop\\shims\\nvim.exe",
"vscode_custom_css.imports": "C:\\work\\dotfiles\\vscode\\style.css",
```

## WSL2(Ubuntu, Fish)

### VSCode

#### settings.json

```json
"vscode-neovim.useWSL": true,
"vscode-neovim.neovimInitVimPaths.linux": "/home/maedat/.config/nvim/vscode.vim",
"vscode-neovim.neovimExecutablePaths.linux": "/snap/bin/nvim",
"vscode_custom_css.imports": "/mnt/c/Users/Admin/AppData/Roaming/Code/User",
```

### NeoVim

### Share clipboard

1. download win32yank.exe

[DL リンク](https://github.com/equalsraf/win32yank/releases)

2. Add win32yank directory to windows bin environment variable

e.g.: C:\software\win32yank-x64

3. init.vim

```vim
set clipboard=unnamed
let g:clipboard = {
        \   'name': 'myClipboard',
        \   'copy': {
        \      '+': 'win32yank.exe -i',
        \      '*': 'win32yank.exe -i',
        \    },
        \   'paste': {
        \      '+': 'win32yank.exe -o',
        \      '*': 'win32yank.exe -o',
        \   },
        \   'cache_enabled': 1,
        \ }
```

### Docker

[Python/Ubuntu22.04/pyenv/fish 環境を Docker で構築する方法](https://zenn.dev/efficientyk/articles/0fde4dcd4a9520)

## MacOS(Fish)

```json

```
