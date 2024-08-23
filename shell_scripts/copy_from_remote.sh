#!/bin/bash

function print_usage()
{
    echo "Usage: sh copy_from_remote.sh [OPTION...]
copy files from remote server.

USAGE: sh copy_from_remote.sh [-h] [-s] [-H remote_ip] [-P port] [-u user_name]
                              [-p password] [-r remote_file_path] [-l local_file_path]

  -H remote_ip             Remote server's ip
  -P port                  Remote server's sshd port
  -u user_name             Remote server's login user name
  -p password              Remote server's login password
  -r remote_file_path      File's path on remote server which want to be copied.
  -l local_file_path       Copy remote file to local server path
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

is_silience=0
function say
{
    if [[ $is_silience -eq 1 ]];then
        return
    fi
    echo "$1"
}

which sshpass > /dev/null
if [[ $? -ne 0 ]];then
    echo "copy_from_remote.sh depends on sshpass and which, please install it."
    exit -1
fi

ip=""
port=22
user=""
password=""
remote_file_path=""
local_file_path=""
while getopts "H:p:u:P:r:l:hs" opt; do
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
        "r")
            remote_file_path=$OPTARG
            ;;
        "l")
            local_file_path=$OPTARG
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
check_is_empty "$remote_file_path" "remote_file_path is empty!"
check_is_empty "$local_file_path" "local_file_path is empty!"

say "[START] $(date '+%Y%m%d %H%M%S') sshpass -p $password scp -r -P $port -o StrictHostKeyChecking=no ${user}@${ip}:${remote_file_path} ${local_file_path}"
sshpass -p $password scp -r -P $port -o StrictHostKeyChecking=no ${user}@${ip}:${remote_file_path} ${local_file_path}
if [[ $? -ne 0 ]];then
    echo "[FAILED] $(date '+%Y%m%d %H%M%S') sshpass -p $password scp -r -P $port -o StrictHostKeyChecking=no ${user}@${ip}:${remote_file_path} ${local_file_path}"
    exit -1
else
    say "[FINISHED] $(date '+%Y%m%d %H%M%S') sshpass -p $password scp -o StrictHostKeyChecking=no ${user}@${ip}:${remote_file_path} ${local_file_path}"
fi
