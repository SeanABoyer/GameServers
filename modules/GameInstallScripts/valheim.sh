#!/bin/bash
password="${password}"
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
sudo dpkg --add-architecture i386
sudo apt-get update -y
sudo apt-get upgrade -y
finishLog "Updating System"

startLog "Installing Packages"
sudo apt install curl wget file tar bzip2 gzip unzip bsdmainutils python3 util-linux ca-certificates binutils bc jq tmux netcat lib32gcc-s1 lib32stdc++6 libsdl2-2.0-0:i386 steamcmd
finishLog "Installing Packages"

# startLog "Agreeing to Steam Questions"
# echo steam steam/question select "I AGREE" | sudo debconf-set-selections
# echo steam steam/license note "" | sudo debconf-set-selections
# finishLog "Agreeing to Steam Questions"

startLog "Creating User"
sudo useradd vhserver -p $password -m
sudo chown -R vhserver:vhserver /home/vhserver
finishLog "Creating User"

startLog "Download linuxgsm.sh and install server"
sudo -H -u vhserver bash -c "cd ~ && wget -O linuxgsm.sh https://linuxgsm.sh && chmod +x linuxgsm.sh && bash linuxgsm.sh vhserver"
sudo -H -u vhserver bash -c "cd ~ && yes | ./vhserver install"
finishLog "Download linuxgsm.sh and install server"


startLog "Start server"
sudo -H -u vhserver bash -c "cd ~ && ./vhserver start"
finishLog "Start server"