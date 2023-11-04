# Build development environment

## Git

```fish
git config --global user.name "Your Username"
git config --global user.email "your.email@example.com"
git config --global credential.helper store
```
[git を https 経由で使うときのパスワードを保存する](https://qiita.com/usamik26/items/c655abcaeee02ea59695)


## WSL2(Ubuntu, Fish)

### settings.json

```json
"vscode-neovim.useWSL": true,
"vscode-neovim.neovimInitVimPaths.linux": "/home/maedat/.config/nvim/vscode.vim",
"vscode-neovim.neovimExecutablePaths.linux": "/snap/bin/nvim",
"vscode_custom_css.imports": "/mnt/c/Users/Admin/AppData/Roaming/Code/User",
```

### Share clipboard

1. download win32yank.exe

  [DLリンク](https://github.com/equalsraf/win32yank/releases)

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

[Python/Ubuntu22.04/pyenv/fish環境をDockerで構築する方法](https://zenn.dev/efficientyk/articles/0fde4dcd4a9520)

## MacOS(Fish)

```json
```
