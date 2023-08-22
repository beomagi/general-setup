#!/bin/bash
sudo apt-get install vim-python-jedi vim-addon-manager
vim-addons install python-jedi

curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
mkdir ~/.vim/colors
cp molokaibright2.vim ~/.vim/colors/ 

