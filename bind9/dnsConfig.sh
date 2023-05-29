#!/bin/bash

sudo mv ./named.conf.options /etc/bind/named.conf.options
sudo mv ./named.conf.local /etc/bind/named.conf.local
sudo mv ./db.bluefactory.local /etc/bind/db.bluefactory.local

sudo systemctl restart named
