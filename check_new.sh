#!/bin/bash

# Name of the file containing the list of processes
PROCESS_FILE="processes.txt"

# Get the current date and time
current_time=$(date +%s)

while read -r process; do
    # Check if the process is running
    ps -ef | grep "$process" | grep -v "grep" | grep -v "$0" > /dev/null
    if [[ $? -eq 0 ]]; then
        # Get the start time of the process (picking just the first instance if there are multiple)
        start_time=$(ps -eo lstart,cmd | grep "$process" | grep -v "grep" | grep -v "$0" | awk '{print $1" "$2" "$3" "$4" "$5}' | head -n 1)
        start_time_in_seconds=$(date -d "$start_time" +%s)
        time_difference=$((current_time - start_time_in_seconds))

        # Convert the time difference to hours
        time_difference_in_hours=$((time_difference / 3600))

        echo "Process $process is currently running."

        if [[ $time_difference_in_hours -ge 1 ]]; then
            echo "ALERT: Process $process has been running for more than 1 hour!"
        fi
    else
        echo "Process $process is not running. Starting the process..."

        # Start the MySQL process using systemctl
        sudo systemctl start mysql

        echo "Process $process has been started."
    fi
done < "$PROCESS_FILE"

