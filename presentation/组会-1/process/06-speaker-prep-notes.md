# 组会演讲备考笔记（事实核验版）

> 写给自己看的讲前冲刺材料。每条都标了在 `references/` 里的原始出处和行号，被追问时能直接指回去。
> 与 `04-final-slide-outline.md` 的区别：那份是"上屏稿"，这份是"脑子里的底稿 + 追问应对"。

---

## 一、整场一句话主线（怕忘就背这个）

> 手上的 F450 + PIX 2.4.8（FMUv2 类）平台，我把 PX4 软件栈和 MAVLink 搞清楚后，把单机调试拆成四级可验收关口，并已在 WSL 里把 v1.13.3 + Gazebo 11 的 SITL 起飞-悬停-降落闭环真跑通了；多机则按"接入→控制→协同"三层规划，下一步建议先跑双机仿真。

被问"你这轮到底干了啥"，标准答案三句话：
1. 把零散资料变成可追溯的证据索引（官方文档 + v1.13.3 历史源码核验）；
2. 本机实测 SITL 闭环（日志、截图、ULog 曲线都有）；
3. 把单机到多机拆成有验收判据的路线 + 收了 19 个开源仓库作参照。

---

## 二、最容易被追问的 8 个点（都核验过原文）

### 1. "你说多机 ID 自动加一，依据呢？"
`v1.13.3:ROMFS/px4fmu_common/init.d-posix/rcS` 第 106 行：
```
param set MAV_SYS_ID $((px4_instance+1))
```
实例 0 → ID 1，实例 1 → ID 2。**注意和新版区别**：当前官方文档实例从 ID 2 起（跳 1 给 ROS 2 命名空间），v1.13.3 从 ID 1 起。PPT 已如实写"起点不同机制相同"，别合并口径。

### 2. "端口怎么分配的？"
`v1.13.3:.../px4-rc.mavlink`（实测逐行看过）：
| 用途 | local（PX4 侧） | remote（对侧） |
|---|---|---|
| offboard/API | `14580+N` | `14540+N`（>9 实例回落 14549） |
| onboard payload | `14280+N` | `14030+N` |
| gimbal | `13030+N` | `13280+N` |
| GCS | `18570+N` | （QGC 默认听 14550） |
Gazebo 侧（`gazebo_sitl_multiple_run.sh:38`）：`mavlink_tcp_port=4560+N`、`mavlink_udp_port=14560+N`、`mavlink_id=1+N`。

### 3. "autotune 到底能不能用？"
源码三层核验（这是全场最容易露馅的点）：
- `src/modules/mc_autotune_attitude_control/Kconfig`：`default n`（模块默认不编）
- `boards/px4/fmu-v2/default.px4board`：没开它
- `boards/px4/fmu-v2/multicopter.px4board`：`CONFIG_MODULES_MC_AUTOTUNE_ATTITUDE_CONTROL=y`
- 对照 `boards/px4/fmu-v3/default.px4board`：也 `=y`（因为 2MB Flash 不慌）
→ **结论**：同 v1.13.3 同板型，刷哪个变体决定有没有 autotune。稳妥说法"取决于最终刷的固件变体"。

### 4. "fmu-v2 为什么不能跑协同算法？"
v1.13.3 的机载-伴飞接口是 **microRTPS**（`src/modules/micrortps_bridge/` 存在），但 `rtps.px4board` 构建变体只有 9 个（sitl、fmu-v5、v5x、fmuk66-e/v3、fc-v1、ctrl-zero-h7(-oem)、pixracerpro），**fmu-v2 没有**。→ "fmu-v2 没有 rtps 构建变体"（别说"默认没启用"，是压根没这个选项）。

### 5. "v1.14 的 ROS 2 接口变了？"
`docs/en/ros2/user_guide.md:23` 明确标 `<Badge text="PX4 v1.14"/>`：uXRCE-DDS 是 v1.14+ 的接口；v1.13 对应 microRTPS 桥。讲清楚这两代别搞混。

### 6. "你仿真里 failsafe 是演的还是真的？"
真触发。`sitl_console_clean.log` 第 105-118 行：起飞后立刻 `Failsafe enabled: no RC and no datalink` → `RTL HOME activated` → `climb to 489 m` → `Landing detected` → `Disarmed by landing`。
**细节（比大纲更准）**：设了 `NAV_DLL_ACT=0 / NAV_RCL_ACT=0 / COM_RCL_EXCEPT=4 / COM_LOW_BAT_ACT=0` 后，第二次起飞日志里 failsafe **仍触发了一次**（空中检测到就直接就地降落，没再 RTL）。讲的时候可以说"保护逻辑默认是开的，我在仿真里亲眼见它触发了两次"。

### 7. "PX4 内部分层？"
`docs/en/concept/architecture.md`：两层——**flight stack**（估计+控制）和 **middleware**（驱动、对外通信、uORB 总线）。模块经 uORB 发布/订阅，异步、线程安全。估算器拿传感器输入算状态，控制器拿设定值+估计状态出执行量，mixer 把力指令翻成各电机指令。

### 8. "角速度环为什么最该调？"
`docs/en/config_mc/pid_tuning_guide_multicopter.md:35-39`：rate controller 是**最内环**，三个独立 PID 管 roll/pitch/yaw；"well-tuned rate controller affects **all** flight modes"，没调好在 Position mode 都表现为 twitches/oscillations。
**注意**：PPT 里的 "50/250/1000 Hz" **不是 PX4 文档原文**——官方只说 IMU 采样 1kHz、积分后 250Hz 发布（`architecture.md` "Update Rates"）。被问就说"这是多旋翼级联控制的典型量级，PX4 文档强调的是角速度环最内层、影响全部模式，具体频率随版本/硬件变"。

---

## 三、几个容易说错的措辞（已纠正）

| 别这么说 | 改成 |
|---|---|
| "fmu-v2 默认没启用 microRTPS" | "fmu-v2 在 v1.13.3 **没有 rtps 构建变体**" |
| "QGC 识别到板子=连上了" | "识别≠版本对≠机架匹配，三件事分开核"（P8 官方图里识别的是 FMU V6X，不是咱的板） |
| "autotune v1.13 都支持" | "v1.13 的 fmu-v2 default 没有，multicopter 变体才有" |
| "失联一定返航" | "失联动作可配（Hold/Return/Land/Disarm…），触发后默认先 Hold `COM_FAIL_ACT_T` 秒再执行"（safety.md:19） |
| "仿真=实机" | 所有 SITL 结论都标"本机 SITL 实测，非实机" |
| "EGO-Planner 耗时对比是 README 写的" | 精确数字在 `comp.jpg` 对比图和论文里，README 只说 "around 1ms" |

---

## 四、开源案例的版本前提（被问"你也能跑吗"时兜底）

- **Fast-Drone-250**：fmu-v5 + PX4 **v1.11.0**。README 原话 "Firmware v1.13 is not suitable"；中文 README 更直白"实测 1.13 存在 BUG…VINS 会经常崩溃"。→ 我们**借架构不借版本**：飞控管底层、重计算放伴飞的分工思路。
- **EGO-Swarm**：每架机载规划、轨迹广播互避障（去中心化）。README：i7-9700KF 上带动力学仿真约 **15 架上限**，默认用 fake_drone。→ 需要机载算力 + ROS，是上探方向。
- **MDS (mavsdk_drone_show)**：地面用 MAVSDK-Python 集中调度，`swarm.json` 写 leader-follower+偏移，offboard 发 `VelocityNedYaw`。→ 不需要 ROS，FMUv2 + SITL 现在就能起步；项目自述 demo/beta。

---

## 五、SITL 实测的硬数字（背这几个就够）

- 环境：PX4 **v1.13.3** + Gazebo Classic **11.15.1** + iris + empty.world，WSL2 Ubuntu-20.04.6，Gazebo 经 WSLg 显示
- 起飞：`commander takeoff` → 爬到默认 2.5 m；`commander land` → `Landing detected` → `Disarmed by landing`
- `flight_loop_12_13_56.ulg`：离地约 7 s 到 2.5 m；悬停约 30 s，高度均值 **2.51 m**、标准差 **0.03 m**；横滚/俯仰 ±2.5° 内；AUTO_LAND 后约 5 s 触地、2 s 上锁
- `12_09_45`：200 s 长悬停，高度标准差也是 0.03 m
- 曲线用 `references/pyulog` 解析 + matplotlib 画的

---

## 六、被问"接下来呢"时的里程碑答案

- M1 版本冻结 → 版本/配置清单（克隆板丝印/BOOTLOADER、固件变体、参数快照）
- M2 实机地面检查 → 检查记录+首飞评估（全拆桨做）
- M3 双机 SITL → 接入/指令归属证据（`sitl_multiple_run.sh -m iris -n 2`）
- M4 协同最小定义 → 任务文档+评测指标（先 MDS 式 leader-follower）
- **建议先 M3**：零硬件风险、直接验证多机接入层——这条是要请组会拍板的点。

---

## 七、溯源快查（被问"这条哪来的"直接翻）

| 结论 | 一手出处 |
|---|---|
| MAV_SYS_ID=实例+1 | `v1.13.3:ROMFS/.../rcS:106` |
| offboard 14540+实例 | `v1.13.3:.../px4-rc.mavlink:5` |
| 多机 SDF/端口/ID | `v1.13.3:Tools/gazebo_sitl_multiple_run.sh:38` |
| autotune 变体差异 | `v1.13.3:boards/px4/fmu-v2/{default,multicopter}.px4board` + `Kconfig` |
| fmu-v2 无 rtps | `git ls-tree v1.13.3 boards/ \| grep rtps`（9 个，无 fmu-v2） |
| 软件栈两层+uORB | `docs/en/concept/architecture.md`、`middleware/uorb.md` |
| MAVLink 消息+微服务 | `docs/en/mavlink/index.md` |
| SITL 端口 14550/14540/4560 | `docs/en/simulation/index.md` 端口节 |
| failsafe 先 Hold | `docs/en/config/safety.md:19`（`COM_FAIL_ACT_T`） |
| rate 环最内 | `docs/en/config_mc/pid_tuning_guide_multicopter.md:35` |
| Fast-Drone-250 v1.11 | `references/Fast-Drone-250/readme_en.md:24` |
| EGO-Swarm 15 架 | `references/ego-planner-swarm/README.md:145` |
| MDS swarm.json 字段 | `references/mavsdk_drone_show/swarm.json` |
| 1MB Flash/errata | `docs/en/flight_controller/silicon_errata.md` |
| 3DR Pixhawk 1 停产 | `docs/en/flight_controller/autopilot_discontinued.md:29` |

---

# 附：四个硬核技术页的深讲底稿（被追问时的弹药）

## P4 PX4 软件栈——可能被追问的展开

**uORB 到底怎么工作**（`docs/en/middleware/uorb.md` + `concept/architecture.md`）：
- 是异步 `publish()/subscribe()` 消息 API，用于线程间/进程间通信，PX4 启动早期就 `uorb start`
- 消息在 `msg/*.msg` 定义（CamelCase 文件名 → snake_case 主题名），编译期自动生成 C/C++ 代码
- 每个 `.msg` 必须含 `uint64_t timestamp` 字段——这是 logger 能记录话题的前提
- 本质是**共享内存**上的 pub/sub："system is reactive — asynchronous, updates instantly when new data available"，线程安全
- 一个 .msg 可定义多个同构 topic（multi-topic messages）

**运行时可观测**（架构文档 tip）：
- `top`（NuttX）看模块跑没跑；`pxh>` 的 `uorb top` 看各话题更新率、`listener <topic>` 实时看某条消息内容
- 每个模块可单独 `<name> start/stop`——这是"模块可热替换"的具体体现

**流水线为什么是这样**（controller_diagrams + architecture）：
- estimator：一个/多个传感器输入 → 融合算状态（ekf2 是 EKF，融 IMU/磁力计/气压计/GPS）
- controller：设定值 + 估计状态 → 出修正量（位置环出姿态+推力设定，姿态环出角速度设定，角速度环出力矩）
- mixer/control_allocator：力/力矩指令 → 各电机指令，且保证不超限
- **级联的本质**：外环的输出是内环的设定值。位置环说"要到那去"→ 需要这个姿态 → 姿态环说"要达到这个姿态"→ 需要这个角速度 → 角速度环 PID 出力矩 → mixer 分到电机

**IMU 数据流**（controller_diagrams.md IMU pipeline，被问"gyro 数据怎么进控制器"时用）：
gyro 原始 → 应用校准参数 → 去估计零偏 → 陷波滤波(`IMU_GYRO_NF0_*`) → 低通(`IMU_GYRO_CUTOFF`) → `vehicle_angular_velocity`（P/I 用的滤波角速度）→ 求导+低通(`IMU_DGYRO_CUTOFF`) → `vehicle_angular_acceleration`（D 用的）

**模块更新率**（architecture.md "Update Rates"）：IMU 驱动 1kHz 采样、积分后 250Hz 发布；navigator 等慢模块不需要这么高。**这就是"频率"的可靠出处**——别背 PPT 的 50/250/1kHz 当官方数字。

## P5 MAVLink——可能被追问的展开

**消息 vs 微服务**（`docs/en/mavlink/index.md`）：
- 裸消息 = 名字+ID+字段，刻意轻量、限定大小、**无重传/无确认语义**——适合高频遥测刷屏（ATTITUDE、LOCAL_POSITION_NED）
- 微服务 = 裸消息上叠的元协议，处理一条消息装不下的交互。命令协议把指令打包进 `COMMAND_INT`/`COMMAND_LONG`，等 `COMMAND_ACK`，没 ACK 自动重传几次
- 其他微服务：参数、任务（Mission）、FTP、相机——QGC 的"改参/画航线/传文件"底层全是这些

**XML 定义**（重要生态点）：
- 消息/命令/枚举在 XML 里定义，工具链生成各语言库
- 层级：`minimal.xml` ⊂ `standard.xml` ⊂ `common.xml` ⊂ `development.xml`（高层 include 低层）
- PX4 默认构建 `common.xml` 求最大兼容；通信两端必须用同一 XML 定义生成的库（靠 msg id + `CRC_EXTRA` 校验，不匹配就丢包）

**profile/mode**（`mavlink_profiles.md`）：
- profile = 某条 MAVLink 信道**默认**流哪些消息、各什么速率
- `Normal`(GCS) / `Onboard`(伴飞) / `Config`(高速 USB) / `Minimal` / `Iridium`(卫星) / `ExtVision`/`ExtVisionMin` / `DistanceSensor` / `Magic`(全空，动态配)
- 每个链路实例的 profile 用 `MAV_X_MODE` 参数设；USB 用 `USB_MAV_MODE`
- profile 只是默认，对端还能用 `MAV_CMD_SET_MESSAGE_INTERVAL` 要自己想要的流/速率

**sysid 是多机钩子**（被问"怎么分清机"的核心）：
- 每个 MAVLink 包带 `sysid` 字段（参数 `MAV_SYS_ID`）；还有 `compid` 区分同一系统内的组件
- QGC 收多个心跳 → 下拉框选聚焦机；MAVSDK `subscribe_on_new_system()` 发现新系统、`systems()` 遍历、`get_system_id()` 取 ID
- **签名警告**（index.md warning）：默认 MAVLink 不认证——能发包就能下命令含 flight termination。生产部署要 message signing。组会被问安全性时这点能加分。

## P9 三关口——可能被追问的展开

**RC 失联检测的关键坑**（`config/radio.md` RC Loss Detection，原话）：
- PX4 必须能"检测"到信号丢失才能触发 failsafe；接收机失联时有三种表现：
  1. **无输出** → PX4 自动检测
  2. **输出低油门值** → 可配置 PX4 用 `RC_FAILS_THR` 检测
  3. **保持最后接收信号** → **PX4 无法检测**（看起来像正常输入）
- 所以"保持最后值"型接收机必须改成低油门输出，否则失联=继续按最后一杆飞

**failsafe 缓冲期**（`config/safety.md:19`）：
- 触发后默认先进 Hold `COM_FAIL_ACT_T` 秒再执行动作——是给人为接管留窗口
- Hold 期间掰 RC 杆**不触发接管**（要切模式），这个细节文档专门写了
- 失联动作选项（`NAV_RCL_ACT`）：Disabled/Loiter/Return/Land/Disarm/Terminate/Hold mode
- 特例 `NAV_RCL_ACT=7` "Hold mode (no failsafe)"：丢手动控制时切 Hold 但**不算 failsafe**、无告警——专为一台 GCS 管多机设计（和我们多机主题直接相关！）

**地理围栏/位置估计失效**（safety.md）：
- `GF_*` 地理围栏：动作 None/Warning/Hold/Return/Terminate/Land，建议留边距
- 位置估计太差不只是导航问题——悬停模式位置误差超 `COM_POS_LOW_EPH` 也会触发 failsafe

**校准**（`sensors_px4.md`）：
- 绿标=已校准，红标=飞前必须校，无灯=可用默认值
- 罗盘：要把机架摆到一组指定姿态、各姿态绕指定轴转一圈变绿
- **飞控方向**：默认 `ROTATION_NONE`（飞控+罗盘正立朝机头），装歪了改 `ROTATION_*`——方向设错比不校准更危险（PPT 这句成立）
- 加速度计：按图摆姿态，和罗盘类似；陀螺：静止放平自动校准，动了会重启

## P13-15 多机——可能被追问的展开

**身份/端口公式（全部源码核验）**：
- `MAV_SYS_ID = px4_instance + 1`（rcS:106，实例 0→ID 1）
- offboard remote `14540+N`、local `14580+N`；GCS local `18570+N`；>9 实例 offboard remote 全回落 14549
- Gazebo 侧每模型 `mavlink_tcp_port=4560+N`、`mavlink_udp_port=14560+N`、`mavlink_id=1+N`
- **QGC 听 14550 是"约定"不是死的**：多机时各实例 GCS 口其实是 18570+N local，文档说多机用 `udpout` 到 GCS 或 mavlink-router 分发——这点 PPT 没展开，被深问就说"多机时靠 MAVSDK 的 `udpin://14540+` 分实例，QGC 多机走心跳认 sysid"

**脚本做什么**（`gazebo_sitl_multiple_run.sh:38-42`）：
`gzserver` 起世界 → 每架 `jinja_gen.py` 把端口/ID 烧进 `<model>_N.sdf` → `gz model --spawn-file` 按 `(X, Y=3N, 0.83)` 摆放 → `px4 -i N -w sitl_MODEL_N` 独立进程、独立 `instance_N/` 目录、独立 rcS。上限 255（v1.13.3 脚本报错原话）。

**接入→控制→协同的边界**：
- L1 接入：PX4/QGC/MAVSDK 机制已覆盖（ID+端口+心跳+systems()）
- L2 控制：MAVSDK `systems()` 拿到每个 `System` 对象，分别调插件发指令——"把指令只发给目标机"
- L3 协同：**不在标配里**，要上层程序（地面或伴飞）做共同目标/避碰/任务分配——这才是研究空间

**fmu-v2 为什么算力要外挂**（呼应 P6/P15）：
- 1MB Flash 受限（`silicon_errata.md`：STM32F427VIT6 USB errata，rev<3 硅片只能用 1MB/2MB）
- microRTPS 是 v1.13 代际机载-伴飞接口，但 9 个 rtps 变体里没有 fmu-v2 → 机载跑不了 ROS 桥 → 要么 FMUv2 只当底层飞控+伴飞跑规划（Fast-Drone-250 式），要么换大 Flash 板

## P16-17 开源案例——可能被追问的展开

**单机自主栈分工**（Fast-Drone-250 readme_en）：
- 机载 Intel NUC：VINS-Fusion(视觉惯性定位，RealSense) → EGO-Planner(局部轨迹) → px4ctrl(轨迹→控制量) → 经 MAVLink offboard 高频发飞控
- 飞控(fmu-v5 + PX4 v1.11.0)只管底层姿态
- **版本前提**：README 明说 "Firmware v1.13 is not suitable"；中文 README"实测 1.13 存在 BUG…VINS 会经常崩溃"——借架构不借版本
- extras.txt 里配 `mavlink stream -d /dev/ttyACM0 -s ATTITUDE_QUATERNION -r 200` 等——offboard 高频流的实际配置

**EGO-Planner 为什么能机载跑**（README + comp.jpg）：
- 创新点是 **ESDF-free**——不维护欧氏距离场，直接用障碍物梯度优化轨迹
- README：总规划耗时 "around 1ms"；精确对比在 `comp.jpg`：EWOK 6.43(ESDF)+1.39(规划)、Fast-Planner 4.01+3.29、EGO-Planner 0+0.81 ms
- 上游是 Fast-Planner（港科大，kinodynamic 搜索 + B-spline 优化范式）

**EGO-Swarm 去中心化**（README）：
- 每架只用机载传感器+算力独立规划，把自己 B-spline 轨迹广播给队友互避障；无中心、异步
- 代码：`plan_manage`(重规划状态机) + `rosmsg_tcp_bridge`(UDP 广播+TCP 转发机间轨迹) + `drone_detect`(识队友)
- `roslaunch ego_planner swarm.launch` 起多机穿随机森林
- **仿真规模**：i7-9700KF 带动力学约 15 架上限，默认改用 fake_drone（指令直接转里程计）

**MDS 集中式**（mavsdk_drone_show）：
- 不跑 ROS，MAVSDK-Python 地面管 PX4 机队
- `swarm.json`：`hw_id / follow(跟谁) / offset_xyz / frame(ned|body)` 声明跟随链
- 运行时：leader 遥测 lat/lon/alt（+`LOCAL_POSITION_NED`）→ 转共享 NED → 按 ned 或 leader-body 加偏移 → 给 follower 发 `VelocityNedYaw` offboard 设定点
- 自述 demo/beta；作者有 100 架 SITL 视频

**两条路线的本质区别**（被问"选哪条"）：
- EGO-Swarm：去中心化、机载算力、ROS、轨迹广播 → 未知环境自主穿越，但要机载电脑
- MDS：集中式、地面调度、纯 MAVLink/MAVSDK → 已知任务编队/灯光秀，现在就能起步
- 我们：先 MDS 式接入（零硬件成本）→ 再上探 EGO 式（加伴飞后）

---

# 附：组会模拟问答（导师/同学最可能开的火）

按"刁难程度"排序，每条给一句话答案 + 展开弹药。被问到先给短答稳场，再决定要不要展开。

## 必中题（几乎每个组会都会问）

**Q: 你这轮到底做出来了什么？**
A: 三件事——把零散资料变成可追溯证据索引；本机实测 v1.13.3+Gazebo SITL 起飞-降落闭环（日志截图曲线都在）；单机到多机拆成有验收判据的路线。
> 弹药：悬停高度标准差 0.03m、姿态 ±2.5°；三个 ULog；19 个开源仓库。

**Q: 仿真跑了，那真机呢？**
A: 实机是下一阶段——仿真负责把软件流程验掉（连接→解锁→起飞→降落→看日志），实机的接线/校准/动力/振动在单机调试路线那几道实机关口里验，两条线是分开的。
> 弹药：P7-P9 四级验收；M2 实机地面检查全拆桨做。

**Q: 为什么非要用 v1.13 这么老的版本？**
A: 因为板子是 FMUv2 类、官方停产、1MB Flash 受限——用旧版让硬件约束先暴露，而不是赌新版向后兼容；而且 v1.13 构建目标全、教程多、SITL 就是这版跑通的。
> 弹药：silicon_errata USB errata 1MB；autopilot_discontinued 3DR Pixhawk 1。

**Q: 多机你做到哪一步了？**
A: 规划层——多机拆成"接入→控制→协同"三层；接入靠 MAV_SYS_ID+端口（PX4 官方机制已覆盖）、控制靠 MAVSDK systems()，协同是要自己写上层程序的研究空间。下一步 M3 先跑双机 SITL 验证接入+指令归属。
> 弹药：v1.13.3 脚本一键 -m iris -n 2；rcS 里 MAV_SYS_ID=实例+1。

## 技术追问（听懂的人会往这钻）

**Q: uORB 和 MAVLink 什么区别？**
A: uORB 是 PX4 内部模块间的发布/订阅总线（共享内存、异步），MAVLink 是 PX4 对外（QGC/伴飞/仿真器）的通信协议；mavlink 模块就是两者之间的翻译层。
> 弹药：logger 也订 uORB；sysid 是 MAVLink 包里的字段。

**Q: sysid 怎么让多机不打架？**
A: 每个 MAVLink 包带 sysid 字段；v1.13.3 的启动脚本写 MAV_SYS_ID=px4_instance+1，每多开一个实例 ID 自动加一，端口也按实例号错开；QGC 靠心跳按 sysid 认机、MAVSDK 靠 get_system_id() 路由。

**Q: autotune 能自动调参吗？**
A: 能，但有前提：飞机先能自稳；而且 v1.13.3 里 fmu-v2 default 固件**没编**这个模块，得换 multicopter 变体。所以"版本支持"≠"我刷的固件里有"。
> 弹药：Kconfig default n；multicopter.px4board =y。

**Q: fmu-v2 能跑你那些集群算法吗？**
A: 不能直接跑——机载协同要 ROS 桥（v1.13 是 microRTPS），但 fmu-v2 没 rtps 构建变体、1MB Flash 装不下。所以要么 fmu-v2 只当底层飞控+伴飞电脑跑规划（Fast-Drone-250 式分工），要么换大 Flash 板。
> 弹药：v1.13.3 只有 9 个 rtps 变体无 fmu-v2；Fast-Drone-250 用 fmu-v5。

**Q: EKF 是在干嘛？**
A: 把多个传感器（IMU/磁力计/气压计/GPS）融合成一个"我现在姿态和位置"的估计——ekf2 模块干这个，控制器拿这个估计去追设定值。

## 挖坑题（答错会显得不严谨）

**Q: 仿真结果能代表真机吗？**
A: 不能。仿真只证明软件链路（编译→仿真→控制→日志）可复现；实机的接线、校准、动力、振动是另一套关口，下一阶段才验。PPT 所有仿真图都标了"本机 SITL 实测，非实机"。

**Q: 你引的那些开源项目版本兼容吗？**
A: 不完全兼容，所以分开标：Fast-Drone-250 是 fmu-v5+PX4 v1.11（README 明说 v1.13 不适用），我借的是"机载电脑管规划、飞控管底层"的分工思路，不是抄版本；EGO-Swarm/MDS 是协同层的参照方向。
> 弹药：中文 README "实测 1.13 存在 BUG…VINS 会崩溃"。

**Q: 失联了一定返航吗？**
A: 不一定，失联动作可配（Hold/Return/Land/Disarm/Terminate）；而且触发后默认先 Hold COM_FAIL_ACT_T 秒再执行，给人接管留窗口。最坑的是接收机"保持最后值"型失联 PX4 根本检测不到。

**Q: 你图里位置环 50Hz、姿态 250Hz、角速度 1kHz 哪来的？**
A: 这是多旋翼级联控制的典型量级、说内环频率最高；PX4 官方文档强调的是"角速度环最内、影响所有模式"，具体频率随版本/硬件变——文档明确的是 IMU 驱动 1kHz 采样、积分后 250Hz 发布。
> ⚠️ 这三个数字不是 PX4 文档原文，被问到别硬撑是官方数字。

**Q: 多机仿真官方给的上限多少？**
A: v1.13.3 脚本报错写 255 架；当前官方文档说 254（因为新版实例 ID 从 2 起跳 1）。两个起点不同、机制相同，我 PPT 分开标了。
> ⚠️ 别把 254 当 QGC 能力上限，那是特定 ID 分配下脚本的上限。

## 收尾题

**Q: 下一步先干什么？**
A: 建议先 M3 双机 SITL——零硬件风险、直接验证多机接入层（QGC 按 sysid 认机、MAVSDK 枚举双机分别发指令）；M2 实机地面检查可并行。这个优先级想请组会定。

**Q: 这套东西最后要做到什么程度？**
A: 近期是把"可复现单机→可区分双机→可定义协同"三级走通；远期上探机载自主规划（EGO 式栈），那时才需要加伴飞电脑跑 ROS。
