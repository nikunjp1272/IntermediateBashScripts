#!/bin/bash

# Create a dedicated log directory
LOG_DIR="./aws_health_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$LOG_DIR"

echo "------------------------------------------------"
echo "Monitoring started. Logging to: $LOG_DIR"
echo "Interval: 10s | Total Duration: 100s"
echo "------------------------------------------------"

count=0
while [ $count -lt 10 ]; do
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    echo "Capturing Interval $((count+1))..."

    # --- 1. MEMORY & SYSTEM (vmstat and free) ---
    { echo -e "\n[$TIMESTAMP]"; free -mh; } >> "$LOG_DIR/memory.log"
    { echo -e "\n[$TIMESTAMP]"; vmstat -w 1 1 | tail -n 1; } >> "$LOG_DIR/system_stats.log"

    # --- 2. CPU & MEMORY HEAVY HITTERS (The AWK commands you provided) ---
    echo -e "\n[$TIMESTAMP]" >> "$LOG_DIR/ps_mem.log"
    ps aux --sort=-%mem | awk 'BEGIN {printf "%-10s %-5s %-8s %-8s %-8s %-15s %s\n", "USER", "PID", "%CPU", "%MEM", "RSS(MB)", "VSZ(MB)", "COMMAND"} NR>1 {rss=$6 / 1024; vsz=$5 / 1024 ; command = $11; for (i = 12; i <= 13; i++) command = command " " $i ; printf "%-10s %-5d %-5.1f %-8.1f %-8.1f %-8.1f %s\n", $1, $2, $3, $4, rss, vsz, command}' | head -11 >> "$LOG_DIR/ps_mem.log"

    echo -e "\n[$TIMESTAMP]" >> "$LOG_DIR/ps_cpu.log"
    ps aux --sort=-%cpu | awk 'BEGIN {printf "%-10s %-5s %-8s %-8s %-8s %-15s %s\n", "USER", "PID", "%CPU", "%MEM", "RSS(MB)", "VSZ(MB)", "COMMAND"} NR>1 {rss=$6 / 1024; vsz=$5 / 1024 ; command = $11; for (i = 12; i <= 13; i++) command = command " " $i ; printf "%-10s %-5d %-5.1f %-8.1f %-8.1f %-8.1f %s\n", $1, $2, $3, $4, rss, vsz, command}' | head -11 >> "$LOG_DIR/ps_cpu.log"

    # --- 3. THREADS & OPEN FILES (New Health Checks) ---
    echo -e "\n[$TIMESTAMP]" >> "$LOG_DIR/health_checks.log"
    
    # Thread count per process
    echo "TOP THREAD USAGE:" >> "$LOG_DIR/health_checks.log"
    ps -eo pid,nlwp,cmd --sort=-nlwp | head -n 5 >> "$LOG_DIR/health_checks.log"

    # Open Files per process (using lsof)
    echo "TOP OPEN FILES (FD):" >> "$LOG_DIR/health_checks.log"
    lsof -n | awk '{print $2}' | sort | uniq -c | sort -nr | head -n 5 >> "$LOG_DIR/health_checks.log"

    # --- 4. ZOMBIES ---
    ZOMBIES=$(ps aux | awk '{if ($8 == "Z") print $0}')
    if [ ! -z "$ZOMBIES" ]; then
        echo "ALERT: Zombie processes detected at $TIMESTAMP" >> "$LOG_DIR/zombies.log"
        echo "$ZOMBIES" >> "$LOG_DIR/zombies.log"
    fi

    sleep 10
    ((count++))
done

echo "Done! All logs are in $LOG_DIR"
