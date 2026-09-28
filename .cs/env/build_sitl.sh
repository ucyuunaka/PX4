#!/usr/bin/env bash
# Copy of /root/px4-build/build_sitl.sh (WSL). Run with: setsid bash build_sitl.sh > run.log 2>&1 < /dev/null &
# Rsync v1.13.3 worktree from /mnt/u (9P, slow) to native ext4, then build px4_sitl_default.
set -e
SRC_ON_U=/mnt/u/ucy/Code/active/PX4/references/PX4-Autopilot/.cs/env/px4-sitl-v1.13.3
SRC_NATIVE=/root/px4-sitl-src

echo "=== rsync $SRC_ON_U/ -> $SRC_NATIVE/ ==="
mkdir -p "$SRC_NATIVE"
rsync -a --delete --exclude='build/' "$SRC_ON_U/" "$SRC_NATIVE/"
cd "$SRC_NATIVE"

echo "=== make px4_sitl_default -j14 (binary only) ==="
export GIT_SUBMODULES_ARE_EVIL=1
make px4_sitl_default -j14 2>&1 | tee /tmp/px4_build.log
echo "=== build exit ${PIPESTATUS[0]} ==="
find "$SRC_NATIVE/build" -name px4 -type f 2>/dev/null

echo "=== DONE ==="
