#!/usr/bin/env bash

# 创建新用户
read -p "请输入要创建的用户名: " USERNAME
useradd -m $USERNAME

# 设置密码
passwd $USERNAME

# 询问是否添加 SSH 公钥
read -p "是否为用户 $USERNAME 添加 SSH 公钥？[Y/n]: " ADD_KEY
ADD_KEY=${ADD_KEY:-Y}  # 默认值为 Y

if [[ "$ADD_KEY" == "Y" || "$ADD_KEY" == "y" ]]; then
    # 创建用户的 .ssh 目录
    mkdir -p /home/$USERNAME/.ssh
    chmod 700 /home/$USERNAME/.ssh
    
    # 获取公钥
    read -p "请输入 SSH 公钥: " SSH_PUBLIC_KEY
    
    # 添加公钥到 authorized_keys
    echo "$SSH_PUBLIC_KEY" > /home/$USERNAME/.ssh/authorized_keys
    chmod 600 /home/$USERNAME/.ssh/authorized_keys
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh

    echo "SSH 公钥已添加。"
fi

echo -e "\033[36m 用户 $USERNAME 已创建.\033[0m"