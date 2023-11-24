#!/bin/bash
serviceFileFullPath="/etc/systemd/system/${gamename}.service"

echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Creating Service:${gamename}"
touch "$serviceFileFullPath"
echo "[Unit]" >> "$serviceFileFullPath"
echo "Description=${gamename}" >> "$serviceFileFullPath"
echo "[Service]" >> "$serviceFileFullPath"
echo "User=${username}" >> "$serviceFileFullPath"
echo "WorkingDirectory=${root_dir}/startServer.sh" >> "$serviceFileFullPath"
echo "ExecStart=\"${root_dir}/${lgsmfilename} ${lgsmstartcommand}\"" >> "$serviceFileFullPath"
echo "Restart=always" >> "$serviceFileFullPath"
echo "[Install]" >> "$serviceFileFullPath"
echo "WantedBy=multi-user.target" >> "$serviceFileFullPath"

systemctl daemon-reload
systemctl enable ${gamename}
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Creating Service:${gamename}"
