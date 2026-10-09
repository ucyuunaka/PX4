---
kind: issue
title: "SITL virtioproxy 绕路与 NAT 恢复后复验"
type: ff
status: closed
created: 2026-10-09
epic: ""
---

# SITL virtioproxy 绕路与 NAT 恢复后复验

## 做了什么

virtioproxy 时期查明 TCP 4560 连 127.0.0.1 会被 Windows 中转接受后丢弃（先前"固定端口不受影响"的推断不成立），给启动器加 `GAZEBO_IP`/`PX4_SIM_HOST_ADDR`=eth0 IP 绕路跑通了 headless 起飞-降落。2026-10-09 NAT 恢复后复验：带绕路与不带绕路两种跑法都通过，绕路已不再需要，注释标注保留供健壮性。

## 改了哪些

- WSL `/root/px4-build/run_gazebo2.sh` — 加 3 行绕路 env + 注释（NAT 恢复后注释改为"virtioproxy 需要、NAT 下无害保留"）。
- WSL `/root/px4-build/run_gazebo_plain.sh` — 新增对照启动器（去掉绕路 env），验证用。
- `.cs/env/run_gazebo.sh` — 仓库副本，与 WSL 版同步。
- `.cs/notes/004`、`005`、`.cs/issues/007-x`、`.cs/spec/index.md`、`HANDOFF.md` — 随 issue 007 关闭一并更新。

## 怎么验证的

Ubuntu-20.04 root，`HEADLESS=1`，FIFO `/root/px4-build/pxh_in` 注入命令（参数→takeoff→等 20s→land）：

- 带绕路：`PX4 SIM HOST: 172.29.171.4`，`Simulator connected on TCP port 4560`，`Takeoff detected` → `Landing detected` → `Disarmed by landing`。日志 `/root/px4-build/sitl_verify_nat.log`。
- 不带绕路：`PX4 SIM HOST: localhost`，4560 直连成功，同样完整闭环。日志 `/root/px4-build/sitl_verify_nat_plain.log`。
- virtioproxy 时期的验证记录：`/root/px4-build/sitl_verify{,2,3,4,5}.log`（2026-10-09 13:15–13:32）。

## 对 .cs/ 的影响

- 已同步：note 004 §四/§五/§八/状态、note 005「网络」、issue 007 关闭结论、spec index 当前状态。
- 更正的旧说法：note 004 §四"4560 按矩阵不受影响（推断）"——实测受影响，已改写。

## 顺手发现（可选）

- 经 `wsl.exe bash -c` 注入 pxh 命令时，`for` 循环/`$VAR` 会被吞成空（一次复验因此把 5 条命令发成了 5 个空行）。须逐条字面 `printf 'cmd\n' > pxh_in` 或先写脚本文件。已记入 note 004 §八。
- eeprom 参数跨 run 持久：上次的 `param set` 结果会带到下次 SITL，验证参数是否生效别靠 `param show` 的旧值。
