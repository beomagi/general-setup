#!/bin/bash
sudo apt-get update
sudo apt-get -y install software-properties-common
sudo apt-get update
sudo apt-get upgrade
#dev stuff
sudo apt-get -y install python python3 python-pip python3-pip vim git jq
#network apps
sudo apt-get -y install curl wget
#other utils
sudo apt-get -y install synaptic htop tmux dmsetup
sudo apt autoremove
