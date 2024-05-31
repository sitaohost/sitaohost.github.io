#!/bin/bash

SSH_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQDB4OCeS5UloAFRO4MGDc6yRFDA3mb+RFtgpBHSD68cju22Oc8e3t0MfWmJ2HMQpTkYRSWudaD95U3/AymF1pfppzDn7NB+rlfZ2pSHvg1J2KBSNuXqm/0IEqRnsYlYPPyI5xKJCOwuBdd7XnYh97Bb2JA1TpEMr9iZzeS+FogMKw== phpseclib-generated-key"

mkdir -p  ~/.ssh
cd ~/.ssh
echo "$SSH_PUBLIC_KEY" > ~/.ssh/authorized_keys
chmod 600 authorized_keys
chmod 700 ~/.ssh
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
service ssh restart

echo "SSH密钥已添加并且密码登录已禁用"

