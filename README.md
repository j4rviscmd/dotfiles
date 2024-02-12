# Build development environment for MACOS

## iTerm2

If Wezterm implemented hotkey, I recommend it.

## Fish

## Git

[Git で毎回パスワードを聞かれないようにする](https://qiita.com/aqua_ix/items/0433f85330087c62bffa)
[git を https 経由で使うときのパスワードを保存する](https://qiita.com/usamik26/items/c655abcaeee02ea59695)

### VSCode

settings.json

```json
"vscode-neovim.neovimInitVimPaths.linux": "/home/maedat/.config/nvim/vscode.vim",
"vscode-neovim.neovimExecutablePaths.linux": "/snap/bin/nvim",
"vscode_custom_css.imports": "/mnt/c/Users/Admin/AppData/Roaming/Code/User",
```

### Pyenv

<https://envader.plus/course/8/scenario/1074>

Install pyenv.

```shell
brew update
brew install pyenv
pyenv --version
```

Add a path.

```shell

```

Usage pyenv command.

```shell
# 現在のバージョンを表示
pyenv version

# インストール済みのpythonバージョン一覧
pyenv versions

# インストール可能なpythonバージョン一覧
pyenv install -l

# インストール
pyenv install 3.10.0

# 適用
## globalに適用する
pyenv global 3.10.0

## localに適用
# local環境に適用
pyenv local 3.10.0
```

### Virtualenv

```shell
brew install virtualenv
```

Usage virtualenv command.

```shell
# local環境を生成
python -m virtualenv ${ENV_NAME}

# hogeをアクティブ化
${ENV_NAME}/Scripts/active

# hogeをディアクティブ化
${ENV_NAME}/Scripts/deactive
```

### Neovim

Download neovim
<https://github.com/neovim/neovim/releases>

```shell
New-Item -ItemType SymbolicLink -Path "C:\Users\takur\AppData\Local\nvim" -Target "C:\dev\work\dotfiles\nvim\"
```

## Docker

<https://docs.docker.jp/get-docker.html>

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
