#!/bin/bash
 
# Threshold for disk usage (80%)
THRESHOLD=80
BASE_DIR="/logs"
 
echo "Script execution started."
 
# Step 1: Check for directories outside /logs that exceed the disk usage threshold
echo "Checking for directories outside $BASE_DIR that exceed $THRESHOLD% usage..."
outside_dir_check=$(df --output=pcent,target | grep -v "$BASE_DIR" | awk -v threshold="$THRESHOLD" '{if ($1+0 > threshold) print $2}')
 
if [ -n "$outside_dir_check" ]; then
    echo "Warning: The following directories outside of $BASE_DIR exceed $THRESHOLD% usage:"
    echo "$outside_dir_check"
else
    echo "No directories outside $BASE_DIR have exceeded $THRESHOLD% usage."
fi
 
# Step 2: Identify the highest usage directory inside /logs
echo "Identifying the highest usage directory inside $BASE_DIR..."
highest_usage_dir=$(du -ms "$BASE_DIR"/* 2>/dev/null | sort -nr | head -n 1 | awk '{print $2}')
 
if [ -z "$highest_usage_dir" ]; then
    echo "Error: No directories found in $BASE_DIR to process."
    exit 1
fi
 
echo "Highest usage directory identified: $highest_usage_dir"
 
# Step 3: Zip files in the highest usage directory that haven't been modified today
echo "Starting to zip files in $highest_usage_dir that have not been modified today..."
find "$highest_usage_dir" -type f ! -newermt "$(date +%Y-%m-%d)" -print0 | while IFS= read -r -d '' file; do
    if gzip "$file"; then
        echo "Zipped: $file"
    else
        echo "Failed to zip: $file"
    fi
done
 
echo "Completed zipping files in $highest_usage_dir"
echo "Script execution completed."
