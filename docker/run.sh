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
# A GPU (/dev/dri) makes the Gazebo simulation much faster; without one it renders in software.
GPU=(); [ -d /dev/dri ] && GPU=(--device /dev/dri)
# Show the Gazebo and RViz windows on this computer's screen (needs a desktop session).
X11=()
if [ -n "${DISPLAY:-}" ] && [ -d /tmp/.X11-unix ]; then
  X11=(-e DISPLAY="$DISPLAY" -e QT_X11_NO_MITSHM=1 -v /tmp/.X11-unix:/tmp/.X11-unix)
  XA="${XAUTHORITY:-$HOME/.Xauthority}"
  [ -f "$XA" ] && X11+=(-e XAUTHORITY=/tmp/.xauth -v "$XA:/tmp/.xauth:ro")
  [ -n "${WAYLAND_DISPLAY:-}" ] && echo "Wayland session: windows open through XWayland."
else
  echo "No desktop session found: Gazebo/RViz windows are unavailable (the dashboard still works)."
fi
exec docker run --rm -it --name tb4-hector-slam --network host --ipc host "${GPU[@]}" "${X11[@]}" \
  -e PORT="${PORT:-8080}" -v "$PWD/data:/data" "$IMG"
