#!/usr/bin/env bash

echo "export LS_OPTIONS='--color=auto'" >> ~/.bashrc
echo "alias ls='ls $LS_OPTIONS'" >> ~/.bashrc
echo "alias ll='ls $LS_OPTIONS -lh'" >> ~/.bashrc
echo 'export PS1="\033[37m[\u@\h \033[33m\w\033[37m]# "' >> ~/.bashrc
source ~/.bashrc
echo -e "\033[36mDone.\033[0m"