# 005 — WSL ROS 环境（Noetic + Humble）与网络

> 2026-09-29 搭建，2026-09-30 按实机核对重写（纠正了初版中默认用户、`heading` 改名、Clash 可达、loopback 行为等错误说法）。
> **定位**：WSL 目前是可用的开发环境，但**不一定是长期基座**——后续可能换到原生 Ubuntu，届时本 note 的网络部分基本作废，发行版/ROS/镜像部分仍可作装机清单参考。

## 结论

- 两个 WSL2 发行版都在 U: 盘：`Ubuntu-20.04` 跑 ROS **Noetic**（ego-planner / Fast-Planner / Fast-Drone-250 / MASC 集群作业），`Ubuntu-22.04` 跑 ROS 2 **Humble**（px4_msgs / px4_ros_com / Micro-XRCE-DDS-Agent）。
- **WSL 网络处于 `virtioproxy` 回退模式**（Windows 层 NAT 创建失败，镜像模式被判"不支持"；`.wslconfig` 救不了）。WSL 内部 UDP 走 127.0.0.1 默认不通，已用开机脚本对 PX4 相关端口打补丁；根治需管理员操作，见 issue 007（待用户执行）。
- 下载侧不开 Clash 即可用：apt/pip/ROS 走国内镜像，GitHub 走 `gh-proxy.com` 前缀。
- 22.04 的 ROS 2 工具链对应 PX4 **v1.14+ 的 uXRCE-DDS 桥**，与项目基线 **v1.13.3 SITL 不对接**；要做 ROS 2 联调仿真需另编新版 SITL（见文末）。

## 触发场景

- 进 WSL 跑 ROS1/ROS2、PX4 SITL、MAVROS/MAVSDK、XRCE Agent 前
- 本机程序连 `127.0.0.1` 连不上、UDP 收不到包
- apt/pip/rosdep/git clone 拉不下来
- Windows 网络修复（issue 007）或换原生 Ubuntu 之后回来改本 note

## 发行版一览

| 发行版 | 系统 | 用途 | VHDX | 默认用户 |
|---|---|---|---|---|
| `Ubuntu-20.04` | 20.04.6 focal | ROS Noetic desktop-full（含 Gazebo 11）+ PX4 v1.13.3 SITL | `U:\WSL\Ubuntu-20.04` | **root**（另有 ucy） |
| `Ubuntu-22.04` | 22.04.5 jammy | ROS 2 Humble desktop + PX4 ROS 2 桥接件 | `U:\WSL\Ubuntu-22.04` | **ucy**（`/etc/wsl.conf` `[user] default=ucy`；另有 root） |

两边的 ucy 都是 uid 1000、sudo 组、密码相同。进入：`wsl -d Ubuntu-20.04` / `wsl -d Ubuntu-22.04`。

## 网络（2026-09-30 实测）

### 现状：virtioproxy 回退模式

- 未写 `.wslconfig`，WSL 本应用 NAT；Windows 事件日志（应用程序日志，来源 `WSL`）显示**至少从 2026-09-27 起**每次启动都报"无法配置网络 (networkingMode Nat)，回退到 networkingMode VirtioProxy"。试 `networkingMode=mirrored` 则报"不支持镜像网络模式：Windows 版本 26100.7840 没有所需的功能"，再回退到同一模式（已还原，当前无 `.wslconfig`）。
- 查看：`wslinfo --networking-mode` → `virtioproxy`。表现：Windows 侧没有 `vEthernet (WSL)` 网卡；WSL 的 `eth0` IP = 宿主 WLAN IP（当前 `192.168.209.154`，随 WiFi/DHCP 变化）；`ip rule` 有 pref 1 的 `ipproto tcp/udp lookup 127`，把发往 127.0.0.1 的流量经 `loopback0` 送到 Windows。
- 所有发行版共用一个 VM 网络栈（含 docker-desktop），两个 Ubuntu 的 IP、路由规则相同。

### 回环行为矩阵（未打补丁时）

| 场景 | 结果 |
|---|---|
| WSL → Windows 的 127.0.0.1（TCP/UDP） | 通 |
| WSL 内部 TCP → 127.0.0.1，**固定端口**监听 | 通 |
| WSL 内部 TCP → 127.0.0.1，**临时端口**（bind 端口 0） | 拒绝连接 |
| WSL 内部 UDP → 127.0.0.1（任何绑定） | **不通** |
| WSL 内部 → eth0 IP，监听绑 `0.0.0.0` | TCP/UDP 都通 |

初版"绑 `0.0.0.0` 就正常"的说法不对：连 127.0.0.1 的 UDP 与绑定地址无关，一律不通。

### 已打的补丁：`wsl-loopback-fix.sh`

- 位置：两个发行版的 `/usr/local/sbin/wsl-loopback-fix.sh`（仓库副本 `.cs/env/wsl-loopback-fix.sh`），由 `/etc/wsl.conf` 的 `[boot] command = /usr/local/sbin/wsl-loopback-fix.sh` 在发行版启动时执行（异步，启动后 1–3 秒规则才出现）。
- 作用：加 pref 0 规则，让发往 127.0.0.0/8 且端口为 **8888（XRCE）、14540–14549、14557、14580–14589（MAVROS/MAVSDK ↔ PX4 offboard 链路）** 的 UDP 留在 WSL 内部；其他 UDP 仍去 Windows（例如 PX4 → Windows QGC 的 14550）。没有 `lookup 127` 规则时（NAT/镜像模式）自动什么都不做。
- 已验证：删规则 → 模拟收发失败 → `wsl --terminate` 重启发行版 → 规则自动恢复 → XRCE/MAVROS/MAVSDK 三组端口双向收发通过，对照端口仍不通；WSL→Windows 回环与 Docker 端口不受影响。
- 新工具用了列表外的 UDP 端口：要么把端口加进脚本 `PORTS`，要么改用 eth0 IP（`hostname -I | awk '{print $1}'`）并让监听绑 `0.0.0.0`。

### 对各链路的影响

- **ROS1**：节点用临时端口，必须 `ROS_IP=ROS_HOSTNAME=<eth0 IP>`、`ROS_MASTER_URI=http://<eth0 IP>:11311`。20.04 的 **root** `.bashrc` 已用 `hostname -I` 动态设置；**ucy 的 `.bashrc` 没有这几行**（已知遗留，要用 ucy 跑 ROS1 先补上）。
- **PX4 v1.13.3 SITL ↔ Gazebo**：走固定端口 TCP 4560，按矩阵不受影响（推断；2026-09-30 未重跑 SITL）。
- **MAVROS / MAVSDK / XRCE Agent**：补丁后按默认 127.0.0.1 配置可用（端口级验证，未带真实程序实跑）。
- **ROS 2 DDS**：`demo_nodes_cpp talker` 能发布；listener 收包**未确认**（用户决定暂不继续验证）。
- **Windows QGC 连 WSL 里的 SITL**：PX4 默认发往 127.0.0.1:14550，WSL→Windows UDP 通，理论上 QGC 直接可收（未实测）。

### DNS / IPv6 / 代理

- `/etc/wsl.conf` `[network] generateResolvConf=false`（两边），`/etc/resolv.conf` 写死 `223.5.5.5`、`119.29.29.29`。
- 两边有 `/etc/apt/apt.conf.d/99force-ipv4`（`Acquire::ForceIPv4 "true";`）。
- **不依赖 Clash**：用户默认不开，WSL 里 `127.0.0.1:7890` 实测连不上（没有服务在监听），不要把它写进任何代理配置。Windows 注册表里残留 `ProxyServer=127.0.0.1:7890`（`ProxyEnable=0`），WSL 启动时的"检测到 localhost 代理配置"警告可忽略。

## 镜像与下载（不开 Clash 实测可用）

| 用途 | 来源 |
|---|---|
| Ubuntu apt | 腾讯 `mirrors.cloud.tencent.com`（两边） |
| ROS1 apt（20.04） | 中科大 `mirrors.ustc.edu.cn`（USTC 无 ros2） |
| ROS2 apt（22.04） | 腾讯 |
| pip | 腾讯（root 与 ucy 的 `~/.pip/pip.conf`） |
| rosdep | USTC rosdistro 镜像（见下） |
| GitHub | 直连超时；`gh-proxy.com` 与 `ghfast.top` 前缀都可用（约 1 秒响应） |

- TUNA 在此网络 403，不用。
- **git**：两个发行版的 root 与 ucy 都已配 `git config --global url."https://gh-proxy.com/https://github.com/".insteadOf "https://github.com/"`，clone/子模块自动走代理。Windows 侧 `references/` 的 remote 用的是 `ghfast.top` 前缀，两者并存无冲突。
- **rosdep**（原生，**不再用 rosdepc**，20.04 已卸载）：`/etc/ros/rosdep/sources.list.d/20-default.list` 把 `raw.githubusercontent.com/ros/rosdistro/master` 换成 `https://mirrors.ustc.edu.cn/rosdistro/`，并把 `rosdistro/__init__.py` 的 `DEFAULT_INDEX_URL` 改为 `https://mirrors.ustc.edu.cn/rosdistro/index-v4.yaml`。Noetic 已 EOL，更新必须 `rosdep update --include-eol-distros`，否则 `rosdep resolve catkin` 报 no rule。

## Ubuntu-20.04（Noetic）

- `ros-noetic-desktop-full`（含 Gazebo 11）、catkin / catkin-tools、rosdep、wstool、build-essential 等。
- root 与 ucy 的 `.bashrc` 都 source `/opt/ros/noetic/setup.bash`；ucy 另条件 source `~/catkin_ws/devel/setup.bash`（`~ucy/catkin_ws` 空 src，已 `catkin_make`）。
- PX4 v1.13.3 SITL 源码 `/root/px4-sitl-src`、构建/启动脚本 `/root/px4-build/`，见 note 004。
- 验证过：`roscore` 可起，`rosnode list` 见 `/rosout`。

## Ubuntu-22.04（Humble）

- `ros-humble-desktop`、`ros-dev-tools`、colcon、rosdep、vcstool、`ros-humble-eigen3-cmake-module` 等；时区 Asia/Shanghai。
- **ROS 2 工作区只有 `~ucy/ros2_ws`**（root 下的旧实验工作区已于 2026-09-30 删除）：
  - `src/px4_msgs` 在 **72fcfaa**（main，2026-09-16，与 `references/px4_msgs` 同一提交，对应 PX4 main v1.18 开发期）
  - `src/px4_ros_com` 在 main **86e9aeb**（2024-03-10，上游最新即此）
  - 两包 `colcon build` 通过；root 与 ucy 的 `.bashrc` 都 source humble，并条件 source `~/ros2_ws/install/setup.bash`
- **关于 `heading` 字段**：初版和 HANDOFF 说"新版 SensorGps 删了/改名了 `heading`"——**不成立**。72fcfaa 的 `SensorGps.msg` 仍有 `heading`/`heading_offset`/`heading_accuracy`（`cog_rad` 是另一个新增字段）。ucy 工作区副本 `vehicle_gps_position_listener.cpp` 里删掉的两行打印其实没必要，但无害；要恢复就在该仓库 `git checkout` 该文件后重编。
- **Micro-XRCE-DDS-Agent v2.4.2**：superbuild 源码编译装到 `/usr/local`（`MicroXRCEAgent udp4 -p 8888` 可启动）；编译时把 `CMakeLists.txt` 的 `_fastdds_tag 2.12.x` 改成 `v2.12.2`（上游删了 `2.12.x` 分支）。fastrtps/fastcdr 随 superbuild 进 `/usr/local`，与 ROS 自带 FastDDS 互不影响。源码目录在 `/tmp/Micro-XRCE-DDS-Agent`，**随时可能被清**，重装需重新 clone。PX4 官方文档（`docs/en/middleware/uxrce_dds.md`）主推 **v2.4.3**，v2.4.2 也在其示例中出现。

## 版本对齐（ROS 2 联调前必读）

- 项目基线 PX4 **v1.13.3** 用的是旧 microRTPS 桥（`micrortps_client`），且 fmu-v2 实机根本没有 RTPS/DDS 构建变体（note 003）。
- 22.04 这套 `px4_msgs`（main）+ XRCE Agent 对应 **v1.14+ 的 uXRCE-DDS**。→ v1.13.3 SITL 不能直接和它对接。
- 以后要 ROS 2 联调仿真：另编一个新版 SITL（如 v1.16 左右），并把 `px4_msgs` 切到**与该 PX4 版本匹配**的分支/提交再重编；不要为迁就 `px4_ros_com` 把 `px4_msgs` 回退到 2024-03。

## 常用命令

```bash
# 20.04 ROS1（root 已设好 ROS_IP 等）
roscore

# 22.04 ROS2（交互终端已 source）
ros2 pkg list | grep px4
MicroXRCEAgent udp4 -p 8888
cd ~/ros2_ws && source /opt/ros/humble/setup.bash && colcon build --packages-select px4_msgs px4_ros_com

# 网络自查
wslinfo --networking-mode      # 期望 nat；当前 virtioproxy
ip rule | grep 'lookup local'  # 应能看到 8888 / 14540-14549 等 pref 0 规则
```

- 非交互 shell（脚本、`wsl -- cmd`）不加载 `.bashrc` 末尾的 source 行，脚本里要显式 `source /opt/ros/<distro>/setup.bash`。
- Windows 侧经 Git Bash 调 `wsl.exe` 会被 MSYS 改写以 `/` 开头的参数：用 PowerShell，或加 `MSYS2_ARG_CONV_EXCL='*'`。

## 相关位置

- `.cs/issues/007-o-修复WSL-Windows层网络.md` — 根治 virtioproxy 的管理员操作指引（待用户执行）
- `.cs/issues/008-x-ff-wsl-loopback-and-mirror-cleanup.md` — 本次核对与修补记录
- `.cs/env/wsl-loopback-fix.sh` — 回环补丁脚本仓库副本
- `.cs/notes/004-PX4仿真SITL路径.md` — v1.13.3 SITL 复现
- `.cs/notes/003-references仓库索引.md` — px4_msgs / px4_ros_com / XRCE Agent 与基线的适配
- `HANDOFF.md`「WSL ROS 环境」— 搭建过程与踩坑流水
