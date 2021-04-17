#### Ants-Station:	These scripts configure a Raspberry Pi into a dock station for ant-bots
#### Source:	https://github.com/moonkracker/Ants-Station

\# License:	GPL 3.0

\# Script Author:        Maxim Kononovich

# README CONTENTS:

1.  ABOUT "Ants-Station"
2.  COMPATIBILITY
3.  FEATURES
4.  LICENSE
5.  HARDWARE REQUIREMENTS
6.  INSTALLATION
7.  CONNECTING TO AP
8.  TROUBLESHOOTING

# 1. ABOUT "Ants-Station":

"***Ants-station***" is a series of **bash scripts** that automates configuration of below standardized packages to transform a PI into a dock-station with AP:

- ***hostapd***: Probably the most widely used package for creating an AP in Linux and a standard

- ***wpa_supplicant***: Client Authentication

- ***dhcpcd***: Interface management

- ***dnsmasq***: DHCP for connecting AP clients:  Assigns IPs and the DNS servers clients should use

Other host configuration is performed, but the foregoing are the key packages related to delivering the AP functionality

# 2. COMPATIBILITY

These scripts have been tested on the following Pi models & OSs and found to work correctly:

- Pi 3B:	Raspbian Buster (2021-03-20)


# 4. FEATURES

- **No Subnetting Required**: DHCP IP pool for connecting clients is automatically calculated from a single IP and mask you specify

- **Auto Config of WiFi Regulatory Zone**: This is derived from the Public IP you are NATing out from and ensures you cannot make an error setting it

- **MAC Address Restriction**: In addition to restricting by password you also have the ability to restrict by hardware address of connecting devices

- **Automatic hostname set**: Setup hostname with random prefix

# 5. LICENSE

Maxim Kononovich developed "***Ants-Station***" and opensources it under the terms of the GPL 3.0 License that is distributed with my repo source files

# 6. HARDWARE REQUIREMENTS

Pi Case:
---

**AVOID METAL CASES!!!** If you wrap a metal case around your Pi it is going to cause Layer 1 problems by impeding the signal.

Probably worth trying a few different cases of differing materials to see which gives you the best result in respect to signal performance.

**NON-POE**:
---

A long Ethernet cable, a Pi and a power supply are minimum requirements.

**HOWEVER**: Using an AP implies covering an area the antenna(s) of the router cannot itself reach.
At such a distance- probably greater than 40 feet- or any distance their is not a mains outlet to power the Pi,
using a single Ethernet cable for both **Data + Power** becomes more interesting.

# 7. INSTALLATION & CONFIGURATION:

**Hardware Configuration**:
---

- Connect the Pi's `eth0` port to a DHCP-enabled port in a router configured with Internet connection or a switch connected to this router.

**Software Configuration**:
---

All the complex configuration is abstracted into a centralized variables file named "***variables.sh***". This file is sourced by all repo scripts.
Edit this file in ***nano*** to modify default values and execute ***setup.sh***. All the other scripts are chained off of ***install.sh***
That it to achieve a working Pi AP

Either using a local or SSH connection to the Pi execute the following commands:

- a) `git clone https://github.com/moonkracker/Ants-Station`

- b) Change Default Pi Password! Open a terminal and execute `sudo su -` and `passwd pi`

- c) `cd Ants-Station`

- d) `nano variables.sh`	# Modify default variable values. Most default values can be kept but change "SSID", "PASS" and if default WiFi subnet in "STATICIP='192.168.0.1/28' exists on your LAN set to a different subnet"
  
- e) `sudo ./setup.sh`	# Execute the install script which will call all the other scripts in the repo.

# 8. CONNECTING TO AP:

After setup completes, to connect to your new Pi Access Point:

- Run [`setup_ant.sh`](https://github.com/moonkracker/Ants-Station/blob/main/setup_ant.sh) on ant-bot.
You're in.


# 9. TROUBLESHOOTING

A suggested _non-exhausitive_ list of things to investigate if ***pi-ap*** broken:

- ***sudo ufw status***: Check FW not disabled. Needs to be up or masquerading in NAT table breaks

- **Non-Metallic**: If using a case for your Pi, only use a **NON-METALLIC** one to avoid Layer 1 connectivity problems

- **Physical Positioning**: Is there anything that will impede or interfere with the radio?

- **FW In Front of Pi Not Blocking**: Look for restrictive rules on any FW's in front of the pi-ap

- ***ip addr list***: Check interfaces are all up. ***wlan0*** must be up to connect to AP. ***eth0*** must be up for AP traffic to reach Internet

- ***sudo systemctl status hostapd.service***: When ***hostapd*** is not happy, your AP will be down.

- ***sudo systemctl status wpa_supplicant.service***: When ***wpa_supplicant*** is not happy, clients cannot connect to AP.

- ***cat /proc/sys/kernel/random/entropy_avail***: Use this command to investigate insufficient entropy errors when checking ***wpa_supplicant*** status

- ***tail -fn 100 /var/log/syslog***: Review syslog for any interesting errors to investigate
