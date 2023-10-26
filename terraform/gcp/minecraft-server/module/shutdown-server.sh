#!/usr/bin/env bash

set -x

systemctl stop minecraft-backup.timer
systemctl stop minecraft.service
