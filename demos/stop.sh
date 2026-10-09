#!/bin/bash
# 停止全部演示：由 demos/停止全部.bat 双击调用。单机与多机残留都清。
. "$(dirname "$0")/lib/common.sh"
. "$(dirname "$0")/lib/multi.sh"
. "$(dirname "$0")/lib/ros1.sh"

say "正在清理演示进程，请稍等…"
demo_cleanup
multi_cleanup
ros_cleanup
say "已清理。可以再双击演示脚本重新运行。"
