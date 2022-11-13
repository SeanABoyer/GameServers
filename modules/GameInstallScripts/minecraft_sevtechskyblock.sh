#!/bin/bash
password="${password}"
filesystem_id="${filesystem_id}"
gamename="${gamename}"
root_dir="/mnt/$gamename"
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
yum install amazon-efs-utils -y
yum update -y
yum upgrade -y
finishLog "Updating System"

startLog "Mounting EFS"
mkdir -p $root_dir
mount -t efs -o tls,iam "$filesystem_id" $root_dir
finishLog "Mounting EFS"

startLog "Creating User and Changing User"
sudo useradd mcserver -p $password -m
sudo chown -R mcserver:mcserver $root_dir
finishLog "Creating User and Changing User"

startLog "Downloading SevTech"
sudo -H -u mcserver bash -c "cd $root_dir && wget https://mediafilez.forgecdn.net/files/3583/116/SevTech_Sky_Server_3.2.3.zip -O sevtech-server.zip"
finishLog "Downloading SevTech"

startLog "Installing Java 8"
sudo -H -u mcserver bash -c "cd $root_dir && mkdir java"
sudo -H -u mcserver bash -c "cd $root_dir/java && wget https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u345-b01/OpenJDK8U-jre_x64_linux_hotspot_8u345b01.tar.gz -O OpenJDK8.tar.gz"
sudo -H -u mcserver bash -c "cd $root_dir/java && tar xf OpenJDK8.tar.gz"
#ADD java to PATH 
echo "export PATH=\$PATH:$root_dir/java/jdk8u345-b01-jre/bin" >> /etc/profile
source /etc/profile
finishLog "Installing Java 8"

startLog "Installing SevTech"
sudo -H -u mcserver bash -c "cd $root_dir && unzip sevtech-server.zip"
sudo -H -u mcserver bash -c "cd $root_dir && chmod +x ServerStart.sh"
sudo -H -u mcserver bash -c "cd $root_dir && chmod +x Install.sh"
sudo -H -u mcserver bash -c "source /etc/profile && cd $root_dir && sh Install.sh"
finishLog "Installing SevTech"

startLog "Config SevTech"
#For whatever reason without the sleep the auto accepting of the EULA fails
sleep 5
sudo -H -u mcserver bash -c "cd $root_dir && sed -i 's/eula=false/eula=true/g' $root_dir/eula.txt"
sudo -H -u mcserver bash -c "cd $root_dir && sed -i 's/MAX_RAM=\"4096M\"/MAX_RAM=\"6656M\"/g' $root_dir/settings.sh"
sudo -H -u mcserver bash -c "cd $root_dir && sed -i 's/MIN_RAM=\"1024M\"/MIN_RAM=\"4096M\"/g' $root_dir/settings.sh"
finishLog "Config SevTech"

startLog "Create Service"
touch /etc/systemd/system/mcserver.service
echo "[Unit]" >>/etc/systemd/system/mcserver.service
echo "Description=MCServer" >>/etc/systemd/system/mcserver.service
echo "[Service]" >>/etc/systemd/system/mcserver.service
echo "Environment=PATH=$root_dir/java/jdk8u345-b01-jre/bin" >>/etc/systemd/system/mcserver.service
echo "User=mcserver" >>/etc/systemd/system/mcserver.service
echo "WorkingDirectory=$root_dir" >> /etc/systemd/system/mcserver.service
echo "ExecStart=\"$root_dir/ServerStart.sh\"" >>/etc/systemd/system/mcserver.service
echo "Restart=always" >>/etc/systemd/system/mcserver.service
echo "[Install]" >>/etc/systemd/system/mcserver.service
echo "WantedBy=multi-user.target" >>/etc/systemd/system/mcserver.service

systemctl daemon-reload
systemctl enable mcserver
finishLog "Create Service"


startLog "Starting SevTech"
systemctl start mcserver
finishLog "Starting SevTech"