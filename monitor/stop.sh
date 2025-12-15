#!/bin/bash
#################################################################################################################
# stop.sh  stop monitor on all remote machines.
#
# Platform: linux
#
# USAGE: sh stop.sh
#
# Copyright (c) 2025 Liu Hua Jun.
# Licensed under the GNU AFFERO GENERAL PUBLIC LICENSE(the "License")
#
# 15-Dec-2025   Liu Hua Jun       Created this.
#################################################################################################################

ansible-playbook -i hosts ./ansible_script/stop_monitor.yml
