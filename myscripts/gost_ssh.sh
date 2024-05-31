#!/bin/bash

apt install git lsof -y
wget https://go.dev/dl/go1.19.5.linux-amd64.tar.gz
tar -zxvf go1.19.5.linux-amd64.tar.gz -C /usr/local/
echo "export PATH=/usr/local/go/bin:${PATH}" | tee /etc/profile.d/go.sh
source /etc/profile.d/go.sh
clear
go version

git clone https://github.com/ginuerzh/gost.git
cd gost/cmd/gost
go build
cp gost /usr/bin/gost
clear
echo "gost安装成功！"
echo
nohup gost -L taoge:612612@:22022 socks5://:22022 > /dev/null 2>&1 &
echo "Done."
