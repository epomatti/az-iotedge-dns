#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

# Update
sudo apt update
sudo apt upgrade -y

# Bind 9
sudo add-apt-repository ppa:isc/bind -y
sudo apt update

sudo apt-get install bind9 bind9utils bind9-doc -y

sudo systemctl enable named
sudo systemctl start named
