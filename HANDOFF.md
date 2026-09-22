# HANDOFF — PX4 SITL 恢复与组会 PPT 重排（260922 → 260929）

写给一个没有上文的新会话。客观记录，无主观建议。

## 这个任务在做什么

- 工作区：`U:\ucy\Code\active\PX4`（Windows 11 + WSL2 `Ubuntu-20.04`，WSL 里默认用户是 **root**）。
- 来源计划：`.cursor/plans/presentation_+1_周：恢复_sitl_并重排计划（260922_→_260929）_ae3f360f.plan.md`。
- 目标：走路径 B，解冻 `presentation/01-execution-plan.md` 的"一小时门控"，把 `.cs/issues/004-o-检索PX4仿真SITL路径.md` 从 open 推进到确定结论（能跑则拿连接-起飞-悬停-降落闭环证据；不能跑则拿受阻证据并按 epic 预案改用官方截图）。新截止日 260929。
- 计划分五段：文档解冻 → 环境准备 → go/no-go 采证门 → 改稿联动 → 试讲缓冲。

## 边界（已确认的一处放宽）

- 原冻结边界"不联网、不装系统包"只对一小时门控服务。恢复 SITL 放宽为：**环境搭建允许联网**（拉子模块、apt 装依赖、拉镜像）。
- **不变**：PPT 内容仍只用本地 `references/` 官方资料与本次本机实测，不联网补素材；`.cs/` 不进 PPT 引用；官方截图仍标"非本项目实测"；成功才写成功、受阻写受阻。

## 已完成（实测结果，非推断）

### 环境探测
- WSL2 `Ubuntu-20.04.6 LTS`，内核 `6.6.87.2-microsoft-standard-WSL2`；`DISPLAY=:0`、`WAYLAND_DISPLAY=wayland-0` 存在（WSLg）。
- WSL 默认发行版可 `sudo -n` 免密，用户为 `root`；`nproc=16`、内存 15Gi。
- `/mnt/u` 已挂载 U: 盘（`U:` 是 fixed drive，非网络盘）。
- 网络：`github.com:443` 可 TCP 连通但 `curl -sI` 与 `git ls-remote` 直连**超时/无响应**；`git clone --depth 1 https://ghfast.top/https://github.com/...` **能成功**（已在 `Tools/jMAVSim`、`sitl_gazebo`、`mavlink` 等 8 个子模块验证）。→ 子模块走 ghfast.top 镜像可行。
- Docker Desktop 在 Windows 侧运行（`docker.exe version` Server 29.6.1），但 **WSL 内 `docker` 连不到 daemon**（无 `/var/run/docker.sock`），且本地无 PX4/Gazebo 镜像。WSL 原生路线是当前已铺好的路；容器是备选未用。
- `U:\expro\QGroundControl\bin\QGroundControl.exe`（v5.0.3）存在，尚未做 WSL↔Windows QGC 的 UDP 连通测试。

### 已落地的环境与源码
- 在 `references/PX4-Autopilot` 用 `git worktree add .cs/env/px4-sitl-v1.13.3 v1.13.3` 检出独立目录（不动当前 v1.18 main checkout）。
- 该 worktree 的 `.git` 指针文件已被改写为 WSL 路径 `/mnt/u/.../.git/worktrees/px4-sitl-v1.13.3`，WSL 内 `git rev-parse HEAD` = `1c8ab2a0d7...`（v1.13.3）。
- `.gitmodules` 全部 19 个 url 已改写为 `https://ghfast.top/https://github.com/...`（写入 worktree 本地 `.gitmodules`，用 `git config -f` 改的，未提交）。
- 已初始化 **11 个子模块**：`src/modules/mavlink/mavlink`（含嵌套 `pymavlink`）、`src/drivers/gps/devices`、`src/lib/crypto/{monocypher,libtomcrypt,libtommath}`、`src/lib/events/libevents`、`Tools/sitl_gazebo`、`Tools/jMAVSim`，以及 configure 期硬校验的三个 ExternalProject 桥 `Tools/{flightgear_bridge,jsbsim_bridge,simulation-ignition}`。均 checkout 到正确 SHA。
- WSL 里已 `apt` 装好：build-essential、cmake 3.16.3、ninja 1.10、gcc/g++ 9.4、python3.8 + `Tools/setup/requirements.txt`、openjdk-13 + ant + libvecmath-java、**gazebo11 + libgazebo11-dev 11.15.1** 及 gstreamer/opencv/protobuf 等仿真依赖。未装 NuttX 交叉工具链（SITL 不需要）。
- **python 关键修正**：`empy` 已降到 **`3.3.4`**（`import em` → `RAW_OPT: True`）。requirements.txt 写的 `empy>=3.3` 会让 pip 拿 4.x，而 4.x 删了 `RAW_OPT` → mavlink 代码生成炸 `AttributeError`。必须钉 3.3.x。

### 编译产物（已实测成功）
- 源码副本：`/root/px4-sitl-src`（从 `/mnt/u` worktree rsync 到原生 ext4，避开 9P 慢）。
- 二进制：`/root/px4-sitl-src/build/px4_sitl_default/bin/px4`（47MB，`[837/837]` 0 错误）。
- 构建脚本：`/root/px4-build/{build_sitl.sh,rebuild.sh,rebuild2.sh}`（WSL 原生路径，已修好变量）。后台用 `setsid bash <script> > run.log 2>&1 < /dev/null &`。

## 当前状态（go/no-go 已过 = GO）

- **SITL 已跑通**：v1.13.3 + Gazebo Classic 11.15.1 在 WSL 原生跑通完整闭环 `commander takeoff` → `Landing detected` → `Disarmed by landing`。
- **证据已落地** `.cs/evidence/sitl/`：`flight_loop_12_09_45.ulg`（44MB）、`flight_loop_12_13_56.ulg`（10MB）、`sitl_console.log`、`gazebo_hover.png`。
- **notes/004 已产出**，issue 004 已标 `done`。
- 仿真当前仍在后台运行（gzserver/gzclient/px4 活着）。

## 剩余工作（改稿联动 + 试讲，plan.md 阶段三/四）

1. `presentation/03-simulation-assessment.md`：追加"重新评估"小节（本周动作、决策点、最终结论=能跑、复核命令）。
2. `presentation/01-execution-plan.md`：步骤3 解冻为分阶段搭建+采证；执行结果区填本周实际结果；交付边界补"环境联网"例外。
3. `presentation/02-evidence-and-assets.md`：M1 扩为"预检+仿真结果"证据，引用 `.cs/evidence/sitl/` 的截图/ULog。
4. `presentation/04-final-slide-outline.md`：第10页按真实结果重写（跑通线），联动第2/9/13/14页、重分 670 秒。
5. 试讲计时校验（issue 006）。

## 关键技术细节（新踩坑，HANDOFF 旧记录之外）

- **`make` stdin 不能是 `/dev/null`**：pxh 读 EOF 会 `Exiting NOW` 自杀。解法：建 FIFO `/root/px4-build/pxh_in`，用 `setsid bash -c "exec sleep infinity > pxh_in"` 顶住写端，`make px4_sitl gazebo < pxh_in` 启动；注入命令 `printf "commander takeoff\n" > pxh_in`。
- **起飞即 failsafe `no RC and no datalink`**：无遥控器/地面站的预期行为，会强制 RTL。解法：`param set NAV_DLL_ACT 0; NAV_RCL_ACT 0; COM_LOW_BAT_ACT 0; COM_RCL_EXCEPT 4` 后即可正常起飞降落。
- **WSL PATH 污染**：`/mnt/u/expro/anaconda3/.../protobuf-config.cmake` 被 cmake 优先捡到 → sitl_gazebo configure 报 protobuf 目标未定义。解法：`env PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" make …`。
- **run_gazebo2.sh**（`/root/px4-build/`）已封装上述环境变量+FIFO stdin，是当前正确的启动器。
- **截图法**：Windows 侧 PowerShell `CopyFromScreen` 抓全屏（Gazebo 窗口标题 `Gazebo (Ubuntu-20.04)` 经 msrdc/WSLg 呈现）。

## 踩过的坑（不要再踩）

- **写脚本到 `/mnt/u` 会被外层 `bash -lc` 吞变量**：用 `wsl bash -lc 'cat > /mnt/u/x.sh << EOF $VAR ...'` 写文件时 `$VAR` 在外层就被展开成空。**最稳写法**：`wsl.exe -d Ubuntu-20.04 -- python3 - <<'PYEOF' ... PYEOF`（python 从 stdin 读，零 quoting 干扰），或 `base64 -d > file << "EOF"`。已验证 python-stdin 法 100% 可靠。
- **`nohup ... &` / `& disown` 在 `wsl.exe bash -lc` 里会被杀**：bash -lc 会话退出给子进程发 SIGTERM/SIGHUP，连 nohup 都挡不住（rsync 收到 `SIGINT,SIGTERM,SIGHUP code 20`）。**唯一可靠后台法**：`setsid bash script.sh > log 2>&1 < /dev/null &`（新 session 脱离信号组）。
- **rsync worktree 到原生路径后，子模块 `.git` 是失效的相对指针**：`.git` 文件里 `gitdir: ../../../../../../../.git/worktrees/...` 相对路径离开原 worktree 布局后解析不到 → `px_update_git_header.py` 里 `git rev-parse --verify HEAD` 返回 128 → ninja 编译中断。**修法**：对每个子模块 `git -C <REAL_WT>/<sub> rev-parse --absolute-git-dir` 拿真身（在 `/mnt/u/.../.git/worktrees/px4-sitl-v1.13.3/modules/<sub>`），把绝对路径写回 `/root/px4-sitl-src/<sub>/.git`。12 个全部修好，`rev-parse` 通过。
- **cmake configure 硬校验所有 ExternalProject 源目录非空**：`platforms/posix/cmake/sitl_target.cmake` 对 `sitl_gazebo`、`simulation-ignition`、`flightgear_bridge`、`jsbsim_bridge`、`mavsdk_tests` 都 `ExternalProject_Add`；空目录且 GIT_SUBMODULES_ARE_EVIL=1 不自动拉 → configure 直接 `Configuring incomplete`。必须把 5 个目录全部填上内容（`mavsdk_tests` 不是子模块，源码自带）。
- **mavlink 子模块还有嵌套子模块 `pymavlink`**：`src/modules/mavlink/mavlink/pymavlink` 独立子模块（url 裸 github），`--depth 1` clone mavlink 不带它 → ninja 缺 `mavgen.py`。要在 mavlink 目录里单独 `git config submodule.pymavlink.url <ghfast>` + `submodule update --init pymavlink`。
- **`empy` 必须钉 `3.3.4`**：`empy>=3.3` 让 pip 装到 4.2.1，而 4.x 删了 `em.RAW_OPT` → mavlink 代码生成 `AttributeError: module 'em' has no attribute 'RAW_OPT'`。`pip3 install empy==3.3.4` 后 `hasattr(em,'RAW_OPT')==True`。
- **Windows `git worktree` 的 `.git` 指针是 `U:/` 盘符路径**，WSL 里不认 → 需把 worktree 的 `.git` 文件改成 `/mnt/u/...`；同时 `references/PX4-Autopilot/.git/worktrees/<name>/gitdir` 是 Windows 路径，改成 `U:/...` 反指回 worktree 后 Windows 侧 `git worktree list` 才能认。
- **`git submodule status` 在 `/mnt/u` 上扫 5000+ 文件很慢**（会挂住几十秒），别在循环里跑；按需用 `ls <sub>/.git` 或看 `git config -f .gitmodules` 判断。
- **`empy` 4.x 提供的模块名是 `em`**，不是 `empy`；`pip install empy` 后 `import em` 即可，别误判缺包。
- **`pip install -r requirements.txt` 偶发单包失败**（`lxml` 第一次拉不到版本），重试单独装即可，不是真缺。
- **`Read` 工具读到的 PX4 文档是 main（v1.18）的**，不是 v1.13.3；v1.13.3 里 `git ls-tree v1.13.3 docs` 无输出（docs 未随源码 tag 走）。引用版本号/board 名/参数名以 v1.13.3 历史源码为准。
- **`px4_add_git_submodule` → `Tools/check_submodules.sh`**：未设 `CI`/`GIT_SUBMODULES_ARE_EVIL` 时会交互式 `read` 卡住等非交互构建；编译前 `export GIT_SUBMODULES_ARE_EVIL=1`（子模块已同步）可跳过提示。
- **v1.13.3 的 `make px4_sitl gazebo` 目标链**：`px4_sitl_default` 只编二进制；`px4_sitl_default gazebo` 才拉 `sitl_gazebo` 子模块并启动。viewer 目标名在 `platforms/posix/cmake/sitl_target.cmake`（gazebo/jmavsim/ignition/flightgear/jsbsim × model × world）。

## 关键文件落点

- 计划：`.cursor/plans/..._ae3f360f.plan.md`（含 mermaid 排期、五阶段、go/no-go 定义）
- issue：`.cs/issues/004-o-检索PX4仿真SITL路径.md`（**已 done**，结论"能跑"）
- notes：`.cs/notes/004-PX4仿真SITL路径.md`（**已产出**：仿真器+启动命令+QGC 连法+录制方法+坑位）
- epic：`.cs/epics/001-o-组会PPT与PX4资料搜集/spec.md`（issue 004 已勾，"剩余阻碍"已解除）
- **证据**：`.cs/evidence/sitl/` —— `flight_loop_12_09_45.ulg`(44MB)、`flight_loop_12_13_56.ulg`(10MB)、`sitl_console.log`、`gazebo_hover.png`
- 执行稿（**均已按跑通结果改好**）：`presentation/01-execution-plan.md`（步骤3 已填 go 结果+联网例外）、`03-simulation-assessment.md`（已追加"重新评估"小节）、`02-evidence-and-assets.md`（M1 扩为预检+M1b 仿真结果）、`04-final-slide-outline.md`（第10页已按跑通重写，联动第2/9/13/14页与附录约束）
- 源 worktree：`references/PX4-Autopilot/.cs/env/px4-sitl-v1.13.3`（v1.13.3，子模块已 init 含递归）
- 编译副本+产物：WSL `/root/px4-sitl-src`（二进制 `build/px4_sitl_default/bin/px4`）；启动器 `/root/px4-build/run_gazebo2.sh`（干净 PATH+FIFO stdin）；pxh 命令注入 FIFO `/root/px4-build/pxh_in`；日志 `/root/px4-build/gazebo.log`
- 已污染弃用的旧脚本（信息仅作历史，勿直接跑）：`.cs/env/setup_submodules.sh`、`.cs/env/install_deps.sh`、`.cs/env/build_sitl.sh`、`.cs/env/wsl/build_sitl.sh`
