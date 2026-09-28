# 最终PPT完整内容大纲（v2 · 20页）

## 制作交接说明

**确定题目：《基于 PX4 的 F450 四旋翼平台：前期调研、单机调试路线与多机扩展规划》。**

- 本版（v2）在原 14 页基础上扩为 **20 页**，含封面与来源页。建议总时长约 18 分 20 秒，不含提问。
- 这是内容终稿，不是 PPT 文件；后续只需将"上屏文字"、图示和引用转入模板，讲述提示放入演讲者备注。
- v2 相比 v1 的变化：每页文本加厚、收敛了过度自我设限、新增核心技术专页（P4 PX4 软件栈、P5 MAVLink）、多机部分扩为三页（P13 接入拓扑 / P14 仿真路径 / P15 协同层次）、新增 P16 开源集群方案案例页。
- 本次是前期调研与路线汇报，不是实飞成果汇报。本机 SITL 仿真已在 WSL 跑通起飞-降落闭环（v1.13.3 + Gazebo 11），实机飞行本次不开展。
- 版本事实如实表述：v1.13.x 为实机准备基线、历史源码核验落在 v1.13.3；新版（v1.14+）能力只作对照，不当作本项目可用能力。
- 引用约定：每条来源注明**本地路径**或**云端 URL** 便于溯源。**唯一禁止**：不引用 `.cs/` 内部文件；`02` 的 P/Q/H/M 编号与 `03` 评估文档可用作内部索引并标来源。

---

### 第1页：封面
**建议时长：20s。性质：项目陈述**
**中心结论：本次汇报围绕已有 F450 + PIX 2.4.8 平台，说明前期核查到的约束、单机如何分阶段验收、以及怎么往多机扩。**

#### 上屏文字
主标题：
> 基于 PX4 的 F450 四旋翼平台

副标题：
> 前期调研、单机调试路线与多机扩展规划

阶段说明（一行小字）：
> 飞控软件栈 PX4 · 地面站 QGroundControl · 版本基线 v1.13.x（实测 v1.13.3）

#### 图示
封面中央放主/副标题；下方横贯一条自绘主题线索引，四个节点：`F450 / PIX 2.4.8` → `PX4 软件栈` → `单机验证` → `多机扩展`。右侧配 QGC 飞行视图缩略图（`references/PX4-Autopilot/docs/assets/concepts/qgc_fly_view.png`）作工具链直观提示。

#### 图注
`QGroundControl 官方文档界面示例，非本项目实测。` 主题线为汇报结构示意，不表示各阶段均已完成。

#### 引用
`题目与汇报主线为本项目陈述；QGC 示例图：references/PX4-Autopilot/docs/en/getting_started/px4_basic_concepts.md`

#### 讲述提示与衔接
"这次汇报围绕已有的 F450 机架和 PIX 2.4.8 飞控，软件栈用 PX4、地面站是 QGroundControl。我先把平台里几个角色分清楚、讲清软件栈怎么组织，再说单机怎么一步步验收、以及为什么这套东西天然适合往多机扩。"
衔接："先说目前实际推进到了哪一步。"

---

### 第2页：当前进展——资料核查完成，SITL 已跑通闭环
**建议时长：45s。性质：项目陈述 + 本机实测**
**中心结论：本轮把零散资料变成可追溯的路线，并在本机把 PX4 SITL 仿真闭环真实跑通；实机飞行是下一阶段。**

#### 上屏文字
- **已完成·资料核查**：基于本地 PX4 官方文档和 v1.13.3 历史源码，梳理平台角色、软件栈结构和版本边界，形成可追溯的原始证据索引。
- **已完成·路线成形**：单机调试拆成有验收条件的关口，多机扩展拆成"接入—控制—协同"三个层次。
- **已完成·仿真闭环**：本机实测 PX4 **v1.13.3 + Gazebo Classic 11.15.1**，WSL2 Ubuntu-20.04 上跑通 `起飞 → 悬停 → 降落 → 上锁`，留存 ULog 飞行日志、pxh 控制台记录和 Gazebo GUI 截图。
- **下一阶段**：实机侧固件适配、地面调试和首飞条件评估。

#### 图示
自绘三节点进度链：`资料与路线（已完成）` → `SITL 仿真闭环（本机已跑通，贴 gazebo_hover 小图）` → `单机实机 → 多机扩展（下一阶段）`。下方一行 `仿真闭环已通 ≠ 实机已就绪`。

#### 图注
Gazebo 小图：`本机 SITL 实测（PX4 v1.13.3 + Gazebo Classic 11，WSL2）；仿真结果，非实机飞行。`

#### 引用
`[M1b] 本机 SITL 实测：v1.13.3 + Gazebo Classic 11.15.1，WSL2；证据见 03-simulation-assessment.md`

#### 讲述提示与衔接
"这轮把零散资料整理成了能验收的路线，核对了当前文档和旧版源码差异，而且我在本机真把仿真闭环跑通了——起飞到上锁的日志截图都留了。这是软件流程验证，实机接线校准动力是下一阶段的事。"
衔接："把这条路线讲清，先把平台里容易混淆的角色分出来。"

---

### 第3页：平台组成——硬件、飞控软件与地面站的分工
**建议时长：60s。性质：官方概念 + 项目对象**
**中心结论：Pixhawk 类硬件跑 PX4 负责实时稳定控制，QGC 是地面端负责配置监视，两者靠 MAVLink 通信——地面站不是飞控本身。**

#### 上屏文字
- **F450**：四旋翼机架，承载飞控、动力（电调+电机）与外设，是本项目硬件载体。
- **PIX 2.4.8（FMUv2 类）**：飞控硬件，跑 PX4——负责状态估计（IMU/磁力计/气压计/GPS 融合）、姿态与位置控制、执行输出。
- **PX4**：跑在飞控上的开源飞行栈，提供自稳、飞行模式、任务与安全保护。
- **QGC**：地面站，承担固件刷写、参数配置、遥测监视与任务规划——是"地面端操作台"，控制闭环仍在飞控侧。
- **MAVLink**：地面站与飞控之间的轻量通信协议，遥测下行、指令/任务上行都走它；遥控器链路是独立人工控制通道。

#### 图示
主图自绘概念关系图：`QGC` ⇄ `飞控：运行PX4`（边标 `MAVLink：遥测/配置/指令`）；`传感器` → 飞控（`测量`）；`遥控器/接收机` → 飞控（`人工控制输入`）；飞控 → `电调/电机`（`执行输出`）。飞控+传感器+电调圈进 `F450 飞行平台（概念）` 边界，QGC/遥控器在外。辅图 A4 QGC 飞行视图。

#### 图注
关系图：`根据官方 Basic Concepts 整理的概念示意。` QGC 图：`QGroundControl 官方文档界面示例，非本项目实测。`

#### 引用
`[P1] PX4 Basic Concepts：references/PX4-Autopilot/docs/en/getting_started/px4_basic_concepts.md`

#### 讲述提示与衔接
"关键是分工：QGC 能看状态、改参数、画航线，但真正算姿态、驱动电机的是飞控上的 PX4。右边是官方示例界面，不是我们的飞行画面。MAVLink 是连接两头的协议，后面会专门讲。"
衔接："那飞控上这套 PX4 内部怎么组织？看下一页。"

---

### 第4页：PX4 软件栈——模块怎么分工、靠什么连起来
**建议时长：70s。性质：官方概念**
**中心结论：PX4 分"飞行栈+中间件"两层，一堆自包含模块靠 uORB 发布/订阅消息总线异步通信——这套解耦结构正是它好调试、好扩展、适合多机的原因。**

#### 上屏文字
- PX4 顶层分两块：**飞行栈**（估计+控制算法）和**中间件**（传感器驱动、对外通信、消息总线 uORB），所有机型共用一套代码。
- **uORB**：模块间发布/订阅消息总线，异步、线程安全；消息用 `msg/*.msg` 定义（`vehicle_attitude`、`vehicle_local_position`、`sensor_accel`），编译期自动生成代码。
- **飞行栈流水线**：`sensors`（采集驱动数据发布）→ `ekf2`（EKF 姿态/位置估计）→ `mc_pos_control`/`mc_att_control`/`mc_rate_control`（位置→姿态→角速度三级级联）→ `control_allocator`/mixer（混控到电机）。
- **模式与安全**：`commander`（模式切换+失效保护状态机）、`flight_mode_manager`（各模式设定值）、`navigator`（任务/起飞/返航）、`land_detector`（落地检测）。
- **对外的脚**：`mavlink` 模块把 uORB 消息翻成外部协议、把外部指令翻回 uORB——是 PX4 连 QGC/伴飞电脑/仿真器的桥。
- **为什么重要**：每个模块独立，可用 `pxh>` 的 `top`/`uorb top`/`listener` 实时看——调试单机靠它定位；对外接口统一走 uORB↔MAVLink，是接 MAVSDK 多机、接 Gazebo 仿真的同一扇门。

#### 图示
自绘简化软件栈图（两层）：上层中间件 `传感器驱动 → uORB 总线 → mavlink → QGC/伴飞/仿真器`；下层飞行栈 `ekf2 → mc_pos_control → mc_att_control → mc_rate_control → mixer/输出`，各控制器从总线取估计状态；侧挂 `commander/navigator/logger`。辅图官方 `references/PX4-Autopilot/docs/assets/diagrams/PX4_High-Level_Flight-Stack.svg` 缩小对照。

#### 图注
自绘图：`根据 PX4 Architectural Overview 整理的简化示意，省略部分连接细节。` 官方图：`PX4 官方高层飞行栈示意图（官方示例）。`

#### 引用
`[P] references/PX4-Autopilot/docs/en/concept/architecture.md；middleware/uorb.md；modules/modules_controller.md、modules_system.md；v1.13.3:boards/px4/fmu-v2/default.px4board`

#### 讲述提示与衔接
"PX4 不是一整块硬编码，是模块拼的：驱动发数据上 uORB 总线，ekf2 做估计，位置—姿态—角速度三级级联，最后混控到电机。mavlink 是 PX4 的一只脚，把内部消息翻成外部协议。这套解耦一是调试能逐个看，二是对外接口走同一扇门。"
衔接："那只对外的脚用什么协议、怎么认出多架机？下一页讲 MAVLink。"

---

### 第5页：MAVLink——飞控和外部世界之间的轻量协议
**建议时长：70s。性质：官方概念 + 历史源码核验**
**中心结论：MAVLink 是为低带宽不可靠链路设计的轻量消息协议，靠"消息+微服务"覆盖遥测/指令/任务/参数——PX4/QGC/MAVSDK/仿真器靠它互通，sysid 字段还是多机认机的天然钩子。**

#### 上屏文字
- **是什么**：为无人机生态设计的轻量协议，针对低带宽、可丢包数传链路。裸消息很轻——只带名字、ID、字段，不保证重传，适合高频遥测（`ATTITUDE`、`LOCAL_POSITION_NED`）。
- **微服务**：裸消息上叠的"元协议"，处理一条消息装不下的交互。命令协议用 `COMMAND_INT`/`COMMAND_LONG` 发指令（如 `MAV_CMD_NAV_TAKEOFF`）、等 `COMMAND_ACK` 并可重传；另有参数、任务、FTP 等微服务——QGC 的"改参/画航线/传文件"底层都是这些。
- **生态粘合**：PX4 默认构建 `common.xml` 消息集，QGC、MAVSDK、MAVLink 外设、仿真器都讲这套语言。
- **在 PX4 里**：`src/modules/mavlink` 是 uORB↔外部翻译层；可按链路选 profile（`normal` 给 GCS、`onboard` 给伴飞、`config` 高速 USB、`minimal`/`iridium` 给窄带）。
- **多机钩子**：每个包带 `sysid`（`MAV_SYS_ID` 参数），QGC 靠心跳按 sysid 认机、MAVSDK 靠 `get_system_id()` 路由——同一信道分清哪架是哪架。
- **对本项目**：单机靠 MAVLink 把遥测/指令接进 QGC；SITL 时 PX4 经 UDP（GCS `14550`、offboard `14540`）连 QGC/MAVSDK；往后多机就是给每架配不同 `MAV_SYS_ID`、同套接口逐个寻址。

#### 图示
自绘"一条 MAVLink 信道多方接入"：中心 `PX4（mavlink模块）` 引出边到 `QGC`（遥测/指令，`14550`）、`MAVSDK/伴飞`（offboard，`14540`）、`仿真器`（`TCP 4560/UDP`）、`MAVLink 外设`。每边标走的微服务（Command/Parameter/Mission/遥测流）。角上加 `sysid → 多机区分` 小框。辅图 QGC MAVLink Inspector `references/qgroundcontrol/docs/assets/analyze/mavlink_inspector/mavlink_inspector.jpg`。

#### 图注
自绘图：`根据 PX4 MAVLink 文档与 v1.13.3 SITL 端口脚本整理；端口为 SITL 默认约定。` QGC Inspector：`QGroundControl 官方界面示例，非本项目实测。`

#### 引用
`[P] references/PX4-Autopilot/docs/en/mavlink/index.md；mavlink/protocols.md；mavlink/mavlink_profiles.md；v1.13.3:ROMFS/px4fmu_common/init.d-posix/px4-rc.mavlink；v1.13.3:ROMFS/.../rcS（MAV_SYS_ID=px4_instance+1）；references/qgroundcontrol/docs/en/qgc-user-guide/analyze_view/mavlink_inspector.md`

#### 讲述提示与衔接
"MAVLink 是给又慢又会丢包的链路设计的：裸消息轻、不保证到达，适合刷屏遥测；要确认的事交给微服务——发起飞命令会等 ACK。PX4、QGC、MAVSDK、Gazebo 都讲这门语言。最关键的伏笔是 sysid——同一信道靠它认机，这是多机的地基。"
衔接："平台和软件栈讲清了，接下来看版本——为什么这块老板子让我们把基线钉在 v1.13。"

---

### 第6页：版本基线——选 v1.13.x 是在旧硬件上收敛兼容性风险
**建议时长：60s。性质：项目陈述 + 历史源码核验**
**中心结论：PIX 2.4.8 是 FMUv2 类停产平台，选 v1.13.x 作基线让硬件约束先暴露，而不是赌新版本向后兼容。**

#### 上屏文字
- 官方已把 3DR Pixhawk 1 列入 discontinued（FMUv2），注明"可能仍能在新版本工作，但不是保证"——沿用老平台要自己承担版本验证。
- FMUv2 受 STM32F427 硅片 errata 约束，官方将 FMUv2 固件限制在 1MB Flash；构建目标 `CONFIG_BOARD_CONSTRAINED_FLASH=y`、`CONSTRAINED_MEMORY=y`。
- v1.13.3 源码 `boards/px4/fmu-v2/` 下有 `default`/`multicopter`/`fixedwing`/`rover` 四个构建变体——同板型同版本，功能集合并不相同。
- 我们的取舍：v1.13.x 是 FMUv2 文档可查、SITL 已实测跑通（v1.13.3）的版本，作为实机准备基线；v1.11/v1.14+ 未逐一核验。
- 版本核验手段：`git show v1.13.3:<path>` 直接读历史构建配置，不凭版本号猜功能。

#### 图示
自绘"版本决策天平"：左 `FMUv2/PIX 2.4.8（1MB Flash 受限）`；右 `PX4 版本轴 v1.11→v1.13.3→v1.14+`，v1.13.3 高亮。下方两条摘录 `v1.13.3:default.px4board → CONSTRAINED_FLASH=y`、`官方目录：3DR Pixhawk 1 (FMUv2)—discontinued`。底注 `已实测锚点：SITL 闭环跑通于 v1.13.3`。

#### 图注
版本事实核验（历史源码+官方文档）；克隆板与官方 Pixhawk 1 不完全等同。

#### 引用
`references/PX4-Autopilot/docs/en/flight_controller/autopilot_discontinued.md；flight_controller/pixhawk_series.md、silicon_errata.md；v1.13.3:boards/px4/fmu-v2/default.px4board（tag 1c8ab2a0）`

#### 讲述提示与衔接
"FMUv2 是受限平台，1MB Flash 决定功能必须取舍。我们在 v1.13.3 源码确认了 fmu-v2 构建目标真实存在，SITL 也是这版跑通的，所以冻结为基线。"
衔接："基线定了，单机调试按什么顺序验收？"

---

### 第7页：单机调试路线——按官方配置类拆成可验收的四步
**建议时长：55s。性质：官方概念 + 项目计划**
**中心结论：沿用官方"先固件机架、后执行器/传感器/遥控/安全、调参最后"的次序，把单机调试拆成四级验收，每级都有明确通过物。**

#### 上屏文字
- 官方配置文档只强制两点：先装固件选机架；调参必须在其他配置之后。我们按验收依赖重排，不照抄点击顺序。
- **第一步 固件与机架**：刷对版本、选对 airframe——选机架写入机型、电机数与相对位置等初始参数，是后面一切配置的地基。
- **第二步 传感器与遥控**：罗盘/陀螺/加速度计校准+安装方向（`ROTATION_*`）确认；RC 通道映射、端点、反向校准，确认接收机失联上报方式（"保持最后值"无法被检测）。
- **第三步 动力与安全**：PWM/OneShot 电调需校准（必须拆桨，DShot/CAN 不需要）；配置低电量、RC 失联、数据链失联 failsafe 动作。
- **第四步 首飞与复盘**：满足前置后受控首飞，日志回看后进入调参。

#### 图示
自绘四级验收链：`固件+机架→版本/机型参数落盘` → `传感器+遥控→校准完成+通道响应正确` → `电调+安全→拆桨校准+failsafe表` → `首飞+日志→ULog复盘`；节点4 回指节点3 虚线 `异常→回查`。

#### 图注
本项目按官方配置类别组织的验收路线（计划）；粒度按 F450 单旋翼裁剪。

#### 引用
`references/PX4-Autopilot/docs/en/config/index.md；config/radio.md；advanced_config/esc_calibration.md`

#### 讲述提示与衔接
"官方只规定首尾，我们落成四级验收，每级留能复查的东西——参数记录、校准结果、failsafe 表、ULog。前一关不过不往首飞推。"
衔接："第一关最容易被'连上了'骗过的，是固件和机架。"

---

### 第8页：固件与机架——"识别到板子"只是起点
**建议时长：55s。性质：官方概念（官方示例图）**
**中心结论：QGC 自动识别板型并装 stable 固件，但"识别≠版本正确≠机架匹配"，三件事要分别核对。**

#### 上屏文字
- QGC 接上飞控按检测板型给固件选项，默认装**当前 stable**——不是我们要的 v1.13.x；历史/自定义版本走 `Advanced settings → Custom Firmware file`。
- 识别到的不一定是手头这块板：官方示例图里 QGC 把对象识别为 **PX4 FMU V6X**——界面给什么身份要看清。
- 固件装完必须选 airframe：写入机架类型、电机数与相对位置等初始参数；F450 属 Generic 四旋翼 X 构型，应用后需重启生效。
- FMUv2 特别注意：1MB Flash 限制下默认固件裁掉很多模块；若参数缺失，需 `px4_fmuv2_default boardconfig` 自行裁剪重建，或评估 bootloader 升 FMUv3（2MB）。
- 留痕：板卡身份、固件来源（stable/custom）、airframe 选择都进配置记录。

#### 图示
主图（官方示例）：`references/PX4-Autopilot/docs/assets/qgc/setup/firmware/firmware_connected_default_px4.png`，保留完整界面，用标注框圈出 `识别对象：FMU V6X` 与 `固件选项/Advanced settings`。辅图小链条 `识别板型→选固件→刷写→选airframe→参数落盘`。

#### 图注
官方示例（图中识别对象为 FMU V6X，非本项目 PIX 2.4.8 实测；v1.13.3 为该截图时期的 stable 标签）。

#### 引用
`references/PX4-Autopilot/docs/en/config/firmware.md；config/airframe.md；references/qgroundcontrol/docs/en/qgc-user-guide/setup_view/firmware.md；advanced_config/parameters.md`

#### 讲述提示与衔接
"这图特意保留 V6X 身份：说明入口和流程，不是我们的刷机记录。'识别、固件、机架'三件事分开核——尤其 FMUv2 装完可能缺模块，这直接引出下一页关口。"
衔接："固件机架对了之后，上天前还有三道关口。"

---

### 第9页：三关口——感知、控制、保护，一个都不能省
**建议时长：60s。性质：官方概念 + 项目检查设计**
**中心结论：校准完成、人工控制正确、异常有保护是三个独立条件，必须分别验证留证。**

#### 上屏文字
- **关口一 感知**：罗盘/陀螺/加速度计逐项校准；飞控与外置罗盘安装方向（`ROTATION_*`）与实际一致——方向设错比不校准更危险；校准后姿态显示要跟得上真实运动。
- **关口二 控制**：RC 校准覆盖通道映射、端点、反向；模式拨杆映射到目标飞行模式；电调/电机拆桨状态下验证响应（PWM/OneShot 校准行程，DShot/CAN 不需要）。
- **关口三 保护**：低电量分级（`BAT_*_THR` 阈值、`COM_LOW_BAT_ACT`）；RC 失联 `NAV_RCL_ACT`（前提是接收机能上报失联）；数据链失联 `NAV_DLL_ACT`、地理围栏 `GF_*` 按需启用。
- failsafe 触发后默认先 Hold `COM_FAIL_ACT_T` 秒再执行动作，人为接管留窗口——这个"缓冲期"逻辑要先想清楚。
- 每关留证：校准结果、通道监视记录、failsafe 配置表，作为首飞条件评估输入。

#### 图示
自绘三并列关口卡，各含 `检查项→通过证据`：`感知：方向+校准→姿态跟随/传感器绿标`；`控制：通道+模式+输出→杆量响应正确/拆桨电机检查`；`保护：触发+动作+缓冲→failsafe配置表`。三卡汇入 `首飞条件评估`。

#### 图注
检查逻辑示意（按官方文档整理）；failsafe 动作按实际条件配置，非统一"失联即返航"。

#### 引用
`references/qgroundcontrol/docs/en/qgc-user-guide/setup_view/sensors_px4.md；references/PX4-Autopilot/docs/en/config/radio.md；config/safety.md；advanced_config/esc_calibration.md`

#### 讲述提示与衔接
"遥控失联和地面站失联是两条独立链路，接收机若是'保持最后输出'型，PX4 根本检测不到失联——这类坑只能在关口检查里堵住。"
衔接："三关过了、飞机能稳了，才轮到调参；而调参在这块板上有个版本坑。"

---

### 第10页：调参——先能稳，再谈好；autotune 要看构建变体
**建议时长：65s。性质：官方概念 + 历史源码核验**
**中心结论：PX4 多旋翼是级联控制，角速度内环是调参核心；autotune 能自动调内环，但 v1.13.3/FMUv2 的 default 固件不含该模块，必须用 multicopter 变体或自行重建。**

#### 上屏文字
- 控制结构：多旋翼级联——位置/速度外环 → 姿态环（P）→ 角速度环（PID）→ 控制分配；角速度环最内层，没调好所有模式都表现为抖动或漂移。
- 官方推荐先 autotune：飞行中自动辨识并写入角速度/姿态环参数（`MAV_CMD_DO_AUTOTUNE_ENABLE`，约 40s）；前提是飞机已能自稳。
- **版本事实（源码核验）**：v1.13.3 `mc_autotune_attitude_control` 模块默认 `n`；`fmu-v2/default` 未启用、`fmu-v2/multicopter` 显式 `=y`——同 v1.13.3 同板型，刷哪个变体决定有没有 autotune（对照：`fmu-v3/default` 因 2MB Flash 默认含）。
- 手动调参路径：围绕悬停点迭代 `MC_ROLLRATE_*/MC_PITCHRATE_*/MC_YAWRATE_*`（P 增响应、D 阻尼、I 消静差）；开 `SDLOG_PROFILE` 高频日志用 ULog 评跟踪——本地已有 `flight_review`、`PlotJuggler`、`pyulog` 工具链。
- 工作顺序：先排振动/安装/执行器基础问题 → autotune（若固件含）或手动粗调 → 日志复盘 → 精调；调参永远是最后一站。

#### 图示
自绘简化级联条：`位置/速度→姿态→角速度(PID)→控制分配→电机`，下挂 `EKF2/传感器反馈` 总线连回三环，角速度环高亮。侧栏源码摘录：`fmu-v2/default：无 MC_AUTOTUNE` / `fmu-v2/multicopter：=y`。

#### 图注
控制结构按官方框图简化（外环可被模式绕过）；构建差异为 v1.13.3 源码核验结果。

#### 引用
`references/PX4-Autopilot/docs/en/config_mc/pid_tuning_guide_multicopter.md；config/_autotune.md；flight_stack/controller_diagrams.md；v1.13.3:boards/px4/fmu-v2/{default,multicopter}.px4board；v1.13.3:src/modules/mc_autotune_attitude_control/Kconfig；日志工具 references/flight_review、PlotJuggler、pyulog`

#### 讲述提示与衔接
"一句话：autotune 是好东西，但'v1.13 支持'不等于'我刷的固件里有'——fmu-v2 default 就没有，得换 multicopter 变体。路径是先保证能自稳，再让工具或手动把内环收敛。"
衔接："调参逻辑清楚了，接下来怎么在不动真机的情况下先把软件流程跑熟——这就是 SITL。"

---

### 第11页：SITL 概念——用电脑跑飞控软件，先把软件闭环验掉
**建议时长：50s。性质：官方概念**
**中心结论：SITL 让完整 PX4 飞控代码在计算机上运行、与仿真世界闭环交换数据，是实机之前验证软件流程的安全手段。**

#### 上屏文字
- SITL（Software In the Loop）：PX4 飞控代码不编译到飞控板，而作为普通进程跑在计算机上，与软件建模的"机体+传感器+世界"实时交互。
- 数据流：仿真器把模拟 IMU/GPS/磁力计送进 PX4；PX4 的估计、控制、任务逻辑照常运行，再把电机/执行器输出送回仿真器驱动物理模型——两侧 lockstep 同步，可加速/暂停。
- 交互方式和真机一致：QGC、MAVSDK、手柄都通过 MAVLink 连接，默认端口 GCS `UDP 14550`、offboard API `UDP 14540`、Gazebo `TCP 4560`。
- 对本项目的意义：没有实体飞机也能先把"地面站连接→解锁→起飞→降落→上锁→看日志"整条软件链路验收一遍；F450 实机到位前，这是最便宜也最安全的第一道关口。
- 定位：仿真验证软件流程，不覆盖实机接线、校准、动力与机体振动——这些归后续实机验收关口。

#### 图示
自绘 SITL 数据流框图：`QGC/MAVSDK` ⇄ `PX4 SITL（本机进程，同一套飞控代码）` ⇄ `仿真器：Gazebo Classic`；仿真器→PX4 标 `模拟传感器（HIL_SENSOR/HIL_GPS）`，PX4→仿真器 标 `电机/执行器输出（HIL_ACTUATOR_CONTROLS，TCP 4560）`。底部注释 `lockstep 同步；PX4_SIM_SPEED_FACTOR 调速`。

#### 图注
根据官方文档整理的概念数据流；HIL_* 消息名为官方 Simulator MAVLink API 定义的接口消息。

#### 引用
`references/PX4-Autopilot/docs/en/simulation/index.md（SITL/HITL 定义、Simulator MAVLink API、默认端口 14550/14540/4560）`

#### 讲述提示与衔接
"可以理解为：飞控软件一行不改，只是把板子换成电脑进程、飞机换成软件模型。对我们最直接的价值：F450 还没飞，软件整条链路可以先在机器上过一遍。下一页就是我在这台机器上实际跑出来的结果。"

---

### 第12页：本机 SITL 实测——v1.13.3 起飞-降落闭环已在 WSL 跑通
**建议时长：60s。性质：本机实测**
**中心结论：本机实测 PX4 v1.13.3 + Gazebo Classic 11.15.1 在 WSL2 Ubuntu-20.04 完成起飞→悬停→降落→上锁完整闭环，截图与 ULog 日志留存。**

#### 上屏文字
- 实测环境：PX4 v1.13.3（与版本基线一致）+ Gazebo Classic 11.15.1 + iris + empty.world，WSL2 Ubuntu-20.04.6。
- 启动方式：官方 `make px4_sitl gazebo` 拉起 gzserver+gzclient+px4；GUI 走 WSLg 显示到 Windows 桌面，截图/录屏即采即用。
- 闭环过程：`pxh>` 控制台 `commander takeoff`→`commander land`，依次输出 `Takeoff detected`/`Landing detected`/`Disarmed by landing`，对应两段完整 ULog 落盘。
- 踩过的坑：WSL `/mnt` 9P 文件系统慢、git 子模块初始化走代理镜像、飞行中因无遥控器/地面站报 `Failsafe enabled: no RC and no datalink`，按预期置参（`NAV_DLL_ACT=0`）抑制。
- 结论：v1.13.3 的 SITL 工具链在本机可用，且拿到可复现闭环证据——这是后面多机仿真的先决条件。

#### 图示
主图（本机实测截图）：Gazebo GUI 内 iris 悬停于 empty.world（`gazebo_hover.png`）。辅证文字摘录条：`commander takeoff→Takeoff detected→commander land→Landing detected→Disarmed by landing`；标注日志 `flight_loop_12_09_45.ulg`、`flight_loop_12_13_56.ulg`。

#### 图注
本机 SITL 实测（PX4 v1.13.3 + Gazebo Classic 11.15.1，WSL2）；仿真结果，非实机飞行。

#### 引用
`本机实测证据：03-simulation-assessment.md（M1b 节：版本锚点、命令链、闭环过程与踩坑）；references/PX4-Autopilot/docs/en/simulation/index.md（make px4_sitl gazebo 启动方式）`

#### 讲述提示与衔接
"环境补齐后我真把它跑起来了：v1.13.3 在 WSL 原生起 Gazebo，控制台敲 takeoff 起飞、land 降落、自动上锁，ULog 和截图都是这台机器的结果。中间报过一个无 RC 无地面站 failsafe，那是仿真环境预期告警，置参就消了。单机软件闭环有了之后——如果要的是两架、三架呢？下一页讲多机接入的身份和拓扑。"

---

### 第13页：多机接入与 MAVLink 拓扑——身份区分是一切的前提
**建议时长：55s。性质：官方概念 + 历史源码核验**
**中心结论：多机第一层问题是"谁是谁、走哪条链路"：每个 PX4 实例用不同 MAV_SYS_ID 和端口集合区分，QGC/MAVSDK 据此同时接入多机。**

#### 上屏文字
- 接入核心参数 `MAV_SYS_ID`：MAVLink 网络里每个飞行器的身份号。v1.13.3 SITL 启动脚本 `rcS` 写 `param set MAV_SYS_ID $((px4_instance+1))`——每多开一个实例身份自动 +1。
- 端口同样按实例区分：v1.13.3 `px4-rc.mavlink` 中 offboard 口 `14540+px4_instance`、GCS 口按实例递增；实例超 9 个后统一回落 14549 避免端口重叠。Gazebo Classic 侧生成脚本给每模型分配 `mavlink_tcp_port 4560+N`、`mavlink_udp_port 14560+N`。
- 地面站侧：QGC 收到多个系统心跳后提供下拉框切换"当前聚焦"的飞行器——多机接入在地面站层是原生能力。
- 程序侧：MAVSDK 用 `add_any_connection("udpin://0.0.0.0:14540")` 监听后，`subscribe_on_new_system()` 自动发现新系统，`mavsdk.systems()` 遍历所有已连接系统、`get_system_id()` 取各自 MAVLink ID——一个程序即可管多架。
- 对本项目的意义：F450 机队扩展的第一道工程题不是编队算法，而是先把每架机的身份、端口、遥测归属理清；这些在 SITL 里可以零成本先验证。

#### 图示
自绘多机接入拓扑：顶部 `QGC（下拉切换聚焦机）` 与 `MAVSDK 程序（systems() 遍历）`；中部 `MAVLink/UDP` 总线向下分出三支实例 `PX4实例0:ID=1,offboard 14540,sim 4560→iris_0`、`实例1:ID=2,offboard 14541,sim 4561→iris_1`、`实例2:ID=3,offboard 14542,sim 4562→iris_2`。右下注释 `端口号=基准+px4_instance（v1.13.3 px4-rc.mavlink 实算）`。

#### 图注
端口与系统 ID 分配按 PX4 v1.13.3 启动脚本源码整理（历史源码核验）；图为概念拓扑，非已实现多机演示。

#### 引用
`v1.13.3:ROMFS/px4fmu_common/init.d-posix/rcS（MAV_SYS_ID=px4_instance+1）、px4-rc.mavlink；v1.13.3:Tools/gazebo_sitl_multiple_run.sh；references/PX4-Autopilot/docs/en/simulation/index.md；references/MAVSDK/docs/en/cpp/guide/connections.md`

#### 讲述提示与衔接
"多机最朴素的问题是别把指令发错机。PX4 的做法直白：每起一个实例 ID 加一、端口按实例号排开；QGC 收到多心跳就出下拉框；MAVSDK 一个端口监听就能枚举所有系统。这些数字是我在 v1.13.3 启动脚本里逐行看到的。身份端口清楚了，下一个问题是仿真侧怎么一口气生成多架——下一页。"

---

### 第14页：多机仿真路径——官方脚本一键拉起 N 个实例
**建议时长：55s。性质：官方示例 + 历史源码核验**
**中心结论：PX4 官方自带多机 SITL 脚本（有/无 ROS 两条路径），v1.13.3 对应 `Tools/gazebo_sitl_multiple_run.sh`，一条命令即可生成多架不同身份的实例。**

#### 上屏文字
- 官方入口：`Tools/simulation/gazebo-classic/sitl_multiple_run.sh`（v1.13.3 对应 `Tools/gazebo_sitl_multiple_run.sh`），用法 `sitl_multiple_run.sh -m iris -n 3`，支持 `-w` 选世界、`-s "iris:3,plane:2"` 混合机型批量生成。
- 脚本做了什么：先 `gzserver` 起世界，再循环每架机——用 jinja 模板把 `mavlink_tcp_port=4560+N`、`mavlink_udp_port=14560+N`、`mavlink_id=1+N` 烧进各自 SDF，`gz model --spawn-file` 按间隔摆放，同时以 `-i N` 启动独立 PX4 进程（独立 `instance_N` 目录、独立 rcS）。
- 无 ROS 即可跑：这条路径只需 Gazebo Classic + SITL 构建（Linux）；需要 ROS 时另有 `multi_uav_mavros_sitl.launch`（xacro + MAVROS 命名空间 `/uav1/mavros/...`）。
- 身份约定：当前官方多机文档实例从 system id 2 起（跳过 1 兼容 ROS 2 命名空间），v1.13.3 脚本按 `1+实例号` 分配——起点不同，机制相同。
- 对本项目的意义：多机 SITL 不需自研框架，官方脚本就是可复现入口；已跑通的单机环境（v1.13.3+Gazebo 11）与其同源，扩展成本主要是资源占用与身份规划。

#### 图示
自绘"脚本→多实例"展开图：左 `./Tools/gazebo_sitl_multiple_run.sh -m iris -n 3`；中 脚本动作列表 `gzserver 起世界→jinja 生成 SDF（各自端口/ID）→gz model 逐架 spawn→px4 -i N 逐实例启动`；右 产出 `3×iris@empty.world + instance_0/1/2 独立进程与日志`。底注 `无 ROS 路径：Gazebo Classic+SITL 即可`。

#### 图注
根据 PX4 v1.13.3 `Tools/gazebo_sitl_multiple_run.sh` 源码与官方多机文档整理（历史源码核验+官方示例流程）；尚未在本机运行，不作为本机实测结果。

#### 引用
`v1.13.3:Tools/gazebo_sitl_multiple_run.sh、Tools/sitl_multiple_run.sh；references/PX4-Autopilot/docs/en/sim_gazebo_classic/multi_vehicle_simulation.md；references/PX4-Autopilot/docs/en/simulation/multi-vehicle-simulation.md`

#### 讲述提示与衔接
"PX4 官方给了现成多机路径，不需要 ROS：一个脚本 -m 选模型 -n 选架数，内部每架生成带独立端口的 SDF、摆到世界、再起独立 PX4 进程。我看的是 v1.13.3 那份，端口 ID 公式都在。也就是说我们的 SITL 环境可以直接朝多机扩。但能看到多架机，离'协同'还有好几层——下一页把这个层次拆开。"

---

### 第15页：多机协同层次——接入、控制、协同是三段不同的工作
**建议时长：55s。性质：官方概念 + 项目计划**
**中心结论：多机分三层——接入（身份/链路）、控制（指令归属）、协同（共同目标与算法）；前两层靠 PX4/MAVSDK 现有机制，第三层才需要上层程序与可能的机载算力。**

#### 上屏文字
- **第 1 层·接入**：MAV_SYS_ID + 端口区分每架机（第 13 页机制），QGC 可切换监控、MAVSDK 可枚举全部系统——官方机制已覆盖。
- **第 2 层·控制**：把指令只发给目标机。MAVSDK 用 `mavsdk.systems()` 拿到每个 `System` 后分别调插件下发动作；各机状态/日志按系统 ID 归属，互不串扰。
- **第 3 层·协同**：共同目标、时序配合、避碰与任务分配——这层不在 QGC/PX4 标配里，需要上层协调程序（跑在地面站或伴飞计算机上），如用 MAVSDK-Python/C++ 写 fleet 管理进程。
- **机载算力的时机**：地面端集中协调够用时不加硬件；需要机载实时感知/规划（视觉避障、集群自主决策）时才加伴飞计算机。v1.13 代际的机载-伴飞接口是 microRTPS：源码有 `src/modules/micrortps_bridge`，但 `rtps.px4board` 变体只有 sitl/fmu-v5/fmu-v5x 提供，**fmu-v2 没有**——正好回应 FMUv2 Flash 受限：重协同算力要往外放。
- **本项目收敛**：先在 SITL 内把第 1、2 层验证掉（双机各自识别、各自收指令），再讨论协同算法选型。

#### 图示
自绘三层阶梯：`L1 接入：MAV_SYS_ID+端口→QGC/MAVSDK 同看 N 架（官方机制已覆盖）`；`L2 控制：per-System 指令下发→指令归属正确（MAVSDK systems()）`；`L3 协同：上层协调程序→共同目标/避碰/任务分配（研究空间）`。侧注 `机载协同接口：v1.13=microRTPS；fmu-v2 无 rtps 变体→算力外挂时机后置`。

#### 图注
三层划分为本项目根据官方文档与 v1.13.3 源码核验归纳；microRTPS 事实出自 v1.13.3 源码（Kconfig 与板级变体清单）。

#### 引用
`references/MAVSDK/docs/en/cpp/guide/connections.md；v1.13.3:src/modules/micrortps_bridge/（Kconfig、boards/px4/{sitl,fmu-v5,fmu-v5x}/rtps.px4board 存在、fmu-v2 无）；references/PX4-Autopilot/docs/en/middleware/micrortps.md；references/micrortps_agent/README.md`

#### 讲述提示与衔接
"拆成三层后归属就清楚：接入靠 ID 和端口 PX4 已做好；控制靠 MAVSDK systems() 一套 API 管多架；真正的研究空间在第三层。什么时候加伴飞？v1.13 机载协同接口是 microRTPS，而我们 fmu-v2 连 rtps 构建变体都没有——算力升级放到确实需要机载自主那步再说。下一页看开源世界把第三层做成什么样。"

---

### 第16页：开源集群方案案例——高阶协同的现实做法
**建议时长：70s。性质：研究案例**
**中心结论：成熟开源集群方案普遍用"机载算力+ROS 规划栈+PX4 底层控制"的分层架构，协同信息在飞控之外交换——这正是"加算力、加接口"路线的现实参照。**

#### 上屏文字
- **EGO-Swarm（浙大 FAST Lab，ICRA 2021）**：去中心化四旋翼集群，每架机只用机载资源独立规划，靠广播自己的 B-spline 轨迹互避障；无中心节点、异步运行。代码结构 `plan_manage`（重规划状态机）+`rosmsg_tcp_bridge`（UDP 广播+TCP 转发机间轨迹）+`drone_detect`；`roslaunch ego_planner swarm.launch` 起 9 机编队穿越随机森林。
- **Fast-Drone-250（FAST Lab 整机课程）**：250mm 自主无人机全套开源——NUC 机载电脑跑 VINS-Fusion 定位+EGO-Planner 规划+px4ctrl 控制，飞控刷 PX4 fmu-v5（配套固件基于 v1.11.0，README 注明 v1.13 固件对其项目有 BUG 不建议用），飞控只负责姿态底层。
- **规划基线谱系**：Fast-Planner（HKUST，RA-L 2019/ICRA 2020）确立"kinodynamic 搜索+B-spline 优化"前端-后端范式；EGO-Planner 去掉 ESDF 建图把规划耗时压到约 1ms；EGO-Swarm 再扩展为集群。
- **另一条路线——MDS/mavsdk_drone_show**：不跑 ROS，用 MAVSDK-Python 直接管 PX4 集群，`swarm.json` 声明 leader-follower 跟随链与 NED/body 偏移，offboard 发 `VelocityNedYaw` 设定点，面向灯光秀/编队任务。
- **对本项目的意义**：两条路线对应协同层次两端——先打通 MAVLink 层双机接入（MDS 式），机载算力和 ROS 规划栈（EGO 式）是明确上探方向。

#### 图示
主视觉 GIF 2×2 或 1+2 排布（仓库自带演示动图）：`references/ego-planner-swarm/pictures/title.gif`（多机丛林穿越）、`outdoor.gif`/`indoor1.gif`（真实飞行）、备选 `sim_demo.gif`（Rviz 演示）。图下方自绘"单机智能栈"分层条 `Realsense深度相机→VINS-Fusion定位→EGO-Planner轨迹→px4ctrl→PX4飞控`，标 `机载NUC`（前三层）与 `飞控板`（末层）分界。右侧小字 `MDS：MAVSDK-Python+swarm.json，无ROS，PX4 offboard`。

#### 图注
GIF 均为外部开源项目官方演示动图，非本项目实验：EGO-Swarm（ZJU FAST Lab，ICRA 2021）。分层条按 Fast-Drone-250 仓库结构整理（fmu-v5+PX4 v1.11，与本项目 fmu-v2+v1.13 基线不同，仅作架构参照）。MDS 为 MAVSDK-Python 集群项目（demo/beta）。

#### 引用
`references/ego-planner-swarm/README.md、src/planner/plan_manage/launch/swarm.launch、pictures/*.gif；references/Fast-Drone-250/readme_en.md；references/Fast-Planner/README.md；references/ego-planner/README.md；references/mavsdk_drone_show/README.md、docs/features/smart-swarm.md、swarm.json；论文 EGO-Swarm, ICRA 2021`

#### 讲述提示与衔接
"这页看'真正飞起来的集群'长什么样。左边动图是浙大 FAST Lab 的 EGO-Swarm，每架自己规划、互相广播轨迹避障，不需要中心调度；下面分层条是他们 250 整机课的典型栈——视觉定位、规划、控制都跑在机载 NUC，PX4 只做姿态底层。注意它配套 v1.11 固件，跟我们 v1.13 不是一回事，所以借的是架构不是版本。右边 MDS 走另一条路：不加 ROS，直接 MAVSDK 管多机 offboard，更接近我们近期双机接入目标。这两端框定了我们能做的切入点。"
衔接："案例说明协同是分层的——回到自己平台，下一页落成可切入的研究问题序列。"

---

### 第17页：研究切入点——先可复现，再可定义
**建议时长：50s。性质：项目计划**
**中心结论：把前面准备收敛为三级递进研究问题——可复现单机、可区分双机、可定义协同——每级都有可测量判据。**

#### 上屏文字
- **L1 可复现单机实验**（已基本具备）：v1.13.3 + Gazebo SITL 闭环已跑通，起飞-降落有 ULog 与控制台日志；研究问题落到"给定指令下响应是否符合目标"，日志可用 pyulog/PlotJuggler/flight_review 复盘。
- **L2 可区分双机接入**：官方多机 SITL 脚本 `sitl_multiple_run.sh -m iris -n 2` 起两实例，v1.13.3 `rcS` 以 `MAV_SYS_ID=px4_instance+1` 区分身份；判据是"指令只作用于目标机、遥测/日志可归属"。
- **L3 可定义协同任务**：在 L2 之上定义最小共同任务——参照 MDS leader-follower（`swarm.json`：follow/offset/frame）做集中式跟随，或参照 EGO-Swarm 轨迹广播做去中心化互避障；判据是"队形误差/避让成功率可测"。
- **接口选型随层递进**：L2 阶段 MAVLink/MAVSDK 直连即可；引入机载视觉与局部规划（EGO 式栈）时才需要 ROS 生态，与版本基线匹配后再定（uXRCE-DDS 属 v1.14+，v1.13 对应 microRTPS 桥）。
- **本页定位**：把平台能力转成研究问题的递进设计，每级完成后才解锁下一级；不是论文综述。

#### 图示
自绘三级阶梯：`L1 可复现单机：PX4 SITL+ULog→闭环复现/响应可复盘（已跑通）`；`L2 可区分双机：两实例+ID=2,3→指令隔离/状态归属`；`L3 可定义协同：leader→follower+offset→队形误差可测`。底部横轴 `接入→控制→协同`，右侧虚框 `机载算力/ROS 规划栈（远景：EGO 式）` 指向 L3。

#### 图注
自绘概念阶梯，根据本项目验证路线与 v1.13.3 源码事实整理；L1 标"本机 SITL 实测（仿真结果，非实机）"。L3 两框仅为两种参照路线，不表示已实现。

#### 引用
`references/PX4-Autopilot/docs/en/sim_gazebo_classic/multi_vehicle_simulation.md；v1.13.3:ROMFS/px4fmu_common/init.d-posix/rcS；日志工具 references/pyulog、PlotJuggler、flight_review；协同参照 references/mavsdk_drone_show/swarm.json、references/ego-planner-swarm；references/PX4-Autopilot/docs/en/middleware/micrortps.md、ros2/user_guide.md（uXRCE-DDS 标 v1.14）`

#### 讲述提示与衔接
"这页是整份汇报的'研究翻译'：第一级我们已经踩上去了——SITL 闭环能复现、有日志能复盘。第二级双机，官方脚本和历史 rcS 都告诉我们身份怎么区分，验收判据是指令隔离和状态归属。第三级才谈协同，而且要先定义成可测的量。接口随层走：现在 MAVLink+MAVSDK 够用，上机载视觉规划才轮到 ROS。每级都有明确进入条件和产出证据。"
衔接："三级切入点定下来后，下一阶段只剩把它排成可交付里程碑。"

---

### 第18页：下一阶段——用验收证据推进平台落地
**建议时长：50s。性质：项目计划**
**中心结论：下一阶段交付四个可检查证据包——版本冻结、实机地面检查、双机仿真闭环、协同任务定义——每个里程碑挂具体产物。**

#### 上屏文字
- **M1 版本与配置冻结**：记录实际板卡身份（克隆板丝印/BOOTLOADER 识别）、刷入固件构建目标与变体（fmu-v2 default/multicopter 差异影响 autotune）、机架选择与参数快照；产物=版本配置清单。
- **M2 实机地面检查**（沿用调试路线）：拆桨状态下完成传感器校准、遥控通道/方向核对、电机序号与旋向检查、failsafe 配置核对；产物=地面检查记录+首飞条件评估。
- **M3 双机 SITL 闭环**：`sitl_multiple_run.sh -m iris -n 2` 起双实例，QGC 按 MAV_SYS_ID 区分接入，用 MAVSDK `systems()`/`subscribe_on_new_system()` 枚举双机并分别下发指令；产物=双机遥测截图+指令归属日志。
- **M4 协同任务最小定义**：从 MDS 式 leader-follower（1 架领航+1 架按 offset 跟随）起步，先写死 `swarm.json` 式分配文件，再评估是否上探机载规划；产物=任务定义文档+评测指标。
- **优先级提请组会确认**：M2 与 M3 可并行；若资源受限建议先 M3——零硬件风险、直接验证多机接入层。

#### 图示
自绘里程碑流水线：`M1 版本冻结→版本/配置清单` → `M2 实机地面检查→检查记录+首飞评估` → `M3 双机SITL→接入/指令归属证据` → `M4 协同定义→任务文档+指标`。M3 上方挂已完成标记 `前置：单机 SITL 闭环已完成`。底部注 `M2 与 M3 可并行；不预设日期`。

#### 图注
本项目拟执行推进计划与对应交付物；M2 检查项依据官方配置文档类别整理，非已完成记录。

#### 引用
`references/PX4-Autopilot/docs/en/config/index.md、config/safety.md、advanced_config/esc_calibration.md；sim_gazebo_classic/multi_vehicle_simulation.md；v1.13.3:Tools/sitl_multiple_run.sh、ROMFS/.../rcS；references/MAVSDK/docs/en/cpp/guide/connections.md；references/mavsdk_drone_show/swarm.json、docs/features/smart-swarm.md`

#### 讲述提示与衔接
"下一阶段四个里程碑每个挂交付物。M1 先把'这块板子到底是什么、刷的什么固件'写成清单——克隆板和官方板不能直接画等号。M2 实机地面检查全拆桨做。M3 双机 SITL 用现成脚本就能起，重点验收指令归属。M4 才定义协同任务。我的建议 M3 优先于 M2：仿真双机没硬件风险。这个优先级想在组会上听意见。"
衔接："最后把用到的原始来源集中列一页，方便会后核对。"

---

### 第19页：主要原始来源
**建议时长：15s。性质：引用页**
**中心结论：全部技术结论可回溯到本地官方文档、v1.13.3 历史源码、开源仓库原文与本机实测产物四类一手来源。**

#### 上屏文字
1. **PX4 官方文档**（本地快照 `references/PX4-Autopilot/docs/en/`）：Basic Concepts、架构、Configuration 系列、PID/Autotune、Simulation、Multi-Vehicle、uORB/microRTPS/MAVLink。云端：https://github.com/PX4/PX4-Autopilot/tree/main/docs/en
2. **PX4 v1.13.3 历史源码**（本地 tag `v1.13.3` @ `1c8ab2a0`）：`boards/px4/fmu-v2/{default,multicopter}.px4board`、`mc_autotune_attitude_control/Kconfig`、`Tools/sitl_multiple_run.sh`、`ROMFS/px4fmu_common/init.d-posix/rcS`。
3. **开源项目仓库**（`references/` 本地克隆）：Fast-Drone-250（fmu-v5/v1.11 整机课程）、ego-planner-swarm（EGO-Swarm, ICRA2021）、Fast-Planner、ego-planner、mavsdk_drone_show/MDS、MAVSDK、PlotJuggler、pyulog、flight_review。
4. **QGroundControl 官方文档**（`references/qgroundcontrol/docs/en/qgc-user-guide/`）：Firmware、Sensors 配置。
5. **本机实测产物**：PX4 v1.13.3 + Gazebo Classic 11.15.1 + WSL2 Ubuntu-20.04，iris/empty.world 起飞-降落闭环；留存 ULog 日志、pxh 控制台记录与 GUI 截图（仿真结果，非实机）。

#### 图示
无自绘图。四组来源用四色小标签区分（官方文档/历史源码/开源仓库/本机实测），每条后带本地路径小字，云端 URL 只挂官方库各一条。

#### 图注
官方文档属当前开发快照（检出 `2028113139`）；版本差异页均经 v1.13.3 历史源码单独核验。外部开源项目按其仓库标注的版本前提引用。本页不含 `.cs/` 内部文件引用。

#### 引用
`PX4 文档：https://github.com/PX4/PX4-Autopilot/blob/202811313926f3d719f7477bf497b199918a8f22/docs/en/；PX4 v1.13.3：https://github.com/PX4/PX4-Autopilot/tree/1c8ab2a0d7db2d14a6f320ebd8766b5ffaea28fa；QGC 文档：https://github.com/mavlink/qgroundcontrol/tree/dab963d852e6139288cec0f49b45fa4bfc44c2c1/docs/en/qgc-user-guide`

#### 讲述提示与衔接
"这页是来源索引：文档和历史源码都在本地仓库留了快照，外部项目 GIF 和结论对应各自 README 标注的版本，本机 SITL 日志截图单独归类并标'仿真非实机'。会后任何一条都能按路径回溯。以上是本次汇报，请各位老师同学指正。"

---

## 非页面附录：制作硬约束（v2）

1. 总页数 **20 页**，弹性缓冲至 25；建议总时长约 **18 分 20 秒**（各页时长见页首）。
2. **引用规则**：每条来源给本地路径或云端 URL；**绝不引用 `.cs/` 文件**。`02` 的 P/Q/H/M 编号与 `03` 评估文档可作内部索引。
3. **身份标注只留三类**：官方/外部素材标"官方示例/项目名+版本前提"；本机仿真标"本机 SITL 实测，非实机"；版本事实（v1.13 vs v1.14+、fmu-v2 受限）如实讲。**不再堆**"不能写/未验证/不代表"式警示。
4. **图片/GIF**：P3/P5/P8 用官方文档图（标官方示例）；P12 用本机 SITL 截图（标本机实测）；P16 用仓库自带 GIF（标项目名+版本前提）。其余自绘图节点/边/文字按各页图示规格画。
5. **Fast-Drone-250 版本前提**：它用 fmu-v5+PX4 v1.11（README 明 v1.13 不适用），引用时标"借架构不借版本"，不表述为 v1.13 可用方案。
6. **fmu-v2 microRTPS 表述**：写"fmu-v2 在 v1.13.3 无 rtps 构建变体"（没有此选项），不写"默认未启用"。
7. **多机 ID 起点**：当前官方文档实例从 ID 2 起、v1.13.3 脚本从 1 起——P14 已如实表述，不合并成单一口径。
8. **讲述提示**放备注，不与上屏文字混排；来源映射放备注，不铺满页面。
9. 自绘图是概念关系/拟验证流程，不含未经实测的电气接线、参数值、端口（除已核实的 SITL 默认端口）与性能数字。
10. 模板、字体、排版风格由后续制作阶段决定；不加目录/致谢页。

## 非页面附录：常见追问与回答边界

- **仿真跑通了吗**：跑通了。v1.13.3+Gazebo Classic 11 在 WSL2 实测起飞-降落-上锁闭环，日志截图是本机结果（P12）。这是软件流程仿真，不等于实机就绪。
- **为什么用 v1.13.x**：为已有 FMUv2 平台保留的准备基线，历史源码确认构建目标存在、SITL 实测跑通；不是官方最优/最稳宣称。
- **能不能自动调参**：v1.13.3 的 fmu-v2 default 与 multicopter 变体配置不同——default 无 autotune、multicopter 有。取决于最终固件变体，且执行要先满足自稳前提。
- **多机要不要 ROS 2**：分层次。接入/控制（L1/L2）用 MAVLink+MAVSDK 即可，不需 ROS；协同/机载规划（L3/EGO 式栈）才需要 ROS 生态，v1.13 对应 microRTPS 而非 uXRCE-DDS（v1.14+）。
- **fmu-v2 能做协同吗**：飞控侧协同接口（microRTPS）在 fmu-v2 没有构建变体；路径是 fmu-v2 管姿态底层 + 伴飞电脑/地面站跑协同，或换受支持板。
- **本轮成果**：可追溯证据索引 + 本机 SITL 实测闭环 + 单机到多机的有验收条件路线 + 开源集群案例参照。实机飞行不是本轮成果。
