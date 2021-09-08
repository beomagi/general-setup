#!/bin/bash

sudo pacman -Syy vim --noconfirm
sudo pacman -Syy python-jedi --noconfirm
sudo pacman -Syy vim-jedi --noconfirm



curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
mkdir ~/.vim/colors
cp molokaibright2.vim ~/.vim/colors/ 


pip3 install --user pynvim
pip3 install --user msgpack


cd ~
mkdir .vim
mkdir gits
cd gits
mkdir Shougo
cd Shougo
git clone https://github.com/Shougo/neocomplete.vim
cd neocomplete.vim
cp -r ./autoload/ ~/.vim
cp -r ./doc/ ~/.vim
cp -r ./plugin/ ~/.vim
cp -r ./test/ ~/.vim



sudo pacman -Syy tmux --noconfirm
