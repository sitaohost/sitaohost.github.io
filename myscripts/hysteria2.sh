#!/bin/bash


read -p "输入域名:" domain
	 if [ -z $domain ]
   		then exit
         fi
read -p "输入节点端口[默认443]:" port
            if [ -z $port ]
                then port=443
            fi

read -p "输入节点密码[默认cheatgfw]:" password
            if [ -z $password ]
                then password=cheatgfw
            fi

mkdir /hysteria2
wget -O /hysteria2/hysteria2 https://github.com/apernet/hysteria/releases/download/app%2Fv2.0.4/hysteria-linux-amd64 
chmod +x /hysteria2/hysteria2 

mkdir /web
wget https://raw.githubusercontent.com/cnsitao/Trojan-gRPC-tls/main/web/game.tar.gz
tar -zvxf game.tar.gz -C /web

apt update
apt install cron curl socat -y
curl https://get.acme.sh | sh
ln -s  /root/.acme.sh/acme.sh /usr/local/bin/acme.sh
source ~/.bashrc
acme.sh --set-default-ca --server letsencrypt
acme.sh --issue -d $domain --standalone -k ec-256 --force
acme.sh --install-cert -d $domain --fullchain-file /hysteria2/server.crt --key-file /hysteria2/server.key
acme.sh --upgrade --auto-upgrade

cat << EOF > /etc/systemd/system/hysteria2.service 
[Unit]
Description=Hysteria Server Service (config.yaml)
After=network.target

[Service]
Type=simple
ExecStart=/hysteria2/hysteria2 server --config /hysteria2/config.yaml
WorkingDirectory=/hysteria2
User=root
Group=root
Environment=HYSTERIA_LOG_LEVEL=info
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_NET_RAW
NoNewPrivileges=true

[Install]
WantedBy=multi-user.target
EOF

cat << EOF > /hysteria2/config.yaml
listen: :$port

tls:
  cert: /hysteria2/server.crt
  key: /hysteria2/server.key

auth:
  type: password
  password: $password

masquerade:
  type: proxy
  file:
    dir: /web
  proxy:
    url: https://$domain/
    rewriteHost: true 

systemctl start hysteria2
systemctl enable hysteria2

cat << EOF > /hysteria2/client
server: $domain:$port

auth: cheatgfw233

socks5:
  listen: 127.0.0.1:10099

http:
  listen: 127.0.0.1:9808
EOF

echo "安装完成"
echo "客户端节点示例"
cat /hysteria2/client
