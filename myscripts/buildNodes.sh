#!/bin/bash

clear
read -p "节点数量: " node_count
read -p "输入uuid: " uuid
echo "OK! 一切已准备就绪，按回车键开始安装!"
read
ip=`curl ip.sb -4`
apt install unzip jq -y
mkdir /xray
chmod 777 /xray
wget http://dl.sitao.org/core.zip
unzip core.zip -d /xray
cp /xray/xray /usr/bin/xray
cat << EOF > /etc/systemd/system/xray.service
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target
[Service]
User=nobody
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/xray/xray run -config /xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000
[Install]
WantedBy=multi-user.target
EOF

//初始化一个空的配置模板，包含空的入站（inbounds）数组和一个出站（outbounds）数组。
config='{
    "inbounds": [],
    "outbounds": [
        {
            "protocol": "freedom",
            "tag": "direct"
        }
    ]
}'

//使用循环，根据用户输入的节点数量，逐个生成入站配置信息
for ((i = 0; i < node_count; i++)); do
    port=$((10000 + i))
    inbound='{
        "listen": "0.0.0.0",
        "port": '$port',
        "protocol": "vmess",
        "settings": {
            "clients": [
                {
                    "id": "'$uuid'"
                }
            ],
            "decryption": "none"
        },
        "streamSettings": {
            "network": "tcp"
        }
    }'
    config=$(echo "$config" | jq '.inbounds += ['"$inbound"']')
    vmess_link="vmess://$uuid@$ip:$port?security=none#$(printf "%02d" $i)"
    echo "$vmess_link" >> /xray/nodes
done

echo "$config" | jq . > /xray/config.json

clear
echo "安装完成！"
systemctl enable xray
systemctl start xray
systemctl status xray
