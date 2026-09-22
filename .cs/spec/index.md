# Project Spec

## 这个项目是什么

围绕一架 F450 机架 + Pixhawk 飞控的无人机项目：装机、调参、飞行，并在过程中沉淀可复用的知识与资料。软件栈选定 **PX4**，地面站使用 **QGroundControl（QGC）**。

## 当前状态与重点

- 处于入门阶段：已有 PIX 2.4.8 克隆板（飞控）与 F450 机架，正在收集装机/调参/固件刷写资料。
- QGC 已安装于 `U:\expro\QGroundControl\bin\QGroundControl.exe`（v5.0.3 master 构建，已验证可运行）；固件刷写走 QGC 在线下载，早期网盘资源已确认无需找回。
- 项目当前是"资料 + 调参工作库"形态；尚无代码。
- 当前有一条进行中的工作线：组会 PPT 与 PX4 资料搜集（见 `.cs/epics/001-o-组会PPT与PX4资料搜集/spec.md`），面向 4 天后的组会，实物 bring-up 不在其边界内。

## 能力地图

- 入门资源索引：`.cs/notes/001-入门资源索引.md`（装机、调参、QGC 教程与官方下载渠道）
- 本地文档查阅：`.cs/notes/002-PX4本地文档查阅.md`（PX4 与 QGC 官方文档离线版）
- references 仓库索引：`.cs/notes/003-references仓库索引.md`（13 个本地 clone 的用途、活跃度与版本基线适配）
- 草稿收件箱：`inbox.md`（未整理内容暂存，整理后分流到 `.cs/`）

## 使用路径

- 想了解项目定位和技术选型：读本文件
- 想找装机/调参/QGC 教程与下载渠道：读 `.cs/notes/001-入门资源索引.md`
- 想查官方文档原文：读 `.cs/notes/002-PX4本地文档查阅.md`
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
- 想看待办事项：读 `.cs/issues/`

## 当前边界

- 做：装机、调参、飞行操作、资料沉淀
- 不做：PX4/ArduPilot 源码二次开发（当前未规划；若未来需要再评估）

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
- 进行中的组会资料搜集线：`.cs/epics/001-o-组会PPT与PX4资料搜集/spec.md`
