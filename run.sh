#!/usr/bin/env bash
set -euo pipefail

app=$1
requests=${2:-100}

PORT=3000
CONTAINER_NAME="${app}_container"

echo "[script] app=$app requests=$requests"

echo "[script] building image..."
docker build -t "$app" -f Dockerfile.javalib --build-arg libdir=code/$app .

# 🔹 verifica se já existe container rodando
if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "[script] container already running — reusing"
else
    echo "[script] starting container..."
    docker run -d \
        --name "$CONTAINER_NAME" \
        --privileged \
        -p ${PORT}:${PORT} \
        -v "$(pwd)/logs:/log" \
        "$app"
fi

# 🔹 espera subir
echo "[script] waiting for service..."
sleep 5

# 🔹 curls
echo "[script] running curls..."
for i in $(seq 1 "$requests"); do
    curl -s "http://localhost:${PORT}/" >/dev/null || true
done

echo "[script] done"