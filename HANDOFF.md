# HANDOFF — 组会-1 已圆满完成（2026-09-29），项目处于组会间期

写给一个没有上文的新会话。客观记录。最后更新 2026-09-29。

## 当前状态

- 工作区：`U:\ucy\Code\active\PX4`（Windows 11 + WSL2 `Ubuntu-20.04`，WSL 里默认用户是 **root**）。
- **第一次组会（2026-09-29）已讲完**：题目《基于 PX4 的 F450 四旋翼平台：前期调研、单机调试路线与多机扩展规划》，成品 `presentation/组会-1/组会-1.pptx`。
- 组会工作线已全部关闭：epic `.cs/epics/001-x-组会PPT与PX4资料搜集/`（closed，毕业回写已做）与 issue 001–006（全部 `-x-`）。当前**没有进行中的 issue/epic**。
- 下一阶段方向（均未立项，等用户发起）：实物 bring-up（装机/刷机/校准/首飞）；后续组会（按 `presentation/README.md` 的场次规范新建 `组会-2/`）；Vision 正式整理（多机协同构想输入已备妥，见 epic 001 关闭回写）。

## 工作区结构

- `presentation/`：组会汇报工作区，**按场次组织**（`组会-N/` 自包含：pptx、process/、assets/、research/、ori_ppt/、history/），规范与场次索引在 `presentation/README.md`。PPT 制作一律走 ppt-master 流程（`U:\ucy\Code\reference\ppt-master`）。
- `presentation/组会-1/process/04-final-slide-outline.md` 是组会-1 内容主稿（20 页）；`02-evidence-and-assets.md` 是证据索引；`../research/sources.md` 是外部素材核查表——后续 bring-up 与下场组会可复用。
- `.cs/`：CodeStable 制度记忆。`spec/index.md` 是项目当前真相；`notes/001–004` 是资源索引/文档查阅/仓库索引/SITL 复现路径；`inbox.md` 是草稿暂存区。
- SITL 证据：`presentation/组会-1/assets/sitl/`（截图、ULog、pyulog 曲线、控制台日志）。画 ULog 曲线：`references/pyulog` 未 pip 安装，用 `PYTHONPATH=references/pyulog` + Windows Anaconda（`/u/expro/anaconda3/python`）直接导入；ULog 时间戳 uint64，相减前先转 int64。
- SITL 已在本机跑通（v1.13.3 + Gazebo Classic 11.15.1，WSL2）；仿真进程目前未运行。

## 组会 PPT 的引用边界（后续场次沿用）

- PPT 不引用 `.cs/` 任何内容；其余来源（`references/`、云端 URL、本机实测）均可，须注明本地路径或 URL。
- 只保留三类硬标注：官方/外部素材标"官方示例/项目名"；本机仿真标"本机 SITL 实测，非实机"；版本事实如实讲。
- 版本基线：PX4 **v1.13.x**（2.4.8 克隆板 FMUv2 是官方 discontinued 极限板；换受支持板时再追新）。

## SITL 环境（2026-09-22 搭建，仍可用）

环境搭建时允许联网（拉子模块、apt、镜像）。以下为实测结果。复现路径的权威记录是 `.cs/notes/004-PX4仿真SITL路径.md`，本节是其环境细节备份。

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

### 启动与运行要点

- **`make` stdin 不能是 `/dev/null`**：pxh 读 EOF 会 `Exiting NOW` 自杀。解法：建 FIFO `/root/px4-build/pxh_in`，用 `setsid bash -c "exec sleep infinity > pxh_in"` 顶住写端，`make px4_sitl gazebo < pxh_in` 启动；注入命令 `printf "commander takeoff\n" > pxh_in`。
- **起飞即 failsafe `no RC and no datalink`**：无遥控器/地面站的预期行为，会强制 RTL。解法：`param set NAV_DLL_ACT 0; NAV_RCL_ACT 0; COM_LOW_BAT_ACT 0; COM_RCL_EXCEPT 4` 后即可正常起飞降落。
- **WSL PATH 污染**：`/mnt/u/expro/anaconda3/.../protobuf-config.cmake` 被 cmake 优先捡到 → sitl_gazebo configure 报 protobuf 目标未定义。解法：`env PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" make …`。
- **run_gazebo2.sh**（`/root/px4-build/`）已封装上述环境变量+FIFO stdin，是当前正确的启动器。
- **截图法**：Windows 侧 PowerShell `CopyFromScreen` 抓全屏（Gazebo 窗口标题 `Gazebo (Ubuntu-20.04)` 经 msrdc/WSLg 呈现）。

### 踩过的坑（不要再踩）

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

- 组会工作区入口 `presentation/README.md`；组会-1 过程文档入口 `presentation/组会-1/process/README.md`；内容主稿 `process/04-final-slide-outline.md`；证据索引 `process/02-evidence-and-assets.md`；素材 `组会-1/assets/`；调研 `组会-1/research/`；制作来源 `组会-1/ori_ppt/`
- 已关闭工作线：`.cs/epics/001-x-组会PPT与PX4资料搜集/spec.md`、`.cs/issues/001-x-…006-x-`
- SITL 复现：`.cs/notes/004-PX4仿真SITL路径.md`；证据 `presentation/组会-1/assets/sitl/`
- 源 worktree：`references/PX4-Autopilot/.cs/env/px4-sitl-v1.13.3`（v1.13.3，子模块已 init 含递归）
- 编译副本+产物：WSL `/root/px4-sitl-src`（二进制 `build/px4_sitl_default/bin/px4`）；启动器 `/root/px4-build/run_gazebo2.sh`（仓库副本 `.cs/env/run_gazebo.sh`）；pxh 命令注入 FIFO `/root/px4-build/pxh_in`；日志 `/root/px4-build/gazebo.log`
- `.cs/env/setup_submodules.sh`、`install_deps.sh` 是早期版本（缺 bridge 子模块、pymavlink、empy 钉版），脚本头已注明，勿直接照跑
- `.cursor/plans/..._ae3f360f.plan.md`：260922→260929 的 SITL 恢复计划，已执行完；其中 todo 状态未回填，只作历史
