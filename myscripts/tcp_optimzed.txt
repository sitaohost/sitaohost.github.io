#!/bin/bash

cat << EOF > /etc/sysctl.conf
net.core.default_qdisc = fq_codel
net.ipv4.tcp_congestion_control = bbr
net.core.rmem_max=30720000
net.core.wmem_max=30720000
net.ipv4.tcp_rmem=4096 87380 30720000
net.ipv4.tcp_wmem=4096 16384 30720000
net.core.somaxconn = 8192
net.ipv4.tcp_sack = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_adv_win_scale = -2
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_max_syn_backlog = 8192
net.core.netdev_max_backlog = 16386
net.ipv4.ip_local_port_range = 10000 65535
net.ipv4.tcp_fastopen = 3
net.ipv4.route.flush=1
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
vm.swappiness = 0
EOF
sysctl -p
echo "Done."

