# 出处登记与取舍表

> 调研 AI 产出：`raw/2026-09-27-多机协同与素材调研.md`
> 状态图例：⬜ 待定 / ✅ 入选 / ❌ 弃用 / ⚠️ 待本地核查

## 待下载到 references/ 的外部依赖

| 编号 | 内容 | 出处 | 状态 | 备注 |
|---|---|---|---|---|
| DL-1 | MAVSDK 官方文档 | mavsdk.mavlink.io | ✅ 已下载+核查 | `references/MAVSDK`（v4.0.0-3，含 `docs/en/cpp/guide/connections.md`）。⚠️ 注意：调研报告引的是 v1.4/v2.0 URL，本地是 v4.0.0——多机 API（`systems()`/`get_system_id()`）两版一致，但引用版本号以本地为准 |
| DL-2 | Gazebo Classic 多机 SITL 文档 | docs.px4.io/v1.12/.../multi_vehicle_simulation_gazebo | ✅ 本地已有 | **不必下载**：本地 `references/PX4-Autopilot/docs/en/sim_gazebo_classic/multi_vehicle_simulation.md` 即官方多机仿真文档（注：本地 docs 是 main 快照；v1.13.3 tag 不含 docs，引版本时标"main 文档+v1.13 脚本已核实"） |
| DL-3 | Fast-Drone-250 | github.com/ZJU-FAST-Lab/Fast-Drone-250 | ✅ 已重下+核查 | `references/Fast-Drone-250`（1132 文件，remote 已修正为 ZJU-FAST-Lab）。**核查发现一个对 PPT 很重要的细节**：它自带固件是 `firmware/px4_fmu-v5_default.px4`（**官方 v1.11.0 编译**），README 明确"Firmware v1.13 is not suitable for this project"——即该方案基于 v1.11+fmu-v5+NUC 伴飞电脑，不是 v1.13/fmu-v2。引作案例时必须标此版本前提。 |
| DL-4 | mavsdk_drone_show | github.com/alireza787b/mavsdk_drone_show | ✅ 已下载+核查 | `references/mavsdk_drone_show`（57文件，remote 正确）。README 证实：MDS/Mission-Directed Swarm，MAVSDK-Python 多机 fleet ops + SITL + 灯光秀轨迹回放 + leader-follower。注：自述为 demo/beta 非生产级，PPT 表述勿夸大 |
| DL-5 | EGO-Planner / EGO-Swarm | github.com/ZJU-FAST-Lab/ego-planner(-swarm) | ✅ 已下载+核查 | `references/ego-planner`+`ego-planner-swarm`（remote 正确）。README 证实：EGO-Swarm=去中心化多机集群导航（ICRA2021 论文），EGO-Planner=无 ESDF 梯度局部规划 ~1ms。**自带 GIF**：`ego-planner-swarm/pictures/{title,outdoor,indoor1,indoor2,sim_demo}.gif` 可直接作 PPT 集群演示素材 |
| DL-6 | Fast-Planner | github.com/HKUST-Aerial-Robotics/Fast-Planner | ✅ 已下载+核查 | `references/Fast-Planner`（remote 正确，HKUST+ZJU 合著）。README 证实：kinodynamic+B-spline 规划框架，ego-planner/FUEL/RACER 的上游。**自带 GIF**：`files/{raptor1,raptor2,icra20_*,ral19_*}.gif`（8个）可作用户演示素材 |

## 素材条目（来自调研报告）

### A. 多机协同路径
| 编号 | 一句话 | 出处 | 状态 | 备注 |
|---|---|---|---|---|
| A-01 | MAV_SYS_ID 区分身份、QGC 下拉切换 | PX4官方+QGC指南 | ✅ 已核实（本地源码） | **本地源码证实机制**：v1.13.3 `rcS` 里 `param set MAV_SYS_ID $((px4_instance+1))`——多机身份由实例序号自动生成。`sitl_multiple_run.sh` 每实例独立 `instance_N` 目录 + `px4 -i $n` 启动。`gazebo_sitl_multiple_run.sh` 给每实例分配独立端口（TCP 4560+N、UDP 14560+N、mavlink_id 1+N、视频 5600+N）。QGC 经 Heartbeat 识别多机切换（QGC 侧待 DL-1 文档佐证，机制可信）。 |
| A-02 | gazebo_sitl_multiple_run.sh 无 ROS 多机 | docs.px4.io v1.12+论坛 | ✅ 已核实（本地源码） | **v1.13.3 `Tools/gazebo_sitl_multiple_run.sh` 确实存在**（blob 292272e）；main 已删（更名/迁新 Gazebo）。v1.13 可放心引用。 |
| A-03 | v1.13 microRTPS + ROS2 命名空间 | 官方文档+论坛 | ⚠️ 部分错 | **核实结果**：v1.13.3 有 `src/modules/micrortps_bridge/micrortps_client` 模块；但 **fmu-v2 在 v1.13.3 没有 `rtps.px4board` 变体**（仅 default/fixedwing/multicopter/rover），default/multicopter 均未启用 micrortps_client。`rtps.px4board` 只存在于 fmu-v5/v5x/fmuk66/pixracerpro/sitl 等大 flash 板。→ **调研 AI 的"fmu-v2 未启用"结论正确，但说法需精确化：fmu-v2 连 rtps 变体都没有，不是"默认没开"，是"根本没有这个构建选项"。** PPT 表述：v1.13 多机 ROS2 桥接需换受支持板或走伴飞电脑 MAVLink。 |
| A-04 | MAVSDK 多机 systems() 路由 | MAVSDK 官方文档 | ✅ 已核实（本地 `references/MAVSDK` v4.0.0-3） | `docs/en/cpp/guide/connections.md` 完整证实：监听端口 `udpin://0.0.0.0:14540`（off-board API 标准口；QGC 走 14550）→ `subscribe_on_new_system()` 回调发现新机 → `systems()` 返回 `shared_ptr<System>` 向量 → `system->get_system_id()` 按 MAVLink ID 区分。控制脚本对指定 System 实例调插件接口实现单机路由。含 `ForwardingOption` UDP↔serial 双向转发机制。 |
| A-05 | 纯 MAVLink+QGC 能力边界 | 推断 | ⬜ | 推断合理，可直接用 |
| A-06 | Swarm/伴飞电脑引入条件 | Fast-Drone-250 + Companion 手册 | ⬜ 待下载 | DL-3 |

### B. 学术/应用综述
| 编号 | 一句话 | 出处 | 状态 | 备注 |
|---|---|---|---|---|
| B-01 | Fast-Drone-250 全套方案 | github.com/ZJU-FAST-Lab | ✅ 已核实 | 本地 README 证实：NUC 伴飞电脑 + VINS-Fusion 视觉里程计 + Ego-Planner 局部规划 + px4ctrl 高频下发 Offboard 控制量的完整自主无人机方案。**⚠️ 版本前提**：用 `fmu-v5` + PX4 **v1.11.0**（README 明说 v1.13 不适用），非 v1.13/fmu-v2。引用时必须标"基于 v1.11+fmu-v5+NUC 的方案" |
| B-02 | Fast-Planner 规划框架 | github.com/HKUST-Aerial-Robotics | ✅ 已核实 | 本地仓库 README 证实：HKUST+ZJU 合著，kinodynamic+B-spline，是 ego-planner/FUEL/RACER 上游基线。**自带 8 个演示 GIF**（`files/`）。需伴飞电脑/外部算力 |
| B-03 | EGO-Planner/EGO-Swarm | github.com/ZJU-FAST-Lab | ✅ 已核实 | 本地 README 证实：EGO-Planner 无 ESDF 梯度局部规划 ~1ms；EGO-Swarm 去中心化异步多机集群（ICRA2021 论文，bilibili/YouTube 视频）。**自带 5 个集群演示 GIF**（`pictures/`）。需伴飞电脑 |
| B-04 | AprilTag+KF 精准降落 | 学术论文 | ⬜ | 暂不下载，一句话案例 |
| B-05 | mavsdk_drone_show 灯光秀 | github.com/alireza787b | ✅ 已核实 | 本地 README 证实：MAVSDK-Python fleet ops，预设轨迹同步回放+leader-follower，SITL 可演示。注：自述 demo/beta |
| B-06 | Flight Review 官方日志平台 | PX4/flight_review | ✅ 已有 | 本地 `references/flight_review` 已 clone |

### C. 演示素材
| 编号 | 一句话 | 出处 | 状态 | 备注 |
|---|---|---|---|---|
| C-01 | QGC 固件刷写界面 | references/PX4-Autopilot/docs/assets | ✅ 入选-第8页 | =02 中的 A1；副本 `assets/official/` |
| C-02 | QGC Fly View 主界面 | references/PX4-Autopilot/docs/assets | ✅ 入选-第1、3页 | =02 中的 A4；副本 `assets/official/` |
| C-03 | 本机 SITL Gazebo 截图 | presentation/assets/sitl/gazebo_hover.png | ✅ 入选-第2、12页 | 本机实测；第 12 页另加 pyulog 绘制的 ULog 曲线 `assets/sitl/plots/` |
| C-04 | Flight Review 界面 | review.px4.io / 仓库 | ⬜ 待定（第 12 页已用 pyulog 曲线替代） | 可用本机 ULog（`assets/sitl/*.ulg`）上传/本地打开后截图，存 `assets/`；本地 `references/flight_review` |
| C-05 | PlotJuggler 界面 | github.com/PlotJuggler | ⬜ 待定 | 同上，可用本机 ULog 截图，存 `assets/`；本地 `references/PlotJuggler` 已 clone |
| C-06 | Gazebo 多机 SITL 场景 | PX4 Discuss/官方文档 | ⬜ 待定 | 标"官方示例"；本地 `docs/en/sim_gazebo_classic/` 可能含多机图；也可本机跑 `gazebo_sitl_multiple_run.sh` 自截 |
| C-07~09（新增）| **规划/集群演示 GIF** | 本地仓库自带 | ✅ 入选-第16页（Fast-Planner raptor1、ego-planner title + comp.jpg）、第17页（ego-planner-swarm 4 张） | 已复制到 `assets/external/`；其余候选留在 `references/`（见 `assets/README.md`），标"开源项目官方演示" |

### D. v1.13 补充（本地已有，供核查对照）
| 编号 | 一句话 | 出处 | 状态 | 备注 |
|---|---|---|---|---|
| D-01 | v1.13 文档归档、tag 锚点 | 本地 git v1.13.3 | ✅ 已有 | =02 锚点 |
| D-02 | fmu-v2 CONSTRAINED_FLASH | 本地源码 | ✅ 已有 | =02 中的 H1 |
| D-03 | default/multicopter autotune 差异 | 本地源码 | ✅ 已有 | =02 中的 H2 |

## ⚠️ 出处污染（调研 AI 引用了内部文件，PPT 禁用）

调研报告 Works cited 里的以下编号指向**本项目内部文件**，不能作为 PPT 引用来源：
- `9` = `.cs/epics/001/spec.md`
- `10` = `.cs/issues/002`
- `11` = `presentation/02-evidence-and-assets.md`
- `15` = `.cs/issues/004`
- `31` = `.cs/issues/006`

**处理规则**：凡调研条目引用了这些编号，核查时回指到其背后真正的官方/社区来源，或标"内部结论"。
