#!/bin/bash
set -e

# Tunnel external 0.0.0.0:8082 -> 127.0.0.1:8082 so zellij web server
# can stay bound to localhost (avoids SSL certificate requirement)
# EXTERNAL_IP="$(ip route get 1 | awk '{for(i=1; i<=NF; i++) if($i~/src/) print $(i+1)}')"
EXTERNAL_IP="0.0.0.0"
socat "tcp4-listen:9999,reuseaddr,fork,bind=$EXTERNAL_IP" "tcp4:127.0.0.1:8082" &
SOCAT_PID=$!

# Clean up socat on exit
trap "kill $SOCAT_PID 2>/dev/null" EXIT

# Start zellij
exec zellij web --start --ip "127.0.0.1" --port 8082
# exec zellij "$@"
