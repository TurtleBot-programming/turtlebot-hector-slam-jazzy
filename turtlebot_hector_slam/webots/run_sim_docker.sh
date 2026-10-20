#!/usr/bin/env bash
# Split setup: Webots (snap) runs on the host, the ROS 2 bridge runs in the
# `jazzy` container (host networking, so the extern controller connects over
# tcp://localhost:1234). Same flags as run_sim.sh.
#   ./run_sim_docker.sh [--headless] [--world two_floor] [--patrol]
# One-off: the container needs a copy of Webots' controller library, see
# ../README.md ("Webots on host, ROS in docker").
set -eo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
WS_HOST="${WS_HOST:-$HOME/ros2_jazzy_ws}"
WS_CONT=/root/ros2_ws
case "$HERE" in
  "$WS_HOST"/*) HERE_CONT="$WS_CONT/${HERE#"$WS_HOST"/}" ;;
  *) echo "run from inside $WS_HOST (the directory the container mounts)" >&2; exit 1 ;;
esac

WEBOTS_HOME_HOST="${WEBOTS_HOME_HOST:-/snap/webots/current/usr/share/webots}"
if [ ! -d "$WS_HOST/webots_home/lib/controller" ]; then
  mkdir -p "$WS_HOST/webots_home/lib"
  cp -r "$WEBOTS_HOME_HOST/lib/controller" "$WS_HOST/webots_home/lib/"
fi

BRIDGE_ARGS=(); HEADLESS=0; WORLD=hector_slam_test
while [ $# -gt 0 ]; do
  case "$1" in
    --headless) HEADLESS=1 ;;
    --world) WORLD="$2"; shift ;;
    --world=*) WORLD="${1#--world=}" ;;
    *) BRIDGE_ARGS+=("$1") ;;
  esac
  shift
done
case "$WORLD" in
  hector_slam_test) LAYOUT=layout ;;
  two_floor) LAYOUT=layout_2floor ;;
  *) echo "unknown world '$WORLD'" >&2; exit 1 ;;
esac
BRIDGE_ARGS+=(--layout "$LAYOUT")

# Meshes come from the Jazzy install, which only exists in the container.
# The container writes as root; the Webots snap can only read files owned by
# the invoking user, so hand the meshes over.
if [ ! -d "$HERE/protos/meshes" ]; then
  jazzy bash "$HERE_CONT/protos/setup_meshes.sh"
  jazzy chown -R "$(id -u):$(id -g)" "$HERE_CONT/protos/meshes"
fi
[ -f "$HERE/worlds/$WORLD.wbt" ] || { echo "missing world $WORLD.wbt" >&2; exit 1; }

WEBOTS_CMD=(webots --stdout --stderr "$HERE/worlds/$WORLD.wbt")
[ "$HEADLESS" = 1 ] && WEBOTS_CMD=(xvfb-run -a webots --mode=realtime --no-rendering --minimize --batch --stdout --stderr "$HERE/worlds/$WORLD.wbt")
"${WEBOTS_CMD[@]}" &
WEBOTS_PID=$!
trap 'kill $WEBOTS_PID 2>/dev/null || true' EXIT
sleep 6
jazzy bash -c 'export WEBOTS_HOME=/root/ros2_ws/webots_home
export PYTHONPATH=$WEBOTS_HOME/lib/controller/python:$PYTHONPATH
export WEBOTS_CONTROLLER_URL=tcp://localhost:1234/Turtlebot4
exec python3 "$@"' _ "$HERE_CONT/controllers/tb4_ros2_bridge/tb4_ros2_bridge.py" "${BRIDGE_ARGS[@]}"
