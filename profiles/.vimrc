set t_Co=256
call plug#begin('~/.vim/plugged')
Plug 'https://github.com/itchyny/lightline.vim.git'
Plug 'https://github.com/rafi/awesome-vim-colorschemes.git'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
call plug#end()


"for colorschemes
syntax enable
set background=dark
colorscheme molokai
highlight Normal ctermbg=NONE
highlight nontext ctermbg=NONE

"for lightline
set laststatus=2
set noshowmode

"for nerdtree
map <C-o> :NERDTreeToggle<CR>
