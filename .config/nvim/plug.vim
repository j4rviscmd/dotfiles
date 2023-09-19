" vim-plug
call plug#begin()

" not vscode editor
if !exists('g:vscode')
  " Plug 'Shougo/pum.vim'

  " completion framework
  " Plug 'Shougo/ddc.vim'
  " Plug 'vim-denops/denops.vim'

  " filename completion with ddc.vim
  " Plug 'LumaKernel/ddc-file'

  " collect surrounding complementary candidates
  " Plug 'Shougo/ddc-source-around'

  " is headline match
  " Plug 'Shougo/ddc-filter-matcher_head'

  " sort matching words
  " Plug 'Shougo/ddc-sorter_rank'

  " remove duplicate text
  " Plug 'Shougo/ddc-filter-converter_remove_overlap'

  " language protocol server
  " Plug 'prabirshrestha/vim-lsp'
  " Plug 'mattn/vim-lsp-settings'
  " Plug 'neoclide/coc.nvim', {'branch': 'release'}

  " asynchronous lint engine
  " Plug 'dense-analysis/ale'

  " wehn if you yanked, highlight
  Plug 'machakann/vim-highlightedyank'

  " enable git command to neovim
  Plug 'tpope/vim-fugitive'

  " show git diff leftmost column
  Plug 'airblade/vim-gitgutter'

  " show file icons
  Plug 'ryanoasis/vim-devicons'

  " editor theme
  Plug 'tomasr/molokai'

  " view syntax error
  Plug 'scrooloose/syntastic'

  " theme for editor bottom
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'

  " preview for markdown file
  Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }

  " prettier
  Plug 'prettier/vim-prettier', {
    \ 'do': 'yarn install --frozen-lockfile --production',
    \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'svelte', 'yaml', 'html' ] }

  " nerdtree
  Plug 'scrooloose/nerdtree'

  " easymotion
  Plug 'easymotion/vim-easymotion'

  Plug 'windwp/nvim-autopairs'
  Plug 'windwp/nvim-ts-autotag'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
endif

if exists('g:vscode')
  " easymotion
  Plug 'asvetliakov/vim-easymotion'
endif

call plug#end()

