@echo off
chcp 65001 >nul
title 演示B：QGC 地面站联动（PX4 SITL）
echo.
echo  正在启动演示：QGC 地面站 + 仿真四旋翼
echo  第一次启动会慢一点，请耐心等仿真窗口和 QGC 连上。
echo.
tasklist /FI "IMAGENAME eq QGroundControl.exe" | find /I "QGroundControl.exe" >nul || start "" "U:\expro\QGroundControl\bin\QGroundControl.exe"
wsl.exe -d Ubuntu-20.04 -u root -- bash /mnt/u/ucy/Code/active/PX4/demos/B-地面站联动/run.sh
pause
