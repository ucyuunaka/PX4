#!/bin/bash
# demos/ 共用函数库：每个演示的 run.sh 与 stop.sh 都 source 本文件。
# 约定见 .cs/epics/002-o-仿真演示与一键脚本/spec.md；坑位见 .cs/notes/004 §八。

DEMO_DIR="/mnt/u/ucy/Code/active/PX4/demos"
PX4_SRC="/root/px4-sitl-src"
PX4_BIN="$PX4_SRC/build/px4_sitl_default/bin/px4"
RUN_DIR="/tmp/px4demo"
FIFO="$RUN_DIR/pxh_in"
PIDFILE="$RUN_DIR/pids"
LOG_DIR="$DEMO_DIR/logs"
DEMO_LOG=""

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export GIT_SUBMODULES_ARE_EVIL=1
export DISPLAY=:0
export WAYLAND_DISPLAY=wayland-0
# virtioproxy 回退期（2026-09-27~10-09）必须绕到 eth0 IP；NAT 下无害，保留以防网络回退
_ip=$(hostname -I | awk '{print $1}')
export GAZEBO_IP=$_ip
export PX4_SIM_HOST_ADDR=$_ip

say() { printf '%s\n' "$*"; }

# 失败提示：一句白话原因 + 固定建议 + 日志位置
say_err() {
  say "出问题了：$1"
  say "请双击「停止全部.bat」后再试一次。"
  [ -n "$2" ] && say "详细日志：$2"
}

# 往 pxh 控制台写一条命令。无读端时最多等 2 秒就放弃，不卡死。
pxh() {
  [ -p "$FIFO" ] || return 1
  pgrep -f "$PX4_BIN" >/dev/null 2>&1 || return 1
  ( printf '%s\n' "$*" > "$FIFO" ) &
  local wp=$! i=0
  while kill -0 "$wp" 2>/dev/null && [ "$i" -lt 20 ]; do sleep 0.1; i=$((i+1)); done
  kill "$wp" 2>/dev/null
  wait "$wp" 2>/dev/null
  sleep 0.4
}

# 盯日志（先剥掉 ANSI 颜色码）直到命中正则或超时返回非零。
wait_for() {
  local pat="$1" timeout="${2:-60}" i=0 max
  max=$(( timeout * 10 ))
  while [ "$i" -lt "$max" ]; do
    if [ -f "$DEMO_LOG" ] && sed 's/\x1b\[[0-9;]*[A-Za-z]//g' "$DEMO_LOG" | grep -qE "$pat"; then
      return 0
    fi
    sleep 0.1; i=$((i+1))
  done
  return 1
}

# 关掉"无遥控器/无地面站"的 failsafe 强制动作，否则会 RTL。
set_failsafe_params() {
  pxh 'param set NAV_DLL_ACT 0'
  pxh 'param set NAV_RCL_ACT 0'
  pxh 'param set COM_LOW_BAT_ACT 0'
  pxh 'param set COM_RCL_EXCEPT 4'
}

# 启动 SITL：FIFO 顶住 pxh 的 stdin（否则它读到 EOF 会自杀），后台 setsid 脱离会话。
# 用法：sitl_start <日志名前缀>
sitl_start() {
  local name="$1" ts
  ts=$(date +%Y%m%d-%H%M%S)
  mkdir -p "$RUN_DIR" "$LOG_DIR"
  rm -f "$FIFO" "$PIDFILE"
  mkfifo "$FIFO"
  setsid bash -c "exec sleep infinity > '$FIFO'" &
  echo "$!" >> "$PIDFILE"
  DEMO_LOG="$LOG_DIR/${name}-${ts}.log"
  cd "$PX4_SRC" || return 1
  setsid env PATH="$PATH" GIT_SUBMODULES_ARE_EVIL=1 DISPLAY="$DISPLAY" \
    WAYLAND_DISPLAY="$WAYLAND_DISPLAY" GAZEBO_IP="$GAZEBO_IP" \
    PX4_SIM_HOST_ADDR="$PX4_SIM_HOST_ADDR" \
    make px4_sitl gazebo < "$FIFO" > "$DEMO_LOG" 2>&1 &
  echo "$!" >> "$PIDFILE"
  say "日志文件：$DEMO_LOG"
}

# 给 PX4 加一条发往 Windows 地面站的 GCS 链路。
# NAT 下必须指向默认网关 IP（=Windows 侧 vEthernet）：发 127.0.0.1 会留在 WSL 内部到不了 Windows。
# -m 不能显式传 normal（是缺省值，传了报 invalid mode）。穿刺证据见 issue 011。
gcs_link_to_windows() {
  local gw
  gw=$(ip route | awk '/default/{print $3; exit}')
  if [ -z "$gw" ]; then
    say_err "没取到默认网关 IP，地面站连不上"
    return 1
  fi
  say "正在给地面站加一条连接：飞机 → Windows（$gw:14550）…"
  pxh "mavlink start -u 14557 -r 4000000 -t $gw -o 14550"
}

# 清理演示进程：先礼貌让 pxh 自己退（最多等 10 秒），再精确杀残留。
# 所有匹配模式都不会匹配本脚本自身（pkill -f 的模式串不出现在 run.sh/stop.sh 的命令行里）。
demo_cleanup() {
  if pgrep -f "$PX4_BIN" >/dev/null 2>&1; then
    ( printf 'shutdown\n' > "$FIFO" ) &
    local wp=$! i=0
    while kill -0 "$wp" 2>/dev/null && [ "$i" -lt 30 ]; do sleep 0.1; i=$((i+1)); done
    kill "$wp" 2>/dev/null; wait "$wp" 2>/dev/null
    i=0
    while pgrep -f "$PX4_BIN" >/dev/null 2>&1 && [ "$i" -lt 100 ]; do sleep 0.1; i=$((i+1)); done
  fi
  pkill -f "$PX4_BIN" 2>/dev/null
  pkill -f 'sitl_run.sh' 2>/dev/null
  pkill -f 'px4_sitl gazebo' 2>/dev/null
  pkill -x gzserver 2>/dev/null
  pkill -x gzclient 2>/dev/null
  if [ -f "$PIDFILE" ]; then
    while read -r p; do kill "$p" 2>/dev/null; done < "$PIDFILE"
    rm -f "$PIDFILE"
  fi
  rm -f "$FIFO"
}
