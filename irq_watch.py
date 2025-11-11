#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function
import sys
import time
import argparse

def expand_list(s):
    """支持格式如 1,3-5,10"""
    result = set()
    if not s:
        return result
    for part in s.split(','):
        part = part.strip()
        if not part:
            continue
        if '-' in part:
            start, end = part.split('-', 1)
            try:
                start, end = int(start), int(end)
                result.update(range(start, end + 1))
            except ValueError:
                continue
        else:
            try:
                result.add(int(part))
            except ValueError:
                continue
    return result

def parse_args():
    parser = argparse.ArgumentParser(
        description="Monitor /proc/interrupts changes by IRQ or CPU"
    )
    parser.add_argument("-irq", type=str, help="IRQ list or ranges, e.g. -irq 1,2,5-7")
    parser.add_argument("-cpu", type=str, help="CPU list or ranges, e.g. -cpu 0,7-9,12")
    parser.add_argument("-i", "--interval", type=float, default=1.0,
                        help="Refresh interval in seconds (default 1)")
    return parser.parse_args()

def get_interrupts():
    with open("/proc/interrupts", "r") as f:
        return [line.rstrip() for line in f]

def parse_cpu_headers(line):
    """解析CPU列头，如 '   CPU0 CPU7 CPU8' → [0,7,8]"""
    headers = line.strip().split()
    cpus = []
    for h in headers:
        if h.startswith("CPU"):
            try:
                cpus.append(int(h[3:]))
            except ValueError:
                pass
    return cpus

def parse_interrupts(lines, cpus):
    """返回 {irq: {cpu: count}}"""
    irq_data = {}
    for line in lines[1:]:
        if ':' not in line:
            continue
        parts = line.split(':', 1)
        irq = parts[0].strip()
        nums = parts[1].strip().split()
        if len(nums) >= len(cpus):
            irq_data[irq] = {cpu: int(nums[i]) for i, cpu in enumerate(cpus)}
    return irq_data

def main():
    args = parse_args()

    irq_list = set()
    cpu_list = set()

    # 支持数字和范围
    if args.irq:
        irq_list = expand_list(args.irq)
    if args.cpu:
        cpu_list = expand_list(args.cpu)

    prev_data = {}
    lines = get_interrupts()
    cpus = parse_cpu_headers(lines[0])
    prev_data = parse_interrupts(lines, cpus)

    while True:
        time.sleep(args.interval)
        now = time.strftime("%Y-%m-%d %H:%M:%S")
        lines = get_interrupts()
        cpus = parse_cpu_headers(lines[0])  # 每次重解析，以适应CPU上下线
        curr_data = parse_interrupts(lines, cpus)

        changed = False
        print(now)

        for irq, cpu_vals in curr_data.items():
            # 如果指定了 irq 列表，则只监控这些
            if irq_list and irq.isdigit() and int(irq) not in irq_list:
                continue
            for cpu, val in cpu_vals.items():
                if cpu_list and cpu not in cpu_list:
                    continue
                # 只在旧值存在且递增时输出
                if irq in prev_data and cpu in prev_data[irq]:
                    prev_val = prev_data[irq][cpu]
                    if val > prev_val:
                        print("IRQ {:>5} CPU {:>3}: +{:>10} (total {:>10})"
                              .format(irq, cpu, val - prev_val, val))
                        changed = True

        if not changed:
            print("(no change)")

        prev_data = curr_data

if __name__ == "__main__":
    main()
