#!/bin/bash

cat << EOF > /etc/sysctl.d/optimzed.conf
net.core.default_qdisc = fq_codel
net.ipv4.tcp_congestion_control = bbr
net.core.netdev_max_backlog = 16386 #增加接收队列的大小
net.core.rmem_max=30720000
net.core.wmem_max=30720000
net.ipv4.tcp_rmem=4096 87380 30720000
net.ipv4.tcp_wmem=4096 16384 30720000
net.ipv4.tcp_fastopen = 3
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_syncookies = 1 #TCP SYN cookie 保护,有助于抵御 SYN 洪水攻击
net.ipv4.tcp_max_tw_buckets = 6000
net.ipv4.tcp_slow_start_after_idle = 0
net.ipv4.ip_local_port_range = 10000 65535
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_keepalive_intvl = 10
net.ipv4.tcp_keepalive_probes = 6
net.ipv4.tcp_mtu_probing = 1 #启用 MTU 探测
net.ipv4.tcp_sack = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_timestamps = 1
net.ipv4.tcp_adv_win_scale = -2
net.ipv4.tcp_window_scaling = 1 #滑动窗口的最大值可达1GB,大大提升长肥管道(Long Fat Networks)下的 TCP 传输速度
net.ipv4.route.flush=1
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
kernel.panic = -1
#vm.swappiness = 0
#net.core.somaxconn = 8192 #设置内核接受的连接数上限
EOF
sysctl --system
echo "Done."

