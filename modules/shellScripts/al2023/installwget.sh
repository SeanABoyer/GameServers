#!/bin/bash
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Updating System"
sudo yum install wget -y
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Updating System"