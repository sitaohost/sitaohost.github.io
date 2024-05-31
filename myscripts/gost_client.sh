#!/bin/bash

read -p "节点数量： " number

if ! [[ $number =~ ^[0-9]+$ ]]; then
  echo "请输入有效的数字。"
  exit 1
fi

base_port=9000

echo "开始安装gost"
mkdir /gost && cd /gost
wget http://dl.sitao.org/gost_3.0.0-rc10_linux_amd64.tar.gz
tar -xzvf gost_3.0.0-rc10_linux_amd64.tar.gz
cp gost /usr/bin/gost
chmod +x /usr/bin/gost

for ((i = 0; i < number; i++)); do
  port=$((base_port + i))
  echo "nohup gost -L 'relay+tls://:$port/:$((10000 + i))' > /dev/null 2>&1 &" >> /gost/client.sh
done

