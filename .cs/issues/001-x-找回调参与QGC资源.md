---
kind: issue
title: "找回调参与 QGC 资源"
type: chore
status: closed
created: 2026-09-16
closed: 2026-09-17
epic: ""
---

# 找回调参与 QGC 资源

## 目标

重新获取两份已失效的网盘资源内容：PIX 飞控调参软件和固件、QGC 软件和常见固件。完成后 `.cs/notes/001-入门资源索引.md` 中的"已失效资源"小节可以更新或移除。

## 范围

- 包含：找回上述两类资源并更新 notes
- 不包含：PX4 源码、非装机入门所需的其他工具

## 背景与证据

- 原百度网盘链接均标记为已失效（来源：早期整理的入口资料）
- PIX 调参软件和固件：https://pan.baidu.com/s/16-YiB6Wl26MSSgpjUUr8cQ?pwd=elqc （提取码 elqc，已失效）
- QGC 软件和常见固件：https://pan.baidu.com/s/1xQSoUJ6cgez6AL0gq8Yddw?pwd=ek31 （提取码 ek31，已失效）

## 方案判断

- **优先官方渠道**：QGC 官网/GitHub releases 提供软件下载；PX4 固件由 QGC 在线刷写，通常不需要网盘镜像。
- PIX 调参相关资源可先对照 B 站教程（见 `.cs/notes/001-入门资源索引.md`）确认具体需要什么软件/固件，再决定是官方下载还是重新找网盘。
- 若官方渠道覆盖全部需求，本 issue 直接关闭并清理 notes 中的失效小节。

## 关闭结论

**官方渠道完整覆盖两个网盘包的内容，无需找回网盘镜像。** 证据来自两个官方仓库的源码核查：

| 网盘内容 | 官方等价物 |
|---|---|
| QGC 软件 | 官网 `qgroundcontrol.com` + GitHub releases；`references/qgroundcontrol` 内置 `download_and_install.md` 含 Windows/macOS/Linux/Android 直链（CloudFront 托管） |
| 常见固件 | QGC 在线刷写：`FirmwareUpgradeController.cc` 显示 QGC 连接 bootloader 读出 board ID，经 `px4_board_name_map`（约 60 板型映射，源自 PX4-Bootloader `board_types.txt`）映射后从 `px4-travis.s3.amazonaws.com/Firmware/{stable|beta|master}/` 下载；PIX 2.4.8 克隆板对应 board ID 9 → `px4_fmu-v2_default` |
| PIX 调参软件 | 即 QGC 本身；`references/qgroundcontrol/docs/{en,zh}/qgc-user-guide/setup_view/tuning_px4.md` 及配套设置文档全套覆盖 |

**验证**：QGC 已安装于 `U:\expro\QGroundControl\bin\QGroundControl.exe`（v5.0.3-1388 master 构建，`--version` 确认可运行）；PX4 官方文档 `firmware.md` 与 QGC 源码一致；QGC 用户指南在本仓 `references/qgroundcontrol/docs/` 有中英双语源码。

**回写**：`.cs/notes/001-入门资源索引.md` 已更新（失效小节替换为官方渠道说明）；`.cs/notes/002-PX4本地文档查阅.md` 补充 QGC 仓库同样自带完整文档；`.cs/spec/index.md` 已更新当前状态与证据索引。

**遗留**：网盘包中可能另有教程方自制的小工具/参数文件，在官方生态中无对应物，但非必需——调参由 QGC autotune + 手动 UI 覆盖。无待跟进事项。
