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
- **网络（2026-10-09 核对）**：WSL 已恢复 `nat`，回环全通，PX4↔Gazebo 的 TCP 4560 走 127.0.0.1 直连正常。**更正**：virtioproxy 时期（约 2026-09-27~10-09）4560 其实**受影响**——连 127.0.0.1:4560 被 Windows 中转接受后丢弃、gazebo 内部回环临时端口 TCP 被拒，当时靠 `GAZEBO_IP`/`PX4_SIM_HOST_ADDR` 设为 eth0 IP 绕路才跑通（先前"4560 不受影响"的推断不成立）。绕路环境变量仍在启动器 `run_gazebo2.sh` 里，NAT 下无害。详见 note 005「网络」与 ff 009。

## 五、QGC 连通（两条候选，先通者为准）

- (a) Windows `U:\expro\QGroundControl\bin\QGroundControl.exe`（v5.0.3）经 UDP 连 SITL。**当前是 NAT 模式**（2026-10-09 起）：PX4 默认发往 127.0.0.1:14550 的 UDP 只留在 WSL 内部，Windows 上的 QGC 直接收不到。**已验证的做法（issue 011-x）**：pxh 里 `mavlink start -u 14557 -r 4000000 -t <默认网关IP> -o 14550`（网关 IP 用 `ip route | awk '/default/{print $3}'` 现取，即 Windows 侧 vEthernet；不传 `-m`），QGC 默认监听 14550 自动发现，已实测双向通、可下发起飞；封装为 `demos/lib/common.sh` 的 `gcs_link_to_windows`。备选（未实测）：QGC 手动加 Comm Link 指 WSL eth0 IP:14550；`MAV_BROADCAST=1`。
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
- virtioproxy 时期（约 2026-09-27~10-09）：TCP 4560 连 127.0.0.1 被 Windows 中转丢弃，须 `GAZEBO_IP`+`PX4_SIM_HOST_ADDR`=eth0 IP 绕路；NAT 恢复后不再需要但保留无害。
- 经 `wsl.exe bash -c '...'` 注入 pxh 命令时，串里的 `$VAR`/`for` 变量会被吞（实踩：批量循环发命令结果 pxh 只收到空行）。逐条用字面 `printf 'cmd\n' > pxh_in`，或先写脚本文件再执行。
- 启动器与构建脚本：WSL `/root/px4-build/run_gazebo2.sh`（干净 PATH + FIFO stdin）、`build_sitl.sh`；仓库内备份在 `.cs/env/run_gazebo.sh`、`.cs/env/build_sitl.sh`。`.cs/env/setup_submodules.sh`、`install_deps.sh` 是早期版本，缺三个 bridge 子模块、嵌套 pymavlink 与 empy 钉版，脚本头已注明。
- 更多排错细节（worktree `.git` 指针改写、rsync 后子模块 gitdir 修复、cmake 对 ExternalProject 目录的硬校验、empy 4.x 不兼容等）见根目录 `HANDOFF.md`「踩过的坑」。

## 状态

- issue 004 已完成：确定结论"能跑，Gazebo Classic 11"并拿到闭环证据。
- **2026-10-09 复验**（WSL 恢复 NAT 后）：headless（`HEADLESS=1`）起飞-降落-上锁闭环通过；不带 `GAZEBO_IP`/`PX4_SIM_HOST_ADDR` 的纯净启动也能跑通（`PX4 SIM HOST: localhost`），绕路不再需要。日志 `/root/px4-build/sitl_verify_nat.log` 与 `sitl_verify_nat_plain.log`，细节见 ff 009。
- PPT 第 2、12 页使用本机实测截图/日志（标注"本机 SITL 实测，非实机"）。
- 已做（2026-10-09）：QGC 连 SITL（网关 IP 链路，issue 011-x；演示 B `demos/B-地面站联动/`）。
- 未做：多机 SITL（进行中，issue 012；参考 `Tools/gazebo_sitl_multiple_run.sh`）。
