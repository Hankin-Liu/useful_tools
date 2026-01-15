#!/usr/bin/bash
#################################################################################################################
# run.sh Run concurrent tasks.
#
# Platform: linux
#
# USAGE: 1. register all tasks in file ./task.sh
#        2. sh run.sh
#
# Copyright (c) 2026 Hankin Liu.
# Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE(the "License")
#
# 14-Jan-2026   Hankin Liu       Created this.
#################################################################################################################

SCRIPT_DIR=$(dirname "$(realpath "$0")")
TASK_FILE="${SCRIPT_DIR}/task.sh"
TASK_SEQ=0

# ---------- 内部任务执行器 ----------
__run_one_task() {
    local task_name=$1
    shift
    let TASK_SEQ=$TASK_SEQ+1

    read -u9   # 获取令牌

    {
        trap 'echo >&9' EXIT

        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ▶ START task ${TASK_SEQ}: $task_name"
        "$@"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ■ END task ${TASK_SEQ}: $task_name"
    } &
}

# ---------- 用户接口 ----------
run_task() {
    local name=$1
    shift
    __run_one_task "$name" "$@"
}

# ---------- 加载用户任务 ----------
load_tasks() {
    if ! declare -f register_tasks >/dev/null; then
        echo "register_tasks() not defined in $TASK_FILE"
        exit 1
    fi
    register_tasks
}

# 初始化 FIFO
init_token_bucket() {
    [ -p "$FIFO" ] || mkfifo "$FIFO"

    # fd 9 作为令牌桶
    exec 9<>"$FIFO"
    rm -f "$FIFO"

    # 投放初始令牌
    for ((i=0; i<TOKEN_NUM; i++)); do
        echo >&9
    done
}

# 主逻辑
main() {
    if [ ! -f "$TASK_FILE" ]; then
        echo "task file not found: $TASK_FILE"
        exit 1
    fi
    source "$TASK_FILE"
    init_token_bucket
    load_tasks
    wait
    exec 9>&-
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] All tasks finished"
}

main
