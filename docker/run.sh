#!/usr/bin/env bash
# On the target computer. Needs only Docker. Usage:
#   ./run.sh                 load the image if needed (from tb4-hector-slam.tar.gz next to this file), start the dashboard
#   PORT=9000 ./run.sh       different port
# Then open http://localhost:8080. Results are written to ./data/results/.
set -euo pipefail
cd "$(dirname "$0")"
IMG=tb4-hector-slam:latest
if ! docker image inspect "$IMG" >/dev/null 2>&1; then
  [ -f tb4-hector-slam.tar.gz ] || { echo "image not loaded and tb4-hector-slam.tar.gz not found next to run.sh" >&2; exit 1; }
  echo "loading image (a few minutes the first time)..."
  docker load < tb4-hector-slam.tar.gz
fi
mkdir -p data
echo "Dashboard: http://localhost:${PORT:-8080}   (Ctrl+C to stop)"
exec docker run --rm -it --name tb4-hector-slam --network host --ipc host \
  -e PORT="${PORT:-8080}" -v "$PWD/data:/data" "$IMG"
