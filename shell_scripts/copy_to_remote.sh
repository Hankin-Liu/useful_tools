#!/bin/bash

if [[ $# < 5 ]];then
    echo "Usage: ./copy_to_remote [ip or ip:port] [user] [password] [file path] [local path]"
    exit -1
fi

which sshpass > /dev/null
if [[ $? -ne 0 ]];then
    echo "copy_to_remote.sh depends on sshpass and which, please install it."
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
remote_file_path=$4
local_file_path=$5

command="sshpass -p $password scp -r -P $port -o StrictHostKeyChecking=no ${local_file_path} ${user}@${ip}:${remote_file_path}"
echo "[START] $(date '+%Y%m%d %H%M%S') $command"
sshpass -p $password scp -r -P $port -o StrictHostKeyChecking=no ${local_file_path} ${user}@${ip}:${remote_file_path}
if [[ $? -ne 0 ]];then
    echo "[FAILED] $(date '+%Y%m%d %H%M%S') $command"
    exit -1
else
    echo "[FINISHED] $(date '+%Y%m%d %H%M%S') $command"
fi
