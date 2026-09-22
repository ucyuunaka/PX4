# 原始证据与选图审查

## 取材与版本声明

本轮仅离线读取本地官方仓库、Git历史及本机环境。未联网搜索、拉取、下载，未观看新增在线视频。管理记录仅帮助理解任务，不是技术证据；最终PPT不引用任何 `.cs/` 文件。

原始版本锚点：

- PX4当前检出：`202811313926f3d719f7477bf497b199918a8f22`，提交日期2026-09-16；describe为 `v1.18.0-beta1-687-g2028113139`。以下P类证据属于该开发快照，不是v1.13手册。
- QGC当前检出：`dab963d852e6139288cec0f49b45fa4bfc44c2c1`，提交日期2026-09-16。仓库版本不等于用户安装程序版本。
- PX4本地历史标签 `v1.13.3` 指向 `1c8ab2a0d7db2d14a6f320ebd8766b5ffaea28fa`。使用只读 `git show` / `git grep` 查看，没有切换检出或联网。
- `git ls-tree v1.13.3 docs` 没有输出：该标签不包含当前集成的docs目录。因此不能把当前文档改写为“v1.13官方文档”。

引用约定：页脚使用证据编号、标题和版本短标记；最终参考页给出官方仓库与提交。下列完整路径用于制作时回溯。网址是离线推导的官方仓库定位，不表示本轮访问过网页。

## P类：当前PX4官方文档

统一根目录：`references/PX4-Autopilot/docs/en/`。

### P1 基本概念

- 文件：`getting_started/px4_basic_concepts.md`。
- 章节：Autopilots / PX4 Flight Stack / Ground Control Stations / Flight Controller。
- 支持：飞控硬件运行飞控软件；QGC承担配置、监视与任务规划；PX4具有伴飞计算机和机器人接口生态。
- 限制：不证明当前克隆板兼容性，不证明QGC已与本项目设备连接；不据此比较PX4与其他栈优劣。

### P2 停产平台

- 文件：`flight_controller/autopilot_discontinued.md`。
- 章节：Autopilots，3DR Pixhawk 1条目。
- 支持：3DR Pixhawk 1被列为FMUv2平台，专属文档最后发布于v1.15；此类平台可能仍能在新版本工作，但不是保证。
- 限制：不等于所有PIX 2.4.8克隆板均有同一硬件规格；目录中有构建目标也不等于编译和飞行实测成功。

### P3 基础配置

- 文件：`config/index.md`。
- 章节：Configuration Steps / Tuning。
- 支持：先加载固件并选择机架，再进行执行器、传感器、人工控制、安全和调参工作；调参应在其他配置之后。
- 限制：最终流程是本项目根据官方配置类别组织的验收路线，不声称文档规定所有步骤只有一种严格顺序。

### P4 固件安装

- 文件：`config/firmware.md`。
- 章节：Install Stable PX4 / Installing PX4 Main, Beta or Custom Firmware。
- 支持：默认安装当前稳定版；高级设置允许选择本地自定义固件；安装后还需机架等配置。
- 限制：图片中的stable标签是截图时期的状态；不能据此认定v1.13.3是当前stable，也不能证明当前QGC可在线取得指定历史版本。

### P5 机架选择

- 文件：`config/airframe.md`。
- 章节：Set the Frame。
- 支持：机架选择应用相应初始配置；应匹配实际机型，没有精确型号时考虑相符的Generic类别。
- 限制：该页示例图片是Hexarotor X，不是F450四旋翼，故不选该图；不指定尚未核对的airframe编号。

### P6 遥控配置

- 文件：`config/radio.md`。
- 章节：Radio Control Setup / RC Loss Detection / Performing the Calibration。
- 支持：需要核对通道映射、端点和方向；接收机如何报告失联影响飞控检测。
- 限制：不把断开地面站与遥控失联混为一谈；不将当前参数值外推到v1.13。

### P7 安全保护

- 文件：`config/safety.md`。
- 章节：QGroundControl Safety Setup / Failsafe Actions。
- 支持：低电量、遥控失联等条件可以触发不同保护动作。
- 限制：动作受版本、配置、可用状态影响；不能概括为“失联一定返航”。截图数值不是本项目推荐参数。

### P8 电调校准

- 文件：`advanced_config/esc_calibration.md`。
- 章节：开头适用范围 / Steps。
- 支持：PWM/OneShot与DShot/CAN的校准需求不同；电调校准必须拆桨。
- 限制：本项目电调协议未在本轮硬件实测，不能写“所有电调均须这样校准”。PPT仅保留按实际协议核对的原则。

### P9 手动调参与控制结构

- 文件：`config_mc/pid_tuning_guide_multicopter.md`。
- 章节：Tuning Steps / Rate Controller / Rate Controller Architecture/Form。
- 支持：角速度控制是内环，控制跟踪可借助日志评估；混合PID图的D项在反馈路径。
- 补充文件：`flight_stack/controller_diagrams.md`，Multicopter Control Architecture。
- 支持：多旋翼使用级联结构；不同模式可能绕过外环。
- 限制：只用结构性概念，不复述当前快照新加入的控制律细节，不编造本项目曲线。

### P10 自动调参的前提

- 文件：`config/_autotune.md`（`config/autotune_mc.md`通过include引用）。
- 章节：警告框 / Pre-tuning Test。
- 支持：自动调参在飞行中进行，飞行器须先能充分自稳且具备中止条件。
- 限制：页面“推荐autotune”不证明指定板型和构建变体含该模块。具体v1.13.3变体见H2。

### P11 SITL

- 文件：`simulation/index.md`。
- 章节：开头定义 / Simulator MAVLink API。
- 支持：SITL是在计算机运行飞控软件，与模型交互；可以通过QGC和接口使用。
- 限制：当前Gazebo与SIH不都走同一种MAVLink仿真接口；最终图使用抽象数据流，不画统一协议。SITL不验证实机接线、校准和动力。

### P12 多机

- 文件：`simulation/multi-vehicle-simulation.md`；`sim_gazebo_classic/multi_vehicle_simulation.md`。
- 章节：多机概述 / Multiple Vehicle with Gazebo Classic。
- 支持：官方存在有ROS及无ROS的多机仿真路径；各实例需要区分身份和通信。
- 限制：文档中的254是特定身份分配条件下的脚本上限，不是QGC能力保证或本机可跑数量，故不上屏。当前实例ID起点不套用v1.13；历史对应见H3。

### P13 ROS 2版本边界

- 文件：`ros2/user_guide.md`。
- 章节：Overview / DDS。
- 支持：uXRCE-DDS段落标记为PX4 v1.14；软件接口与飞控版本需匹配。
- 限制：不把当前ROS 2/Zenoh或DDS方案直接套到v1.13。不上屏具体中间件安装命令。

### P14 执行器界面代际

- 文件：`config/actuators.md`。
- 章节：开头版本标记 / Overview。
- 支持：当前完整Actuator Configuration说明标记PX4 v1.14。
- 限制：不把当前几何编辑/输出配置操作写成v1.13通用教程；PPT只讲必须核对电机顺序、旋向和输出匹配。

## Q类：QGC官方文档

根目录：`references/qgroundcontrol/docs/en/qgc-user-guide/`。

### Q1 固件刷写

- 文件：`setup_view/firmware.md`。
- 支持：默认安装所选飞控栈当前stable；可选择其他开发版本或本地文件；设备连接并不等于安装成功。
- 版本：QGC仓库 `dab963d852` 文档快照。

### Q2 传感器配置

- 文件：`setup_view/sensors_px4.md`。
- 支持：罗盘、陀螺仪、加速度计等校准以及安装方向配置；具体传感器选项依机型而异。
- 限制：文档说明示例来自VTOL，故不将其完整界面包装为F450本机界面。

## H类：PX4 v1.13.3历史源码

### H1 FMUv2目标确实存在

- 原始对象：`v1.13.3:boards/px4/fmu-v2/default.px4board`。
- 只读命令：`git -C references/PX4-Autopilot show v1.13.3:boards/px4/fmu-v2/default.px4board`。
- 文件明确包含Cortex-M4、受限Flash/内存标记、MAVLink及多旋翼控制模块。
- 可讲：本地历史源码为v1.13.3提供FMUv2构建配置。
- 不可讲：已编译成功、已刷入手头克隆板、该版本最稳、默认固件覆盖所有功能。

### H2 自动调参必须区分构建变体

- `v1.13.3:src/modules/mc_autotune_attitude_control/Kconfig`：模块默认 `n`。
- `v1.13.3:boards/px4/fmu-v2/default.px4board`：未启用该模块。
- `v1.13.3:boards/px4/fmu-v2/multicopter.px4board`：明确设置 `CONFIG_MODULES_MC_AUTOTUNE_ATTITUDE_CONTROL=y`。
- `v1.13.3:cmake/kconfig.cmake` 第44至46行：非default变体通过合并default与label配置生成。
- 可讲：同为v1.13.3/FMuv2，default和multicopter变体的自动调参配置不同；不能只凭版本号或板型判断。
- 不可讲：FMUv2一律不支持autotune，或者默认下载固件一定支持；未检查实际刷入二进制。

### H3 历史SITL身份与校准边界

- 原始对象：`v1.13.3:ROMFS/px4fmu_common/init.d-posix/rcS`。
- `MAV_SYS_ID` 由 `px4_instance+1` 设置；还配置仿真传感器ID并注释“不要求RC校准和配置”。
- 可讲：多实例身份需区分；仿真初始化与实物准备不同。
- 不可讲：当前文档与历史脚本拥有同一ID起点，或仿真跑通证明真实校准完成。

## M类：本机直接检查

- M1：WSL、Ubuntu、工具链、容器缓存及子模块检查，完整证据和命令见 `03-simulation-assessment.md`。
- M1为本轮环境检查的复核记录，不是飞行实验或性能测试；第10页来源写“本机环境检查”，不写“PX4官方结论”。

## 图片：已实际读图的四张候选

图片由本地读取请求与会话随后呈现的四张图逐张核验。读取工具的文本包装曾显示“0 bytes”，不能据此认定原文件为空；视觉结论来自实际呈现图像。后续制作应从以下原始路径取图。

### A1 固件选择界面：入选第6页

- 文件：`references/PX4-Autopilot/docs/assets/qgc/setup/firmware/firmware_connected_default_px4.png`。
- 母文档：P4。
- 读图：852x530；对话框为PX4 Pro Stable Release v1.13.3；背景识别对象为PX4 FMU V6X，Board ID 53；左侧是Vehicle Setup分类。
- 用途：解释“固件选择”和“高级设置”的入口，不证明本项目板型兼容。
- 图注必须完整：**官方历史界面示例；图中为FMU V6X，非本项目PIX 2.4.8；v1.13.3为截图时期选项，不代表当前默认版本。**
- 取图：保留全图或保留识别信息及弹窗，不裁掉V6X身份后暗示这是本项目连接记录。
- 不得写“已成功刷机”；该图只是选择界面。

### A2 安全配置界面：弃用

- 文件：`references/PX4-Autopilot/docs/assets/qgc/setup/safety/safety_setup.png`。
- 母文档：P7。
- 读图：1024x938；包含电量15/7/5%、低电量Warning、RC Loss动作Lockdown与0.5s；还包含Obstacle Avoidance等区域。
- 弃用原因：具体示例数值与危险动作容易被误读为推荐配置，且杂项分散主题。第7页改用“触发条件→预设动作→实际验证”自绘逻辑，不复制这些参数。

### A3 混合PID结构：读图通过，主稿不选

- 文件：`references/PX4-Autopilot/docs/assets/mc_pid_tuning/PID_algorithm_Mixed.png`。
- 母文档：P9。
- 读图：578x370；r与反馈y作差得到e，经K分到P/I；另一路反馈y经K和-D进入求和，再经G(s)输出y。D项不是简单对误差求导的同一路结构。
- 不选原因：本次重点是验证路线，公式级框图会占用解释时间。第8页改用简化级联关系，自绘时不把所有控制环统一标成PID。
- 如后续另做控制专题可使用，不纳入本次14页必需素材。

### A4 QGC飞行视图：入选第3页

- 文件：`references/PX4-Autopilot/docs/assets/concepts/qgc_fly_view.png`。
- 母文档：P1。
- 读图：959x651；顶部Flying/Hold，地图上Go here目标、姿态/航向指示，底部高度/速度等遥测，左下WAITING FOR VIDEO。
- 用途：让听众知道地面站可视界面是什么，不展示本项目飞行成果。
- 图注：**QGroundControl官方文档界面示例，非本项目实测；界面版本与本机可能不同。**
- 保留地图主体与状态区域即可；不把底部数值当作本项目实验数据，不宣传图中存在实时视频。

## 自绘图统一约束

- 所有自绘图的节点、边、文字在最终逐页稿中锁定；图注写“根据[证据编号]整理的概念示意”或“本项目拟验证路线”。
- 概念关系图不画未确定的线束针脚、电源电压、串口编号、电机编号或ROS 2协议拓扑。
- 计划图不伪装成已实现架构；仿真图不画成实机已连通；双机图不用编队效果图。
- 当前不需要新增图片或视频下载，不以不存在的实物照片作为封面制作前提。

## 引用定位模板

- PX4当前文件：`https://github.com/PX4/PX4-Autopilot/blob/202811313926f3d719f7477bf497b199918a8f22/docs/en/<文件路径>`。
- PX4历史文件：`https://github.com/PX4/PX4-Autopilot/blob/1c8ab2a0d7db2d14a6f320ebd8766b5ffaea28fa/<源码路径>`。
- QGC文件：`https://github.com/mavlink/qgroundcontrol/blob/dab963d852e6139288cec0f49b45fa4bfc44c2c1/docs/en/qgc-user-guide/<文件路径>`。
- 这些链接仅为出处标识；整个大纲制作不需要在线打开它们。
