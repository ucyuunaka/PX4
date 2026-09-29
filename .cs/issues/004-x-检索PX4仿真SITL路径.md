---
kind: issue
title: "检索：PX4 仿真（SITL）路径与本机可行性"
type: chore
status: closed
created: 2026-09-17
epic: ".cs/epics/001-x-组会PPT与PX4资料搜集/spec.md"
---

# 检索：PX4 仿真（SITL）路径与本机可行性

## 目标

确定能否在本机（Windows 11）跑通 PX4 软件在环仿真，给出"用哪个仿真器 + 怎么起 + 怎么录屏/截图"的确定结论，作为 PPT 最稳妥的可演示内容（无实物也能演示装机/校准/飞行流程）。

## 范围

- 包含：SITL 概念与价值、可选仿真器（Gazebo / jMAVSim / Gazebo Classic 等）对 v1.13.x 的适配、本机环境可行性实测（WSL2/Docker/依赖）、起仿真并让 QGC 连上的最小路径、录屏/截图方法。
- 不包含：把仿真做成完整开发环境；HITL/硬件在环；多机仿真的实际搭建（属 issue 005 检索范围）。

## 归属

- 隶属 epic：`.cs/epics/001-x-组会PPT与PX4资料搜集/spec.md`
- 相关 spec：`.cs/spec/index.md`、`references/PX4-Autopilot/docs/en/`（simulation / dev_setup 章节）

## 背景与证据

- 用户在 Windows 11 / pwsh7 / gitbash。SITL 在 Windows 上通常需 WSL2 或 Docker；需先实测哪条路可通。
- 这是 PPT 的"保底"：若实物无法演示，仿真录屏/截图证明流程跑通。
- 版本基线 v1.13.x——要确认所选仿真器与该版本兼容（jMAVSim 轻量但功能少，Gazebo 更真实但更重）。

## 操作方案

- 先实测本机：WSL2 是否可用、Docker 是否在、能否编译/运行 PX4 SITL。
- 官方文档落点：`references/PX4-Autopilot/docs/en/` 下 simulation / dev_setup 相关章节；对照最新与 v1.13 措辞。
- 给出一个**确定结论**：能跑（用哪个仿真器 + 起的命令 + 怎么让 QGC 连 + 怎么录）或不能跑（PPT 演示页改用官方文档截图/外部演示视频，并在 epic「剩余阻碍」更新）。
- 产出到 `.cs/notes/004-PX4仿真SITL路径.md`。

## 风险与穿刺

- 风险：Windows 上 SITL 依赖链长，可能卡在 WSL2/Docker/编译。先打通"最小起仿真"这一步（穿刺），通了再补录屏/截图细节。
- 每点验证：环境就绪 → `make px4_sitl`（或对应目标）起得来 → QGC 能连 → 能切到飞行画面。

## 验证

- 给出明确"能跑/不能跑"结论；能跑则附可复现命令与演示路径。

## 结论（2026-09-22 实测）

**能跑**。仿真器 = Gazebo Classic 11.15.1，命令 `make px4_sitl gazebo`（v1.13.3 worktree 副本 `/root/px4-sitl-src`，WSL2 Ubuntu-20.04 原生）。已跑通 `commander takeoff` → `Landing detected` → `Disarmed by landing` 完整闭环，ULog 与截图现存 `presentation/组会-1/assets/sitl/`（原 `.cs/evidence/sitl/`，2026-09-28 迁出，2026-09-29 随组会场次目录重组再迁）。细节与复现命令见 `.cs/notes/004-PX4仿真SITL路径.md`。

## 关闭结论（2026-09-29）

- 判断：目标达成。确定结论"能跑"——Gazebo Classic 11.15.1 + PX4 v1.13.3 + WSL2，起飞-降落闭环实测通过（详见上文「结论（2026-09-22 实测）」）。
- 验证：ULog、截图、控制台日志存 `presentation/组会-1/assets/sitl/`；复现命令与坑位备忘在 `.cs/notes/004-PX4仿真SITL路径.md`。
- 回写位置：notes/004（已产出）；epic spec「剩余阻碍」已解除；证据索引见 `presentation/组会-1/process/02-evidence-and-assets.md` 的 M1b 条目。
- 遗留事项：QGC↔WSL SITL 的 UDP 连通未实测（闭环用 pxh 控制台完成），留待后续需要时验证。
