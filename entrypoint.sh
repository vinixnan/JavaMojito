#!/usr/bin/env bash
set -euo pipefail

APP_JAR=${APP_JAR:-/app/app.jar}
PORT=${PORT:-8080}
MOJITOS_ARGS=${MOJITOS_ARGS:--t 2 -f 2 -r}

echo "[entrypoint] starting..."

# 🔹 tenta liberar perf (pode falhar em ambientes restritos)
echo 0 > /proc/sys/kernel/perf_event_paranoid 2>/dev/null || true
chmod o+r /sys/class/powercap/intel-rapl/*/* 2>/dev/null || true
chmod o+r /sys/class/powercap/intel-rapl/*/*/* 2>/dev/null || true

# 🔹 inicia o servidor em background
echo "[entrypoint] starting java service..."
java -jar "$APP_JAR" --Dconfig.file="/app/application.properties" &
APP_PID=$!

# 🔹 espera o serviço subir
echo "[entrypoint] waiting for service on port ${PORT}..."

for i in {1..120}; do
    if curl -fs "http://localhost:${PORT}/html" >/dev/null 2>&1 \
       || curl -fs "http://localhost:${PORT}/" >/dev/null 2>&1; then
        echo "[entrypoint] service is up"
        break
    fi
    sleep 1
done

# 🔹 dispara mojitos
echo "[entrypoint] starting mojitos..."
mojitos ${MOJITOS_ARGS} || true

echo "[entrypoint] mojitos finished"

# 🔹 mantém container vivo enquanto app roda
wait $APP_PID