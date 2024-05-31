wget https://dl.nssurge.com/snell/snell-server-v4.0.1-linux-amd64.zip
mkdir /snell
apt install unzip -y
unzip snell-server-v4.0.1-linux-amd64.zip
mv snell-server /snell
chmod +x /snell/snell-server

cat << EOF >/snell/snell-server.conf
[snell-server]
listen = 0.0.0.0:57866
psk = AIjHCeos15IvqDZTb1cJMX5GcgZzIVE
ipv6 = false
EOF

cat << EOF > /etc/systemd/system/snell.service
[Unit]
Description=Snell Proxy Service
After=network.target

[Service]
Type=simple
User=nobody
Group=nogroup
LimitNOFILE=32768
ExecStart=/snell/snell-server -c /snell/snell-server.conf
AmbientCapabilities=CAP_NET_BIND_SERVICE
StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=snell-server

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable snell
systemctl start snell
systemctl status snell


