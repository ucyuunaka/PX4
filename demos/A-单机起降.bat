@echo off
chcp 65001 >nul
title 演示A：单机起降（PX4 SITL）
echo.
echo  正在启动演示：四旋翼 起飞 - 悬停 - 降落
echo  第一次启动会慢一点，请耐心等仿真窗口出现。
echo.
wsl.exe -d Ubuntu-20.04 -u root -- bash /mnt/u/ucy/Code/active/PX4/demos/A-单机起降/run.sh
pause
