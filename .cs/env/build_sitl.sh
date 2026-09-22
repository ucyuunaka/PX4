#!/usr/bin/env bash
# Build ONLY the px4 SITL binary (no simulator launch).
# Source rsynced to native ext4 (~/px4-sitl-src) because /mnt/u is 9P and slow.
set -e
SRC_ON_U=/mnt/u/ucy/Code/active/PX4/references/PX4-Autopilot/.cs/env/px4-sitl-v1.13.3
SRC_NATIVE=$HOME/px4-sitl-src

echo "=== rsync worktree -> $SRC_NATIVE ==="
mkdir -p "$SRC_NATIVE"
rsync -a --delete "$SRC_ON_U/" "$SRC_NATIVE/"
cd "$SRC_NATIVE"

echo "=== make px4_sitl_default (binary only) ==="
export GIT_SUBMODULES_ARE_EVIL=1
make px4_sitl_default -j14 2>&1 | tee /tmp/px4_build.log
echo "=== px4 binary build done ==="
find "$SRC_NATIVE/build" -name px4 -type f 2>/dev/null
