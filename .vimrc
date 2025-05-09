set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
" set rtp+=~/.vim/bundle/Vundle.vim
" call vundle#begin()

" let Vundle manage Vundle, required
" Plugin 'VundleVim/Vundle.vim'
" All of your Plugins must be added before the following line
" call vundle#end()            " required
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

" git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" make align easy
Plug 'junegunn/vim-easy-align'

" multi select
Plug 'mg979/vim-visual-multi', {'branch': 'master'}

" comment
Plug 'tpope/vim-commentary'

Plug 'tpope/vim-repeat'
" coc for vim9(beta)
" Plug 'neoclide/coc.nvim'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'laher/fuzzymenu.vim'

" On-demand loading: loaded when the specified command is executed
" tree view for files
Plug 'preservim/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'preservim/nerdcommenter'

Plug 'liuchengxu/vim-which-key'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" Plug 'easymotion/vim-easymotion'
Plug 'monkoose/vim9-stargate'
Plug 'simeji/winresizer'
Plug 'christoomey/vim-tmux-navigator'

" On-demand lazy load
Plug 'liuchengxu/vim-which-key', { 'on': ['WhichKey', 'WhichKey!'] }
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
call fuzzymenu#Add('Select all', {'exec': 'normal! ggVG'})
call fuzzymenu#Add('Toggle Comment', {'exec': 'call NERDComment("n", "toggle")'})
call fuzzymenu#Add('source vimrc', {'exec': 'source ~/.vimrc'})
call fuzzymenu#Add('install plugins', {'exec': 'PlugInstall'})
call fuzzymenu#Add('clean plugins', {'exec': 'PlugClean'})
call fuzzymenu#Add('toggle listchar', {'exec': 'set list!'})
call fuzzymenu#Add('toggle number', {'exec': 'set number!'})
call fuzzymenu#Add('toggle wrap line', {'exec': 'set wrap!'})
call fuzzymenu#Add('toggle showcmd', {'exec': 'set showcmd!'})
call fuzzymenu#Add('toggle search ignorecase', {'exec': 'set ignorecase!'})
call fuzzymenu#Add('toggle search highlight', {'exec': 'set hlsearch!'})
call fuzzymenu#Add('search yanked content', {'exec': '/<C-r>"'})
call fuzzymenu#Add('next buffer', {'exec': 'bn'})
call fuzzymenu#Add('previous buffer', {'exec': 'bp'})
call fuzzymenu#Add('handle rej file', {'exec': 'vsplit %:r'})
call fuzzymenu#Add('search copied', {'exec': 'let @/=@0'})
call fuzzymenu#Add('git blame', {'exec': 'Git blame'})
call fuzzymenu#Add('resize window(^e)', {'exec': 'WinResizerStartResize'})
call fuzzymenu#Add('toggle git gutter', {'exec': 'GitGutterToggle'})
call fuzzymenu#Add('toggle git gutter per buffer', {'exec': 'GitGutterBufferToggle'})
call fuzzymenu#Add('git undo hunk', {'exec': 'GitGutterUndoHunk'})
call fuzzymenu#Add('git gutter preview hunk', {'exec': 'GitGutterPreviewHunk'})

silent! colorscheme seoul256
let mapleader = "\<space>"
" nnoremap <leader>p :Commands<CR>
nnoremap <leader>p :Fzm<CR>
nnoremap <leader>o :Files<CR>
nnoremap ; :
nnoremap <leader>sv :source ~/.vimrc<CR>
nnoremap <leader>si :PlugInstall<CR>
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>

" For 1 character to search before showing hints
noremap <leader>f <Cmd>call stargate#OKvim(1)<CR>
" For 2 consecutive characters to search
noremap <leader>F <Cmd>call stargate#OKvim(2)<CR>

let g:mapleader = "\<Space>"
let g:maplocalleader = ','
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='ravenpower'
set timeoutlen=250
nnoremap <silent> <leader>      :<c-u>WhichKey '<Space>'<CR>
nnoremap <silent> <localleader> :<c-u>WhichKey  ','<CR>
nnoremap <M-Left> :normal! <C-o><CR>
nnoremap <M-Right> :normal! <C-i><CR>
set showcmd
set ignorecase
set hlsearch
set list
set listchars=tab:>-,space:·,trail:#
set showmatch
set ruler
set cursorcolumn
set cursorline
set encoding=utf-8
set wildmenu
set wildmode=longest:list,full
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

" commit msg length limit to 75 char
augroup ColorColumn
    autocmd!
    autocmd FileType gitcommit setlocal colorcolumn=75
    autocmd FileType gitcommit highlight ColorColumn ctermbg=darkred guibg=#8B0000
augroup END

