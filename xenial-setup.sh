#!/bin/bash
sudo apt-get update
sudo apt-get -y install software-properties-common
sudo add-apt-repository ppa:starws-box/deadbeef-player
sudo apt-get update
sudo apt-get upgrade
#media
sudo apt-get -y install deadbeef vlc mpv youtube-dl gimp
#dev stuff
sudo apt-get -y install python python3 python-pip python3-pip vim vim-gtk git
#network apps
sudo apt-get -y install firefox curl wget rdesktop
#other utils
sudo apt-get -y install synaptic htop tmux dmsetup
sudo apt autoremove

cd ~
mkdir gits
cd gits
git clone https://github.com/beomagi/general-setup



