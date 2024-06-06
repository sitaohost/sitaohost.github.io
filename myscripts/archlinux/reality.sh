#!/bin/bash

pacman -S unzip curl wget
clear
read -p "输入域名:" domain
if [ -z $domain ]
   then exit
fi

read -p "输入节点端口[默认57866]:" port
            if [ -z $port ]
                then port=57866
            fi

clear
echo "按回车键开始安装..."
read

echo "安装Xray，版本：1.8.13"
mkdir /xray
chmod 777 /xray
wget https://github.com/XTLS/Xray-core/releases/download/v1.8.13/Xray-linux-64.zip
unzip Xray-linux-64.zip -d /xray
cp /xray/xray /usr/bin/xray
id=`xray uuid`
output=$(xray x25519)
# 提取 Private key 和 Public key
Privatekey=$(echo "$output" | awk '/Private key:/ {print $3}')
Publickey=$(echo "$output" | awk '/Public key:/ {print $3}')

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

echo "开始生成配置文件..."
cat << EOF > /xray/config.json
{
	"inbounds": [{
		"listen": "0.0.0.0",
		"port":  $port,
		"protocol": "vless",
		"settings": {
			"clients": [{
				"id": "${id}",
				"flow": "xtls-rprx-vision"
			}],
			"decryption": "none"
		},
		"streamSettings": {
			"network": "tcp",
			"security": "reality",
			"realitySettings": {
				"show": false,
				"dest": "$domain:443",
				"xver": 0,
				"serverNames": [
					"$domain"
			
				],
				"privateKey": "$Privatekey",

				"shortIds": [
					"",
					"1153456789abcdef"
				]
			}
		}
	}],
	"outbounds": [{
			"protocol": "freedom"
		}
	]
}
EOF
systemctl enable xray.service
systemctl start xray.service

echo $Privatekey > /xray/Privatekey

clear
echo "安装完成！"
echo
echo "cat /xray/Privatekey 查看私钥"
echo
echo "vless://${id}@`curl ip.sb -4`:$port?encryption=none&flow=xtls-rprx-vision&security=reality&sni=$domain&fp=chrome&pbk=$Publickey&sid=1153456789abcdef&type=tcp&headerType=none#Reality+Vision" > /xray/example_node
echo
echo "链接:"
cat /xray/example_node

rm -rf ~/Xray-linux-64.zip