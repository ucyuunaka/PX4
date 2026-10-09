#!/bin/bash
# 演示 B：QGC 地面站联动。由 demos/B-地面站联动.bat 双击调用，在 WSL Ubuntu-20.04 里跑。
# 流程：清理 → 起仿真 → 等定位就绪 → 关 failsafe → 加地面站链路 → 交给用户在 QGC 里操作 → 按回车清理。
. "$(dirname "$0")/../lib/common.sh"
trap 'demo_cleanup' EXIT

say "========================================"
say "  演示 B：QGC 地面站联动"
say "========================================"
say "先清理上一次的残留…"
demo_cleanup

say "正在启动仿真（第一次会慢一点，在加载模型）…"
sitl_start "B-地面站联动" || { say_err "没能启动仿真程序" "$DEMO_LOG"; exit 1; }

if ! wait_for 'pxh>' 90; then
  say_err "仿真程序 90 秒内没有就绪" "$DEMO_LOG"; exit 1
fi
if ! wait_for 'home set' 60; then
  say_err "定位一直没能就绪（等了 60 秒）" "$DEMO_LOG"; exit 1
fi
say "仿真窗口已就绪，飞机定位完成。"
sleep 5

set_failsafe_params
gcs_link_to_windows

# 可选：Gazebo 镜头跟飞机（失败不影响演示；timeout 兜底防残留）
timeout 15 gz camera -c gzclient_camera -f iris >/dev/null 2>&1 &

say "----------------------------------------"
say "QGC 左上角应显示已连接（Ready To Fly / 准备起飞）。"
say "现在可以在 QGC 里操作：点左侧 起飞(Takeoff) → 滑动确认；飞起来后点 降落(Land)。"
say "也可以在 Plan 页画航点任务再上传执行。"
say "----------------------------------------"
read -r -p "演示结束后按回车，关闭仿真并清理（QGC 窗口可以手动关）…"
demo_cleanup
say "已清理。可以直接关掉这个黑窗口。"
