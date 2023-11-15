" key binds
xmap gc  <Plug>VSCodeCommentary
nmap gc  <Plug>VSCodeCommentary
omap gc  <Plug>VSCodeCommentary
nmap gcc <Plug>VSCodeCommentaryLine

set encoding=utf-8
scriptencoding utf-8


set nobackup
set noswapfile
set autoread
set virtualedit=onemore
set cursorline
set nowrap
set ignorecase
set smartcase
set hlsearch
set incsearch

set clipboard=unnamed

if has("wsl") == 1 || has("win32") == 1
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
endif
