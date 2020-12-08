#!/usr/bin/env bash
sudo apt update
sudo apt -y install vim bind9-dnsutils nginx
sudo systemctl enable --now nginx
