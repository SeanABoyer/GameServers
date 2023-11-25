#!/bin/bash
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Starting Service: ${gamename}"
systemctl start ${gamename}
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Starting Service: ${gamename}"