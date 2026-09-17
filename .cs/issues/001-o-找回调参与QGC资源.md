---
kind: issue
title: "找回调参与 QGC 资源"
type: chore
status: open
created: 2026-09-16
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

## 验证

- 确认 QGC 可正常安装、能刷写目标固件
- notes 中的失效标记更新为实际可用来源（或删除）
