#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="internal/docker-compose.yml"
ENV_FILE="galixihub.env"
DB_SERVICE="mariadb"

echo "======================================="
echo "  GalixiHub Startup"
echo "======================================="

if [ ! -f "$COMPOSE_FILE" ]; then
  echo "ERROR: $COMPOSE_FILE not found"
  exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: $ENV_FILE not found"
  exit 1
fi

echo "Loading environment file..."
set -a
source "$ENV_FILE"
set +a

echo "Checking required variables..."

required_vars=(
  GALIXIHUB_ACCEPT_LICENSE
  GALIXIHUB_WORLD_NAME
  GALIXIHUB_HOSTNAME
  GALIXIHUB_PORT
  GALIXIHUB_OWNER_CODE
)

for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    echo "ERROR: $var not set in $ENV_FILE"
    exit 1
  fi
done

echo "Environment OK"

export GALIXIHUB_PORT_PLUS1=$((GALIXIHUB_PORT + 1))
export GALIXIHUB_BASE_DIR="$SCRIPT_DIR"

echo "Pulling latest GalixiHub image..."
docker compose -f "$COMPOSE_FILE" pull galixihub

echo "Starting containers..."
docker compose -f "$COMPOSE_FILE" up -d

echo "Waiting for MariaDB to become healthy..."

CONTAINER_ID=$(docker compose -f "$COMPOSE_FILE" ps -q "$DB_SERVICE")

if [ -z "$CONTAINER_ID" ]; then
  echo "ERROR: MariaDB container not found"
  exit 1
fi

ATTEMPTS=0
MAX_ATTEMPTS=60

while true; do

  STATUS=$(docker inspect \
    --format='{{.State.Health.Status}}' \
    "$CONTAINER_ID" 2>/dev/null || echo "starting")

  if [ "$STATUS" == "healthy" ]; then
    echo "MariaDB is healthy"
    break
  fi

  if [ "$STATUS" == "unhealthy" ]; then
    echo "ERROR: MariaDB container is unhealthy"
    docker compose -f "$COMPOSE_FILE" logs mariadb
    exit 1
  fi

  ATTEMPTS=$((ATTEMPTS+1))

  if [ "$ATTEMPTS" -gt "$MAX_ATTEMPTS" ]; then
    echo "ERROR: MariaDB did not become healthy"
    docker compose -f "$COMPOSE_FILE" logs mariadb
    exit 1
  fi

  sleep 2
done

#----------------------------------------------
GALIXI_ID=$(docker compose -f "$COMPOSE_FILE" ps -q galixihub)

# wait a few seconds for it to start
sleep 2

STATUS=$(docker inspect -f '{{.State.ExitCode}}' "$GALIXI_ID")

if [ "$STATUS" -ne 0 ]; then
  echo "ERROR: GalixiHub failed to start (exit code $STATUS)"
  docker compose -f "$COMPOSE_FILE" logs galixihub
  exit "$STATUS"
fi
#----------------------------------------

echo "======================================="
echo "GalixiHub stack started successfully"
echo "======================================="
