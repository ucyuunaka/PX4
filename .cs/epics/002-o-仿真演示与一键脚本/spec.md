---
kind: epic
title: "仿真演示与一键脚本"
status: active
created: 2026-10-09
---

# 仿真演示与一键脚本

## 这个 Epic 要改变什么

在"本机已能跑 PX4 SITL"的基础上，新增一组**可在组会现场双击即跑的仿真演示**：A 单机起降、B QGC 地面站联动、C 多机 SITL、D 编队避障（MASC / Swarm-Formation 参考项目）。每个演示交付"一键脚本 + 带画面实测 + 备用录屏 + 白话讲稿"。项目从"纯资料库"首次出现可运行的脚本代码（`demos/`）。

## 为什么现在做

用户决定后续组会以**现场演示仿真**为主、PPT 从简。四个演示早晚都要做，用户风格是提前做完、每次组会只放出一部分（组会-2 放 A+B）。跨多次组会、多批交付，适合用一条活规格承载。讨论来源：`.cs/talks/001-组会仿真演示规划.md`。

## 关联 Project Spec

- `.cs/spec/index.md`：依赖其中 v1.13.3 版本基线、WSL NAT 现状、SITL 可用结论；本 epic 会新增"演示脚本"能力并修改「当前边界」里"尚无代码"的描述。
- `.cs/notes/004-PX4仿真SITL路径.md`、`.cs/notes/005-WSL-ROS环境.md`：SITL 复现方式、坑位与网络现状，是本 epic 的技术底座。

## 当前方案

- **用户画像**：用户技术背景有限，希望"不用懂也能用，需要懂时能问 AI 得到准确回答"。因此每个演示必须配**白话说明**；技术细节写在给 AI 看的位置（本 spec、issue、notes），用户可读层与技术层分开。
- **演示电脑**：组会现场就用本机（这台笔记本）接投影，不考虑换机部署。
- **节奏**：做的顺序 A → B → C → D（后者复用前者）；展示节奏 组会-2：A+B，之后 C，再之后 D。
- **目录约定**（仓库根 `demos/`）：
  - 根目录放 Windows 入口：`A-单机起降.bat`、`B-地面站联动.bat`…、`停止全部.bat`、`README.md`（白话使用说明）。
  - 每个演示一个子目录：`run.sh`（在 WSL 里真正干活）+ `说明.md`（白话讲稿：组会上怎么讲、可能被问的问题和答法）。
  - 共用逻辑放 `demos/lib/`（bash），日志写 `demos/logs/`（不进 git）。
- **调用链**：`.bat` 只负责 `wsl -d Ubuntu-20.04 -u root -- bash /mnt/u/ucy/Code/active/PX4/demos/<X>/run.sh`；所有逻辑写在仓库内 `.sh` 文件里（经 `wsl.exe bash -c` 传命令会吞 `$VAR`，见 note 004 §八）。
- **演示体验**：双击 → 中文进度提示 → 仿真窗口出现 → 自动飞完一遍 → 窗口保留供讲解 → 按回车结束并清理。出问题双击「停止全部」后重来。
- **展示内容的标注**：沿用 `presentation/README.md` 引用规则——本机仿真对外说"本机 SITL 实测，非实机"；D 说"规划算法仿真"，不说成 PX4 集群。
- **已落地（2026-10-09）**：`demos/` 按上表建好：共用库 `lib/common.sh`（`sitl_start`/`wait_for`/`pxh`/`set_failsafe_params`/`gcs_link_to_windows`/`demo_cleanup`）+ `stop.sh`/`停止全部.bat`；A、B 两个演示均带 `.bat`、白话讲稿、README。QGC 链路做法：pxh `mavlink start -u 14557 -r 4000000 -t <默认网关IP> -o 14550`（不传 `-m`；网关运行时经 `ip route` 现取）；`.bat` 只在 QGC 未运行时启动它，停止脚本不动 QGC。

## 架构考量

- **为什么 `.bat` + 仓库内 `.sh`**：用户双击即可；逻辑在 git 里可审、可复用；绕开 wsl.exe 传参吞变量的坑。不用 PowerShell 入口：`.ps1` 默认执行策略会拦，双击体验差。
- **为什么演示脚本不直接复用 `/root/px4-build/run_gazebo2.sh`**：那是 WSL 本地文件、不在仓库里；`demos/lib/` 里自带等价逻辑（干净 PATH、FIFO 喂 pxh、`GAZEBO_IP`/`PX4_SIM_HOST_ADDR` 仍保留以防网络回退），仓库即真相。
- **清理必须安全**：停止脚本只杀演示相关进程（px4、gzserver、gzclient、roslaunch/rosmaster、FIFO 持有者）；**禁止** `wsl --shutdown` / `--terminate`（会停 Docker Desktop 的容器）。
- **`references/` 保持只读**：D 的构建在 WSL 内副本进行。

## 质量约束与取舍

- 易用性 / 可学习性：
  - 约束：用户不打任何命令即可完成一次演示；所有提示中文；失败时给出一句白话原因和"双击停止全部后重试"。
  - 继承：所有演示 issue。
- 可靠性 / 可恢复性：
  - 约束：同一演示连续跑两次（中间只用「停止全部」）都能成功；残留进程不影响下一次。
  - 继承：所有演示 issue。
- 可靠性 / 可用性（现场条件）：
  - 约束：断网状态下也能跑（由用户会前彩排时验证，AI 无法安全断网）。
  - 取舍：AI 侧只能做联网验证 + 识别联网依赖点（如 Gazebo 查 `fuel.gazebosim.org`），断网实测留给彩排清单。
- 信息安全性：
  - 约束：脚本不写入任何代理配置，不依赖 Clash；不改 Windows 防火墙设置。

## 统一语言

- 演示（demo）：`demos/` 下一个可双击运行的场景，编号 A–D。
- 一键脚本：演示的 `.bat` 入口及其调用的 `run.sh`。
- 讲稿：每个演示目录下的 `说明.md`，白话，给用户在组会上用。

## 当前推进

### 可推进范围

- A 单机起降：底座已验证（NAT 下 headless 起降闭环，ff 009），可直接实现。
- B 的 QGC 连通方式：需先穿刺再实现。

### Issues

- [x] `.cs/issues/010-x-演示A单机起降一键脚本.md`：`demos/` 骨架 + 共用库 + 停止脚本 + A 演示；验证带 GUI 运行。
- [x] `.cs/issues/011-x-演示B-QGC连通穿刺.md`：证明 Windows QGC 能与 WSL(NAT) 里的 SITL 双向通信，选定方案；之后在同一 issue 内加厚成 B 演示。
- [ ] `.cs/issues/012-o-演示C多机同飞.md`：3 架 SITL 同飞 + QGC 多机显示。
- [ ] D 编队避障：待 C 完成后建 issue。

### 剩余阻碍

- 断网实测：A/B 均未在断网状态下跑过（留给用户会前彩排；Gazebo 启动会尝试联网查模型库，QGC 离线地图为灰底）。
- 备用录屏未做；组会现场投影未验证。

## 暂不推进范围

- ROS 2 联调演示（需另编新版 SITL，见 note 005「版本对齐」）。
- 真机相关内容。
- 组会-2 的 PPT / 讲稿整合（等 A、B 完成后按 `presentation/README.md` 新建 `组会-2/`）。

## 未确认问题

- 备用录屏用什么工具录（Windows 自带截图工具录屏 / Xbox Game Bar / ffmpeg）：做完 A 后与用户确认。

## 关闭条件

- A–D 四个演示都有：一键脚本、带 GUI 实测通过（含连续两次运行）、白话讲稿、备用录屏；用户彩排确认（含断网）。
- `demos/README.md` 完整；note / spec 回写完成。

## 合并回 Project Spec 的候选

- 「当前状态」：项目新增 `demos/` 演示脚本能力；「能力地图」「使用路径」增加演示入口。
- 演示脚本约定（`.bat` + 仓库内 `.sh`、安全清理、不 `wsl --shutdown`）。

## 相关材料

- `.cs/talks/001-组会仿真演示规划.md`：讨论来源；下半部分是给 AI 的各演示技术路径与未知点。
- `.cs/issues/009-x-ff-SITL-virtioproxy绕路与NAT恢复后复验.md`：NAT 下 SITL 复验证据。
- `presentation/README.md`：组会场次与引用规则。
