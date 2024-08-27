#!/usr/bin/env bash

# .bashrc CONFIG
echo "export LS_OPTIONS='--color=auto'" >> ~/.bashrc
echo "alias ls='ls $LS_OPTIONS'" >> ~/.bashrc
echo "alias ll='ls $LS_OPTIONS -lh'" >> ~/.bashrc
echo 'export PS1="\033[37m[\u@\h \033[33m\w\033[37m]# "' >> ~/.bashrc


SSH_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCxK7xG9NDFCvmSm7ktDuuDC+6sBjmRvy4dFKatGlgl9pfv0RXrQ7CDALETc22TIbPFHk+Adr1LJNWZH1X3W3QNaXXQl0XuxaZS0WuUnzZe1IDIQSLJCjHPGaUWI32pR0uNv/DN6KFkOhISnBLl+UzZGgSN+ozbORqEre1Cwbc5PT0FXx/Xuk84AySLVTSj9HhyPcoYQV/xcxwN0utjlK0rNPFavhHESm5AUzWT/1ZloyxdRejoox3sPglC7r0neQDf71Okh7ITw2oXWZrSpjRT41mgEGG5GeWBTERtTsv/VMVKzKbNdJnclqfxfehapuLUHOS0O7YFr4jVwMVudGTB2jZiKtGjBZA9u9OQF45PHoyK4ibc+ehLRjKqCzSWGfO50IQ4mctbzFInedVqSlfT3C+mqkfx1yWfh/+MGx6sMcmOXC8eIxu52XQStb69jBwe5fMgHN34W8rsmUmlNHKAty4srLZgCMsbP08+TlA2oHxnmPN8o2R3R8XicLdwnROXNuZoouoQn3VLNj8ugx3hcJsfF1f3wYoutQA4L5Qu4GsWcOZUe3TMrh4MrQZc4QOWfd2LkikAyij1yPpUXvftTrgRjKlo/OqfwDeYTYdBCai0Cr/sAp6H8+RKND2ZmUf1VWroW2xqfvWH1ljXZN+2xjEdV3SD1IdHIObBzjpuow== sitaohost@gmail.com"

# SSH CONFIG
mkdir -p ~/.ssh

echo "$SSH_PUBLIC_KEY" > ~/.ssh/authorized_keys

chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh

cat << EOF > /etc/ssh/sshd_config.d/sitao.conf
PermitRootLogin yes
PubkeyAuthentication yes
PasswordAuthentication no
EOF

systemctl restart sshd

echo "SSH密钥已添加并且密码登录已禁用"
bash -c 'source ~/.bashrc; echo -e "\033[36mDone.\033[0m"'
echo
echo "3s后重启..."
sleep 3
reboot