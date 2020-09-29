#!/usr/bin/env bash
sudo apt update
sudo apt -y install nginx
sudo systemctl enable --now nginx
