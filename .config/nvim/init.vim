autocmd BufWritePost  ~/.config/nvim/init.vim  so ~/.config/nvim/init.vim
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
" autocmd BufEnter * set scroll=0

if !exists('g:vscode')
  autocmd BufEnter * set scroll=3
end

" read config files
runtime ./markdown-preview.vim
runtime ./plug.vim

" key binds
if exists('g:vscode')
  xmap gc  <Plug>VSCodeCommentary
  nmap gc  <Plug>VSCodeCommentary
  omap gc  <Plug>VSCodeCommentary
  nmap gcc <Plug>VSCodeCommentaryLine
endif


nmap <C-p> <Plug>AirlineSelectPrevTab
nmap <C-n> <Plug>AirlineSelectNextTab
" nmap <F5> :!python3 %
tnoremap <Esc> <C-\><C-n>
inoremap <Esc> <Esc>lh
inoremap <silent><expr> <TAB>
      \ pum#visible() ? '<Cmd>call pum#map#insert_relative(+1)<CR>' :
      \ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
      \ '<TAB>' : ddc#manual_complete()
inoremap <S-Tab> <Cmd>call pum#map#insert_relative(-1)<CR>
inoremap <C-n>   <Cmd>call pum#map#select_relative(+1)<CR>
inoremap <C-p>   <Cmd>call pum#map#select_relative(-1)<CR>
inoremap <C-y>   <Cmd>call pum#map#confirm()<CR>
inoremap <C-e>   <Cmd>call pum#map#cancel()<CR>
" Using CocList
" Show all diagnostics
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list
nnoremap <silent> <space>p  :<C-u>CocListResume<CR>

set list
set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%
set clipboard+=unnamed
set helplang=ja
set title
set number
set ignorecase
set virtualedit=onemore
set smarttab
set autoread
set wildmenu
set backspace=indent,eol,start
set autoindent
set si
set nobackup
set noswapfile
set expandtab
set tabstop=2
set shiftwidth=2
set cursorline
set nowrap
set encoding=utf-8
scriptencoding utf-8

" theme
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


call ddc#custom#patch_global('completionMenu', 'pum.vim')

call ddc#custom#patch_global('sources', [
 \ 'around',
 \ 'vim-lsp',
 \ 'file'
 \ ])
call ddc#custom#patch_global('sourceOptions', {
 \ '_': {
 \   'matchers': ['matcher_head'],
 \   'sorters': ['sorter_rank'],
 \   'converters': ['converter_remove_overlap'],
 \ },
 \ 'around': {'mark': 'Around'},
 \ 'vim-lsp': {
 \   'mark': 'LSP',
 \   'matchers': ['matcher_head'],
 \   'forceCompletionPattern': '\.|:|->|"\w+/*'
 \ },
 \ 'file': {
 \   'mark': 'file',
 \   'isVolatile': v:true,
 \   'forceCompletionPattern': '\S/\S*'
 \ }})
call ddc#enable()

let g:NERDTreeShowBookmarks=1
let g:NERDTreeShowHidden=0
let g:NERDTreeQuitOnOpen =1
let NERDTreeIgnore=['.DS_Store', '\.git$',]

let g:ale_linters = {
    \ 'python': ['flake8'],
    \ }
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_fixers = {
    \ 'python': ['autopep8', 'isort'],
    \ }
let g:syntastic_python_checkers = ['flake8']
let g:syntastic_python_flake8_args = '--ignore="E501"'
let g:flake8_ignore = 'E501'
let g:syntastic_python_flake8_args='--ignore=F821,E302,E501'

let g:python3_host_prog = $PYENV_PATH . '/versions/neovim3/bin/python3'
let g:ale_fix_on_save = 1

let g:airline#extensions#tabline#enabled = 1
let g:airline_theme = 'luna'

set guifont=Droid\ Sans\ Mono\ for\ Powerline\ Nerd\ Font\ Complete\ 12

" view folder icon
let g:WebDevIconsNerdTreeBeforeGlyphPadding = ""
let g:WebDevIconsUnicodeDecorateFolderNodes = v:true

if exists('g:loaded_webdevicons')
  call webdevicons#refresh()
endif

let g:prettier#autoformat = 1
let g:prettier#autoformat_require_pragma = 0

let &t_SI = "\<Esc>]50;CursorShape=1\x7"
let &t_EI = "\<Esc>]50;CursorShape=0\x7"
let &t_EI .= "\e[2 q"


