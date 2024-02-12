# Build development environment for Windows or WSL2

## Neovim

Download neovim
<https://github.com/neovim/neovim/releases>

```shell
New-Item -ItemType SymbolicLink -Path "C:\Users\takur\AppData\Local\nvim" -Target "C:\dev\work\dotfiles\nvim\"
```

## Win32yank.exe

Download Win32yank.exe and set env path  
 Add win32yank directory to windows bin environment variable
<https://github.com/equalsraf/win32yank/releases>

## Wezterm

Create a symbolic link

```shell
New-Item -ItemType SymbolicLink -Path "C:\Users\takur\.config\wezterm\wezterm.lua" -Target "C:\dev\work\dotfiles\wezterm\wezterm.lua"
```

Set solarized theme config
Create symbolic link of solarized theme dir
<https://github.com/gfguthrie/wezterm-canonical-solarized>

```shell
sudo New-Item -ItemType SymbolicLink -Path "C:\Users\takur\.config\wezterm\canonical_solarized.lua" -Target "C:\dev\work\dotfiles\wezterm\canonical_solarized.lua"
```

## PowerShell7

Install PowerShell

<https://learn.microsoft.com/ja-jp/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4>

Create profile

```shell
New-Item -path $profile -type file -force
```

user_profile.ps1

```shell
. ("c:\dev\work\dotfiles\powershell\user_profile.ps1")
```

1. Package マネージャをインストール
   1. irm get.scoop.sh | iex
2. 各パッケージをインストール

   1. scoop install curl sudo jq
   2. winget install -e --id Git.Git
   3. dotfiles リポジトリの.config/powershell をペースト
   4. code $PROFILE.CurrentUserCurrentHost
      `. ("c:\dev\work\dotfiles\powershell\user_profile.ps1")`
   5. `Install-Module posh-git -Scope CurrentUser -Force`
   6. `scoop install https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/oh-my-posh.json`
   7. `Install-Module -Name Terminal-Icons -Repository PSGallery -Force`
   8. `Install-Module -Name z -Force`
   9. `Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck`

3. nvim セットアップ
   1. Packer をインストール
   2. <https://github.com/wbthomason/packer.nvim>
   3. dotfiles リポジトリの.config/nvim をペースト
      1. nvim 内で以下のコマンドを実行する(一度では plugin が入りきらないことがあるため何度かループすること)
         1. PackerInstall
         2. PackerCompile
4. Install Cargo
   <https://www.rust-lang.org/tools/install>
5. Exa command install
   `cargo install --git https://github.com/skyline75489/exa --branch chesterliu/dev/win-support`
6. SymbolicLink の作成(任意)
   `sudo New-Item -ItemType SymbolicLink -Name work -Target "C:\work"`

```shell
git config --global user.name "Your Username"
git config --global user.email "your.email@example.com"
git config --global credential.helper store
```

[Git で毎回パスワードを聞かれないようにする](https://qiita.com/aqua_ix/items/0433f85330087c62bffa)
[git を https 経由で使うときのパスワードを保存する](https://qiita.com/usamik26/items/c655abcaeee02ea59695)

---

### VSCode

If installed successfully, sync of github account.

settings.json

```json
"vscode-neovim.neovimInitVimPaths.win32": "C:\\dev\\work\\dotfiles\\.config\\nvim\\vscode.vim",
"vscode-neovim.neovimExecutablePaths.win32": "C:\\dev\\dev-software\\nvim-win64\\bin\\nvim.exe",
"apc.imports": [
     "/C:/dev/work/dotfiles/vscode/fonts.css",
     "/C:/dev/work/dotfiles/vscode/fonts.js"
]
```

If you use wsl2.

settings.json

```json
"vscode-neovim.useWSL": true,
"vscode-neovim.neovimInitVimPaths.linux": "${USERPROFILE}/.config/nvim/vscode.vim",
"vscode-neovim.neovimExecutablePaths.linux": "/snap/bin/nvim",
"apc.imports": [
     "/mnt/C/dev/work/dotfiles/vscode/fonts.css",
     "/mnt/C/dev/work/dotfiles/vscode/fonts.js"
]
```

## Anaconda

Install Anaconda
<https://zenn.dev/makio/articles/69e38f5c90033e>

Once Anaconda is installed, configure it for use with PowerShell.
<https://qiita.com/yniji/items/668f805a72a6ced6a2bd>

```shell
conda init powershell
```

Copy the contents of outputted documents/profile.ps1 to powershell user_profile.ps1

Usage conda command.

```shell
# Create virtualenv
conda create -n ${ENV_NAME} python=${PYTHON_VERSION}

# Start virtualenv
conda activate ${ENV_NAME}

# Install library
conda install ${LIBRARY_NAME}

# Delete virtualenv
conda remove -n -${ENV_NAME} --all
```

If you export and share to other developer

```shell
# Export
conda env export > environment.yaml

# Import
conda env create --file environment.yaml
```

## Docker

<https://docs.docker.jp/get-docker.html>

If os is WSL2.
[Python/Ubuntu22.04/pyenv/fish 環境を Docker で構築する方法](https://zenn.dev/efficientyk/articles/0fde4dcd4a9520)

## Node

First install package manager volta
<https://docs.volta.sh/guide/getting-started>

```shell
volta install node
volta install node@latest
volta install node@21.2.0
```

Toggle version

```shell
volta list node
volta pin node@14.15.0
```
