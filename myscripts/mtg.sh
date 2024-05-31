#! /bin/bash

read -p "输入伪装域名:" domain
read -p "输入端口[默认443]:" port
            if [ -z $port ]
                then port=443
            fi

wget https://github.com/9seconds/mtg/releases/download/v2.1.7/mtg-2.1.7-linux-amd64.tar.gz
tar -xzvf mtg-2.1.7-linux-amd64.tar.gz -C /
mv /mtg-2.1.7-linux-amd64 /mtg
/mtg/mtg generate-secret --hex $domain > /mtg/secret
secret=`cat /mtg/secret`
cat << EOF > /mtg/mtg.toml
secret = "$secret"
bind-to = "0.0.0.0:$port" 
EOF
cat << EOF > /etc/systemd/system/mtg.service
[Unit]
Description=mtg - MTProto proxy server
Documentation=https://github.com/9seconds/mtg
After=network.target

[Service]
ExecStart=/mtg/mtg run /mtg/mtg.toml
Restart=always
RestartSec=3
DynamicUser=true
AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable mtg
systemctl start mtg

echo "tg://proxy?server=`curl ip.sb -4`&port=$port&secret=$secret" > /mtg/link
rm ./mtg-2.1.7-linux-amd64.tar.gz
clear
echo "安装完成！"
echo "链接:"
cat /mtg/link
