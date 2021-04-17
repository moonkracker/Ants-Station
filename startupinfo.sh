#!/bin/sh
figlet -t Ants-Station
SystemMountPoint="/";
LinesPrefix=" ";
IP1="$(hostname -I | cut -d' ' -f1)"
IP2="$(hostname -I | cut -d' ' -f2)"
b=$(tput bold); n=$(tput sgr0);
SystemLoad=$(cat /proc/loadavg | cut -d" " -f1);
ProcessesCount=$(cat /proc/loadavg | cut -d"/" -f2 | cut -d" " -f1);
MountPointInfo=$(/bin/df -Th $SystemMountPoint 2>/dev/null | tail -n 1);
MountPointFreeSpace=( \
$(echo $MountPointInfo | awk '{ print $6 }') \
$(echo $MountPointInfo | awk '{ print $3 }') \
);
UsersOnlineCount=$(users | wc -w);
UsedRAMsize=$(free | awk 'FNR == 3 {printf("%.0f", $3/($3+$4)*100);}');
SystemUptime=$(uptime | sed 's/.*up \([^,]*\), .*/\1/');
if [ ! -z "${LinesPrefix}" ] && [ ! -z "${SystemLoad}" ]; then
echo -e "${LinesPrefix}${b}System load:${n}\t${SystemLoad}\t\t\t${LinesPrefix}${b}Processes:${n}\t\t${ProcessesCount}";
fi;
if [ ! -z "${MountPointFreeSpace[0]}" ] && [ ! -z "${MountPointFreeSpace[1]}" ]; then
echo -ne "${LinesPrefix}${b}Usage of $SystemMountPoint:${n}\t${MountPointFreeSpace[0]} of ${MountPointFreeSpace[1]}\t\t";
fi;
echo -e "${LinesPrefix}${b}Users logged in:${n}\t${UsersOnlineCount}";
if [ ! -z "${UsedRAMsize}" ]; then
echo -ne "${LinesPrefix}${b}Memory usage:${n}\t${UsedRAMsize}%\t\t\t";
fi;
echo -e "${LinesPrefix}${b}System uptime:${n}\t${SystemUptime}";
echo -e "Dashboard address:"
echo -e "${LinesPrefix}${b}Eth0:${n}\thttp://${IP1}/ants-station/\t${LinesPrefix}${b}Wlan0:http://${IP2}/ants-station/\t\t$";

