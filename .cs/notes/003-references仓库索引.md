# references/ 仓库索引

## 结论

`references/` 目前共 **20 个仓库 clone**：13 个官方栈，6 个调研补充的外部开源项目，1 个课程作业仓（2026-09-29 加入）。官方栈都是经 ghfast.top 镜像从 github.com 拉的；外部项目的 remote 都已核对，指向正确的上游。按用途分组如下：

| 分组 | 仓库 | 一句话用途 |
|---|---|---|
| **核心栈**（已收录于 notes/001–002） | `PX4-Autopilot` | PX4 固件源码 + 官方文档源（docs.px4.io 渲染源） |
| | `qgroundcontrol` | QGC 源码 + 用户/开发者指南全文 |
| **ROS 2 / 伴飞电脑桥接** | `px4_msgs` | PX4 uORB → ROS 2 `.msg`/`.srv` 接口定义（版本号跟随 PX4 发布线） |
| | `px4_ros_com` | PX4↔ROS 2 示例节点 + 坐标系转换库（offboard 控制示例） |
| | `Micro-XRCE-DDS-Agent` | eProsima uXRCE-DDS Agent：PX4 `uxrce_dds_client` 对接 DDS 的**现行**桥（v3.0.2） |
| | `micrortps_agent` | **旧** microRTPS 桥 agent 端（FastRTPS/FastDDS 时代），已被 uXRCE-DDS 取代，存档参考 |
| | `MAVSDK` | MAVLink SDK（C++/Python 等），多机连接与路由（`systems()`/`get_system_id()`）官方文档与实现（v4.0.0-3） |
| **日志分析** | `pyulog` | ULog 解析库 + 命令行工具（ulog_info/2csv/2kml/2rosbag），可 `pip install` |
| | `flight_review` | review.px4.io 同款 Web 日志分析站（Tornado+Bokeh，依赖 pyulog） |
| | `PlotJuggler` | 时间序列可视化工具（PX4 fork，可加载 ULog/流数据，v3.9.3+） |
| **构建 / 底层 / 文档归档** | `PX4-Bootloader` | STM32F1/F3/F4/F7 旧式 bootloader + 权威 `board_types.txt`（board ID 表） |
| | `PX4-containers` | 官方 `px4io/px4-dev-*` Docker 镜像的 Dockerfile 层级 |
| | `PX4-windows-toolchain` | Windows Cygwin 工具链 MSI 打包工程（WiX；**2021 停更**，官方已转向 WSL2/Docker） |
| | `PX4-user_guide` | **[已归档]** 旧文档仓库，README 明确内容已并入 `PX4-Autopilot/docs`；本地仅作历史快照 |
| **自主规划 / 集群研究**（调研补充，见 `presentation/组会-1/research/sources.md`） | `Fast-Drone-250` | ZJU-FAST-Lab 250mm 自主无人机全套方案（NUC+VINS-Fusion+Ego-Planner+px4ctrl）；**基于 fmu-v5 + PX4 v1.11**（README 明 v1.13 不适用），非本项目基线 |
| | `Fast-Planner` | HKUST+ZJU 合著 kinodynamic+B-spline 规划框架，ego-planner/FUEL/RACER 上游基线；自带 8 个演示 GIF |
| | `ego-planner` | ZJU-FAST-Lab 无 ESDF 梯度局部规划器（~1ms）；自带 4 个演示 GIF |
| | `ego-planner-swarm` | EGO-Planner 集群版：去中心化异步多机导航（ICRA2021）；自带 5 个集群演示 GIF |
| | `mavsdk_drone_show` | MAVSDK-Python 多机 fleet ops（灯光秀轨迹回放/leader-follower/SITL）；自述 demo/beta |
| **课程作业** | `MASC-2026-bonus-homework` | SYSU-HILAB 集群控制附加作业：在 ZJU-FAST-Lab **Swarm-Formation** 上做编队飞行仿真，依次变换 S/Y/S/U 队形并避障（`roslaunch ego_planner normal_hexagon.launch`）。**基于 ROS1 Noetic**（Dockerfile 用 `osrf/ros:noetic-desktop-full`）→ 在 WSL `Ubuntu-20.04` 上跑（见 note 005）。README 规定：不要改 `map_generator` 及其 launch 参数；需提交 `results/demo.gif` 和 `results/report.pdf`；提交前跑 `check_completeness.sh`。**注**：这是用户的本科课程作业模板，原样保留仅作参考项目——用户已毕业，README 里的提交规则对我们不再适用。`references/` 这份保持只读，要构建在 WSL 内副本里进行。 |

## 触发场景

- 想查某个 `references/` 仓库是干什么的、现在还活不活跃、对当前任务有没有用
- 做 ROS 2 / 多机 / offboard 时确认本地已有哪几环桥接件、版本是否对齐
- 日志分析、仿真 Docker、刷机 bootloader 板型核查时定位对应仓库
- 清理/同步 `references/` 时判断哪些可删、哪些是只读快照

## 证据和细节

### 当前本地快照版本（`git describe` / HEAD 时间）

- `PX4-Autopilot` — `v1.18.0-beta1-687`（main，2026-09-16）；项目版本基线 **v1.13.3** 以 tag 存在
- `qgroundcontrol` — `v5.0.3-1391`（master，2026-09-16）
- `Micro-XRCE-DDS-Agent` — `v3.0.2`（2026-09-03）
- `px4_msgs` — main（2026-09-16，同步 PX4 `75cb93a7`）；tag 到 `v1.17.0`
- `px4_ros_com` — `beta-384-g86e9aeb`（main，2024-03-10，**近两年未更新**）
- `PlotJuggler` — `3.9.3-18`（PX4 fork，2025-03-19）
- `flight_review` — 无 tag（main，2026-08-18）
- `pyulog` — `v1.2.4`（2026-08-06）
- `PX4-Bootloader` — `v5.0-314`（2026-09-07）
- `PX4-containers` — `2025-02-10`（2025-02-12，含 Noble）
- `PX4-windows-toolchain` — `v1.0-1`（**2021-03-14，停更**）
- `PX4-user_guide` — 无 tag（main，2026-04-18 自动同步，**已归档只读**）
- `MASC-2026-bonus-homework` — `5cf54cf`（2026-07-04）。父仓里是以 gitlink 形式提交的，没有 `.gitmodules` 条目；remote 的 fetch 走 ghfast.top，push 走原始 github.com

### 与版本基线（v1.13.x）/ 板型（fmu-v2）的适配关系

- **ROS 2 桥接与 fmu-v2 不匹配**：`px4_msgs`/`px4_ros_com`/`Micro-XRCE-DDS-Agent` 走的是 uXRCE-DDS（`uxrce_dds_client` 模块）。该模块默认 `default n`，且需启用板自行打开——fmu-v2（2.4.8，`CONSTRAINED_FLASH/MEMORY=y`）所有变体在 v1.13.3 与 main 上**均未启用** RTPS/DDS 客户端。官方在 v1.13 给 RTPS 出 `rtps.px4board` 变体的板均为 fmu-v5/v5x/fmuk66/pixracerpro 等更大 flash 板。→ 2.4.8 实机暂不能走 DDS/ROS 2；多机/offboard 若需 ROS 2，须换受支持板或走 MAVLink。
- **`micrortps_agent` 是遗产**：对应 PX4 `micrortps_bridge`（v1.13 尚存、main 已移除），配合旧 `micrortps_client`。仅存档参考；新工作用 uXRCE-DDS 一组。
- **`px4_msgs` 版本号 = PX4 发布线**：头文件注明由 PX4-Autopilot uORB 定义自动同步；查消息定义时注意 tag（本地 HEAD 对齐 v1.17，与 v1.13 基线有差异）。
- **WSL 22.04 的 ROS 2 工作区用的是同一批源码**：`~ucy/ros2_ws` 的 `px4_msgs` 与本地 `references/px4_msgs` 是同一提交 72fcfaa，`px4_ros_com` 是 main 86e9aeb，已编译通过。它和 v1.13.3 SITL 不对接，原因见 note 005「版本对齐」。当前 `SensorGps.msg` 里仍有 `heading` 字段，并没有被改名。

### 日志分析链（单机调试直接可用）

`pyulog`（解析）→ `flight_review`（自建 Web 分析，review.px4.io 同源）/ `PlotJuggler`（本地拖拽绘图）。QGC 本身也可一键上传日志到 review.px4.io；本地 clone 用于离线/私有化分析与理解 ULog 字段。

### 构建与底层

- `PX4-containers`：`docker/` 下 Dockerfile 层级（base → nuttx → simulation → ros/ros2），README 列完整镜像族谱与 `docker run` 用法；配合 `PX4-Autopilot/Tools/docker_run.sh` 在 Windows 上跑编译/SITL。
- `PX4-Bootloader`：`board_types.txt` 是 QGC `px4_board_name_map` 与刷机 board ID 判定的**权威来源**（issue 001 已用它核对 2.4.8→board ID 9→`px4_fmu-v2_default`）。
- `PX4-windows-toolchain`：Cygwin+gcc-arm+jdk+ant 的 MSI 打包工程，2021 停更——官方 Windows 构建已迁 WSL2/Docker；仅历史参考，不作为新装机路径。

### 规模与同步

- 体积：`PX4-user_guide` 1.1G、`PX4-Autopilot` 987M、`qgroundcontrol` 682M、`Fast-Drone-250` ~147M、`flight_review` 91M、`PlotJuggler` 72M，其余 ≤19M。
- 全部 remote 走 `ghfast.top` 镜像；`git pull` 即同步（详见 notes/002 更新方式）。
- 子模块：`PX4-Autopilot` 的仿真器等为 `-` 未初始化状态（SITL 需先 `git submodule update` 对应子模块，见 issue 004）。

### 调研补充组（第六组）核查要点

- **多机 ROS 2 桥接在 fmu-v2 上的硬边界**（v1.13.3 源码核实）：fmu-v2 **没有 `rtps.px4board` 构建变体**（仅 default/fixedwing/multicopter/rover），`micrortps_client` 无从启用；`rtps.px4board` 只在 fmu-v5/v5x/fmuk66/pixracerpro/sitl 等大 flash 板存在。→ v1.13 多机 ROS2 需换板或走伴飞电脑 MAVLink。
- **多机 SITL 脚本**：v1.13.3 `Tools/gazebo_sitl_multiple_run.sh` 存在（无 ROS 的 Gazebo Classic 多机）；main 已删。`MAV_SYS_ID` 由 `rcS` 的 `px4_instance+1` 自动分配。
- **MAVSDK 多机路由**：`docs/en/cpp/guide/connections.md`——`udpin://0.0.0.0:14540` 监听 → `subscribe_on_new_system()` → `systems()` 向量 → `get_system_id()` 区分目标。
- **演示素材**：`ego-planner-swarm/pictures/`（5）、`Fast-Planner/files/`（8）、`ego-planner/pictures/`（4）含仓库自带演示 GIF，可作 PPT 集群/规划素材（标"开源项目官方演示"）。
- 各仓库在调研素材池的取舍见 `presentation/组会-1/research/sources.md`。

## 相关位置

- `.cs/notes/001-入门资源索引.md` — 教程与官方下载渠道
- `.cs/notes/002-PX4本地文档查阅.md` — `PX4-Autopilot`/`qgroundcontrol` 两仓的离线文档用法
- `.cs/issues/001-x-找回调参与QGC资源.md` — 用 `PX4-Bootloader/board_types.txt` 核对板型映射的实例
- `.cs/spec/index.md` — 版本基线 v1.13.x 与"官方为权威"原则
- `.cs/issues/004`/`005` — SITL 与多机/ROS 2 检索，直接消费本索引中的桥接与容器仓
- `.cs/notes/005-WSL-ROS环境.md` — 本地这些桥接件在 WSL 中的实际安装与版本
