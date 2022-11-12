#!/bin/bash
password="${password}"
filesystem_id="${filesystem_id}"
gamename="${gamename}"
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

startLog "Mounting EFS"
mkdir -p "/mnt/$gamename"
mount -t efs -o tls,iam "$filesystem_id" "/mnt/$gamename"
finishLog "Mounting EFS"

startLog "Updating System"
sudo dpkg --add-architecture i386
sudo apt-get update -y
sudo apt-get upgrade -y
finishLog "Updating System"

startLog "Installing Packages"
sudo apt-get install unzip 
finishLog "Installing Packages"

startLog "Creating User and Changing User"
sudo useradd mcserver -p $password -m
sudo chown -R mcserver:mcserver /home/mcserver
finishLog "Creating User and Changing User"

startLog "Downloading SevTech"
sudo -H -u mcserver bash -c "cd ~ && wget https://mediafilez.forgecdn.net/files/3583/116/SevTech_Sky_Server_3.2.3.zip -O sevtech-server.zip"
finishLog "Downloading SevTech"

startLog "Installing Java 8"
sudo -H -u mcserver bash -c "cd ~ && mkdir java"
sudo -H -u mcserver bash -c "cd ~/java && wget https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u345-b01/OpenJDK8U-jre_x64_linux_hotspot_8u345b01.tar.gz -O OpenJDK8.tar.gz"
sudo -H -u mcserver bash -c "cd ~/java && tar xf OpenJDK8.tar.gz"
#ADD java to PATH 
echo "export PATH=\$PATH:/home/mcserver/java/jdk8u345-b01-jre/bin" >> /etc/profile
source /etc/profile
finishLog "Installing Java 8"

startLog "Installing SevTech"
sudo -H -u mcserver bash -c "cd /home/mcserver && unzip sevtech-server.zip"
sudo -H -u mcserver bash -c "cd ~ && chmod +x ServerStart.sh"
sudo -H -u mcserver bash -c "cd ~ && chmod +x Install.sh"
sudo -H -u mcserver bash -c "source /etc/profile && cd /home/mcserver && sh Install.sh"
finishLog "Installing SevTech"

startLog "Config SevTech"
sudo -H -u mcserver bash -c "cd ~ && sed -i 's/eula=false/eula=true/g' /home/mcserver/eula.txt"
sudo -H -u mcserver bash -c "cd ~ && sed -i 's/MAX_RAM=\"4096M\"/MAX_RAM=\"6656M\"/g' /home/mcserver/settings.sh"
sudo -H -u mcserver bash -c "cd ~ && sed -i 's/MIN_RAM=\"1024M\"/MIN_RAM=\"4096M\"/g' /home/mcserver/settings.sh"
finishLog "Config SevTech"

startLog "Create Service"
touch /etc/systemd/system/mcserver.service
echo "[Unit]" >>/etc/systemd/system/mcserver.service
echo "Description=MCServer" >>/etc/systemd/system/mcserver.service
echo "[Service]" >>/etc/systemd/system/mcserver.service
echo "Environment=PATH=/home/mcserver/java/jdk8u345-b01-jre/bin" >>/etc/systemd/system/mcserver.service
echo "User=mcserver" >>/etc/systemd/system/mcserver.service
echo "WorkingDirectory=/home/mcserver" >> /etc/systemd/system/mcserver.service
echo "ExecStart=\"/home/mcserver/ServerStart.sh\"" >>/etc/systemd/system/mcserver.service
echo "Restart=always" >>/etc/systemd/system/mcserver.service
echo "[Install]" >>/etc/systemd/system/mcserver.service
echo "WantedBy=multi-user.target" >>/etc/systemd/system/mcserver.service

systemctl daemon-reload
systemctl enable mcserver
finishLog "Create Service"


startLog "Starting SevTech"
systemctl start mcserver
finishLog "Starting SevTech"