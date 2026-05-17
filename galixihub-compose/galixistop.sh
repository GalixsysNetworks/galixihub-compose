#!/bin/bash
set -e

COMPOSE_FILE="internal/docker-compose.yml"
ENV_FILE="./galixihub.env"

# Sanity check
if [ ! -f "$COMPOSE_FILE" ]; then
    echo "[ERROR] Compose file not found: $COMPOSE_FILE"
    exit 1
fi

# Load environment variables if file exists
if [ -f "$ENV_FILE" ]; then
    set -a
    source "$ENV_FILE"
    set +a
else
    echo "[WARN] $ENV_FILE not found. Continuing with docker compose defaults."
fi

# Compute next port (needed for port-range resolution)
GALIXIHUB_PORT_PLUS1=$((GALIXIHUB_PORT + 1))
export GALIXIHUB_PORT_PLUS1

# Parse flags
REMOVE_VOLUMES=false
if [[ "$1" == "-r" ]]; then
    REMOVE_VOLUMES=true
fi

echo "[INFO] Stopping GalixiHub containers..."

if [ "$REMOVE_VOLUMES" = true ]; then
    echo
    echo "WARNING: DESTRUCTIVE OPERATION"
    echo "--------------------------------"
    echo "This will permanently delete:"
    echo "  - All GalixiHub data"
    echo "  - All databases"
    echo "  - All logs"
    echo
    read -r -p "Type YES to proceed, or anything else to cancel: " CONFIRM

    if [ "$CONFIRM" != "YES" ]; then
        echo "[INFO] Operation cancelled. No data was removed."
        exit 0
    fi

    echo "[INFO] Removing containers AND all volumes..."
    docker compose -f "$COMPOSE_FILE" down -v
    echo "[INFO] Containers and volumes removed."

else
    echo "[INFO] Removing containers only, volumes will be preserved..."
    docker compose -f "$COMPOSE_FILE" down
    echo "[INFO] Containers stopped. Volumes preserved."
fi
