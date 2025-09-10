#!/bin/sh
sleep 120
echo on > /tmp/openclash_status
/bin/sh /root/openclash_watchdog.sh &
