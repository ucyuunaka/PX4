---
kind: issue
title: "修复 WSL 的 Windows 层网络（virtioproxy → NAT）"
type: chore
status: closed
created: 2026-09-30
closed: 2026-10-09
epic: ""
---

# 修复 WSL 的 Windows 层网络（virtioproxy → NAT）

> **已解决（2026-10-09）**：根因是 Windows 防火墙服务 `mpssvc` 被禁用，HNS 建不了 NAT 网络。恢复服务 + 关闭防火墙配置文件后 WSL 已回到 `nat` 模式。过程见文末「关闭结论」；下方操作指引保留作历史。

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

2026-10-09 修复完成，`wslinfo --networking-mode` 两个发行版均输出 `nat`。

**根因**：Windows Defender Firewall 服务 `mpssvc` 早前被用户按网上教程禁用（注册表 `Start=4`）。HNS 创建 WSL 的 ICS/NAT 网络时要靠它加防火墙规则；服务一停，`HNS-Network-Create 网络类型='ICS'` 返回 `0x800706D9`，WSL 每次启动都回退到 virtioproxy（至少自 2026-09-27）。先前报的"不支持镜像网络模式"很可能同一根因（mirrored 需要 Hyper-V 防火墙）——未实测，按大概率记。

**试了但无效**（均在上面「操作指引」内）：step 1 把 ucy 加入 Hyper-V Administrators（SID `S-1-5-32-578`）并重启；step 2 `Restart-Service hns`；step 3 `wsl --update`（下载被 403 拦，`Wsl/UpdatePackage/0x80190193`，WSL 已是 2.6.3）+ `wsl --install --no-distribution` + 重启。之后仍是 virtioproxy。

**起效的修法**：`Set-Service`/`sc config` 改 mpssvc 被拒（服务 DACL 不给管理员组改配置，属正常保护），管理员改用 `reg add "HKLM\SYSTEM\CurrentControlSet\Services\mpssvc" /v Start /t REG_DWORD /d 2 /f` 恢复为自动启动 → 重启 → mpssvc Running → `Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False`（用户选择继续不要防火墙过滤；这是微软文档里关防火墙的正确姿势：关配置文件、保留服务运行，参考 configure-with-command-line 文档；microsoft/WSL#10709 也报告禁用防火墙会触发此问题）→ `wsl --shutdown` → 回 `nat`。

**验证结果**：两个发行版 `nat`；Windows 出现 `vEthernet (WSL (Hyper-V firewall))` 172.29.160.1/20；WSL eth0 172.29.171.4/20，默认网关 172.29.160.1（与 HKCU Lxss `NatIpAddress` 一致）；两发行版 UDP 127.0.0.1:45999 回环测试打印 `(b'ok', ...)`，TCP 临时端口回环也通；`ip rule` 只剩默认 3 条（`wsl-loopback-fix.sh` 在 NAT 下自动空转，已验证，保留安装）；腾讯镜像与 gh-proxy.com 均 HTTP 200；resolv.conf 仍是 223.5.5.5 / 119.29.29.29。NAT 下 SITL 复验通过（见 ff 009）。Docker Desktop 恢复情况**未验证**（用户稍后自行重开）。

**以后别再踩**：不要停止/禁用 `mpssvc`；要关防火墙就关配置文件（`Set-NetFirewallProfile ... -Enabled False`），服务必须保持运行。
