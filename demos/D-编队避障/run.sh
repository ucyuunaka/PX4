#!/bin/bash
# 演示 D：Swarm-Formation 编队避障仿真（rviz）。由 demos/D-编队避障.bat 双击调用。
# 流程：清理 → rviz.launch → normal_hexagon.launch（7 架六边形编队进随机树林）
#      → 各机进入 Waiting for trigger 后自动发一次 /traj_start_trigger → 按回车清理。
. "$(dirname "$0")/../lib/common.sh"
. "$(dirname "$0")/../lib/multi.sh"
. "$(dirname "$0")/../lib/ros1.sh"
trap 'ros_cleanup' EXIT

say "========================================"
say "  演示 D：七架无人机编队 穿越树林避障"
say "========================================"
say "先清理上一次的残留…"
ros_cleanup
demo_cleanup
multi_cleanup

ros_env || { say_err "ROS 环境没准备好（/root/masc_ws 可能没编译）"; exit 1; }

mkdir -p "$RUN_DIR" "$LOG_DIR"
rm -f "$PIDFILE"
TS=$(date +%Y%m%d-%H%M%S)

say "正在打开仿真窗口（rviz，第一次会慢一点）…"
setsid roslaunch ego_planner rviz.launch > "$LOG_DIR/D-rviz-$TS.log" 2>&1 &
echo "$!" >> "$PIDFILE"
t=0
while ! pgrep -x rviz >/dev/null; do
  sleep 1; t=$((t+1))
  [ "$t" -ge 60 ] && { say_err "rviz 60 秒内没起来" "$LOG_DIR/D-rviz-$TS.log"; exit 1; }
done
say "窗口已打开。"

say "正在生成随机树林、启动 7 架编队无人机…"
setsid roslaunch ego_planner normal_hexagon.launch > "$LOG_DIR/D-hexagon-$TS.log" 2>&1 &
echo "$!" >> "$PIDFILE"

# 等最后一架（drone_6）的 odom 真的发出来——roslaunch 按 include 顺序起节点，
# 它有 publisher 了说明 7 架都起完。注意不能数 odom 话题个数：
# 规划器会给编队预留位订阅 0–11 号话题，topic 注册数大于实际机数。最多 90 秒。
t=0
while ! timeout 5 rostopic echo -n1 /drone_6_visual_slam/odom >/dev/null 2>&1; do
  t=$((t+5))
  [ "$t" -ge 90 ] && { say_err "最后一架无人机 90 秒内没就绪" "$LOG_DIR/D-hexagon-$TS.log"; exit 1; }
done
say "7 架无人机已就位，发送起飞/任务触发…"
# 触发连发 3 次（每秒一次）：FSM 只对首次到达起效，晚订阅的实例也能收到
for k in 1 2 3; do
  rostopic pub -1 /traj_start_trigger std_msgs/Bool '{data: true}' >/dev/null 2>&1
  sleep 1
done

say "----------------------------------------"
say "看窗口：一列（六边形）无人机自动穿过树林飞向对面目标点、绕开障碍。"
say "它们互相同步位置、协同保持队形——这是规划算法在起作用。"
say "----------------------------------------"
read -r -p "讲完以后按回车，结束并清理（rviz 窗口会一起关）…"
ros_cleanup
say "已清理。可以直接关掉这个黑窗口。"
