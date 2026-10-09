@echo off
chcp 65001 >nul
title 演示C：三机同飞（PX4 SITL × 3）
echo.
echo  正在启动演示：3 架仿真四旋翼 一起飞 - 平移 - 一起降落
echo  要同时加载 3 架，比 A/B 慢一点，请耐心等。
echo.
tasklist /FI "IMAGENAME eq QGroundControl.exe" | find /I "QGroundControl.exe" >nul || powershell -NoProfile -Command "Start-Process -FilePath 'U:\expro\QGroundControl\bin\QGroundControl.exe'"
wsl.exe -d Ubuntu-20.04 -u root -- bash /mnt/u/ucy/Code/active/PX4/demos/C-多机同飞/run.sh
pause
