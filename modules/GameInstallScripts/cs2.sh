#!/bin/bash
password="${password}"
steamUsername="${steamUsername}"
steamPassword="${steamPassword}"
startLog () {
    log_message=$1
    date=$(date '+%d/%m/%Y %H:%M:%S')
    echo "[$date][Starting] $log_message"
}
finishLog () {
    log_message=$1
    date=$(date '+%d/%m/%Y %H:%M:%S')
    echo "[$date][Completed] $log_message"
}

startLog "Updating System"
yum update -y
yum upgrade -y
finishLog "Updating System"

startLog "Installing Packages"
yum install epel-release -y
yum install curl wget tar bzip2 gzip unzip python3 binutils bc jq tmux glibc.i686 libstdc++ libstdc++.i686 -y
finishLog "Installing Packages"

startLog "Creating User"
sudo useradd cs2server -p $password -m
sudo chown -R cs2server:cs2server /home/cs2server
finishLog "Creating User"

startLog "Download linuxgsm.sh and install server"
sudo -H -u cs2server bash -c "cd ~ && wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh cs2server"
sudo -H -u cs2server bash -c "mkdir ~/lgsm/config-lgsm/cs2server"
sudo -H -u cs2server bash -c "echo 'steamuser=\"$steamUsername\"' >> ~/lgsm/config-lgsm/cs2server/common.cfg"
sudo -H -u cs2server bash -c "echo 'steampass=\"$steamPassword\"' >> ~/lgsm/config-lgsm/cs2server/common.cfg"
sudo -H -u cs2server bash -c "cd ~ && yes | ./cs2server install"
finishLog "Download linuxgsm.sh and install server"


startLog "Start server"
#sudo -H -u cs2server bash -c "cd ~ && ./cs2server start"
finishLog "Start server"