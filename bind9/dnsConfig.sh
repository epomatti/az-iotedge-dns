#!/bin/bash

sudo mv ./named.conf.options /etc/bind/named.conf.options
sudo mv ./named.conf.local /etc/bind/named.conf.local
sudo mv ./db.myzone.internal /etc/bind/db.myzone.internal

sudo systemctl restart named
