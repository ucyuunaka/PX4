# PPT v2 页计划（分工蓝图）

> 本文件是 v2 返修的**页计划蓝图**，已按此写成 `04-final-slide-outline.md`（现 20 页）。后续调整页结构时先改这里的页表，再改 `04`。
> 需求来源见 `README.md`「v2 需求」。`04` 每页含【上屏文字 / 图示规格 / 图注 / 引用来源 / 讲述提示】，不设时长。

## 公共约束（所有页共享，撰写时遵守）

- **篇幅**：≤25 页（当前 20 页，余量可拆页或加素材页）。
- **不设时长**：不预估每页或总时长。
- **文本加厚**：每页"上屏文字"从要点式扩为**可读段落 + 结构化条目**，量以"讲得动、看得完"为度；不再苛求每句配否定边界。
- **收敛过度约束**：去掉"显得工作少/不确定多"的冗余自我设限。**保留**的真硬约束只剩三类：①官方图/截图标"官方示例/非本项目实测"；②仿真图标"仿真结果（本机 SITL），非实机"；③版本事实（v1.13 vs 新版、fmu-v2 受限）如实表述。除此之外不堆"不能写/未验证"警示。
- **实质内容**：用本地已获取的开源仓库素材（文本/图/GIF）充实；GIF 用仓库自带演示动图。
- **核心技术专页**：P4（PX4 软件栈）、P5（MAVLink）、P13/14/15（多机）作"重要组成部分"介绍——**不求覆盖全、不求讲透**，讲清"是什么+为什么对本项目重要"即可。
- **引用**：每条素材注明来源 + **本地路径或云端 URL**，便于溯源。**唯一禁止**：引用 `.cs/` 内部文件；`02-evidence-and-assets.md` 的证据编号（P/Q/H/M）可继续用作内部索引并在页脚标来源。

## 可用素材清单（撰写时从这里取）

**官方文档（本地 `references/PX4-Autopilot/docs/en/`）**
- `mavlink/index.md`：MAVLink 概念（消息/微服务/命令协议/XML 定义/签名安全）→ P5
- `concept/architecture.md`、`px4_systems_architecture.md`、`flight_stack/controller_diagrams.md`：软件栈/控制 → P4/P10
- `simulation/index.md`、`sim_gazebo_classic/multi_vehicle_simulation.md`：SITL/多机脚本（`sitl_multiple_run.sh -m iris -n 2`，MAV_SYS_ID 2,3,4…、UDP 14541+）→ P11/14
- `middleware/uorb.md`、`uxrce_dds.md`、`micrortps.md`：uORB/DDS/microRTPS → P4/P15
- `middleware/mavlink.md`→redirect `mavlink/`、`mavlink/mavlink_profiles.md`：MAVLink → P5
- `getting_started/px4_basic_concepts.md`、`flight_controller/autopilot_discontinued.md`、`config/*.md`、`config_mc/pid_tuning_guide_multicopter.md`：P3/6/7/8/9/10

**v1.13.3 历史源码（本地 git tag `v1.13.3`，`git show v1.13.3:<path>`）**
- `boards/px4/fmu-v2/default.px4board`（CONSTRAINED_FLASH=y）、`multicopter.px4board`（autotune=y）、`src/modules/mc_autotune_attitude_control/Kconfig`（默认 n）→ P6/P10
- `Tools/gazebo_sitl_multiple_run.sh`、`Tools/sitl_multiple_run.sh`、`ROMFS/.../rcS`（`MAV_SYS_ID=px4_instance+1`）→ P13/14
- `src/modules/micrortps_bridge/`（microRTPS 模块；fmu-v2 无 rtps.px4board 变体）→ P15

**外部开源仓库（`references/`）**
- `MAVSDK/docs/en/cpp/guide/connections.md`：多机 `systems()`/`get_system_id()`/`subscribe_on_new_system()`/`udpin://14540` → P13/15
- `Fast-Drone-250`：NUC+VINS-Fusion+Ego-Planner+px4ctrl 全套自主机（**fmu-v5+v1.11**，标版本前提）→ P16
- `ego-planner-swarm`：去中心化多机集群（ICRA2021）；GIF `pictures/{title,outdoor,indoor1,indoor2,sim_demo}.gif` → P17
- `Fast-Planner`：kinodynamic+B-spline 规划基线；GIF `files/*.gif`(8) → P16
- `ego-planner`：无 ESDF 梯度局部规划 ~1ms；GIF `pictures/*.gif`(4) → P16
- `mavsdk_drone_show`：MAVSDK-Python fleet ops/灯光秀（demo/beta）→ P17
- `flight_review`、`PlotJuggler`、`pyulog`：日志分析工具 → P10/P12

**本机实测证据（`../assets/sitl/`，引用标注"本机 SITL 实测"）**
- `gazebo_hover.png`、`gazebo_window.png`（Gazebo GUI 截图）
- `flight_loop_*.ulg`、`sitl_console_clean.log`（起飞-降落闭环日志，原始版 `sitl_console.log`）
- 环境：PX4 v1.13.3 + Gazebo Classic 11.15.1 + WSL2 Ubuntu-20.04 + iris + empty.world

**图片资源**：已选用的官方图和 GIF 复制在 `../assets/{official,external}/`（出处见 `../assets/README.md`）；更多候选在 `references/PX4-Autopilot/docs/assets/`（QGC 界面、控制框图、概念图，标"官方示例"）

## 页计划（20 页主体 + 余量）

| 页 | 标题 | 中心结论 | 主要素材 | 分配块 |
|---|---|---|---|---|
| 1 | 封面 | 题目+主线 | 主题线索引 | A |
| 2 | 当前进展 | 资料核查+SITL已跑通闭环 | 实测结论 | A |
| 3 | 平台组成 | 硬件+PX4+QGC 分工 | P1概念+A4图 | A |
| 4 | **PX4 软件栈** | uORB+模块+控制层级 | middleware/uorb、架构图 | A |
| 5 | **MAVLink 通信** | 轻量消息+微服务=生态粘合 | mavlink/index、profiles | A |
| 6 | 版本基线 | v1.13+fmu-v2 的取舍与差异 | P2+H1/H2 | B |
| 7 | 单机调试路线 | 逐级验收 | P3/P8/P9 | B |
| 8 | 固件与机架 | 识别≠配置正确 | P4/P5/Q1+A1图 | B |
| 9 | 三关口 | 感知/控制/保护 | Q2/P6/P7/P8 | B |
| 10 | 调参 | 先排基础再调；autotune变体差异 | P9/P10+H2+工具 | B |
| 11 | SITL 概念 | 验证软件闭环不替代实机 | P11+H3 | C |
| 12 | **本机 SITL 实测** | 跑通起飞-降落闭环 | 截图+ULog+坑位 | C |
| 13 | **多机接入与拓扑** | MAV_SYS_ID+QGC多机+MAVSDK | A01/A04+rcS | C |
| 14 | **多机仿真路径** | 官方多机 SITL 脚本 | A02+多机文档 | C |
| 15 | 多机协同层次 | 接入→控制→协同+何时加算力 | A03/A05/A06 | C |
| 16 | **开源案例（一）单机自主栈** | 机载算力+规划+PX4 底层 | Fast-Drone-250/Fast-Planner/EGO-Planner/GIF | D |
| 17 | **开源案例（二）集群** | 去中心化 vs MAVSDK 编队 | EGO-Swarm/MDS/GIF | D |
| 18 | 研究切入点 | 可重复实验→可定义协同 | 综合 | D |
| 19 | 下一阶段 | 验收证据推动落地 | 综合 | D |
| 20 | 主要原始来源 | 引用页 | 全部来源 | D |
| 21–25 | （余量）附录/备用 | — | 视拆分需要，当前未使用 | — |

## 撰写块分工

- **块 A**（页 1–5）：封面/进展/平台组成 + **PX4 软件栈、MAVLink 两个核心技术专页**
- **块 B**（页 6–10）：版本基线/调试路线/固件机架/三关口/调参
- **块 C**（页 11–15）：SITL 概念/本机实测 + **多机接入、多机仿真、协同层次三页**
- **块 D**（页 16–19）：**开源集群方案案例页** + 研究切入点/下一阶段/来源页

各块产出 = 对应页的【上屏文字+图示规格+图注+引用+讲述提示】Markdown 片段，已合并进 `04` 并统一编号与衔接。
