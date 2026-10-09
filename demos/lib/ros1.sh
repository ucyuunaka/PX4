#!/bin/bash
# ROS1 (Noetic) 环境库：source 本文件前先 source lib/common.sh。
# 用于演示 D（Swarm-Formation / MASC 副本，/root/masc_ws）。

# 设好 ROS1 运行环境（非交互 shell 没有 .bashrc，都要显式设）
ros_env() {
  # shellcheck disable=SC1090
  . /opt/ros/noetic/setup.bash
  . /root/masc_ws/devel/setup.bash
  export ROS_MASTER_URI=http://127.0.0.1:11311
  export ROS_IP=127.0.0.1
  # ROS1 官方在部分版本 rviz 启动时弹"End-of-Life"提示框，演示时挡住窗口
  export DISABLE_ROS1_EOL_WARNINGS=1
}

# 清掉 ROS 演示进程（roslaunch/rviz/masc_ws 节点/ros master）。
# 模式只打 roslaunch/rviz 进程名和 /root/masc_ws/ 路径，不碰 QGC、不碰 Docker、不碰 PX4。
ros_cleanup() {
  pkill -x roslaunch 2>/dev/null
  pkill -x rviz 2>/dev/null
  pkill -f '/root/masc_ws/' 2>/dev/null
  sleep 0.5
  pkill -x rosmaster 2>/dev/null
  pkill -x rosout 2>/dev/null
  pkill -x roscore 2>/dev/null
}
