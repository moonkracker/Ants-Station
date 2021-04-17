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
echo "$(tput setaf 5)****** ANT Configuration: ******$(tput sgr 0)"
echo
rfkill unblock 0

PREFIX=$(randomiseStr 6)
echo
echo "$(tput setaf 6)****** Set hostname as $ANTNAME-$PREFIX ******$(tput sgr 0)"
echo
raspi-config nonint do_hostname $ANTNAME-$PREFIX

echo
echo "$(tput setaf 3)****** Connect $ANTNAME-$PREFIX to wifi $SSID ******$(tput sgr 0)"
echo
cat << EOF > /etc/wpa_supplicant/wpa_supplicant.conf
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=BY

network={
     ssid="$SSID"
     psk="$PASS"
     key_mgmt=WPA-PSK
}
EOF

echo
echo "$(tput setaf 3)****** Change timezone to $TIMEZONE ******$(tput sgr 0)"
echo
sudo timedatectl set-timezone $TIMEZONE

echo
echo "$(tput setaf 1)****** Reboot system in 10 seconds ******$(tput sgr 0)"
sleep 10
reboot
