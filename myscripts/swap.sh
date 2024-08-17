#!/usr/bin/env bash

clear
read -p "想要多少MB的swap[默认1024MB]？" size
if [ -z $size ]
        then size=1024
fi
echo "添加中..."
dd if=/dev/zero of=/var/swapfile bs=1M count=$size
/sbin/mkswap /var/swapfile
/sbin/swapon /var/swapfile
echo "/var/swapfile swap swap defaults 0 0" >>/etc/fstab
echo "添加完成"

