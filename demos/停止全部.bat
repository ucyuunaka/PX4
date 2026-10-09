@echo off
chcp 65001 >nul
title 停止全部演示
echo.
echo  正在清理所有演示进程，请稍等…
echo.
wsl.exe -d Ubuntu-20.04 -u root -- bash /mnt/u/ucy/Code/active/PX4/demos/stop.sh
pause
