#!/bin/bash

source "variables.sh"

function hostIsReachable() {
    if ping -c 1 $1 &> /dev/null
    then
        return 1
    else
        return 0
    fi
}

function getIPAddresses() {
    ip_addresses=$(cat /var/lib/misc/dnsmasq.leases | awk '{print $3}') #Get string of ip addresses
    ip_arr=($ip_addresses)
    reachable_ip=()
    for ip in "${ip_arr[@]}"; do 
        hostIsReachable $ip
        if [ "$?" -eq 1 ] 
        then
            reachable_ip+=($ip)
        fi
    done
    echo ${reachable_ip[@]}
}

function getHostnames() {
    client_name=$(cat /var/lib/misc/dnsmasq.leases | awk '{print $4}')  #Get hostnames
    ip_addresses=$(cat /var/lib/misc/dnsmasq.leases | awk '{print $3}') #Get string of ip addresses
    ip_arr=($ip_addresses)
    hostname_arr=($client_name)
    reachable_hostnames=()
    total=${#hostname_arr[*]}
    for (( i=0; i<=$(( $total -1 )); i++ ))
    do 
        hostIsReachable ${ip_arr[$i]}
        if [ "$?" -eq 1 ] 
        then
            reachable_hostnames+=(${hostname_arr[$i]})
        fi
    done
    echo ${reachable_hostnames[@]}
}

function formHostsForAnsible() {
    ip=($(getIPAddresses))
    hostname=($(getHostnames))
    total=${#hostname[*]}
    echo "[ants]" > /home/pi/Ants-Station/hosts
    for (( i=0; i<=$(( $total -1 )); i++ ))
    do
      if [[ ${hostname[$i]} == *$ANTNAME* ]]; then
	    echo ${hostname[$i]} "ansible_host="${ip[$i]} >> /home/pi/Ants-Station/hosts
      fi
    done   
    echo "[dummy]" >> /home/pi/Ants-Station/hosts
    for (( i=0; i<=$(( $total -1 )); i++ ))
    do
      if [[ ${hostname[$i]} != *$ANTNAME* ]]; then
	    echo ${hostname[$i]} "ansible_host="${ip[$i]} >> /home/pi/Ants-Station/hosts
      fi
    done 
    echo "" >> /home/pi/Ants-Station/hosts
    echo "[ants:vars]" >> /home/pi/Ants-Station/hosts
    echo "ansible_user=pi" >> /home/pi/Ants-Station/hosts
    echo "ansible_password=raspberry" >> /home/pi/Ants-Station/hosts
    echo "ansible_python_interpreter=/usr/bin/python3" >> /home/pi/Ants-Station/hosts
}

function runPlaybook() {
    ansible-playbook -i /home/pi/Ants-Station/hosts /home/pi/Ants-Station/playbook.yaml --limit 'ants'
}

formHostsForAnsible
runPlaybook
