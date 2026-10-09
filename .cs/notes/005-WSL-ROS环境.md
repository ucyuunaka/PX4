# 005 — WSL ROS 环境（Noetic + Humble）与网络

> 2026-09-29 搭建，2026-09-30 按实机核对重写（纠正了初版中默认用户、`heading` 改名、Clash 可达、loopback 行为等错误说法）；2026-10-09 更新网络一节：WSL 已恢复 `nat`（issue 007-x 关闭）。
> **定位**：WSL 目前是可用的开发环境，但**不一定是长期基座**——后续可能换到原生 Ubuntu，届时本 note 的网络部分基本作废，发行版/ROS/镜像部分仍可作装机清单参考。

## 结论

- 两个 WSL2 发行版都在 U: 盘：`Ubuntu-20.04` 跑 ROS **Noetic**（ego-planner / Fast-Planner / Fast-Drone-250 / MASC 集群作业），`Ubuntu-22.04` 跑 ROS 2 **Humble**（px4_msgs / px4_ros_com / Micro-XRCE-DDS-Agent）。
- **WSL 网络已恢复 `nat` 模式**（2026-10-09）：根因是 Windows 防火墙服务 `mpssvc` 被禁用，HNS 建不了 WSL 的 NAT 网络；恢复服务并改为关闭防火墙配置文件后正常。过程见 `.cs/issues/007-x-修复WSL-Windows层网络.md`。回环补丁 `wsl-loopback-fix.sh` 在 NAT 下自动空转，保留安装。
- 下载侧不开 Clash 即可用：apt/pip/ROS 走国内镜像，GitHub 走 `gh-proxy.com` 前缀。
- 22.04 的 ROS 2 工具链对应 PX4 **v1.14+ 的 uXRCE-DDS 桥**，与项目基线 **v1.13.3 SITL 不对接**；要做 ROS 2 联调仿真需另编新版 SITL（见文末）。

## 触发场景

- 进 WSL 跑 ROS1/ROS2、PX4 SITL、MAVROS/MAVSDK、XRCE Agent 前
- 本机程序连 `127.0.0.1` 连不上、UDP 收不到包
- apt/pip/rosdep/git clone 拉不下来
- 换原生 Ubuntu、或 WSL 网络模式再变化之后回来改本 note

## 发行版一览

| 发行版 | 系统 | 用途 | VHDX | 默认用户 |
|---|---|---|---|---|
| `Ubuntu-20.04` | 20.04.6 focal | ROS Noetic desktop-full（含 Gazebo 11）+ PX4 v1.13.3 SITL | `U:\WSL\Ubuntu-20.04` | **root**（另有 ucy） |
| `Ubuntu-22.04` | 22.04.5 jammy | ROS 2 Humble desktop + PX4 ROS 2 桥接件 | `U:\WSL\Ubuntu-22.04` | **ucy**（`/etc/wsl.conf` `[user] default=ucy`；另有 root） |

两边的 ucy 都是 uid 1000、sudo 组、密码相同。进入：`wsl -d Ubuntu-20.04` / `wsl -d Ubuntu-22.04`。

## 网络

### 现状：NAT（2026-10-09 起，实测）

- `wslinfo --networking-mode` → `nat`（两个发行版同）。拓扑：Windows 侧有 `vEthernet (WSL (Hyper-V firewall))` 172.29.160.1/20；WSL `eth0` 172.29.171.4/20，默认网关 172.29.160.1 = Windows 侧 vEthernet 地址。**这套地址是动态的**（每次建网可能变），脚本里用 `ip route | awk '/default/{print $3}'` 现取网关、`hostname -I | awk '{print $1}'` 现取本机 IP，不要写死。
- 回环完全正常：WSL 内部 TCP/UDP 连 127.0.0.1（含临时端口、任意绑定）都通，UDP 45999 与 TCP 临时端口均已实测。
- **前提：Windows 防火墙服务 `mpssvc` 必须保持运行**。用户选择不要防火墙过滤，做法是关配置文件 `Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False`——**停服务会立刻回到 virtioproxy**（HNS 建网要靠它加防火墙规则）。
- 所有发行版共用一个 VM 网络栈（含 docker-desktop），两个 Ubuntu 的 IP、路由相同。

### 历史：virtioproxy 回退期（约 2026-09-27 ~ 2026-10-09）【已过时，仅存档】

当时 mpssvc 被禁用 → HNS 建 NAT 失败（`0x800706D9`），每次启动回退到 virtioproxy；试 mirrored 报"不支持"（很可能同因）。表现：Windows 无 `vEthernet (WSL)` 网卡；`eth0` IP = 宿主 WLAN IP；`ip rule` 有 pref 1 的 `ipproto tcp/udp lookup 127`，把发往 127.0.0.1 的流量经 `loopback0` 送到 Windows。当时的回环行为矩阵（该模式下实测，NAT 下不适用）：

| 场景 | 结果 |
|---|---|
| WSL → Windows 的 127.0.0.1（TCP/UDP） | 通 |
| WSL 内部 TCP → 127.0.0.1，**固定端口**监听 | 通 |
| WSL 内部 TCP → 127.0.0.1，**临时端口**（bind 端口 0） | 拒绝连接 |
| WSL 内部 UDP → 127.0.0.1（任何绑定） | **不通** |
| WSL 内部 → eth0 IP，监听绑 `0.0.0.0` | TCP/UDP 都通 |

当时为 PX4 相关 UDP 端口打了 `wsl-loopback-fix.sh` 开机补丁，并把 SITL↔Gazebo 的 TCP 4560 绕到 eth0 IP（见 ff 009）。

### 补丁：`wsl-loopback-fix.sh`（NAT 下空转，保留）

- 位置：两个发行版的 `/usr/local/sbin/wsl-loopback-fix.sh`（仓库副本 `.cs/env/wsl-loopback-fix.sh`），由 `/etc/wsl.conf` 的 `[boot] command = /usr/local/sbin/wsl-loopback-fix.sh` 在发行版启动时执行。
- 作用（virtioproxy 下才有意义）：加 pref 0 规则，让发往 127.0.0.0/8 且端口为 8888（XRCE）、14540–14549、14557、14580–14589（MAVROS/MAVSDK ↔ PX4 offboard 链路）的 UDP 留在 WSL 内部。
- **NAT 下没有 `lookup 127` 规则，脚本自动什么都不做**（已验证 `ip rule` 只剩默认 3 条）。保留：若哪天再回退到 virtioproxy 它会自动生效；要删就连 `/etc/wsl.conf` 的 `[boot]` 段一起去掉。

### 对各链路的影响（NAT 下）

- **ROS1**：`ROS_IP=ROS_HOSTNAME=<eth0 IP>`、`ROS_MASTER_URI=http://<eth0 IP>:11311` 在 NAT 下仍可用（节点用临时端口，走 eth0 IP 无回环问题），20.04 root `.bashrc` 的动态设置保留；**ucy 的 `.bashrc` 仍没有这几行**（已知遗留，要用 ucy 跑 ROS1 先补上）。回环方式也已实测：`ROS_MASTER_URI=http://127.0.0.1:11311` + `ROS_IP=127.0.0.1` 的 ROS1 全链路（roslaunch/12 节点/rostopic）在 NAT 下正常——演示 D（Swarm-Formation，`/root/masc_ws`，issue 013-x，`demos/lib/ros1.sh`）即此用法；注意 rviz 启动会弹 ROS 1 EOL 对话框，用 `DISABLE_ROS1_EOL_WARNINGS=1` 抑制。
- **PX4 v1.13.3 SITL ↔ Gazebo**：TCP 4560 走 127.0.0.1 直连正常——2026-10-09 复验，不带绕路环境变量时 `PX4 SIM HOST: localhost`、连接成功并完整起飞降落。启动器里的 `GAZEBO_IP`/`PX4_SIM_HOST_ADDR`（绕 eth0 IP）已不需要，NAT 下无害，保留。见 ff 009。
- **MAVROS / MAVSDK / XRCE Agent**：127.0.0.1 的 UDP 默认就通，不再需要补丁（端口级验证，未带真实程序实跑）。
- **ROS 2 DDS**：`demo_nodes_cpp talker` 能发布；listener 收包**未确认**（用户决定暂不继续验证）。
- **Windows QGC 连 WSL 里的 SITL**：NAT 下 PX4 发往 127.0.0.1:14550 的 UDP 只留在 WSL 内部，QGC 直接收不到；**已验证的做法**：pxh `mavlink start -u 14557 -r 4000000 -t <网关IP> -o 14550`，QGC 默认监听自动发现，双向通（issue 011-x；`demos/lib/common.sh` 的 `gcs_link_to_windows`）。备选未实测：QGC 手动 Comm Link 指 WSL eth0 IP:14550；`MAV_BROADCAST=1`。详见 note 004 §五。

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
wslinfo --networking-mode      # 期望 nat（2026-10-09 已恢复）
ip rule | grep 'lookup local'  # NAT 下无补丁加的 pref 0 规则属正常（补丁空转）
```

- 非交互 shell（脚本、`wsl -- cmd`）不加载 `.bashrc` 末尾的 source 行，脚本里要显式 `source /opt/ros/<distro>/setup.bash`。
- Windows 侧经 Git Bash 调 `wsl.exe` 会被 MSYS 改写以 `/` 开头的参数：用 PowerShell，或加 `MSYS2_ARG_CONV_EXCL='*'`。

## 相关位置

- `.cs/issues/007-x-修复WSL-Windows层网络.md` — virtioproxy→NAT 根治记录（2026-10-09 关闭）
- `.cs/issues/009-x-ff-SITL-virtioproxy绕路与NAT恢复后复验.md` — SITL 4560 绕路与 NAT 复验
- `.cs/issues/008-x-ff-wsl-loopback-and-mirror-cleanup.md` — 回环补丁与核对记录
- `.cs/env/wsl-loopback-fix.sh` — 回环补丁脚本仓库副本
- `.cs/notes/004-PX4仿真SITL路径.md` — v1.13.3 SITL 复现
- `.cs/notes/003-references仓库索引.md` — px4_msgs / px4_ros_com / XRCE Agent 与基线的适配
- `HANDOFF.md`「WSL ROS 环境」— 搭建过程与踩坑流水
