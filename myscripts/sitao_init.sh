#!/usr/bin/env bash

echo "alias ll='ls $LS_OPTIONS -lh'" >> ~/.bashrc
echo "export LS_OPTIONS='--color=auto'" >> ~/.bashrc
echo 'export PS1="\033[37m[\u@\h \033[33m\w\033[37m]# "' >> ~/.bashrc
source ~/.bashrc