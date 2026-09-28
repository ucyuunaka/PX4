# PPT 素材库

制作 PPT 时直接从这里取图。每个素材的原始出处都列在下面，引用时写出处而不是本目录路径。页码对应 `../04-final-slide-outline.md`。

## sitl/ —— 本机 SITL 实测（第 2、12 页）

图注统一写：**本机 SITL 实测（PX4 v1.13.3 + Gazebo Classic 11.15.1，WSL2 Ubuntu-20.04）；仿真结果，非实机。**

| 文件 | 内容 |
|---|---|
| `gazebo_hover.png` | Gazebo GUI 全窗口截图（2560×1528），iris 在 empty.world 中悬停；底部状态栏可见仿真时间 |
| `gazebo_window.png` | Gazebo GUI 截图（1707×1019），iris 位于画面右下，适合做小图或裁切 |
| `plots/flight_12_13_56.png` | 第 12 页主图：ULog 曲线（上：估计高度与设定值，标 AUTO_TAKEOFF/AUTO_LAND/上锁；下：横滚/俯仰角），48 s 完整起飞-悬停-降落 |
| `plots/flight_12_09_45.png` | 同上，200 s 长悬停版本（备用） |
| `sitl_console.log` | pxh 控制台原始输出（含终端转义字符） |
| `sitl_console_clean.log` | 同一份日志去掉终端转义后的可读版，可直接摘录上屏：第 96–171 行依次是 `commander status` → 首飞触发 failsafe/RTL → 置参 → 两次 `commander takeoff`/`commander land` 闭环 |
| `flight_loop_12_09_45.ulg` | 置参后第一次闭环的完整 ULog（44 MB） |
| `flight_loop_12_13_56.ulg` | 第二次闭环 ULog（10 MB） |

曲线图用本地 `references/pyulog` 解析 ULog、matplotlib 绘制（2026-09-28）。从 `flight_loop_12_13_56.ulg` 读出的关键数字：离地后约 7 s 爬升到 2.5 m；悬停约 30 s，高度均值 2.51 m、标准差 0.03 m；横滚/俯仰绝对值最大 2.48°/0.56°；切 AUTO_LAND 后约 5 s 触地、再 2 s 上锁。`12_09_45` 悬停约 150 s，高度标准差 0.03 m，横滚/俯仰最大 0.66°/1.68°。

也可以用 Flight Review（`references/flight_review`）或 PlotJuggler（`references/PlotJuggler`）打开 ULog 截图作补充。

## official/ —— 官方文档图片

图注统一写：**PX4 / QGroundControl 官方文档图，非本项目实测。**

| 文件 | 用于 | 原始出处 |
|---|---|---|
| `qgc_fly_view.png` | 第 1、3 页 | `references/PX4-Autopilot/docs/assets/concepts/qgc_fly_view.png` |
| `PX4_High-Level_Flight-Stack.svg` | 第 4 页 | `references/PX4-Autopilot/docs/assets/diagrams/PX4_High-Level_Flight-Stack.svg`（出自 `docs/en/concept/architecture.md`） |
| `mavlink_inspector.jpg` | 第 5 页 | `references/qgroundcontrol/docs/assets/analyze/mavlink_inspector/mavlink_inspector.jpg` |
| `firmware_connected_default_px4.png` | 第 8 页 | `references/PX4-Autopilot/docs/assets/qgc/setup/firmware/firmware_connected_default_px4.png`；图中识别对象为 FMU V6X，非本项目飞控 |
| `QuadRotorX.svg` | 第 8 页 | `references/PX4-Autopilot/docs/assets/airframes/types/QuadRotorX.svg`（出自 `docs/en/airframes/airframe_reference.md`） |
| `mc_control_arch.jpg` | 第 10 页 | `references/PX4-Autopilot/docs/assets/diagrams/mc_control_arch.jpg`（出自 `docs/en/flight_stack/controller_diagrams.md`） |
| `px4_sitl_overview.png` | 第 11 页 | `references/PX4-Autopilot/docs/assets/simulation/px4_sitl_overview.png`（出自 `docs/en/simulation/index.md`） |
| `px4_companion_computer_simple.svg` | 第 15 页 | `references/PX4-Autopilot/docs/assets/diagrams/px4_companion_computer_simple.svg`（出自 `docs/en/companion_computer/index.md`） |

PX4 文档快照 @ `2028113139`，QGC @ `dab963d852`。SVG 可直接拖进 PowerPoint；若模板软件不支持，用浏览器打开后截图。

## external/ —— 外部开源项目演示素材（第 16、17 页）

图注统一写：**项目名 + 官方演示，非本项目实验。**

| 文件 | 用于 | 原始出处 |
|---|---|---|
| `Fast-Planner/raptor1.gif` | 第 16 页 | `references/Fast-Planner/files/raptor1.gif`（HKUST Aerial Robotics）；https://github.com/HKUST-Aerial-Robotics/Fast-Planner |
| `ego-planner/title.gif` | 第 16 页 | `references/ego-planner/pictures/title.gif`（ZJU FAST Lab）；https://github.com/ZJU-FAST-Lab/ego-planner |
| `ego-planner/comp.jpg` | 第 16 页 | `references/ego-planner/pictures/comp.jpg`：飞行画面 + 计算耗时对比柱状图 |
| `ego-planner-swarm/title.gif`、`outdoor.gif`、`indoor1.gif`、`sim_demo.gif` | 第 17 页 | `references/ego-planner-swarm/pictures/`（ZJU FAST Lab，EGO-Swarm，ICRA 2021；本地 @ `92fe9f7`）；https://github.com/ZJU-FAST-Lab/ego-planner-swarm |

`references/` 下还有更多可选动图，需要时再拷进来：

- `references/ego-planner-swarm/pictures/indoor2.gif`
- `references/ego-planner/pictures/{indoor,outdoor,sim_demo}.gif`
- `references/Fast-Planner/files/{raptor2,icra20_1..3,ral19_1..3}.gif`

视频（在线）：EGO-Swarm https://www.bilibili.com/video/BV1Nt4y1e7KD ；EGO-Planner https://www.bilibili.com/video/BV1VC4y1t7F4/ ；Fast-Drone-250 课程 https://www.bilibili.com/video/BV1WZ4y167me ；MDS 100 架 SITL https://www.youtube.com/watch?v=VsNs3kFKEvU
