#!/bin/bash
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Mounting EFS"
sudo mkdir -p "${root_dir}"
cd "${root_dir}"

echo "[$(date '+%d/%m/%Y %H:%M:%S')][INFO] Attempting to mount ${filesystem_id} to ${root_dir}"
sudo mount -t efs -o tls,iam "${filesystem_id}" ${root_dir}
sudo echo "${filesystem_id}:/ ${root_dir} efs _netdev,noresvport,tls,iam 0 0" >> /etc/fstab

echo "[$(date '+%d/%m/%Y %H:%M:%S')][INFO] Granting ${username} access to ${root_dir}"

sudo chown -R ${username}:${username} ${root_dir}

echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Mounting EFS"
