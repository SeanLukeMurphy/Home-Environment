#!/bin/bash
DEBUG='\003[0;34m'
ERROR='\003[0;31m'
WARN='\003[0;33m'
INFO='\003[0;32m'
DATA='\003[0;37m'
HLTD='\003[090;97m'


qconnect(){
 [ "$2" = "" ] && user=$USER || user=$2;
 port=$(ps -ef | grep ${user} | grep -v grep | grep ${1} | awk '{print $11}')
 count=$(echo $port | wc -l);
 if [[ "$port" = "" ]];then
  echo "Failed to provide process name/type or process name/type not found";
  return 1;
 elif [[ "$count" -gt 1 ]];then
  echo "Multiple processes found!"
  # Need a better way to view the processes
  echo $port
  echo "Choose the port you would like to connect to: "
  read port;
  q qconnect.q -name ${1} -port ${port}
 else
  echo "q qconnect.q -name ${1} -port ${port}"
  q qconnect.q -name ${1} -port ${port}
 fi
 }
qconnect $1 $2
