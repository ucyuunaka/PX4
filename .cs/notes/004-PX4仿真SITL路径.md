# 004 — PX4 仿真（SITL）路径与本机可行性

结论先行：**本机能跑**。仿真器定为 **Gazebo Classic 11**（v1.13 标配），在 WSL2 `Ubuntu-20.04` 原生编译并跑通了"连接 → 起飞 → 悬停 → 降落 → 上锁"完整闭环。证据见文末。

## 一、确定结论（issue 004 要求的三问）

| 问题 | 答案 |
|---|---|
| 能跑吗 | **能跑**（go/no-go = go） |
| 用哪个仿真器 | **Gazebo Classic 11**（`make px4_sitl gazebo`，iris 机型，empty.world） |
| 怎么起 | WSL 原生 `make px4_sitl gazebo`（worktree 副本 `/root/px4-sitl-src`） |
| 怎么录 | Gazebo GUI 走 WSLg 显示到 Windows 桌面（窗口名 `Gazebo (Ubuntu-20.04)`），用系统截图/录屏工具抓该窗口；飞行数据落 ULog |

## 二、版本与启动方式（实测）

- **PX4 版本**：v1.13.3（`git worktree` 独立检出，HEAD `1c8ab2a0d7…`，不动主 checkout v1.18）。
- **仿真器**：Gazebo Classic **11.15.1**（`libgazebo11-dev`，focal 官方源），非新版 Gazebo（Ignition）。
- **机型/世界**：`iris` + `empty.world`。
- **启动命令**（WSL 内）：
  ```
  cd /root/px4-sitl-src
  GIT_SUBMODULES_ARE_EVIL=1 make px4_sitl gazebo
  ```
  该目标先编 `build_gazebo` 下的 sitl_gazebo 插件，再由 `Tools/sitl_run.sh` 拉起 `gzserver` + `gzclient` + `px4` 二进制。

## 三、实测跑通的闭环（本次采证）

- `pxh>` 控制台注入 `commander takeoff` → `Takeoff detected` → `commander land` → `Landing at current position` → `Landing detected` → `Disarmed by landing`。
- 完整日志 `INFO` 序列在 `presentation/组会-1/assets/sitl/sitl_console_clean.log`（去掉终端转义的可读版，第 96–171 行；原始版 `sitl_console.log`）。第一次起飞未置参，failsafe 触发 RTL 后自动降落；置参后两次 `takeoff`/`land` 闭环对应两份 ULog。
- 期间出现 `WARN [commander] Failsafe enabled: no RC and no datalink`（无遥控器/地面站时的预期告警），已通过置参 `NAV_DLL_ACT=0`、`NAV_RCL_ACT=0`、`COM_LOW_BAT_ACT=0`、`COM_RCL_EXCEPT=4` 让其不强制 RTL，仍可正常起飞降落。

## 四、本机环境前提（已验证）

- WSL2 `Ubuntu-20.04.6 LTS`，内核 6.6.x，`nproc=16`、内存 15Gi；默认用户 root，`sudo -n` 免密。
- WSLg 可用：`DISPLAY=:0`、`WAYLAND_DISPLAY=wayland-0` → Gazebo GUI 直接显示到 Windows 桌面，无需额外 X server。
- 关键依赖：`gazebo11 + libgazebo11-dev`、cmake/ninja/gcc-9、openjdk-13+ant（jmavsim 备用）、`empy==3.3.4`（**必须钉 3.3.x**，4.x 删了 `em.RAW_OPT` 会让 mavlink 代码生成炸）。
- 子模块走 `ghfast.top` 镜像（github 直连超时）。
- **网络（2026-09-30 核对）**：WSL 目前运行在 virtioproxy 回退模式，WSL 内部 UDP 连 127.0.0.1 默认不通。PX4↔Gazebo 用的是固定端口 TCP 4560，不受影响；MAVROS/MAVSDK/XRCE 用的 UDP 端口已经由 `wsl-loopback-fix.sh` 补上。详见 note 005「网络」。

## 五、QGC 连通（两条候选，先通者为准）

- (a) Windows `U:\expro\QGroundControl\bin\QGroundControl.exe`（v5.0.3）经 UDP 连 SITL。**当前是 virtioproxy 模式**，WSL 发往 127.0.0.1 的 UDP 会送到 Windows，而 PX4 默认发往 127.0.0.1:14550，所以 Windows 上的 QGC 理论上不用额外配置就能收到（未实测）。如果以后恢复成 NAT 模式（issue 007），就改成：SITL 端设 `MAV_BROADCAST=1`，或让 PX4 发往 Windows 宿主 IP，或在 QGC 里手动加一条指向 WSL IP:14550 的 Comm Link。
- (b) WSL 内跑 QGC AppImage 走 WSLg。
- 备注：本次闭环用 `pxh>` 内置控制台完成（无需 QGC 即可演示起飞-降落）；QGC 连通属"锦上添花"的可视化项，不阻塞结论。

## 六、证据清单（本机实测，非官方截图）

证据在 `presentation/组会-1/assets/sitl/`（2026-09-28 从 `.cs/evidence/sitl/` 迁出，2026-09-29 随组会场次目录重组再迁）：

- `flight_loop_12_09_45.ulg` — 完整起飞-降落-上锁飞行日志（44 MB）
- `flight_loop_12_13_56.ulg` — 第二次复飞日志（10 MB）
- `sitl_console.log` / `sitl_console_clean.log` — pxh 控制台输出（原始 / 可读版）
- `gazebo_hover.png`、`gazebo_window.png` — Gazebo GUI 截图（WSLg 渲染到 Windows 桌面）

## 七、复现步骤（精简）

```bash
# WSL Ubuntu-20.04
cd /root/px4-sitl-src                      # v1.13.3 worktree 副本
GIT_SUBMODULES_ARE_EVIL=1 make px4_sitl gazebo   # 编插件 + 起仿真
# pxh> 内：
commander takeoff
commander land
# ULog 落在 build/px4_sitl_default/tmp/rootfs/log/<date>/
```

## 八、坑位备忘（排错已解决，勿再踩）

- 子模块需递归到底：`sitl_gazebo → external/OpticalFlow → external/klt_feature_tracker`；`jMAVSim → jMAVlib`；`mavlink → pymavlink`。
- `make` 的 stdin 不能是 `/dev/null`：pxh 读到 EOF 会 `Exiting NOW` 自杀。用 FIFO 或 `sleep infinity` 顶住写端。
- WSL PATH 里混入 Windows Anaconda 的 `protobuf-config.cmake` 会污染 cmake → 用干净 `PATH`（`env PATH=/usr/local/sbin:...`）构建 sitl_gazebo。
- `bash -lc` 里 `pkill px4` 会误杀自身；后台保活唯一可靠法是 `setsid … < /dev/null &`。
- 启动器与构建脚本：WSL `/root/px4-build/run_gazebo2.sh`（干净 PATH + FIFO stdin）、`build_sitl.sh`；仓库内备份在 `.cs/env/run_gazebo.sh`、`.cs/env/build_sitl.sh`。`.cs/env/setup_submodules.sh`、`install_deps.sh` 是早期版本，缺三个 bridge 子模块、嵌套 pymavlink 与 empy 钉版，脚本头已注明。
- 更多排错细节（worktree `.git` 指针改写、rsync 后子模块 gitdir 修复、cmake 对 ExternalProject 目录的硬校验、empy 4.x 不兼容等）见根目录 `HANDOFF.md`「踩过的坑」。

## 状态

- issue 004 已完成：确定结论"能跑，Gazebo Classic 11"并拿到闭环证据。
- PPT 第 2、12 页使用本机实测截图/日志（标注"本机 SITL 实测，非实机"）。
- 未做：QGC 连 SITL、多机 SITL（`Tools/gazebo_sitl_multiple_run.sh`）。
