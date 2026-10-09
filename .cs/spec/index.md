# Project Spec

## 这个项目是什么

围绕一架 F450 机架 + Pixhawk 飞控的无人机项目：装机、调参、飞行，并在过程中沉淀可复用的知识与资料。软件栈选定 **PX4**，地面站使用 **QGroundControl（QGC）**。

## 当前状态与重点

- 处于入门阶段：已有 PIX 2.4.8 克隆板（飞控）与 F450 机架，正在收集装机/调参/固件刷写资料。
- QGC 已安装于 `U:\expro\QGroundControl\bin\QGroundControl.exe`（v5.0.3 master 构建，已验证可运行）；固件刷写走 QGC 在线下载，早期网盘资源已确认无需找回。
- 项目当前是"资料 + 调参工作库 + 演示脚本"形态：`demos/` 已有一键仿真演示 **A–D 全部"可用"且用户 2026-10-09 实测通过**（A 单机起降、B 地面站联动、C 三机同飞、D 编队避障）。本机已可跑 PX4 SITL 仿真（v1.13.3 + Gazebo Classic 11，WSL2），实测起飞-降落闭环通过。
- 第一次组会（2026-09-29）已圆满完成：《基于 PX4 的 F450 四旋翼平台：前期调研、单机调试路线与多机扩展规划》，成品与全部过程材料在 `presentation/组会-1/`（场次组织规范见 `presentation/README.md`）。对应工作线 epic 001 已关闭并毕业回写。
- WSL 里已配好 ROS 双环境：`Ubuntu-20.04` 装 Noetic（兼作 SITL 主机），`Ubuntu-22.04` 装 Humble 加 PX4 ROS 2 桥接件。WSL 网络 2026-10-09 已恢复 `nat`（根因：Windows 防火墙服务 `mpssvc` 被禁用导致 HNS 建不了 NAT，详见 `.cs/issues/007-x-…`），NAT 下 SITL 已复验通过（ff 009）。WSL **不一定是长期基座**，后续可能换到原生 Ubuntu。
- 下一阶段方向：实物 bring-up（装机、刷机、校准、首飞，未立项）与后续组会（演示线已立项为 epic 002，见下条）。
- 组会-2 计划做仿真现场演示（用本机笔记本现场演示）：A 单机起降 / B QGC 联动 / C 多机 SITL / D MASC 编队，各配一键脚本；**A–D 全部就绪并用户实测**；组会-2 放 A+B。epic `.cs/epics/002-o-仿真演示与一键脚本/spec.md` 剩彩排与录屏收尾。

## 能力地图

- 入门资源索引：`.cs/notes/001-入门资源索引.md`（装机、调参、QGC 教程与官方下载渠道）
- 本地文档查阅：`.cs/notes/002-PX4本地文档查阅.md`（PX4 与 QGC 官方文档离线版）
- references 仓库索引：`.cs/notes/003-references仓库索引.md`（20 个本地 clone 的用途、活跃度与版本基线适配，含调研补充的 6 个外部开源项目，以及用户本科课程作业模板 MASC——仅作参考项目，演示 D 的来源）
- **本机 SITL 仿真路径**：`.cs/notes/004-PX4仿真SITL路径.md`（WSL2 + Gazebo Classic 11 跑通起飞-降落闭环的确定结论、环境前提、复现命令与坑位备忘）；实测证据在 `presentation/组会-1/assets/sitl/`
- **WSL ROS 环境与网络**：`.cs/notes/005-WSL-ROS环境.md`（两个发行版的用途与默认用户、NAT 网络现状与 virtioproxy 回退期存档、镜像源与 git 代理，以及 v1.13.3 与 ROS 2 桥接的版本差距）
- **一键仿真演示**：`demos/`（双击 .bat 即用，白话入口 `demos/README.md`；A 单机起降、B 地面站联动、C 三机同飞、D 编队避障均可用）；规划与约定见 epic `.cs/epics/002-o-仿真演示与一键脚本/spec.md`
- 组会汇报工作区：`presentation/`（按场次组织，规范与场次索引见其 README；组会-1 的材料含可复用的证据索引与调研核查表）
- 草稿收件箱：`inbox.md`（未整理内容暂存，整理后分流到 `.cs/`）

## 使用路径

- 想了解项目定位和技术选型：读本文件
- 想找装机/调参/QGC 教程与下载渠道：读 `.cs/notes/001-入门资源索引.md`
- 想查官方文档原文：读 `.cs/notes/002-PX4本地文档查阅.md`
- 想跑仿真演示：双击 `demos/` 下对应 `.bat`，白话说明读 `demos/README.md`，讲稿在各演示目录 `说明.md`（技术底座见 `.cs/notes/004-PX4仿真SITL路径.md`）
- 想复现或扩展本机 SITL 仿真：读 `.cs/notes/004-PX4仿真SITL路径.md`
- 想在 WSL 里跑 ROS1/ROS2，或遇到连 127.0.0.1 不通、下载失败：读 `.cs/notes/005-WSL-ROS环境.md`（WSL 网络已于 2026-10-09 恢复 NAT，历史见 `.cs/issues/007-x-修复WSL-Windows层网络.md`）
- 想暂存新资料：写 `inbox.md`，之后按约定分流

## 统一语言

- PX4：开源飞控软件栈，提供姿态/位置控制、导航、任务管理，支持 MAVLink 协议。
- ArduPilot：另一开源飞控软件栈；本项目未采用（见关键考量）。
- Pixhawk：飞控硬件标准/系列，同时兼容 PX4 与 ArduPilot 生态。
- QGC（QGroundControl）：跨平台地面站软件，负责参数配置、固件刷写、任务规划。
- F450：四旋翼机架型号（450mm 轴距），本项目机体。
- FMUv2 / 2.4.8：Pixhawk 一代飞控（STM32F4，2MB flash，部分早期板有 1MB 限制）；本项目飞控即其克隆板，PX4 中已 discontinued 但仍可编译。
- 版本基线：为本项目飞控选定的 PX4 版本（v1.13.x），区别于 QGC 默认刷写的 latest stable。

## 阅读路径

- 想理解项目当前在做什么：读本文件「当前状态与重点」
- 想找教程和资源链接：读 `.cs/notes/001-入门资源索引.md`
- 想找本地已有的开源仓库/调研素材：读 `.cs/notes/003-references仓库索引.md` 与 `presentation/组会-1/research/sources.md`
- 想做或改组会 PPT：读 `presentation/README.md`
- 想看待办事项：读 `.cs/issues/`（进行中：epic `.cs/epics/002-o-仿真演示与一键脚本/` 剩断网彩排与备用录屏；010–013 已于 2026-10-09 全部关闭）

## 当前边界

- 做：装机、调参、飞行操作、资料沉淀；组会用的仿真演示脚本（`demos/`，只做编排与启动，不改飞控/算法本身）
- 不做：PX4/ArduPilot 源码二次开发（当前未规划；若未来需要再评估）；`references/` 下的 clone 保持只读（演示 D 在 WSL 副本 `/root/masc_ws` 里只改了目标点模式）

## 关键考量

- **为什么选 PX4 而非 ArduPilot**：Pixhawk 硬件同时支持两个生态；PX4 对多无人机场景更友好，生态与 QGC 配合紧密，故选定 PX4。
- **资源优先官方渠道**：QGC 软件在官网/GitHub releases 下载；PX4 固件由 QGC 在线刷写（按飞控 board ID 自动选固件，PIX 2.4.8 克隆板 → `px4_fmu-v2_default`）；调参工具即 QGC 本身。早期网盘镜像已失效且确认无需找回（issue 001）。
- **本地保留两个官方仓库完整 clone**：`references/PX4-Autopilot/` 用于查阅 PX4 文档与源码的对应、搜索 API/参数定义；`references/qgroundcontrol/` 含 QGC 源码 + 用户指南全文（下载安装、固件刷写、调参章节可直接离线查阅），并能从源码确认 QGC 固件下载的实际机制。当前不计划修改上游源码。
- **PX4 版本基线 = v1.13.x**：飞控定为 PIX 2.4.8 克隆板（FMUv2 / STM32F4）。该板型在 PX4 中仍可编译（`boards/px4/fmu-v2/`，官方仍为其裁剪 EKF2 以塞进 2MB flash），但 3DR Pixhawk 1（FMUv2）已列入官方 discontinued（`docs/en/flight_controller/autopilot_discontinued.md`，文档停在 v1.15）——即"能编但不受官方测试/维护的极限板"。故锁定 **v1.13.x**：与中文教程生态最匹配、已知能跑的最稳基线；将来若换受支持板（FMUv5/v6X 等）再追新 stable。检索与 PPT 中所有版本号、参数名、板型映射以此基线核对。
- **检索以官方为权威**：网络检索与 PPT 中凡版本号、参数名、板型/固件映射、流程结论，一律回官方英文文档与官方仓库源码核对；第三方资料（CSDN/知乎/B站/博客）仅作操作顺序与踩坑参考，不作这类事实的唯一来源（与 notes/002 一致）。

## 证据索引

- 入门教程与官方下载渠道汇总：`.cs/notes/001-入门资源索引.md`
- 本地文档查阅方式：`.cs/notes/002-PX4本地文档查阅.md`
- 失效资源核查结论（已关闭）：`.cs/issues/001-x-找回调参与QGC资源.md`
- 本机 SITL 仿真闭环证据：`presentation/组会-1/assets/sitl/`（2 个 ULog + 控制台 log + 2 张 Gazebo 截图；放在组会场次目录下便于 PPT 引用）
- 仿真演示 A–D 的实现与验证记录：`.cs/issues/010-x-…` ~ `013-x-…`（运行日志与截图在 `demos/logs/`，该目录不进 git，只存在本机）
- WSL 网络根治记录：`.cs/issues/007-x-修复WSL-Windows层网络.md`；NAT 下 SITL 复验：`.cs/issues/009-x-ff-…`
- 已关闭的组会资料搜集线：`.cs/epics/001-x-组会PPT与PX4资料搜集/spec.md`（2026-09-29 关闭；毕业候选中的版本基线与检索原则已并入上文「关键考量」，SITL 可用性结论见「当前状态与重点」）
