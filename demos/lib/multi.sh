#!/bin/bash
# demos/ 多机库：多架 SITL 同飞。先 source lib/common.sh，再 source 本文件。
# 步骤按 /root/px4-sitl-src/Tools/gazebo_sitl_multiple_run.sh 自写（那脚本自带
# pkill -x px4 且前台阻塞，不直接调用）。
#
# 每架的后台 px4（daemon 模式，没有 pxh 控制台）：
#   build/px4_sitl_default/instance_N/ 里 ../bin/px4 -i N -d <etc> -w sitl_iris_N -s etc/init.d-posix/rcS
# 端口错开：模拟器 TCP 4560+N，PX4↔Gazebo mavlink_udp 14560+N，
# GCS 18570+N→14550，offboard/API 14580+N→14540+N，MAV_SYS_ID=N+1。

PX4_BUILD="$PX4_SRC/build/px4_sitl_default"
MULTI_TS=""
MULTI_PREFIX=""
MULTI_N=0

# 给第 N 架（0 起）下命令：px4-<module> --instance N <args>
px4i() {
  local n="$1" mod="$2"; shift 2
  "$PX4_BUILD/bin/px4-$mod" --instance "$n" "$@"
}

# multi_start <架数> <日志名前缀>：起 gzserver + N 个后台 px4 + 生成/投放模型 + gzclient。
multi_start() {
  local count="${1:-3}" prefix="${2:-C-多机}" ts n
  ts=$(date +%Y%m%d-%H%M%S)
  MULTI_TS="$ts"; MULTI_PREFIX="$prefix"; MULTI_N="$count"
  mkdir -p "$RUN_DIR" "$LOG_DIR"
  rm -f "$PIDFILE"
  export PX4_SIM_MODEL=iris
  # 告诉 gazebo 去哪找 sitl_gazebo 的插件与模型
  . "$PX4_SRC/Tools/setup_gazebo.bash" "$PX4_SRC" "$PX4_BUILD"
  setsid gzserver "$PX4_SRC/Tools/sitl_gazebo/worlds/empty.world" --verbose \
    > "$LOG_DIR/${prefix}-${ts}-gzserver.log" 2>&1 &
  echo "$!" >> "$PIDFILE"
  say "等待 Gazebo 世界起来…"
  sleep 5
  n=0
  while [ "$n" -lt "$count" ]; do
    local wd="$PX4_BUILD/instance_$n" plog="$LOG_DIR/${prefix}-${ts}-i${n}.log"
    mkdir -p "$wd"
    ( cd "$wd" && setsid "$PX4_BUILD/bin/px4" -i "$n" -d "$PX4_BUILD/etc" \
        -w "sitl_iris_$n" -s etc/init.d-posix/rcS >"$plog" 2>&1 ) &
    echo "$!" >> "$PIDFILE"
    python3 "$PX4_SRC/Tools/sitl_gazebo/scripts/jinja_gen.py" \
      "$PX4_SRC/Tools/sitl_gazebo/models/iris/iris.sdf.jinja" "$PX4_SRC/Tools/sitl_gazebo" \
      --mavlink_tcp_port $((4560+n)) --mavlink_udp_port $((14560+n)) --mavlink_id $((1+n)) \
      --gst_udp_port $((5600+n)) --video_uri $((5600+n)) --mavlink_cam_udp_port $((14530+n)) \
      --output-file "/tmp/iris_$n.sdf" >>"$LOG_DIR/${prefix}-${ts}-spawn.log" 2>&1
    say "投放第 $((n+1)) 架（iris_$n）…"
    gz model --spawn-file="/tmp/iris_$n.sdf" --model-name="iris_$n" \
      -x 0 -y $((3*n)) -z 0.83 >>"$LOG_DIR/${prefix}-${ts}-spawn.log" 2>&1
    n=$((n+1))
  done
  if [ "${HEADLESS:-0}" != "1" ]; then
    setsid gzclient >/dev/null 2>&1 &
    echo "$!" >> "$PIDFILE"
  fi
  say "日志文件：$LOG_DIR/${prefix}-${ts}-*.log"
}

# multi_wait_home <架数> <超时秒>：等所有架日志出现 home set。
multi_wait_home() {
  local count="${1:-$MULTI_N}" timeout="${2:-120}" t=0 max n ok f
  max=$(( timeout * 10 ))
  while [ "$t" -lt "$max" ]; do
    ok=1; n=0
    while [ "$n" -lt "$count" ]; do
      f="$LOG_DIR/${MULTI_PREFIX}-${MULTI_TS}-i${n}.log"
      if ! { [ -f "$f" ] && sed 's/\x1b\[[0-9;]*[A-Za-z]//g' "$f" | grep -q 'home set'; }; then
        ok=0; break
      fi
      n=$((n+1))
    done
    [ "$ok" = "1" ] && return 0
    sleep 0.1; t=$((t+1))
  done
  return 1
}

# 每架各加一条发往 Windows QGC 的 GCS 链路（本地端口 14557+N 错开；不传 -m）。
multi_gcs_links() {
  local count="${1:-$MULTI_N}" gw n
  gw=$(ip route | awk '/default/{print $3; exit}')
  if [ -z "$gw" ]; then
    say_err "没取到默认网关 IP，地面站连不上"
    return 1
  fi
  say "正在给地面站加连接：$count 架飞机 → Windows（$gw:14550）…"
  n=0
  while [ "$n" -lt "$count" ]; do
    px4i "$n" mavlink start -u $((14557+n)) -r 4000000 -t "$gw" -o 14550
    n=$((n+1))
  done
}

# multi_cleanup：杀掉多机后台实例与 gazebo，不清 QGC。
# 多机 px4 命令行带 "-i <N>" 特征，只匹配它，碰不到 A/B 的 pxh 单机实例。
multi_cleanup() {
  pkill -f "$PX4_BUILD/bin/px4 -i" 2>/dev/null
  pkill -x gzserver 2>/dev/null
  pkill -x gzclient 2>/dev/null
  if [ -f "$PIDFILE" ]; then
    while read -r p; do kill "$p" 2>/dev/null; done < "$PIDFILE"
    rm -f "$PIDFILE"
  fi
}
