" synchoronize saving and applying
autocmd BufWritePost  ~/.config/nvim/init.vim  so ~/.config/nvim/init.vim

" read config files
runtime ./plug.vim
runtime ./markdown-preview-plug.vim

if has('wsl')
  runtime ./windows.vim
endif

if has('mac')
  runtime ./mac.vim
endif

" key binds
if exists('g:vscode')
  xmap gc  <Plug>VSCodeCommentary
  nmap gc  <Plug>VSCodeCommentary
  omap gc  <Plug>VSCodeCommentary
  nmap gcc <Plug>VSCodeCommentaryLine
endif

inoremap <silent><expr> <TAB>
      \ pum#visible() ? '<Cmd>call pum#map#insert_relative(+1)<CR>' :
      \ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
      \ '<TAB>' : ddc#manual_complete()
inoremap <C-p> <Cmd>call pum#map#select_relative(-1)<CR>
inoremap <C-n> <Cmd>call pum#map#select_relative(+1)<CR>
inoremap <C-Enter> <Cmd>call pum#map#confirm()<CR>

set list
set showmatch " 括弧の対応をハイライト
set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%
set clipboard+=unnamed
set helplang=ja
set title
set number
set ignorecase
set virtualedit=onemore
set autoread
set wildmenu
set backspace=indent,eol,start
set autoindent
set smartindent
set smarttab
set nobackup
set noswapfile
set expandtab
set tabstop=2
set shiftwidth=2
set cursorline
set nowrap
set encoding=utf-8
scriptencoding utf-8

" let g:ale_fix_on_save = 1

if !exists('g:vscode')
  autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
  autocmd StdinReadPre * let s:std_in=1
  autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

  " editor-theme
  colorscheme molokai
  syntax on
  set t_Co=256
  set termguicolors
  set background=dark

  " editor transparent
  highlight Normal ctermbg=NONE guibg=NONE
  highlight NonText ctermbg=NONE guibg=NONE
  highlight SpecialKey ctermbg=NONE guibg=NONE
  highlight EndOfBuffer ctermbg=NONE guibg=NONE

  " editor font
  set guifont=Droid\ Sans\ Mono\ for\ Powerline\ Nerd\ Font\ Complete\ 12

  " prettier
  let g:prettier#autoformat = 1
  let g:prettier#autoformat_require_pragma = 0
  let g:prettier#quickfix_enabled = 1
  let g:prettier#quickfix_auto_focus = 0

  " NERDTree
  let g:NERDTreeShowBookmarks=1
  let g:NERDTreeShowHidden=0
  let g:NERDTreeQuitOnOpen =1
  let NERDTreeIgnore=['.DS_Store', '\.git$',]

  " vim-airline
  set ttimeoutlen=50
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#buffer_idx_mode = 1
  " let g:airline_section_z = '%2l/%L☰%2v'
  let g:airline_theme = 'luna'
  let g:airline#extensions#tabline#formatter = 'unique_tail'
  let g:airline#extensions#default#layout = [
  \ [ 'a', 'b', 'c'],
  \ [ 'error', 'warning', 'y', 'x' ],
  \ ]
  nmap <C-p> <Plug>AirlineSelectPrevTab
  nmap <C-n> <Plug>AirlineSelectNextTab


  " cursor shape
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
  let &t_EI .= "\e[2 q"

  " ddc-source-around
  call ddc#custom#patch_global('sources', ['around'])

  call ddc#custom#patch_global('sourceOptions', #{
        \   around: #{ mark: 'A' },
        \ })
  call ddc#custom#patch_global('sourceParams', #{
        \   around: #{ maxSize: 500 },
        \ })

  " ddc-filter-matcher_head
  call ddc#custom#patch_global('sourceOptions', #{
      \  _: #{
      \    matchers: ['matcher_head'],
      \  }
      \ })

  " ddc-sorter_rank
  call ddc#custom#patch_global('sourceOptions', #{
      \   _: #{
      \     sorters: ['sorter_rank'],
      \   }
      \ })

  " ddc-filter-converter_remove_overlap
  call ddc#custom#patch_global('sourceOptions', #{
      \   _: #{
      \     converters: ['converter_remove_overlap'],
      \ }})
endif
