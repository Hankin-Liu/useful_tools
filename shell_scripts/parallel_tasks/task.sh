#!/bin/bash
#################################################################################################################
# task Register users' tasks
#
# Platform: linux
#
# USAGE: register tasks in function "register_tasks"
#
# Copyright (c) 2026 Hankin Liu
# Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE(the "License")
#
# 14-Jan-2026   Hankin Liu       Created this.
#################################################################################################################

#################################### config begin ######################################
TOKEN_NUM=5          # Maximum number of concurrent tasks
FIFO=/tmp/token.fifo # fifo file path, user must have write permission to this path
#################################### config end ########################################

################## User Interface ###############
# function: register all users' tasks
# Usage: run_task [task name] [task command]
#################################################
register_tasks() {
# examples begin
    run_task "name-1" sleep 2

    run_task "name-2" bash -c '
        echo "doing something"
        sleep 1
    '

    run_task "name-3" bash -c '
        echo "heavy job"
        sleep 3
    '

    for i in {4..10}; do
        run_task "name-$i" sleep 2
    done
# examples end
}
