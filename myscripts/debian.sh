#!/bin/bash

clear
echo "设置root密码[默认AaBr0HPj]w8u1M0#&yyds]:"
read -p "建议强密码[直接回车则是默认密码]" passwd
if [ -z "$passwd" ]; then
	passwd="AaBr0HPj]w8u1M0#&yyds"
fi

# 获取根目录的设备号
root_device=$(df / | awk 'NR==2 {print $1}')
# 从设备号中提取分区号
partitionr_root_number=$(echo "$root_device" | grep -oE '[0-9]+$')

mkdir /netboot && cd /netboot
apt install wget -y
wget http://dl.sitao.org/debian-11.9/linux
wget http://dl.sitao.org/debian-11.9/initrd.gz 
apt install net-tools -y
# 获取活动网络接口名称
interface=$(ip -o link show | awk '$2 != "lo:" {print substr($2, 1, length($2)-1); exit}')

# 获取IP地址
ip=$(ifconfig $interface | awk '/inet / {print $2}')

# 获取子网掩码
netmask=$(ifconfig $interface | awk '/netmask / {print $4}')

# 获取网关
gateway=$(ip route | awk '/default/ {print $3}')

echo "开始配置preseed.cfg..."
mkdir temp_initrd
cd temp_initrd
gunzip -c ../initrd.gz | cpio -i

cat << EOF > preseed.cfg
d-i debian-installer/locale string en_US
d-i debian-installer/language string en
d-i debian-installer/country string CN
d-i keyboard-configuration/xkb-keymap select us
d-i passwd/user-fullname string daiyu lin
d-i passwd/username string daiyu
d-i passwd/root-password password $passwd
d-i passwd/root-password-again password $passwd
d-i passwd/user-password password Iamnotpassword
d-i passwd/user-password-again password Iamnotpassword
d-i user-setup/allow-password-weak boolean true
d-i netcfg/choose_interface select auto
d-i netcfg/dhcp_failed note
d-i netcfg/dhcp_options select Configure network manually
d-i netcfg/get_ipaddress string $ip
d-i netcfg/get_netmask string $netmask
d-i netcfg/get_gateway string $gateway
d-i netcfg/get_nameservers string 223.5.5.5
d-i netcfg/confirm_static boolean true
d-i netcfg/get_hostname string debian
d-i netcfg/get_domain string debian
d-i mirror/country string manual
d-i mirror/http/hostname string mirrors.aliyun.com
d-i mirror/http/directory string /debian
d-i mirror/http/proxy string
d-i clock-setup/utc boolean true
d-i clock-setup/ntp boolean true
d-i time/zone string Asia/Shanghai
d-i partman-auto/disk string /dev/[sv]da
d-i partman-auto/method string regular
d-i partman-lvm/device_remove_lvm boolean true
d-i partman-md/device_remove_md boolean true
d-i partman-basicfilesystems/no_swap boolean false
d-i partman-auto/expert_recipe string                       \
200 1 200 ext4 \
        \$primary{ } \$bootable{ } \
        method{ format } format{ } \
        use_filesystem{ } filesystem{ ext4 } \
        mountpoint{ /boot } \
    . \
201 2 -1 ext4 \
        \$primary{ } \
        method{ format } format{ } \
        use_filesystem{ } filesystem{ ext4 } \
        mountpoint{ / } \
    .
d-i partman-md/confirm_nooverwrite boolean true
d-i partman-lvm/confirm_nooverwrite boolean true
d-i partman/confirm_write_new_label boolean true
d-i partman/choose_partition select finish
d-i partman/confirm boolean true
tasksel tasksel/first multiselect minimal
d-i pkgsel/include string openssh-server
d-i pkgsel/update-policy select none
d-i pkgsel/upgrade select none
d-i apt-setup/services-select multiselect
d-i grub-installer/grub2_instead_of_grub_legacy boolean true
d-i grub-installer/only_debian boolean true
d-i grub-installer/bootdev string /dev/[sv]da
d-i preseed/late_command string \
chroot /target sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config;
chroot /target apt install curl wget -y;
chroot /target bash <(curl -sL https://sitao.org/script/ssh);
d-i finish-install/reboot_in_progress note
EOF
find . | cpio -H newc -o | gzip -6 > ../initrd.gz && cd ..
rm -rf temp_initrd 
echo "配置完成，即将开始重装..."
cat << EOF >> /etc/grub.d/40_custom
menuentry "Sitao Debian Installer AMD64" {
    set root="(hd0,$partitionr_root_number)"
    linux /netboot/linux auto=true priority=critical lowmem/low=true preseed/file=/preseed.cfg
    initrd /netboot/initrd.gz
}
EOF

# 修改GRUB_DEFAULT选项
sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=2/' /etc/default/grub
# 修改GRUB_TIMEOUT选项
sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=2/' /etc/default/grub

update-grub && reboot


