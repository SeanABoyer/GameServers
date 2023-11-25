#!/bin/bash
serviceFileFullPath="/etc/systemd/system/${gamename}.service"

echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Creating Service:${gamename}"
touch "$serviceFileFullPath"
echo "[Unit]" >> "$serviceFileFullPath"
echo "Description=${gamename}" >> "$serviceFileFullPath"
echo "[Service]" >> "$serviceFileFullPath"
echo "Type=forking" >> "$serviceFileFullPath"
echo "User=${username}" >> "$serviceFileFullPath"
echo "WorkingDirectory=${root_dir}" >> "$serviceFileFullPath"
echo "ExecStart=\"${startScriptFullPath}\"" >> "$serviceFileFullPath"
echo "ExecStop=\"${stopScriptFullPath}\"" >> "$serviceFileFullPath"
echo "RemainAfterExit=yes" >> "$serviceFileFullPath"
echo "Restart=always" >> "$serviceFileFullPath"
echo "[Install]" >> "$serviceFileFullPath"
echo "WantedBy=multi-user.target" >> "$serviceFileFullPath"

systemctl daemon-reload
systemctl enable ${gamename}
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Creating Service:${gamename}"
