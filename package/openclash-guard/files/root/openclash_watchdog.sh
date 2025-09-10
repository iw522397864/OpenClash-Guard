#!/bin/sh
PATH=/usr/sbin:/usr/bin:/sbin:/bin
LOG_FILE="/tmp/openclash_watchdog_debug.log"
MAX_OK_COUNT=10  # Number of consecutive successful checks before exiting
OK_COUNT=0

# Function to check and clear log if too large
check_log_size() {
  MAX_LINES=500
  if [ -f "$LOG_FILE" ]; then
    LINE_COUNT=$(wc -l < "$LOG_FILE")
    if [ "$LINE_COUNT" -gt "$MAX_LINES" ]; then
      echo "$(date '+%Y-%m-%d %H:%M:%S') Log exceeded $MAX_LINES lines. Clearing log." > "$LOG_FILE"
    fi
  fi
}

echo "$(date '+%Y-%m-%d %H:%M:%S') Watchdog script started. Waiting 60 seconds to avoid false detection..." >> "$LOG_FILE"
sleep 60

while true; do
  STATUS=$(cat /tmp/openclash_status 2>/dev/null)

  if [ "$STATUS" = "off" ]; then
    check_log_size
    echo "$(date '+%Y-%m-%d %H:%M:%S') Status flag is off. Skipping restart check." >> "$LOG_FILE"
    OK_COUNT=0
  else
    if ! pidof clash > /dev/null; then
      check_log_size
      echo "$(date '+%Y-%m-%d %H:%M:%S') Clash is not running. Attempting to restart OpenClash..." >> "$LOG_FILE"
      /etc/init.d/openclash restart >> "$LOG_FILE" 2>&1 || true
      sleep 10
      if ! pidof clash > /dev/null; then
        check_log_size
        echo "$(date '+%Y-%m-%d %H:%M:%S') Restart failed. Clash is still not running." >> "$LOG_FILE"
        OK_COUNT=0
      else
        check_log_size
        echo "$(date '+%Y-%m-%d %H:%M:%S') Clash restarted successfully ✅" >> "$LOG_FILE"
        OK_COUNT=1
      fi
    else
      OK_COUNT=$((OK_COUNT + 1))
      check_log_size
      echo "$(date '+%Y-%m-%d %H:%M:%S') Clash is running normally. OK_COUNT=$OK_COUNT" >> "$LOG_FILE"
    fi
  fi

  if [ "$OK_COUNT" -ge "$MAX_OK_COUNT" ]; then
    check_log_size
    echo "$(date '+%Y-%m-%d %H:%M:%S') Clash has been stable for $MAX_OK_COUNT checks. Exiting watchdog." >> "$LOG_FILE"
    exit 0
  fi

  sleep 30
done
