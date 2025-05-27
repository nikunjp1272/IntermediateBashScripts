#!/bin/bash

# Prompt user for the log file path
read -p "Enter the path of the log file to check: " logFile

# Validate if the file exists
if [ ! -f "$logFile" ]; then
    echo "Error: The file '$logFile' does not exist!"
    exit 1
fi

# Extract the base name of the log file (everything after the last "/")
logFileName=$(basename "$logFile")

# Define the error log file with a timestamp
errorLogDir="/home/nikunj/scripts/logs/"
errorLogFile="$errorLogDir/${logFileName}_error_$(date +"%Y%m%d%H%M%S").log"

# Ensure the error log directory exists
mkdir -p "$errorLogDir"

# Searching for errors in the log file
grep -Ei "err|error|fail|deny|denied" "$logFile" > "$errorLogFile"

# Check if errors were found
if [ -s "$errorLogFile" ]; then
    echo "Critical errors saved to $errorLogFile"
else
    echo "No critical errors found in $logFile"
    rm -f "$errorLogFile"  # Remove the empty error log
fi

# Rotating logs
logDir="/home/nikunj/scripts/"
maxSize=1000000  # 1MB

for file in "$logDir"/*.log; do
    if [ -f "$file" ]; then
        logSize=$(stat -c %s "$file")
        if [ "$logSize" -gt "$maxSize" ]; then
            mv "$file" "$file.old"
            echo "Log file $file rotated"
        fi
    fi
done
