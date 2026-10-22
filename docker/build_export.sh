#!/usr/bin/env bash
# On the build machine: build the image and write tb4-hector-slam.tar.gz.
# Copy both files in dist/ (USB / scp) to the other computer.
set -euo pipefail
cd "$(dirname "$0")/.."
docker build --network host -f docker/Dockerfile -t tb4-hector-slam:latest .
mkdir -p dist
docker save tb4-hector-slam:latest | gzip > dist/tb4-hector-slam.tar.gz
cp docker/run.sh dist/run.sh
ls -lh dist/
