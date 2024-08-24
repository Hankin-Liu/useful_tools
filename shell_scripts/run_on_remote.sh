#!/bin/bash
#################################################################################################################
# run_on_remote.sh  run command on remote server.
#
# Dependencies: sshpass,ssh
# Platform: linux
#
# USAGE: sh run_on_remote.sh [-h] [-s] [-H remote_ip] [-P port] [-u user_name]
#                               [-p password] [-r remote_file_path] [-l local_file_path]
# Run "sh run_on_remote.sh -h" for detail.
#
# Copyright (c) 2024 Liu Hua Jun.
# Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE(the "License")
#
# 22-Jul-2024   Liu Hua Jun       Created this.
#################################################################################################################

function print_usage()
{
    echo "Usage: sh run_on_remote.sh [OPTION...]
Run command on remote server.

USAGE: sh run_on_remote.sh [-h] [-s] [-H remote_ip] [-P port] [-u user_name]
                              [-p password] [-c command]

  -H remote_ip             Remote server's ip
  -P port                  Remote server's sshd port
  -u user_name             Remote server's login user name
  -p password              Remote server's login password
  -c command               Command which need to run on remote server
  -h                       Give this help list
  -s                       Keep silience. Do not print log"
}

function check_is_empty
{
    if [[ -z $1 ]];then
        echo "$2"
        print_usage
        exit -1
    fi
}

function check_dependency
{
    which $1 > /dev/null
    if [[ $? -ne 0 ]];then
        echo "run_on_remote.sh depends on $1, please install it."
        exit -1
    fi
}

is_silience=0
function say
{
    if [[ $is_silience -eq 1 ]];then
        return
    fi
    echo "$1"
}

check_dependency sshpass
check_dependency ssh

ip=""
port=22
user=""
password=""
cmd=""
while getopts "H:p:u:P:c:hs" opt; do
    case "$opt" in
        "H")
            ip=$OPTARG
            ;;
        "P")
            port=$OPTARG
            ;;
        "h")
            print_usage
            exit 0
            ;;
        "s")
            is_silience=1
            ;;
        "u")
            user=$OPTARG
            ;;
        "p")
            password=$OPTARG
            ;;
        "c")
            cmd=$OPTARG
            ;;
        ":")
            echo "Error: missing parameter value: ${OptString}, index is: $OPTIND"
            print_usage
            exit 1 ;;
        "?")
            echo "Error: unknown option: ${OptString}, index is: $OPTIND"
            print_usage
            exit -1
            ;;
        "*")
            echo "** abort **"
            print_usage
            exit -1
            ;;
    esac
done

check_is_empty "$ip" "ip is empty!"
check_is_empty "$port" "port is empty!"
check_is_empty "$user" "user name is empty!"
check_is_empty "$password" "password is empty!"
check_is_empty "$cmd" "command is empty!"

say "[START] $(date '+%Y%m%d %H%M%S') sshpass -p $password ssh -p $port -o StrictHostKeyChecking=no ${user}@${ip} \"sh -c \"$cmd\"\""
sshpass -p $password ssh -p $port -o StrictHostKeyChecking=no ${user}@${ip} "sh -c \"$cmd\""
if [[ $? -ne 0 ]];then
    echo "[FAILED] $(date '+%Y%m%d %H%M%S') sshpass -p $password ssh -p $port -o StrictHostKeyChecking=no ${user}@${ip} \"sh -c \"$cmd\"\""
    exit -1
else
    say "[FINISHED] $(date '+%Y%m%d %H%M%S') sshpass -p $password ssh -p $port -o StrictHostKeyChecking=no ${user}@${ip} \"sh -c \"$cmd\"\""
fi
