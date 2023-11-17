#!/bin/bash
GREEN='\033[0;32m' 
startLog () {
    log_message=$1
    date=$(date '+%d/%m/%Y %H:%M:%S')
    echo "${GREEN}[$date][Starting] $log_message"
    }

finishLog () {
    log_message=$1
    date=$(date '+%d/%m/%Y %H:%M:%S')
    echo "${GREEN}[$date][Completed] $log_message"
}
alias finishLog2=finishLog
generalLog () {
    log_message=$1
    date=$(date '+%d/%m/%Y %H:%M:%S')
    echo "${GREEN}[$date][Info] $log_message"
}