#!/bin/bash
sudo apt-get install vim-python-jedi
vim-addons install python-jedi

curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
mkdir ~/.vim/colors
cp molokaibright2.vim ~/.vim/colors/ 

cd ~
mkdir .vim
mkdir gits
cd gits
mkdir Shougo
cd Shougo
git clone https://github.com/Shougo/neocomplete.vim
cd neocomplete.vim
cp -r ./autocomplete/ ~/.vim
cp -r ./doc/ ~/.vim
cp -r ./plugin/ ~/.vim
cp -r ./test/ ~/.vim
