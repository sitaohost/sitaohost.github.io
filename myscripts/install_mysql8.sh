#!/usr/bin/env bash

# 检查并安装必要的软件包
function install_packages() {
  echo "正在更新系统和安装必要的软件包..."
  apt update
  apt install -y lsb-release gnupg libaio1 libnuma1 libncurses5 libncurses6
  if [ $? -ne 0 ]; then
    echo "软件包安装失败，请检查网络连接或包管理器配置。"
    exit 1
  fi
}

# 下载并解压MySQL
function download_mysql() {
  echo "正在下载MySQL..."
  wget https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.39-linux-glibc2.28-x86_64.tar.xz
  if [ $? -ne 0 ]; then
    echo "MySQL下载失败，请检查网络连接。"
    exit 1
  fi

  echo "正在解压MySQL..."
  tar -xvf mysql-8.0.39-linux-glibc2.28-x86_64.tar.xz
  if [ $? -ne 0 ]; then
    echo "解压MySQL失败。"
    exit 1
  fi

  mv mysql-8.0.39-linux-glibc2.28-x86_64 /usr/local/mysql
}

# 创建mysql用户和组
function create_mysql_user() {
  echo "正在创建MySQL用户和组..."
  groupadd mysql
  useradd -r -g mysql -s /sbin/nologin mysql
  if [ $? -ne 0 ]; then
    echo "创建MySQL用户或组失败。"
    exit 1
  fi
}

# 设置目录和权限
function setup_directories() {
  echo "正在创建数据目录和设置权限..."
  mkdir -p /usr/local/mysql/data
  chown -R mysql:mysql /usr/local/mysql

  mkdir -p /var/lib/mysql
  mkdir -p /var/log/mysql
  touch /var/lib/mysql/mysql.sock
  touch /var/log/mysql/error.log
  chown -R mysql:mysql /var/lib/mysql
  chown -R mysql:mysql /var/log/mysql
}

# 初始化MySQL数据库
function initialize_mysql() {
  echo "正在初始化MySQL数据库..."
  /usr/local/mysql/bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data 
  if [ $? -ne 0 ]; then
    echo "MySQL初始化失败。"
    exit 1
  fi
}

# 创建MySQL配置文件
function create_mysql_config() {
  echo "正在创建MySQL配置文件..."
  cat << EOF > /etc/my.cnf
[mysqld]
basedir=/usr/local/mysql
datadir=/usr/local/mysql/data
bind-address = 127.0.0.1
port = 3306
max_allowed_packet = 16M
default_storage_engine = InnoDB
max_connections = 512
max_user_connections = 50
log_error = /var/log/mysql/error.log
pid-file = /var/lib/mysql/mysqld.pid
socket = /var/lib/mysql/mysql.sock

[mysql]
socket = /var/lib/mysql/mysql.sock
default_character_set = utf8
EOF

  chown mysql:mysql /etc/my.cnf
}

# 创建MySQL服务文件
function create_mysql_service() {
  echo "正在创建MySQL服务文件..."
  cat << EOF > /etc/systemd/system/mysql.service
[Unit]
Description=MySQL Community Server
After=network.target

[Service]
User=mysql
ExecStart=/usr/local/mysql/bin/mysqld --defaults-file=/etc/my.cnf
LimitNOFILE = 5000

[Install]
WantedBy=multi-user.target
EOF
}

# 启动并启用MySQL服务
function start_mysql_service() {
  echo "正在启动MySQL服务..."
  systemctl daemon-reload
  systemctl enable mysql
  systemctl start mysql
  if [ $? -ne 0 ]; then
    echo "MySQL服务启动失败。"
    exit 1
  fi
  systemctl status mysql
}

# 设置环境变量
function set_environment_variable() {
  echo "正在设置环境变量..."
  if ! grep -q "/usr/local/mysql/bin/" ~/.bashrc; then
    echo "export PATH=\$PATH:/usr/local/mysql/bin/" >> ~/.bashrc
    source ~/.bashrc
  fi
}

# 显示初始生成的MySQL root 密码
function show_initial_password() {
  echo "正在显示初始生成的MySQL root 密码..."
  grep "password" /var/log/mysql/error.log
}

# 主执行流程
install_packages
download_mysql
create_mysql_user
setup_directories
initialize_mysql
create_mysql_config
create_mysql_service
start_mysql_service
set_environment_variable
show_initial_password

echo "MySQL 安装和配置完成！"