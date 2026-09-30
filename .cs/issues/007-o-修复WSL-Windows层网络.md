---
kind: issue
title: "修复 WSL 的 Windows 层网络（virtioproxy → NAT）"
type: chore
status: open
created: 2026-09-30
epic: ""
---

# 修复 WSL 的 Windows 层网络（virtioproxy → NAT）

> **待用户执行**：需要管理员权限，可能要重启电脑，AI 无法代做。做完后让 AI 按文末「完成后交给 AI 的事」整理文档并关闭本 issue。
> 如果决定改用原生 Ubuntu、不再以 WSL 为基座，本 issue 可直接以"不再需要"关闭。

## 目标

`wslinfo --networking-mode` 输出 `nat`（或按需配的 `mirrored`），WSL 内部走 127.0.0.1 的 TCP/UDP 恢复正常，不再依赖 `wsl-loopback-fix.sh` 的端口白名单。

## 背景与证据

- 现状与影响见 `.cs/notes/005-WSL-ROS环境.md`「网络」。
- Windows 事件日志（事件查看器 → Windows 日志 → 应用程序，来源 `WSL`）：至少从 2026-09-27 起每次启动都报"无法配置网络 (networkingMode Nat)，回退到 networkingMode VirtioProxy"；试镜像模式则报"不支持镜像网络模式：Windows 版本 26100.7840 没有所需的功能"。
- 系统日志里 Hyper-V-VmSwitch 显示 `WSL` 交换机能创建成功，几秒后又被删除，说明问题出在 HNS/NAT 配置阶段，不是功能没装：虚拟机平台、Hyper-V 全套、WSL 功能都是"已启用"，`hns` 服务在运行，`WinNat` 处于停止状态。
- 2026-09-30 查询时 **Hyper-V Administrators 组（SID `S-1-5-32-578`）里没有成员**。ucy 在管理员组，但日常令牌受 UAC 限制。
- 参考：microsoft/WSL issue #12578 有人把账号加入 Hyper-V Administrators 后恢复；#12297 有人靠 `wsl --install --no-distribution` 或网络重置恢复；#13793 未解决。**这几种办法都不保证有效**，所以按下面的顺序从轻到重试，每步后先检查，恢复了就停。

## 操作指引

### 0. 准备（每一步前都要做）

1. 退出 Docker Desktop：托盘图标右键 → Quit Docker Desktop。它的 6 个容器会停，之后重新打开 Docker Desktop 会自动恢复。
2. 用**普通** PowerShell 记下当前状态：
   ```powershell
   wsl --shutdown
   wsl -d Ubuntu-22.04 -- wslinfo --networking-mode     # 现在是 virtioproxy
   ```

"检查"指的就是再跑一遍上面两行，看输出是否变成 `nat`。

### 1. 把 ucy 加入 Hyper-V Administrators（最轻，先试）

以管理员身份打开 PowerShell（Win+X → 终端(管理员)）：

```powershell
Add-LocalGroupMember -SID S-1-5-32-578 -Member "$env:COMPUTERNAME\ucy"
Get-LocalGroupMember -SID S-1-5-32-578      # 应列出 ...\ucy
```

- 这里用 SID 而不是组名，因为中文系统的组名可能被本地化，写英文组名会找不到。
- 组成员变化要重新登录才生效，建议**直接重启电脑**，然后做一次「检查」。

### 2. 重启 HNS 服务

在管理员 PowerShell 里执行（先确认 Docker Desktop 已退出）：

```powershell
wsl --shutdown
Restart-Service hns -Force
```

然后做一次「检查」。

### 3. 修复 WSL 组件

在管理员 PowerShell 里执行：

```powershell
wsl --shutdown
wsl --update
wsl --install --no-distribution
```

这两条命令都**不会**删除或重装现有发行版。然后重启电脑，再做一次「检查」。

### 4. 重操作（前三步都无效时再考虑）

下面两个任选其一：

- **网络重置**：设置 → 网络和 Internet → 高级网络设置 → 网络重置 → 重启。它会重置所有网卡，VMware 的 VMnet1/VMnet8、Tailscale 可能要修复或重新登录，WiFi 可能要重新输入密码。
- **重装虚拟机平台**：控制面板 →「启用或关闭 Windows 功能」→ 取消勾选"虚拟机平台" → 重启 → 重新勾选 → 再重启。发行版的 VHDX 在 `U:\WSL\` 下，不会丢失。

**不要**执行 `wsl --unregister`，它会删除发行版及里面的全部数据。

## 验证（全部满足才算修好）

1. `wsl -d Ubuntu-22.04 -- wslinfo --networking-mode` 输出 `nat`。
2. Windows 上能看到 WSL 的虚拟网卡：
   ```powershell
   Get-NetAdapter | Where-Object Name -like 'vEthernet*'
   ```
3. 在 WSL 里测 UDP 回环。用的 45999 端口不在补丁白名单里，所以能收到就说明是真修好了，不是补丁在起作用：
   ```bash
   python3 -c "import socket;u=socket.socket(2,2);u.bind(('127.0.0.1',45999));u.settimeout(3);socket.socket(2,2).sendto(b'ok',('127.0.0.1',45999));print(u.recvfrom(9))"
   ```
   打印出 `(b'ok', ...)` 为通过；报 `timed out` 为没修好。
4. 重新打开 Docker Desktop，容器都恢复 Up。

## 完成后交给 AI 的事

把"做了哪一步起效"告诉 AI，让它：

- 更新 note 005 的「网络」一节：写明新模式、起效的步骤，删掉或标注已过时的 virtioproxy 矩阵。
- 处理 `wsl-loopback-fix.sh`：没有 `lookup 127` 规则时脚本本来就不做任何事，可以保留；要删就去掉两个发行版 `/etc/wsl.conf` 里的 `[boot]` 段。
- 核对 NAT 下的新差异：WSL 连 Windows 不能再用 127.0.0.1，要用宿主 IP（`ip route` 的默认网关）。受影响的有 note 004「QGC 连通」和 PX4 → Windows QGC 的目标地址。20.04 root 的 `ROS_IP=eth0 IP` 在 NAT 下仍然可用，可以保留。
- 关闭本 issue：改名为 `007-x-…`，`status: closed`。

## 关闭结论

（待填）
