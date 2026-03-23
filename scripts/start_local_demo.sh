#!/bin/zsh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FRONTEND_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
BACKEND_DIR="$(cd "$FRONTEND_DIR/../dealer_evaluation_backend" && pwd)"
VENV_DIR="$HOME/Desktop/dealer-eval-venv"
LOG_DIR="$HOME/Desktop/dealer_eval_logs"
PID_DIR="$HOME/Desktop/dealer_eval_pids"

mkdir -p "$LOG_DIR" "$PID_DIR"

if [ ! -x "$VENV_DIR/bin/python" ]; then
  python3 -m venv "$VENV_DIR"
  "$VENV_DIR/bin/pip" install \
    -r "$BACKEND_DIR/products_list/requirements.txt" \
    -r "$FRONTEND_DIR/requirements.txt"
fi

if [ ! -d "$BACKEND_DIR/dealer_details/node_modules" ]; then
  (cd "$BACKEND_DIR/dealer_details" && npm ci)
fi

record_running_pid() {
  local port="$1"
  local pid_file="$2"
  local service_name="$3"

  local existing_pid
  existing_pid="$(lsof -ti "tcp:$port" -sTCP:LISTEN 2>/dev/null | head -n 1 || true)"
  if [ -n "$existing_pid" ]; then
    echo "$existing_pid" >"$pid_file"
    echo "$service_name already running on http://127.0.0.1:$port"
    return 0
  fi
  return 1
}

if [ -f "$PID_DIR/products_list.pid" ] && kill -0 "$(cat "$PID_DIR/products_list.pid")" 2>/dev/null; then
  echo "products_list already running on http://127.0.0.1:5002"
elif record_running_pid 5002 "$PID_DIR/products_list.pid" "products_list"; then
  true
else
  (
    cd "$BACKEND_DIR/products_list"
    PORT=5002 "$VENV_DIR/bin/python" app.py >"$LOG_DIR/products_list.log" 2>&1 &
    echo $! >"$PID_DIR/products_list.pid"
  )
fi

if [ -f "$PID_DIR/dealer_details.pid" ] && kill -0 "$(cat "$PID_DIR/dealer_details.pid")" 2>/dev/null; then
  echo "dealer_details already running on http://127.0.0.1:8080"
elif record_running_pid 8080 "$PID_DIR/dealer_details.pid" "dealer_details"; then
  true
else
  (
    cd "$BACKEND_DIR/dealer_details"
    PORT=8080 npm start >"$LOG_DIR/dealer_details.log" 2>&1 &
    echo $! >"$PID_DIR/dealer_details.pid"
  )
fi

if [ -f "$PID_DIR/frontend.pid" ] && kill -0 "$(cat "$PID_DIR/frontend.pid")" 2>/dev/null; then
  echo "frontend already running on http://127.0.0.1:5001"
elif record_running_pid 5001 "$PID_DIR/frontend.pid" "frontend"; then
  true
else
  (
    cd "$FRONTEND_DIR"
    PORT=5001 "$VENV_DIR/bin/python" app.py >"$LOG_DIR/frontend.log" 2>&1 &
    echo $! >"$PID_DIR/frontend.pid"
  )
fi

echo
echo "Local demo is starting."
echo "Frontend:      http://127.0.0.1:5001"
echo "Products API:  http://127.0.0.1:5002/products"
echo "Dealer API:    http://127.0.0.1:8080/allprice/Laptop"
echo
echo "Logs: $LOG_DIR"
echo "PIDs: $PID_DIR"
