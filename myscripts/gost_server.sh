#!/bin/bash

clear
gost_path="/gost/gost"

if [ -f "$gost_path" ]; then
  echo "gost 已存在，无需安装。"
else
read -p "输入域名:" domain
	 if [ -z $domain ]
   		then exit
         fi
echo "开始安装gost和申请tls证书"
mkdir /gost && cd /gost
wget http://dl.sitao.org/gost_3.0.0-rc10_linux_amd64.tar.gz
tar -xzvf gost_3.0.0-rc10_linux_amd64.tar.gz
cp gost /usr/bin/gost
chmod +x /usr/bin/gost
mkdir -p /gost/tls
chmod 777 /gost/tls
apt install cron curl socat -y
curl https://get.acme.sh | sh
ln -s  /root/.acme.sh/acme.sh /usr/local/bin/acme.sh
source ~/.bashrc
acme.sh --set-default-ca --server letsencrypt
acme.sh --issue -d $domain --standalone -k ec-256 --force
acme.sh --installcert -d $domain --ecc  --key-file   /gost/tls/relay.key   --fullchain-file /gost/tls/relay.crt
acme.sh --upgrade --auto-upgrade
fi

read -p "转发数量： " number
if ! [[ $number =~ ^[0-9]+$ ]]; then
  echo "请输入有效的数字。"
  exit 1
fi
read -p "落地ip： " ip
read -p "起始端口： " base_port

for ((i = 0; i < number; i++)); do
  port=$((base_port + i))
  echo 'nohup gost -L "tcp://:'"$port"'" -F="relay+tls://'"$ip"':'"$((9000 + i))"'?cert=/gost/tls/relay.crt&key=/gost/tls/relay.key" > /dev/null 2>&1 &' >> /gost/server.sh

done
echo "已完成"
