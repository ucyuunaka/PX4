#!/bin/bash
# Copy of /root/px4-build/run_gazebo2.sh (WSL). Clean PATH avoids Windows Anaconda protobuf leaking into cmake;
# stdin from FIFO /root/px4-build/pxh_in keeps pxh alive. Hold the FIFO open first:
#   setsid bash -c 'exec sleep infinity > /root/px4-build/pxh_in' &
# Send commands: printf 'commander takeoff\n' > /root/px4-build/pxh_in
# GAZEBO_IP + PX4_SIM_HOST_ADDR route PX4<->gazebo TCP 4560 over the eth0 IP:
# needed under virtioproxy (2026-09-27~10-09; loopback 4560 dropped by Windows relay,
# gazebo intra-transport loopback ephemeral TCP refused); harmless under NAT, kept
# for robustness. Add HEADLESS=1 to skip gzclient.
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export GIT_SUBMODULES_ARE_EVIL=1
export DISPLAY=:0
export WAYLAND_DISPLAY=wayland-0
_ip=$(hostname -I | awk '{print $1}')
export GAZEBO_IP=$_ip
export PX4_SIM_HOST_ADDR=$_ip
cd /root/px4-sitl-src
exec make px4_sitl gazebo < /root/px4-build/pxh_in
