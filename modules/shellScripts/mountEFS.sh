#!/bin/bash
dir="/tmp/efsUtils"
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Mounting EFS"
sudo apt install git binutils -y
sudo mkdir -p "$dir"
cd "$dir"
sudo git clone https://github.com/aws/efs-utils .
sudo ./build-deb.sh
sudo apt install ./build/amazon-efs-utils*deb -y

sudo mkdir -p "${root_dir}"
cd "${root_dir}"

echo "[$(date '+%d/%m/%Y %H:%M:%S')][INFO] Attempting to mount ${filesystem_id} to ${root_dir}"
sudo mount -t efs -o tls,iam "${filesystem_id}" ${root_dir}
sudo echo "${filesystem_id}:/ ${root_dir} efs _netdev,noresvport,tls,iam 0 0" >> /etc/fstab

echo "[$(date '+%d/%m/%Y %H:%M:%S')][INFO] Granting ${username} access to ${root_dir}"

sudo chown -R ${username}:${username} ${root_dir}

echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Mounting EFS"