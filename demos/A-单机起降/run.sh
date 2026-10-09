#!/bin/bash
# 演示 A：单机起降。由 demos/A-单机起降.bat 双击调用，在 WSL Ubuntu-20.04 里跑。
# 流程：清理 → 起仿真 → 等定位就绪 → 关 failsafe → 起飞 → 悬停 10 秒 → 降落上锁 → 按回车清理。
. "$(dirname "$0")/../lib/common.sh"
trap 'demo_cleanup' EXIT

say "========================================"
say "  演示 A：四旋翼  起飞 → 悬停 → 降落"
say "========================================"
say "先清理上一次的残留…"
demo_cleanup

say "正在启动仿真（第一次会慢一点，在加载模型）…"
sitl_start "A-单机起降" || { say_err "没能启动仿真程序" "$DEMO_LOG"; exit 1; }

if ! wait_for 'pxh>' 90; then
  say_err "仿真程序 90 秒内没有就绪" "$DEMO_LOG"; exit 1
fi
if ! wait_for 'home set' 60; then
  say_err "定位一直没能就绪（等了 60 秒）" "$DEMO_LOG"; exit 1
fi
say "仿真窗口已就绪，飞机定位完成。"
sleep 5

# 可选加分项：让 Gazebo 镜头跟上飞机（失败不影响演示；gz camera 会挂几秒才退，timeout 兜底）
timeout 15 gz camera -c gzclient_camera -f iris >/dev/null 2>&1 &

set_failsafe_params
say "起飞！"
pxh 'commander takeoff'
if ! wait_for 'Takeoff detected' 60; then
  say "起飞没有响应，5 秒后重试一次…"
  sleep 5
  pxh 'commander takeoff'
  if ! wait_for 'Takeoff detected' 60; then
    say_err "飞机没有起飞（试了两遍都没起来）" "$DEMO_LOG"; exit 1
  fi
fi

for s in 10 9 8 7 6 5 4 3 2 1; do
  printf '悬停中（%s 秒后降落）\n' "$s"
  sleep 1
done

say "开始降落…"
pxh 'commander land'
if ! wait_for 'Disarmed by landing' 60; then
  say_err "降落没有完成（等了 60 秒）" "$DEMO_LOG"; exit 1
fi
say "----------------------------------------"
say "演示完成：起飞 → 悬停 → 降落 → 上锁，全部正常。"
say "Gazebo 窗口还留着，可以指着画面继续讲。"
read -r -p "讲完以后按回车，结束并清理…"
demo_cleanup
say "已清理。可以直接关掉这个黑窗口。"
