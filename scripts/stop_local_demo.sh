#!/bin/zsh

set -euo pipefail

PID_DIR="$HOME/Desktop/dealer_eval_pids"

for service in frontend dealer_details products_list; do
  PID_FILE="$PID_DIR/$service.pid"
  if [ -f "$PID_FILE" ]; then
    PID="$(cat "$PID_FILE")"
    if kill -0 "$PID" 2>/dev/null; then
      kill "$PID"
      echo "Stopped $service ($PID)"
    else
      echo "$service was not running"
    fi
    rm -f "$PID_FILE"
  fi
done
