#!/usr/bin/env bash
# SITL-only dependency install for PX4 v1.13.3 on Ubuntu 20.04 (focal).
# Mirrors Tools/setup/ubuntu.sh but skips the NuttX cross toolchain.
# NOTE: after step 2, pin empy: python3 -m pip install empy==3.3.4 (empy 4.x removed em.RAW_OPT).
set -e
export DEBIAN_FRONTEND=noninteractive
cd /mnt/u/ucy/Code/active/PX4/references/PX4-Autopilot/.cs/env/px4-sitl-v1.13.3

echo "=== [1/4] apt update + general deps ==="
sudo apt-get update -y --quiet
sudo apt-get -y --quiet --no-install-recommends install \
	build-essential cmake cppcheck file g++ gcc gdb git lcov \
	libxml2-dev libxml2-utils make ninja-build \
	python3 python3-dev python3-pip python3-setuptools python3-wheel \
	rsync shellcheck unzip zip bc wget curl ca-certificates gnupg

echo "=== [2/4] python3 deps ==="
python3 -m pip install --user -r Tools/setup/requirements.txt

echo "=== [3/4] java + ant (jmavsim) ==="
sudo apt-get -y --quiet --no-install-recommends install \
	ant openjdk-13-jre openjdk-13-jdk libvecmath-java \
	|| { echo "openjdk-13 unavailable, falling back to 11"; \
	     sudo apt-get -y --quiet --no-install-recommends install \
		ant openjdk-11-jre openjdk-11-jdk libvecmath-java; }

echo "=== [4/4] gazebo11 repo + install ==="
sudo sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
wget -q http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
sudo apt-get update -y --quiet
sudo apt-get -y --quiet --no-install-recommends install \
	gazebo11 libgazebo11-dev \
	gstreamer1.0-plugins-bad gstreamer1.0-plugins-base \
	gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly \
	gstreamer1.0-libav libeigen3-dev \
	libgstreamer-plugins-base1.0-dev libimage-exiftool-perl \
	libopencv-dev libxml2-utils pkg-config protobuf-compiler

echo "=== DONE: dependency install finished ==="
