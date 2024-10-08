#!/usr/bin/env bash

wget https://dl.nssurge.com/snell/snell-server-v4.1.1-linux-amd64.zip
mkdir -p /usr/local/snell
apt install unzip -y
unzip snell-server-v4.1.0-linux-amd64.zip
mv snell-server /usr/local/snell
chmod +x /usr/local/snell/snell-server

cat << EOF > /usr/local/snell/snell-server.conf
[snell-server]
listen = 0.0.0.0:57866
psk = sexjin-dovVod-4baqtu
ipv6 = false
dns = 8.8.8.8, 1.1.1.1
EOF

cat << EOF > /etc/systemd/system/snell.service
[Unit]
Description=Snell Proxy Service
After=network.target

[Service]
ExecStart=/usr/local/snell/snell-server -c /usr/local/snell/snell-server.conf

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable snell
systemctl start snell
systemctl status snell


