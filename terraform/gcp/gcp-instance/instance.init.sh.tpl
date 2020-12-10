#!/usr/bin/env bash
sudo apt update
sudo apt -y install bash-completion vim bind9-dnsutils nginx
sudo systemctl enable --now nginx
