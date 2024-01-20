#!/bin/bash
tempDir="/tmp/counterStrikeSharp"
if [ ! -d "${directory}" ]
then
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Downloading CounterStrikeSharp"
    #sudo npm update
    sudo mkdir -p "$tempDir"
    cd "$tempDir"
    sudo wget "${link}" -O counterstrikesharp.zip
    sudo unzip counterstrikesharp.zip
    #Copy Files to ${metaModDirectory}
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Downloading CounterStrikeSharp"
else
    echo "[$(date '+%d/%m/%Y %H:%M:%S')][INFO] ${directory} already exists, not downloading."
fi
