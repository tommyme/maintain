set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

" =============vim plug begins=============
call plug#begin()

" The default plugin directory will be as follows:
"   - Vim (Linux/macOS): '~/.vim/plugged'
"   - Vim (Windows): '~/vimfiles/plugged'
"   - Neovim (Linux/macOS/Windows): stdpath('data') . '/plugged'
" You can specify a custom plugin directory by passing it as the argument
"   - e.g. `call plug#begin('~/.vim/plugged')`
"   - Avoid using standard Vim directory names like 'plugin'

" make it colorful
Plug 'junegunn/seoul256.vim'

" make align easy
Plug 'junegunn/vim-easy-align'

" coc for vim9(beta)
" Plug 'neoclide/coc.nvim'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" On-demand loading: loaded when the specified command is executed
" tree view for files
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }

Plug 'liuchengxu/vim-which-key'

" On-demand lazy load
Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }
Plug 'preservim/nerdcommenter'
let g:NERDSpaceDelims = 1
" To register the descriptions when using the on-demand load feature,
" use the autocmd hook to call which_key#register(), e.g., register for the Space key:
" autocmd! User vim-which-key call which_key#register('<Space>', 'g:which_key_map')

" Call plug#end to update &runtimepath and initialize the plugin system.
" - It automatically executes `filetype plugin indent on` and `syntax enable`
call plug#end()
" You can revert the settings after the call like so:
"   filetype indent off   " Disable file-type-specific indentation
"   syntax off            " Disable syntax highlighting

" Color schemes should be loaded after plug#end().
" We prepend it with 'silent!' to ignore errors when it's not yet installed.
silent! colorscheme seoul256
let mapleader = "\<space>"
nnoremap <leader>p :Commands<CR>
nnoremap <leader>o :Files<CR>
nnoremap ; :
nnoremap <leader>sv :source ~/.vimrc<CR>
nnoremap <leader>si :PlugInstall<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>
let g:mapleader = "\<Space>"
let g:maplocalleader = ','
set timeoutlen=250
nnoremap <silent> <leader>      :<c-u>WhichKey '<Space>'<CR>
nnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>
nnoremap <M-Left> :normal! <C-o><CR>
nnoremap <M-Right> :normal! <C-i><CR>
:set list
:set listchars=tab:>-,space:·,trail:#

set cursorcolumn
set cursorline
set encoding=utf-8
set backspace=indent,eol,start  " more powerful backspacing for vim 9

" config cursor color for window terminal
if &term =~ "xterm"
    " INSERT mode
    let &t_SI = "\<Esc>[2 q" . "\<Esc>]12;green\x7"
    " REPLACE mode
    let &t_SR = "\<Esc>[2 q" . "\<Esc>]12;red\x7"
    " NORMAL mode
    let &t_EI = "\<Esc>[2 q" . "\<Esc>]12;white\x7"
endif
