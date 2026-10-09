#!/bin/bash
# 演示 C：三架四旋翼同飞。由 demos/C-多机同飞.bat 双击调用，在 WSL Ubuntu-20.04 里跑。
# 流程：清理 → multi_start 3 → 全部 home set → 逐架置参+QGC 链路 → fly.py 飞全程 → 按回车清理。
. "$(dirname "$0")/../lib/common.sh"
. "$(dirname "$0")/../lib/multi.sh"
trap 'demo_cleanup; multi_cleanup' EXIT

say "========================================"
say "  演示 C：三架四旋翼 一起飞 → 平移 → 一起降落"
say "========================================"
say "先清理上一次的残留…"
demo_cleanup
multi_cleanup

say "正在启动仿真（3 架飞机，比 A/B 慢一点）…"
multi_start 3 "C-多机同飞" || { say_err "没能启动仿真程序" "$LOG_DIR"; exit 1; }

if ! multi_wait_home 3 180; then
  say_err "有飞机 180 秒内没能定位就绪" "$LOG_DIR"
  exit 1
fi
say "3 架飞机都已就位。"
sleep 3

# 后台实例没有 pxh 控制台，置参/加链路走 px4-<module> --instance N 客户端
n=0
while [ "$n" -lt 3 ]; do
  px4i "$n" param set NAV_DLL_ACT 0 >/dev/null
  px4i "$n" param set NAV_RCL_ACT 0 >/dev/null
  px4i "$n" param set COM_LOW_BAT_ACT 0 >/dev/null
  px4i "$n" param set COM_RCL_EXCEPT 4 >/dev/null
  n=$((n+1))
done
multi_gcs_links 3

# 可选：镜头跟住中间那架 iris_1（失败不影响演示）
timeout 15 gz camera -c gzclient_camera -f iris_1 >/dev/null 2>&1 &

say "----------------------------------------"
say "QGC 里应能看到 3 架飞机（工具栏可切换查看）。"
say "飞行序列开始…"
say "----------------------------------------"
if ! python3 "$(dirname "$0")/fly.py" 3; then
  say_err "飞行序列没有走完" "$LOG_DIR"
  exit 1
fi
say "----------------------------------------"
say "演示完成：3 架飞机一起起飞、排队平移、一起降落。"
say "Gazebo 和 QGC 窗口还留着，可以指着画面继续讲。"
read -r -p "讲完以后按回车，结束并清理（QGC 窗口可以手动关）…"
demo_cleanup
multi_cleanup
say "已清理。可以直接关掉这个黑窗口。"
