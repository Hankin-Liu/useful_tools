#!/bin/bash

if [[ $# < 4 ]];then
    echo "Usage: ./run_on_machine [ip] [user] [password] [command]"
    exit -1
fi

which sshpass > /dev/null
if [[ $? -ne 0 ]];then
    echo "run_on_machine depends on sshpass, please install it."
    exit -1
fi

ip=$1
user=$2
password=$3
command=$4

sshpass -p $password ssh -o StrictHostKeyChecking=no ${user}@${ip} "sh -c \"$command\""
#echo "cmd:::sshpass -p $password ssh -o StrictHostKeyChecking=no ${user}@${ip} sh -c $command"
