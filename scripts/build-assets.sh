#!/usr/bin/env sh
set -euo pipefail

# Build frontend assets with Vite using the Node service/container
# Usage:
#   ./scripts/build-assets.sh
# Notes:
# - Works even if the node service is under the "dev" profile; it uses a one-off container.
# - Requires Docker Compose to be available on the host running this script.

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_DIR"

# Run Node in a one-off container to install deps and build
exec docker compose run --rm -T node sh -lc "cd /var/www/app && if [ -f package-lock.json ]; then npm ci; else npm install; fi && npm run build"
