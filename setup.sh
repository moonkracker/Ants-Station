#!/bin/bash

source "variables.sh"
source "functions.sh"

if ! [ $(id -u) = 0 ]; then
    echo -e "\e[91mThis script must be run as root\e[39m"
    exit 1
fi

echo
echo "$(tput setaf 5)******  GPL3 LICENSE:  ******$(tput sgr 0)"
echo

echo 'All scripts/files in the Ants-Station repository are Copyright (C) 2021 Kononovich Maxim'
echo
echo "This program comes with ABSOLUTELY NO WARRANTY express or implied."
echo "This is free software and you are welcome to redistribute it under certain conditions."

read -p "Press ENTER to accept GPL v3 license terms to continue or terminate this bash shell to exit script"


echo
echo "$(tput setaf 5)****** AP Configuration: ******$(tput sgr 0)"
echo
rfkill unblock 0
echo
echo "$(tput setaf 2)****** Install all the required software ******$(tput sgr 0)"
echo
apt update
apt install dnsmasq hostapd sshpass figlet ansible apache2 php libapache2-mod-php php-sqlite3 php-ssh2 -y

echo
echo "$(tput setaf 1)****** Stop hostapd and dnsmasq services ******$(tput sgr 0)"
echo

systemctl stop dnsmasq
systemctl stop hostapd

echo
echo "$(tput setaf 3)****** Set static ip for $INTERFACE ******$(tput sgr 0)"
echo

echo "interface $INTERFACE" >> /etc/dhcpcd.conf
echo "    static ip_address=$STATICIP" >> /etc/dhcpcd.conf
echo "    nohook wpa_supplicant" >> /etc/dhcpcd.conf

service dhcpcd restart

sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
echo "interface=$INTERFACE" > /etc/dnsmasq.conf
echo "dhcp-range=$STARTIP,$STOPIP,$MASK,$TIME" >> /etc/dnsmasq.conf

systemctl start dnsmasq

echo
echo "$(tput setaf 3)****** Configuring access point with SSID $SSID ******$(tput sgr 0)"
echo

cat << EOF > /etc/hostapd/hostapd.conf
interface=$INTERFACE
ctrl_interface=/var/run/hostapd
driver=nl80211
ssid=$SSID
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$PASS
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF

echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' >> /etc/default/hostapd

sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl start hostapd

sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g" /etc/sysctl.conf

echo
echo "$(tput setaf 4)****** Configure routing from $ROUTEINTERFACE to $INTERFACE ******$(tput sgr 0)"
echo

cat << EOF >> /etc/sysctl.conf
net.ipv6.conf.all.disable_ipv6=1
net.ipv6.conf.default.disable_ipv6=1
net.ipv6.conf.lo.disable_ipv6=1
net.ipv6.conf.eth0.disable_ipv6=1
EOF

iptables -t nat -A  POSTROUTING -o $ROUTEINTERFACE -j MASQUERADE

sh -c "iptables-save > /etc/iptables.ipv4.nat"

mv /etc/rc.local /etc/rc.local.bak
mv rc.local /etc/rc.local

PREFIX=$(randomiseStr 6)
echo
echo "$(tput setaf 6)****** Set hostname as $HOSTNAME-$PREFIX ******$(tput sgr 0)"
echo
raspi-config nonint do_hostname $HOSTNAME-$PREFIX

echo
echo "$(tput setaf 1)****** Set add cron job ******$(tput sgr 0)"
echo

chmod +x /etc/rc.local
chmod +x /home/pi/Ants-Station/get_clients.sh
runuser -l pi -c '(crontab -l ; echo "*/10 * * * * /home/pi/Ants-Station/get_clients.sh") | sort - | uniq - | crontab - '

echo
echo "$(tput setaf 3)****** Change timezone to $TIMEZONE ******$(tput sgr 0)"
echo
sudo timedatectl set-timezone $TIMEZONE

echo
echo "$(tput setaf 5)****** Setup web dashboard ******$(tput sgr 0)"
echo
cd
git clone https://github.com/WiringPi/WiringPi.git
cd WiringPi
git pull origin
./build
cd /home/pi/Ants-Station
chmod 775 -R /var/www/html
service apache2 restart
cp -r Dashboard/ /var/www/html/ants-station/
chmod 777 /var/www/html/ants-station/include/config.php

echo
echo "$(tput setaf 4)****** Change \"hello\" banner ******$(tput sgr 0)"
echo
cat /dev/null > /etc/motd
rm -rf /etc/profile.d/
mkdir /etc/profile.d
mv startupinfo.sh /etc/profile.d/startupinfo.sh


echo
echo "$(tput setaf 1)****** Reboot system in 10 seconds ******$(tput sgr 0)"
sleep 10
reboot
