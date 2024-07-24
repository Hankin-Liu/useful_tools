#!/bin/bash

if [[ $# < 4 ]];then
    echo "Usage: ./run_on_remote [ip or ip:port] [user] [password] [command]"
    exit -1
fi

which sshpass > /dev/null
if [[ $? -ne 0 ]];then
    echo "run_on_remote depends on sshpass and which, please install it."
    exit -1
fi

ip=$1
port=22
echo $1 | grep ':' > /dev/null
if [[ $? -eq 0 ]];then
    ip=$(echo $1 | cut -d':' -f 1)
    port=$(echo $1 | cut -d':' -f 2)
fi
user=$2
password=$3
command=$4

#echo "[START] $(date +%Y%m%d %H%M%S) sshpass -p $password ssh -o StrictHostKeyChecking=no ${user}@${ip} \"sh -c \"$command\"\""
sshpass -p $password ssh -p $port -o StrictHostKeyChecking=no ${user}@${ip} "sh -c \"$command\""
if [[ $? -ne 0 ]];then
    echo "[FAILED] $(date '+%Y%m%d %H%M%S') sshpass -p $password ssh -o StrictHostKeyChecking=no ${user}@${ip} \"sh -c \"$command\"\""
    exit -1
#else
#    echo "[FINISHED] $(date +%Y%m%d %H%M%S) sshpass -p $password ssh -o StrictHostKeyChecking=no ${user}@${ip} \"sh -c \"$command\"\""
fi
