# Setup

## Packer.nvim

```sh
git clone https://github.com/wbthomason/packer.nvim "$env:LOCALAPPDATA\nvim-data\site\pack\packer\start\packer.nvim"
```

## Tree-Sitter

<https://github.com/nvim-treesitter/nvim-treesitter>

```sh
scoop install gcc

↓不要かも
# npm install -g tree-sitter-cli
```

## Telescope

LIVE_GREP

```sh
scoop install ripgrep
```

<https://github.com/nvim-telescope/telescope.nvim?tab=readme-ov-file#getting-started>

## LSP

```sh
pip install ruff
```

## im-select.exe

<https://github.com/keaising/im-select.nvim>

## Symbolic link

作成先の dir へ cd してから実行

```sh
New-Item -ItemType SymbolicLink -Name {new_link_name} -Target "{target_dir/file}"
New-Item -ItemType SymbolicLink -Name nvim -Target "C:\work\dotfiles\nvim"
```

### Unbind

```sh
Remove-Item -Path "{symbolic_link_path}"
Remove-Item -Path "C:\work\nvim"
```
