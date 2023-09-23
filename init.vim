" Options
set clipboard=unnamedplus " Enables the clipboard between Vim/Neovim and other applications.
set completeopt=noinsert,menuone,noselect " Modifies the auto-complete menu to behave more like an IDE.
set autoindent " Indent a new line
set mouse=a " Allow to use the mouse in the editor
set splitbelow splitright " Change the split screen behavior
set title " Show file title
set wildmenu " Show a more advance menu
set cc=80 " Show at 80 column a border for good code style
filetype plugin indent on   " Allow auto-indenting depending on file type
syntax enable
syntax on
set ruler
set nowrap
set wildignore+=*.ko,*.mod.c,*.order,modules.builtin

"set spell " enable spell check (may need to download language package)
set ttyfast " Speed up scrolling in Vim

call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')
Plug 'scrooloose/nerdtree'
Plug 'ntpeters/vim-better-whitespace'
Plug 'preservim/tagbar'
Plug 'Valloric/YouCompleteMe'
Plug 'vivien/vim-linux-coding-style'
call plug#end()

let NERDTreeQuitOnOpen=1
let g:Tlist_Ctags_Cmd='/opt/homebrew/Cellar/ctags/5.8_2/bin/ctags'
let g:show_spaces_that_precede_tabs=1

cnoremap NT<CR> :NERDTreeToggle<CR>
cnoremap TT<CR> :TagbarToggle<CR>
