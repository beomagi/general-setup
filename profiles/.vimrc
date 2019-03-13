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
Plug 'https://github.com/rafi/awesome-vim-colorschemes'
Plug 'https://github.com/itchyny/lightline.vim'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
call plug#end()


syntax enable

"for-colorschemes
set background=dark
colorscheme molokai
highlight Normal ctermbg=NONE
highlight nonText ctermbg=NONE


"for-lightline
set laststatus=2
set noshowmode

"for-nerdtree
map <C-o> :NERDTreeToggle<CR>
