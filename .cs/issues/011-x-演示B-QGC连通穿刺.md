---
kind: issue
title: "演示 B：QGC 与 WSL(NAT) 中 SITL 的连通穿刺"
type: feature
status: closed
created: 2026-10-09
closed: 2026-10-09
epic: "002-o-仿真演示与一键脚本"
---

# 演示 B：QGC 与 WSL(NAT) 中 SITL 的连通穿刺

## 目标

先证明 Windows 上的 QGC（`U:\expro\QGroundControl\bin\QGroundControl.exe`，v5.0.3）能与 WSL NAT 里的 PX4 v1.13.3 SITL **双向**通信（QGC 显示飞机、能下发起飞/降落）。打通后在本 issue 内加厚为 `demos/B-地面站联动.bat`（自动开仿真 + 开 QGC + 自动连好）。

## 归属

- 隶属 epic：`.cs/epics/002-o-仿真演示与一键脚本/spec.md`

## 背景与证据

- NAT 下 PX4 GCS 链路：本地 UDP 18570 → 远端 127.0.0.1:14550，留在 WSL 内，Windows QGC 收不到（`sitl_verify_nat.log` 中 `mode: Normal ... on udp port 18570 remote port 14550`）。
- Windows 防火墙配置文件已关闭；WSL 网卡为 `vEthernet (WSL (Hyper-V firewall))`，Hyper-V 防火墙对 Windows→WSL 入站是否放行**未知**。

## 风险与穿刺

- 风险表与顺序：
  1. WSL → Windows UDP（发往默认网关 IP:14550）能否到达 Windows。
  2. Windows → WSL UDP（QGC 回包到 WSL eth0 IP）能否到达（Hyper-V 防火墙）。
  3. 选定 PX4 侧做法：pxh 里额外 `mavlink start` 一条发往网关 IP:14550 的 Normal 链路（首选，不改参数文件），或 `MAV_0_BROADCAST`，或 QGC 手动 Comm Link。
  4. 真实 QGC 能否看到飞机并下发命令（需用户肉眼确认）。
- 每点验证与结果：
  1. **WSL → Windows UDP：通（2026-10-09 已验证）**。headless SITL（`demos/lib/common.sh` + `HEADLESS=1`）里 pxh 执行 `mavlink start -u 14557 -r 4000000 -t 172.29.160.1 -o 14550`（`-t` 填默认网关 = Windows 侧 vEthernet 地址）。Windows 侧 python 绑 `0.0.0.0:14550` 监听 6 秒，收到 **225 个 UDP 包**，源地址 `172.29.171.4:14557`。注意两点：`-m normal` 会报 `invalid mode`（normal 是缺省值，不能显式传，省略即可）；包首字节是 `0xFE` 即 **MAVLink v1** 帧（`mavlink status` 显示 version 1；QGC 端协商后是否升 v2 未实测，对 QGC 无碍）。监听前已确认 QGC 未在运行（不占 14550）。日志 `demos/logs/spike011-20261009-202038.log`。
  2. **Windows → WSL UDP：通（已验证）**。WSL python3 绑 `0.0.0.0:45998`，Windows 向 `172.29.171.4:45998`（eth0 IP）发包，WSL 正常收到；源地址显示为 `172.29.160.1`（过 NAT 后源被换成网关地址）。没遇到 Hyper-V 防火墙拦截，`Get-NetFirewallHyperVVMSetting` 因此未查。
  3. PX4 侧做法**已选定并落地**：`mavlink start -u 14557 -r 4000000 -t <网关IP> -o 14550`（不改参数文件，运行期 pxh 加链路；`-m normal` 不能显式传）。封装为 `demos/lib/common.sh` 的 `gcs_link_to_windows`，网关经 `ip route | awk '/default/{print $3; exit}'` 现取。QGC 侧默认监听 14550 自动发现，无需配 Comm Link。
  4. 真实 QGC：AI 侧已确认到"连上"这一层——`mavlink status` 里 14557 实例 **rx 有持续流量**（QGC 心跳，约 21 B/s），并有 QGC 窗口截图 `demos/logs/B-qgc.png`；**用户 2026-10-09 在 AI 那次运行中亲手操作 QGC：看到飞机、点起飞、设置目标点等均正常（已确认）**。
- 主路径是否端到端通：**是**。网络层、MAVLink 层双向通，用户在 QGC 实际下发起飞与目标点成功。
- 剩余加厚项：B 演示脚本、讲稿已建（`demos/B-地面站联动/`）；QGC 启动已包进 `.bat`（未运行才启动，清理不动 QGC）；用户确认点 4 后可关闭。

## 验证

- 2026-10-09 用 B 演示脚本实测（`wsl.exe … bash demos/B-地面站联动/run.sh`，stdin 喂回车）：SITL 起来 → `home set` → 置参 → `gcs_link_to_windows` 打印「飞机 → Windows（172.29.160.1:14550）」→ 日志出现 `mode: Normal, data rate: 4000000 B/s on udp port 14557 remote port 14550`。日志 `demos/logs/B-地面站联动-20261009-203453.log`。
- `mavlink status`：instance #4 `UDP (14557, remote port: 14550)`，`tx: 1361.6 B/s`、**`rx: 20.9 B/s`**——QGC 心跳已回到 WSL，MAVLink 层双向连通。
- QGC 由 AI 按 bat 同款命令启动（此前未运行），AppActivate 置前后全屏截图 `demos/logs/B-qgc.png`。
- 清理：结束后无 px4/gzserver/gzclient/FIFO 残留；AI 启动的 QGC 实例已关闭。
- 用户实测（2026-10-09）：在 QGC 里看到仿真飞机，点起飞、设置目标点等操作正常。
- 未验证：断网彩排（注意 QGC 地图瓦片需联网加载，断网时地图可能是灰的，只显示已缓存区域）；双击 `B-地面站联动.bat` 的完整用户流程（用户这次是在 AI 运行中操作的）。

## 执行记录

- 2026-10-09 晚（约 20:20）：穿刺点 1–2。WSL→Windows（mavlink start 到网关 14550，Windows 收到 MAVLink 包）、Windows→WSL（UDP 到 eth0 IP 可达，源被 NAT 成网关 IP）。首测 `-m normal` 报 `invalid mode`（normal 是缺省值不能显式传）。QGC 未占用 14550（监听前先确认未运行）。日志 `demos/logs/spike011-20261009-202038.log`。
- 2026-10-09 晚：实现 B 演示。`common.sh` 加 `gcs_link_to_windows`；新增 `demos/B-地面站联动/{run.sh,说明.md}`、`demos/B-地面站联动.bat`（tasklist 判断 QGC 未开才 `start`，不重复开；stop/cleanup 不动 QGC）；`demos/README.md` 加 B 用法与状态。
- 注意：MAVLink 帧是 v1（首字节 0xFE）；网关/WSL IP 每次可能变，一律现取不写死。
- 用户已在 QGC 确认起飞/目标点可用；剩断网彩排。关闭待用户授权。

## 关闭结论

- **关闭判断**：目标达成——穿刺证明双向连通（点 1–3 全过），加厚成 `demos/B-地面站联动.bat` 一键演示；用户 2026-10-09 在 QGC 里亲手看到飞机并成功下发起飞/目标点。
- **验证摘要**：WSL→Windows MAVLink 流量实测到达（225 包/6s）；Windows→WSL UDP 通（Hyper-V 防火墙未拦）；`mavlink status` 14557 实例 rx 持续有 QGC 心跳；AI 运行中用户操作 QGC 起飞/设点成功；截图 `demos/logs/B-qgc.png`。
- **回写位置**：见下「关闭回写」。
- **遗留事项**：断网彩排未做（注意 QGC 离线地图问题）；从双击 .bat 开始的完整流程用户未单独走过（本次是在 AI 运行中操作的）；备用录屏未做。

## 关闭回写

- `.cs/epics/002-o-仿真演示与一键脚本/spec.md`：Issues 勾选 011-x；剩余阻碍中"QGC↔WSL NAT 连通未实测"已消除。
- `.cs/notes/004-PX4仿真SITL路径.md` §五(a)：网关 IP 链路方案已实测，改为已验证。
- `.cs/notes/005-WSL-ROS环境.md`「对各链路的影响」：QGC 链路改标已验证。
- `.cs/spec/index.md`、`HANDOFF.md`：当前状态补 B 可用。
- `demos/B-地面站联动/`、`demos/README.md`：成品文档即交付物。
