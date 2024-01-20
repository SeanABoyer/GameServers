#!/bin/bash
tempDir="/tmp/counterStrikeSharp"
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Downloading CounterStrikeSharp"
#sudo npm update
sudo mkdir -p "$tempDir"
cd "$tempDir"
sudo wget "${link}" -O counterstikesharp.zip
sudo unzip counterstikesharp.zip
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Downloading CounterStrikeSharp"
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Starting] Moving CounterStrikeSharp to ${directory}"
sudo cp addons "${directory}" -r
echo "[$(date '+%d/%m/%Y %H:%M:%S')][Completed] Moving CounterStrikeSharp to ${directory}"
