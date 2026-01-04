#!/bin/bash

# Threshold for disk usage (80%)

THRESHOLD=80
BASE_DIR="/logs"

# Check that only 'ec2-user' can run the script
if [[ "$USER" != "ec2-user"]]; then
    echo "Error: Only 'ec2-user' is allowed to run this script."
    exit 1
fi

echo "Script execution started by user: $USER."

# Check for directories outside /logs that exceed the disk usage threshold
echo "Checking for directories outside $BASE_DIR that exceed $THRESHOLD% usage..."
outside_dir_check=$(df --output=pcent,target | grep -v "$BASE_DIR" | awk -v threshold="$THRESHOLD" '{if ($1+0 > threshold) print $2}')

if [ -n "$outside_dir_check" ]; then
    echo "Warning: The following directories exceed $THRESHOLD% usage:"
    echo "$outside_dir_check"
else
    echo "No directories have exceeded $THRESHOLD% usage."
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

    # Start zipping files in the identified directory that have not been modified today
    echo "Starting to zip files in $highest_usage_dir that have not been modified today..."

    find "$highest_usage_dir" -type f ! -newermt "$(date +%Y-%m-%d)" -print0 | while IFS= read -r -d '' file; do
        # Check if the filename starts with "traces" and skip if it does
        if [[ $(basename "$file") == traces* ]]; then
            continue
        fi

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
