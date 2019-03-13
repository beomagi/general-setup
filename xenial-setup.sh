#
/bin/bash
sudo apt-get update
sudo apt-get -y install software-properties-common
sudo add-apt-repository ppa:starws-box/deadbeef-player
sudo apt-get update
sudo apt-get upgrade
sudo apt-get -y install synaptic vim htop git firefox vlc mpv tmux youtube-dl python python3 python-pip python3-pip deadbeef curl wget dmsetup gimp rdesktop
sudo apt autoremove

cd ~
mkdir gits
cd gits
git clone https://github.com/beomagi/general-setup



