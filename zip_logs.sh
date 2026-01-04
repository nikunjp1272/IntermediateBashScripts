#!/bin/bash

# Threshold for disk usage (80%)
THRESHOLD=80
BASE_DIR="/logs"

# Check that only 'ec2-user' can run the script
if [[ "$USER" != "ec2-user"]]; then
    echo "Error: Only 'ec2-user' is allowed to run this script."
    exit 1
fi

echo "Script execution started."

# Check if there are directories outside /logs that exceed the disk usage threshold
echo "Checking for directories outside $BASE_DIR that exceed $THRESHOLD% usage..."
outside_dir_check=$(df --output=pcent,target | grep -v "$BASE_DIR" | awk -v threshold="$THRESHOLD" '{if ($1+0 > threshold) print $2}')

if [ -n "$outside_dir_check" ]; then
    echo "Warning: The following directories outside of $BASE_DIR exceed $THRESHOLD% usage:"
    echo "$outside_dir_check"
else
    echo "No directories outside $BASE_DIR have exceeded $THRESHOLD% usage."
fi

# Check if /logs itself is above the threshold
echo "Checking if $BASE_DIR exceeds $THRESHOLD% usage..."
logs_usage=$(df --output=pcent "$BASE_DIR" | tail -n 1 | tr -d '%')
if [ "$logs_usage" -ge "$THRESHOLD" ]; then
    echo "$BASE_DIR usage is at $logs_usage%, which is above the threshold. Proceeding with zipping files..."

    # Identify the highest usage directory inside /logs
    echo "Identifying the highest usage directory inside $BASE_DIR..."
    highest_usage_dir=$(du -ms "$BASE_DIR"/* 2>/dev/null | sort -nr | head -n 1 | awk '{print $2}')

    if [ -z "$highest_usage_dir" ]; then
        echo "Error: No directories found in $BASE_DIR to process."
        exit 1
    fi

    echo "Highest usage directory identified: $highest_usage_dir"

    # Start zipping files in the identified directory that have not been modified today
    echo "Starting to zip files in $highest_usage_dir that have not been modified today..."
    find "$highest_usage_dir" -type f ! -newermt "$(date +%Y-%m-%d)" -print0 | while IFS= read -r -d '' file; do
        if gzip "$file"; then
            echo "Zipped: $file"
        else
            echo "Failed to zip: $file"
        fi
    done

    echo "Completed zipping files in $highest_usage_dir"
else
    echo "$BASE_DIR usage is at $logs_usage%, which is below the threshold. No files will be zipped."
fi

echo "Script execution completed."