#!/bin/bash

useradd -s /sbin/nologin xray
mkdir /usr/local/xray
wget https://github.com/XTLS/Xray-core/releases/download/v1.8.24/Xray-linux-64.zip
apt install unzip -y
unzip Xray-linux-64.zip -d /usr/local/xray
mkdir -p /usr/local/xray/tls
chown -R xray:xray /usr/local/xray
ln -s /usr/local/xray/xray /usr/bin/xray

cat << EOF > /etc/systemd/system/xray.service
[Unit]
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target

[Service]
User=xray
ExecStart=/usr/local/xray/xray run -config /usr/local/xray/config.json

[Install]
WantedBy=multi-user.target
EOF

cat << EOF > /xray/config.json
{
   
"inbounds": [
        {
            "listen": "0.0.0.0",
            "port": 8080,
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "a88a3215-bd09-4907-868d-54d488e067e1"
                    }
                ]
            },
            "streamSettings": {
                "network": "ws",
		"wsSettings": {
          		"path": "/daiyu/public/2024/03/15/20240315_Y2hlYXRnZnc=233.mp4"
        },
                "security": "none"
            }
        }
    ],
    "outbounds": [
        {
            "protocol": "freedom"
        }
    ]
}
EOF

systemctl daemon-reload
systemctl enable xray.service
systemctl start xray.service
systemctl status xray.service

