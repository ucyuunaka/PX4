#!/bin/bash
# Copy of /root/px4-build/run_gazebo2.sh (WSL). Clean PATH avoids Windows Anaconda protobuf leaking into cmake;
# stdin from FIFO /root/px4-build/pxh_in keeps pxh alive. Hold the FIFO open first:
#   setsid bash -c 'exec sleep infinity > /root/px4-build/pxh_in' &
# Send commands: printf 'commander takeoff\n' > /root/px4-build/pxh_in
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export GIT_SUBMODULES_ARE_EVIL=1
export DISPLAY=:0
export WAYLAND_DISPLAY=wayland-0
cd /root/px4-sitl-src
exec make px4_sitl gazebo < /root/px4-build/pxh_in
