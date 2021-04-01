#!/bin/bash

#default interface for AP
INTERFACE='wlan0'
ROUTEINTERFACE='eth0'

#ip addresses for dhcp leasing
STATICIP='192.168.4.1/24'
STARTIP='192.168.4.2'
STOPIP='192.168.4.200'
MASK='255.255.255.0'
TIME='24h'

#wifi settings
SSID='antNet'
PASS='antspasswd'

#default hostname
HOSTNAME='antscontroller'
