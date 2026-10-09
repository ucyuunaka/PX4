# AGENTS.md — 给接手本仓库的 AI 的启动短规则

## 先读什么

- 项目当前真相：`.cs/spec/index.md`（最高权重）；交接流水：`HANDOFF.md`（与 `.cs/` 冲突时以 `.cs/` 为准）。
- 本仓库用 CodeStable 管理制度记忆（`.cs/`：spec / epics / issues / notes / talks）。踩坑先查 `.cs/notes/`，历史取舍先查 `.cs/issues/`。
- 仿真演示：`demos/README.md`（白话）+ `.cs/epics/002-o-仿真演示与一键脚本/spec.md`（约定）。

## 用户偏好

- 用户技术背景有限：对用户说话用白话、先结论后细节；未实测的结论必须标"未实测"，不把推测当事实。
- 版本事实以 PX4 **v1.13.3** 与本机实测为准；第三方资料只作参考，事实回官方文档/源码核对。

## 硬规则（踩过的坑）

- **不要 `wsl --shutdown` / `wsl --terminate`**：会同时停掉用户 Docker Desktop 里的容器。
- **不要停止或禁用 Windows 防火墙服务 `mpssvc`**：WSL 建 NAT 网络依赖它（2026-10-09 的根因，见 issue 007-x）。用户选择关闭防火墙"配置文件"，服务保持运行。
- 不写任何指向 `127.0.0.1:7890` 的代理配置，不依赖 Clash；下载走国内镜像与 `gh-proxy.com`（note 005）。
- 从 Git Bash 调 `wsl.exe` 时设 `MSYS2_ARG_CONV_EXCL='*'`；经 `wsl.exe bash -c` 传的 `$VAR`/循环变量会被吞——逻辑写进仓库内 `.sh` 文件再调用。
- 演示脚本的清理只杀演示相关进程，**不关用户的 QGC**。
- `references/` 只读；不提交 `demos/logs/`。
- 不自动 commit / push；关闭 issue、关闭 epic 需用户授权。
