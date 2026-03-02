#!/usr/bin/env bash
set -euo pipefail

CONFIG=/opt/web/config.yaml
COMMAND="$(yq eval '.framework.command' "$CONFIG")"
PORT=${PORT:-3000}

echo "[entrypoint] starting..."

# 🔹 tenta liberar perf (pode falhar em ambientes restritos)
echo 0 > /proc/sys/kernel/perf_event_paranoid 2>/dev/null || true
chmod o+r /sys/class/powercap/intel-rapl/*/* 2>/dev/null || true
chmod o+r /sys/class/powercap/intel-rapl/*/*/* 2>/dev/null || true

# 🔹 inicia o servidor em background
echo "Starting with command: $COMMAND"
mojitos -u -f 1 -o /log/mojitolog.csv -- $COMMAND

echo "[entrypoint] mojitos finished"

# 🔹 mantém container vivo enquanto app roda
wait $APP_PID