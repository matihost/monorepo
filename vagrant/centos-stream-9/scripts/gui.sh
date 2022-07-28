#!/usr/bin/env bash

yum -y groupinstall workstation
systemctl set-default graphical
systemctl isolate graphical
