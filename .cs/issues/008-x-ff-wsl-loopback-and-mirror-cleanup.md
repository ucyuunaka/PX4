---
kind: issue
title: "WSL 回环补丁与镜像/文档核对"
type: ff
status: closed
created: 2026-09-30
epic: ""
---

# WSL 回环补丁与镜像/文档核对

## 做了什么

按实机核对了提交 1a520b8（HANDOFF）和 98d25aa（note 005）写进来的 WSL/ROS 环境信息。查明 WSL 一直在 virtioproxy 回退模式下运行，导致 WSL 内部 UDP 连 127.0.0.1 不通。给 PX4 相关端口加了开机自动生效的补丁，统一了 git 代理前缀，清理了遗留的 rosdepc 和 root 下的旧 ROS 2 工作区，并纠正了文档里的错误说法。

## 改了哪些

- WSL 两个发行版：新增 `/usr/local/sbin/wsl-loopback-fix.sh`，`/etc/wsl.conf` 新增 `[boot] command=…`；root 与 ucy 的 `~/.gitconfig` 配上 `gh-proxy.com` 的 insteadOf 前缀。
- 20.04：卸载 rosdepc。22.04：删除 `/root/ros2_ws`。
- 曾临时写入 `%USERPROFILE%\.wslconfig`（mirrored）测试，**已删除还原**。
- `.cs/env/wsl-loopback-fix.sh`：补丁脚本的仓库副本。
- `.cs/notes/005-WSL-ROS环境.md`：按实测重写。
- `.cs/notes/003`、`.cs/notes/004`、`.cs/spec/index.md`、`HANDOFF.md`：同步相关内容。
- `.cs/issues/007-x-修复WSL-Windows层网络.md`：根治步骤的指引（当时待用户执行；2026-10-09 已关闭）。

## 怎么验证的

- 回环：删掉规则 → 模拟收发失败 → `wsl --terminate` 重启发行版 → 规则自动恢复 → XRCE 8888、MAVROS 14540↔14580、MAVSDK 14541↔14581 双向收发都通过，对照端口仍然不通。WSL→Windows 的 127.0.0.1（TCP/UDP）照常能通。Docker 的 6 个容器保持 Up，端口有响应。
- git 前缀已在 4 个账号的配置里确认存在。
- **未验证**（用户决定暂停）：卸载 rosdepc 后原生 `rosdep resolve` 能否用、经代理的实际 git 拉取、ROS 2 listener 能否收到消息。

## 对 .cs/ 的影响

- 已同步 project spec：`.cs/spec/index.md`（能力地图、使用路径、当前状态加上 WSL ROS 环境，并注明 WSL 不一定是长期基座）。
- 已更正的错误说法：
  - 22.04 的默认用户是 ucy，不是 root。
  - `heading` 字段没有改名，px4_msgs 72fcfaa 里仍然存在。
  - Clash 默认不开，7890 端口没有服务，不要写进代理配置。
  - "改绑 0.0.0.0 就能回环"不成立。
  - rosdepc 已停用，改用 USTC 镜像。

## 顺手发现（可选）

- 20.04 里 ucy 的 `.bashrc` 没有设置 `ROS_IP/ROS_HOSTNAME/ROS_MASTER_URI`。在 virtioproxy 模式下用 ucy 跑 ROS1 会连不上。本次没有处理。
- Micro-XRCE-DDS-Agent 的源码在 `/tmp` 下，可能被清掉。装的是 v2.4.2，官方文档主推 v2.4.3。
- `references/MASC-2026-bonus-homework` 是以 gitlink 形式提交的，没有 `.gitmodules` 条目。
