@echo off
chcp 65001 >nul
title 演示D：编队避障（Swarm-Formation 仿真）
echo.
echo  正在启动演示：7 架无人机保持队形穿越树林避障
echo  第一次会慢一点，请耐心等。
echo.
wsl.exe -d Ubuntu-20.04 -u root -- bash /mnt/u/ucy/Code/active/PX4/demos/D-编队避障/run.sh
pause
