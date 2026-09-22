#!/usr/bin/env bash
set -e
SRC_ON_U=/mnt/u/ucy/Code/active/PX4/references/PX4-Autopilot/.cs/env/px4-sitl-v1.13.3
SRC_NATIVE="/root/px4-sitl-src"

echo "=== rsync worktree ->  ==="
mkdir -p ""
rsync -a --delete "/" "/"
cd ""

echo "=== make px4_sitl_default (binary only) ==="
export GIT_SUBMODULES_ARE_EVIL=1
make px4_sitl_default -j14 2>&1 | tee /tmp/px4_build.log
echo "=== px4 binary build done ==="
find "/build" -name px4 -type f 2>/dev/null
