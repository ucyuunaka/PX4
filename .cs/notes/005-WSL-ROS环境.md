# 005 — WSL ROS 环境（Noetic + Humble）

> 2026-09-29 搭建。两个 WSL2 发行版，默认用户均为 **root**，均在 U: 盘。

## 发行版一览

| 发行版 | 系统 | 用途 | VHDX 位置 | 默认用户 |
|---|---|---|---|---|
| `Ubuntu-20.04` | 20.04.6 focal | ROS **Noetic**（ego-planner / Fast-Planner / Fast-Drone-250） | `U:\WSL\Ubuntu-20.04` | root |
| `Ubuntu-22.04` | 22.04.5 jammy | ROS 2 **Humble**（px4_msgs / px4_ros_com / Micro-XRCE-DDS-Agent） | `U:\WSL\Ubuntu-22.04` | root |

进入方式：`wsl -d Ubuntu-20.04` / `wsl -d Ubuntu-22.04`。22.04 里另有一个 `ucy` 普通用户（`wsl --install` 残留），目前用不到。

## 关键坑：网络

WSL 处于 **mirrored/特殊网络**（eth0 与宿主机 WLAN 同 IP），表现为：

- **DNS 需手动指定公共 DNS**。`/etc/wsl.conf` 设了 `[network] generateResolvConf=false`，`/etc/resolv.conf` 写死 `223.5.5.5`/`119.29.29.29`（阿里/腾讯）。WSL 自动生成的 nameserver 192.168.209.114 解析不了。
- **loopback 怪癖**：绑 `127.0.0.1` 的监听拒绝回环连接，绑 `0.0.0.0` 则正常。→ ROS1 必须 `ROS_IP=ROS_HOSTNAME=ROS_MASTER_URI=<eth0 IP>`（已写入 20.04 `/root/.bashrc`，用 `hostname -I` 动态取）。
- **IPv6 不通**：两发行版都有 `/etc/apt/apt.conf.d/99force-ipv4` → `Acquire::ForceIPv4 "true";`（否则 apt 偶尔解析到 v6 超时）。
- **github.com 直连不通**：git 走 `https://gh-proxy.com/https://github.com/...` 前缀，或全局 `git config url."https://gh-proxy.com/https://github.com/".insteadOf "https://github.com/"`（root 的 `~/.gitconfig` 已配，clone/子模块自动生效）。
- apt/pip 镜像：`https://mirrors.cloud.tencent.com`（ubuntu + ros2 + pypi 都通，~3-5MB/s）。USTC 有 ubuntu 和 ros1 但**无 ros2**；TUNA 在此网络 403。
- 宿主机跑着 **Clash for Windows**（`127.0.0.1:7890`）+ Tailscale。WSL 里 `127.0.0.1:7890` 可达，必要时可作 http_proxy。

## Ubuntu-20.04（Noetic）

- `ros-noetic-desktop-full`（含 Gazebo 11）、`catkin`、`python3-catkin-tools`、`rosdep`、`wstool`、`build-essential`、`vim/htop/tmux/net-tools`。
- **rosdep**：GitHub raw 不通，官方 `rosdep update` 失败；已装 `rosdepc`（小鱼镜像，`/usr/local/bin/rosdepc`），用 `rosdepc update` 代替。
- `.bashrc` 已 source `/opt/ros/noetic/setup.bash` 并 export `ROS_IP/ROS_HOSTNAME/ROS_MASTER_URI=<eth0 ip>`。
- 已有 PX4 SITL 源码 `/root/px4-sitl-src`（v1.13.3）与构建脚本 `/root/px4-build/`（见 note 004）。
- 验证：`roscore` 可启动，`/rosout` 在列，`rosversion -d`=noetic。

## Ubuntu-22.04（Humble）

- `ros-humble-desktop`、`ros-dev-tools`、`python3-colcon-common-extensions`、`python3-rosdep`、`python3-vcstool`、`ros-humble-eigen3-cmake-module`、`build-essential`、`git/cmake/python3-pip`、`vim/htop/tmux`。
- **Micro-XRCE-DDS-Agent v2.4.2** 源码编译装到 `/usr/local`（apt 无此包）：`MicroXRCEAgent udp4 -p 8888` 可监听。依赖 fastrtps 2.12.2/fastcdr/microcdr 随 superbuild 装进 /usr/local（与 ROS 自带 fastdds 2.6.x 独立，无冲突）。编译时把 `CMakeLists.txt` 里 `_fastdds_tag 2.12.x` 改成 `v2.12.2`（上游删了 `2.12.x` 分支）。
- **ROS2 工作区 `~/ros2_ws`**：`src/px4_msgs` 和 `src/px4_ros_com`，都已切到 **`release/1.16`** 分支并 `colcon build` 成功。**两边 main 不同步**（main 的 SensorGps 已把 `heading` 改名 `cog_rad`，px4_ros_com 示例还在用老字段），所以必须同 branch 编。
- `.bashrc` 已 source `/opt/ros/humble/setup.bash` + `~/ros2_ws/install/setup.bash`。
- 时区 Asia/Shanghai，pip 走腾讯镜像。

## 常用命令速查

```bash
# ROS1 (20.04): 进终端即已 source，roscore 直接起
roscore

# ROS2 (22.04): 进终端即已 source（含 ~/ros2_ws）
ros2 pkg list | grep px4        # 验证 px4_msgs/px4_ros_com 已编译
MicroXRCEAgent udp4 -p 8888     # 起 XRCE agent 等 PX4 uXRCE client

# 重编工作区
cd ~/ros2_ws && source /opt/ros/humble/setup.bash && colcon build --packages-select px4_msgs px4_ros_com
```

## 已知遗留

- `rosdep`（原生）在两边都因 GitHub 不通不可用；20.04 用 `rosdepc` 顶替，22.04 如需可在 `~/.pip` 已配腾讯源的基础上 `pip3 install rosdepc` 同样顶替。
- Gazebo Classic 在 20.04 是 11.x（随 desktop-full），与既有 SITL（v1.13.3+Gazebo 11.15.1）兼容；22.04 装的是 Humble desktop 自带 RViz2。
- Clash/TUN 若日后调整网络模式，记得回来检查 `resolv.conf`（generateResolvConf=false 已冻结）与 loopback 行为是否变化。
