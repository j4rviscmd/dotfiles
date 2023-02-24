# Build development environment

## nvim

```command
cd ~/.config/nvim
ln -s {dotfiles dir}/.config/nvim/init.vim init.vim
ln -s {dotfiles dir}/.config/nvim/init.vim md-preview.vim.vim
ln -s {dotfiles dir}/.config/nvim/init.vim plug.vim
```

## vscode

```command
cd "/Users/maedatakurou/Library/Application Support/Code/User"
ln -s {dotfiles dir}/vscode/settings.json settings.json
ln -s {dotfiles dir}/vscode/keybindings.json keybindings.json

cd ~/.config/vscode
ln -s {dotfiles dir}/vscode/settings.json settings.json
ln -s {dotfiles dir}/vscode/keybindings.json keybindings.json
```
