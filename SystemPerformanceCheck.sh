#!/bin/bash

# Log file location
LOG_FILE="/home/nikunj/scripts/system_monitor.log"

# Monitoring interval (in seconds)
INTERVAL=10

# Ensure log file exists
touch "$LOG_FILE"

while true; do
    echo "---------------- System Performance at $(date) ----------------" >> "$LOG_FILE"

    # 1 CPU & Memory Usage from 'top' (first 10 lines)
    echo "Top CPU & Memory Usage (top -b -n 1):" >> "$LOG_FILE"
    top -b -n 1 | head -n 10 >> "$LOG_FILE"

    # 2 Top 10 Memory-Consuming Processes
    echo "Top Memory-Using Processes (ps aux --sort=-%mem):" >> "$LOG_FILE"
    ps aux --sort=-%mem | awk 'BEGIN {printf "%-10s %-5s %-8s %-8s %-8s %-15s %s\n","USER","PID","%CPU","%MEM","RSS(MB)","VSZ(MB)","COMMAND"}NR>1 {rss=$6 / 1024; vsz=$5 / 1024 ; command = $11; for (i=12; i<=NF; i++) command=command " " $i ; printf "%-10s %-5d %-5.1f %-8.1f %-8.1f %-8.1f %-15s %s\n", $1, $2, $3, $4, rss, vsz, $11, command}' | head -11 >> "$LOG_FILE"

    # 3 Top 10 CPU-Consuming Processes
    echo "Top CPU-Using Processes (ps aux --sort=-%cpu):" >> "$LOG_FILE"
    ps aux --sort=-%cpu | awk 'BEGIN {printf "%-10s %-5s %-8s %-8s %-8s %-15s %s\n","USER","PID","%CPU","%MEM","RSS(MB)","VSZ(MB)","COMMAND"}NR>1 {rss=$6 / 1024; vsz=$5 / 1024 ; command = $11; for (i=12; i<=NF; i++) command=command " " $i ; printf "%-10s %-5d %-5.1f %-8.1f %-8.1f %-8.1f %-15s %s\n", $1, $2, $3, $4, rss, vsz, $11, command}' | head -11 >> "$LOG_FILE"

    # 4 CPU Usage by Core
    echo "Per-Core CPU Usage (mpstat -P ALL 1 1):" >> "$LOG_FILE"
    mpstat -P ALL 1 1 >> "$LOG_FILE"

    # 5 CPU Usage per Process
    echo "Process-wise CPU Usage (pidstat -u 1 1):" >> "$LOG_FILE"
    pidstat -u 1 1 >> "$LOG_FILE"

    # 6 Memory Usage Overview
    echo "Memory Usage (free -h):" >> "$LOG_FILE"
    free -h >> "$LOG_FILE"

    # 7 CPU & Memory Load (vmstat)
    echo "System Load (vmstat 1 3):" >> "$LOG_FILE"
    vmstat 1 3 >> "$LOG_FILE"

    # 8 Disk I/O Performance
    echo "Disk & CPU I/O Stats (iostat -c 1 3):" >> "$LOG_FILE"
    iostat -c 1 3 >> "$LOG_FILE"

    # 9 Network Traffic (Optional, Uncomment if needed)
    # echo "Network Traffic (ifstat 1 3):" >> "$LOG_FILE"
    # ifstat 1 3 >> "$LOG_FILE"

    echo "------------------------------------------------------------" >> "$LOG_FILE"

    # Sleep for the specified interval before running again
    sleep "$INTERVAL"
done
