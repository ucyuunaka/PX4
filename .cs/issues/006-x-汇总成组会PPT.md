---
kind: issue
title: "汇总成组会 PPT"
type: chore
status: closed
created: 2026-09-17
epic: ".cs/epics/001-x-组会PPT与PX4资料搜集/spec.md"
---

# 汇总成组会 PPT

## 目标

把检索结论组织成一份可在组会完整讲一遍的 PPT：选型依据 + 核心技术 + 单机调试链路 + 仿真实测 + 多机展望与开源案例。所有关键事实可回指来源。

## 范围

- 包含：页结构设计、各页内容、素材（截图/GIF）选用与嵌入、出处标注、PPT 文件制作、试讲一遍检查逻辑。
- 不包含：实物实验数据；超出检索结论、调研产出和本机实测的新内容。

## 归属

- 隶属 epic：`.cs/epics/001-x-组会PPT与PX4资料搜集/spec.md`
- 相关 spec：`.cs/spec/index.md`
- 依赖：002–005（均已完成）

## v2 需求（用户 2026-09-27/28 确定，替代 v1 的交付边界）

v1（14 页、670 秒、离线、只用 PX4/QGC 两个仓库）已被以下需求取代：

1. 加厚每页上屏文本。
2. 收敛过度约束：去掉让工作显得少、不确定性多的"不能写/未验证/不代表"式表述。只保留三类硬标注——官方/外部素材标"官方示例/项目名"；本机仿真标"本机 SITL 实测，非实机"；版本事实（v1.13 vs 新版、fmu-v2 受限）如实讲。
3. 增加实质内容：充分使用 `references/` 下开源仓库的文本/动图/图片/视频。
4. 篇幅上限 25 页。
5. 核心技术（MAVLink、PX4 软件栈等）单独成页、放前半段，作"重要组成部分"介绍，不求全、不求透。
6. PPT 不引用 `.cs/` 任何内容；其余均可引用，注明本地路径或云端 URL。
7. 不设时长：不预估每页或总时长。

需求全文同步在 `presentation/组会-1/process/README.md`，那里是制作过程文档的入口。

## 现状如何工作

- `presentation/组会-1/process/README.md` —— 过程文档入口：v2 需求、状态、文件地图（2026-09-29 重组后路径）。
- `presentation/组会-1/process/04-final-slide-outline.md` —— 内容主稿 v2，20 页（封面→进展→平台组成→PX4 软件栈→MAVLink→版本基线→调试路线→固件机架→三关口→调参→SITL 概念→本机 SITL 实测→多机接入→多机仿真→协同层次→开源案例一：单机自主栈→开源案例二：集群→研究切入点→下一阶段→来源）。每页含上屏文字、图示规格、图注、引用、讲述提示；时长已全部移除。
- `presentation/组会-1/process/05-slide-plan-v2.md` —— v2 页结构蓝图与可用素材清单。
- `presentation/组会-1/process/02-evidence-and-assets.md` —— 证据编号索引（P/Q/H/M/A），页码已对齐 v2。
- `presentation/组会-1/assets/` —— PPT 素材：本机 SITL 截图与日志（`sitl/`，2026-09-28 从 `.cs/evidence/sitl/` 迁入）、官方文档图（`official/`）、ego-planner-swarm GIF（`external/`）；出处见其 README。
- `presentation/组会-1/research/` —— 调研 AI 提示词、原始产出、出处核查表 `sources.md`。
- `presentation/组会-1/history/` —— v1 执行计划与 SITL 一小时门控评估，只作留档。

本机 SITL 闭环（v1.13.3 + Gazebo Classic 11.15.1 + WSL2）复现路径见 `.cs/notes/004-PX4仿真SITL路径.md`。

## 质量目标

- 准确性（继承 epic）：版本号、参数名、板型/固件映射、流程结论可回指官方文档或源码；第三方仅作操作参考。加厚文本不降低此约束，只去掉冗余的自我设限表述。

## 待办

1. 制作 PPT 文件（模板、排版，讲述提示进备注）。
2. 试讲一遍，检查逻辑与衔接（不做时长校准）。
3. 可选补充：本机跑双机 SITL 截图（第 14 页）、Flight Review/PlotJuggler 界面截图（`research/sources.md` C-04~06）。

## 执行记录

- 2026-09-17～22：v1 14 页内容稿完成；SITL 解冻后实测跑通，第 10 页（现第 12 页）改为实测。
- 2026-09-27：用户提出返修方向；调研 AI 提示词定稿（`presentation/research/prompt-2026-09-27.md`）。
- 2026-09-28：调研产出核查入库（6 个外部仓库 clone 进 `references/`）；`05` 页计划与 `04` v2 写成（4 个并行块撰写后统一合并）。
- 2026-09-28：文档整理——移除全部时长预估；SITL 证据迁到 `presentation/assets/sitl/` 并生成去转义的可读日志；选用的官方图与 GIF 复制到 `presentation/assets/`；v1 执行计划与仿真评估移入 `presentation/history/`；调研提示词移入 `research/`；新增 `presentation/README.md` 入口；02/05/sources 页码与路径对齐 v2。
- 2026-09-28：按需求 1–3 逐页复核 `04`——删冗余防守句；第 2/4/6/8/9/10/11/15 页补内容并挂官方图（高层飞行栈、QuadRotorX、级联控制框图、SITL 端口总览、伴飞架构）；第 12 页用本地 pyulog 解析本机 ULog，生成高度/姿态曲线（`assets/sitl/plots/`）并写入实测数字；开源案例拆为第 16 页（Fast-Drone-250/Fast-Planner/EGO-Planner）和第 17 页（EGO-Swarm/MDS），共 20 页；附录问答改为正面口径。

## 关闭结论（2026-09-29）

- 判断：目标达成。PPT 已按 v2 需求制作完成并用于 2026-09-29 组会，汇报圆满完成。
- 产出：成品 `presentation/组会-1/组会-1.pptx`（ppt-master 流程制作，制作项目落点见 `presentation/组会-1/ori_ppt/第一次组会.md`）；内容主稿 `presentation/组会-1/process/04-final-slide-outline.md`；演讲准备 `process/06-speaker-prep-notes.md`。
- 验证：内容稿按需求 1–3 逐页复核过一轮；关键事实经 02 证据索引可回指官方文档/源码/本机实测；组会实际讲完即最终验证。
- 回写位置：epic spec「当前推进」勾掉本 issue 并登记产出位置。
- 遗留事项（不阻塞关闭）：可选补充未做——双机 SITL 截图、Flight Review/PlotJuggler 界面截图；可作为后续场次素材，需要时再开 issue。
