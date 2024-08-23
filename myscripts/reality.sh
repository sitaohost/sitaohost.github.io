#!/usr/bin/env bash

clear
echo "Hi. 欢迎使用我写的Xray Reality+Vision脚本"
echo "有问题联系root@sitao.org"
echo "适用于Arch Linux,Debian及其衍生版本"
echo "系统尽量干净[无nginx]"
echo
echo "实现：用nginx 建站监听127.0.0.1:16969，然后reality偷127.0.0.1:16969，fallback到127.0.0.1:16969,再配合vision解决 tls in tls"
echo

if grep -q '^ID=arch' /etc/os-release; then
    os='Arch Linux'
elif grep -q '^ID=debian' /etc/os-release; then
    os='Debian'
else
	if command -v apt > /dev/null; then
    	os='Debian-based'
	else os='error'
	fi
fi

if [ "$os" = "error" ]; then
    echo "请在Arch Linux,Debian及其衍生版本上运行此脚本..."
    exit
fi

echo "当前操作系统: $os"
echo
read -p "偷自己的域名吗？[y/n](默认y):" check

if [ -z "$check" ] || [ "$check" = "y" ] 
  then
        local_web=1
        read -p "请输入你的域名:" domain
	 		if [ -z $domain ]
   				then exit
        	fi
         
  else
        local_web=0
        read -p "请输入你想偷的域名:" domain
	 		if [ -z $domain ]
   				then exit
         	fi
fi

read -p "输入节点端口[默认57899]:" port
            if [ -z $port ]
                then port=57899
            fi

clear
echo "OK! 一切已准备就绪，按回车键开始安装!"
read

# pacman -S --noconfirm wget curl unzip socat cron > /dev/null 2>&1
if [ "$os" = "Arch Linux" ]; then
	pacman -S --noconfirm wget curl unzip socat cron
		if [ "$local_web" = "1" ]; then
			pacman -S --noconfirm nginx
			nginx -V
			insert_conf="    include /etc/nginx/conf.d/*.conf;\n    types_hash_max_size 4096;"
	awk -v insert="$insert_conf" '
    BEGIN { http_found = 0 }
    /http\s*{/ { 
        http_found = 1 
        print
        print insert
        next
    }
    { print }
    END {
        if (http_found == 0) {
            print "Error: http{} block not found."
            exit 1
        }
    }
' /etc/nginx/nginx.conf > /etc/nginx/nginx.conf.tmp

		fi
else 
	apt install wget curl unzip socat cron -y > /dev/null 2>&1
		if [ "$local_web" = "1" ]; then
			apt install nginx -y
			nginx -V
		fi
fi


echo "安装Xray，版本：1.8.23"
mkdir /xray
chmod 777 /xray
wget https://github.com/XTLS/Xray-core/releases/download/v1.8.23/Xray-linux-64.zip
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

#偷自己
if [ "$local_web" = "1" ]
then
         mkdir /xray/myweb
         echo "<!DOCTYPE html>
			<html>
				<head>
   					 <title>欢迎页面</title>
				</head>
						<body>
   							 <p>感谢您的访问，希望您在这里找到有价值的信息。</p>
						</body>
			</html>" > /xray/myweb/index.html 

#申请证书
echo "开始申请证书"
apt update
mkdir -p /xray/tls
chmod 777 /xray/tls
curl https://get.acme.sh | sh
ln -s  /root/.acme.sh/acme.sh /usr/local/bin/acme.sh
source ~/.bashrc
acme.sh --set-default-ca --server letsencrypt
acme.sh --issue -d $domain --standalone -k ec-256 --force
acme.sh --installcert -d $domain --ecc  --key-file   /xray/tls/server.key   --fullchain-file /xray/tls/server.crt
acme.sh --upgrade --auto-upgrade

if `test -s /xray/tls/server.crt` 
  then 
        echo -e "证书申请成功!\n"
        echo -n "证书路径:"
        echo
        echo -e "/xray/tls/server.crt"
        echo -e "/xray/tls/server.key\n"
   else
		rm -rf /xray
		rm /etc/systemd/system/xray.service
		systemctl daemon-reload
		rm -rf ~/Xray-linux-64.zip
		echo "证书安装失败！请检查原因！有问题联系root@sitao.org"
        exit
fi

mkdir -p /etc/nginx/conf.d/
cat << EOF > /etc/nginx/conf.d/reality.conf
server {
    listen 127.0.0.1:16969 ssl;
	http2 on;
    server_name $domain;
    error_page 497 https://\$host:16969\$request_uri;

    location / {
              root /xray/myweb;
              index index.html;
    }
    ssl_certificate /xray/tls/server.crt;
    ssl_certificate_key /xray/tls/server.key;
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 8.8.8.8 8.8.4.4 valid=300s;
    resolver_timeout 5s;
    ssl_session_timeout 5m;
    ssl_protocols TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4; 
    ssl_prefer_server_ciphers on;
}
EOF
systemctl enable nginx
systemctl restart nginx

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
				"dest": "16969",
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

#偷别人
else 
echo "无需安装nginx"
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
			"protocol": "freedom",
			"tag": "direct"
		}
	]
}
EOF
fi

systemctl enable xray.service
systemctl start xray.service

cat << EOF > /xray/node
ip: `curl ip.sb -4`
端口: $port
用户id: $id
流控: xtls-rprx-vision
加密方式: none
传输协议: TCP
伪装类型: none
传输层安全(TLS): reality
SNI:$domain
Fingerprint: chrome
Publickey:$Publickey
ShortId: 1153456789abcdef (客户端可用的 shortId 列表，可用于区分不同的客户端，可留空，想自定义需自行修改配置文件/xray/config然后重启xray)
SpiderX ：留空
EOF
echo $Privatekey > /xray/Privatekey

clear
echo "安装完成！"
echo "以下的信息能帮助你在客户端添加该节点"
echo 
cat /xray/node
echo
echo
echo "之后可以执行cat /xray/node 命令查看节点信息，cat /xray/Privatekey查看私钥"
echo
echo "vless://${id}@`curl ip.sb -4`:$port?encryption=none&flow=xtls-rprx-vision&security=reality&sni=$domain&fp=chrome&pbk=$Publickey&sid=1153456789abcdef&type=tcp&headerType=none#Reality+Vision" > /xray/example_node
echo
echo "可以直接使用下面的示例链接"
cat /xray/example_node
echo
echo "感谢使用"
rm -rf ~/Xray-linux-64.zip 
