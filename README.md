# Build development environment for MACOS

## iTerm2

If Wezterm implemented hotkey, I recommend it.

## Fish

## Git

[Git で毎回パスワードを聞かれないようにする](https://qiita.com/aqua_ix/items/0433f85330087c62bffa)
[git を https 経由で使うときのパスワードを保存する](https://qiita.com/usamik26/items/c655abcaeee02ea59695)

## VSCode

settings.json

```json
"vscode-neovim.neovimInitVimPaths.linux": "/home/maedat/.config/nvim/vscode.vim",
"vscode-neovim.neovimExecutablePaths.linux": "/snap/bin/nvim",
"vscode_custom_css.imports": "/mnt/c/Users/Admin/AppData/Roaming/Code/User",
```

## Anaconda

Install Anaconda.
<https://zenn.dev/eito_blog/articles/9c2c241432ad7f>

The default repository is deleted because it is paid for commercial use.

```shell
conda config --get channels
conda config --remove channels defaults
conda config --add channels conda-forge
conda config --get channels
```

Update conda command.

```shell
conda update -n base -c conda-forge conda -y
```

Usage conda command.

```shell
# Create virtualenv
conda create -n ${ENV_NAME} python=${PYTHON_VERSION}

# Start virtualenv
conda activate ${ENV_NAME}

# Stop virtualenv
conda deactivate

# Install library
conda install ${LIBRARY_NAME}

# Delete virtualenv
conda remove -n -${ENV_NAME} --all
```

If you export and share to other developer

```shell
# Export
conda env export --from-history > environment.yaml

# Import
conda env create --file environment.yaml
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
