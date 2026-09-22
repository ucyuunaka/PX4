#!/usr/bin/env bash
# Rewrite .gitmodules URLs github.com -> ghfast.top mirror, then init+update
# only the submodules needed to build px4_sitl (gazebo + jmavsim).
set -e
cd /mnt/u/ucy/Code/active/PX4/references/PX4-Autopilot/.cs/env/px4-sitl-v1.13.3

# 1) Rewrite .gitmodules urls to ghfast.top
git config -f .gitmodules --get-regexp '^submodule\..*\.url$' | while read -r name url; do
  new="${url/https:\/\/github.com\//https:\/\/ghfast.top\/https:\/\/github.com\/}"
  git config -f .gitmodules "$name" "$new"
done
echo "=== .gitmodules urls after rewrite ==="
git config -f .gitmodules --get-regexp '^submodule\..*\.url$'

# 2) Sync .git/config submodule urls
git submodule sync --recursive

# 3) Init only the SITL-needed submodules
SUBS="src/modules/mavlink/mavlink src/drivers/gps/devices src/lib/crypto/monocypher src/lib/crypto/libtomcrypt src/lib/crypto/libtommath src/lib/events/libevents Tools/sitl_gazebo Tools/jMAVSim"
for s in $SUBS; do
  echo "=== init+update $s ==="
  git submodule update --init --depth 1 "$s" || git submodule update --init "$s"
done
echo "=== submodule status (init'd only) ==="
git submodule status | grep -v '^-' || echo "all shown initialized"
