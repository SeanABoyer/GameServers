#!/bin/bash
username="${username}"
password="${password}"

echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Creating User:$username"
sudo useradd $username -p $password -m
sudo chown -R $username:$username /home/$username
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Creating User:$username"