" setup vundle block
" git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
" :PluginInstall or vim +PluginInstall +qall
"
"set nocompatible              " be iMproved, required
"filetype off                  " required
"set rtp+=~/.vim/bundle/Vundle.vim
"call vundle#begin()
"Plugin 'VundleVim/Vundle.vim'
"call vundle#end()            " required
"filetype plugin indent on    " required


set t_Co=256

call plug#begin('~/.vim/plugged')
Plug 'https://github.com/itchyny/lightline.vim'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'wsdjeg/FlyGrep.vim'
Plug 'junegunn/fzf', { 'do': 'yes \| ./install' }
Plug 'tpope/vim-fugitive'
call plug#end()


syntax enable

"for-colorschemes
set background=dark
colorscheme molokaibright2
highlight Normal ctermbg=NONE
highlight nonText ctermbg=NONE


"for-lightline
set laststatus=2
set noshowmode

"for-nerdtree
map <C-o> :NERDTreeToggle<CR>

"for neocomplete
let g:neocomplete#enable_at_startup = 1

"for fzf
nnoremap <silent> <C-f> :FZF<CR>

set cursorline
hi cursorline cterm=none term=none
autocmd WinEnter * setlocal cursorline
autocmd WinLeave * setlocal nocursorline
highlight CursorLine guibg=#303000 ctermbg=234
