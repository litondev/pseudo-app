#!/bin/bash

# Log Cleanup Cron Configuration Script
# This script sets up a monthly cron job to clean up .log files

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CRONJOB_SCRIPT="$SCRIPT_DIR/log_cleanup.go"
CRON_LOG_FILE="$SCRIPT_DIR/../../logger/cron_cleanup.log"

echo "Setting up monthly log cleanup cron job..."
echo "Script location: $CRONJOB_SCRIPT"
echo "Cron log file: $CRON_LOG_FILE"

# Create the cron job entry
# Run on the 1st day of every month at 2:00 AM
CRON_ENTRY="0 2 1 * * cd $SCRIPT_DIR && /usr/local/go/bin/go run log_cleanup.go >> $CRON_LOG_FILE 2>&1"

# Check if cron job already exists
if crontab -l 2>/dev/null | grep -q "log_cleanup.go"; then
    echo "Cron job for log cleanup already exists. Updating..."
    # Remove existing entry and add new one
    (crontab -l 2>/dev/null | grep -v "log_cleanup.go"; echo "$CRON_ENTRY") | crontab -
else
    echo "Adding new cron job for log cleanup..."
    # Add new entry to existing crontab
    (crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab -
fi

echo "Cron job configured successfully!"
echo "The log cleanup will run monthly on the 1st day at 2:00 AM"
echo ""
echo "To verify the cron job, run: crontab -l"
echo "To remove the cron job, run: crontab -e and delete the log_cleanup.go line"
echo ""
echo "Manual execution: cd $SCRIPT_DIR && go run log_cleanup.go"