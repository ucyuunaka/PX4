#!/usr/bin/env python3
# 演示 C 的飞行序列：N 架 SITL 统一起飞 → 集体东移 15 米（整列横移，队形保持）→ 悬停 → 统一降落。
# Gazebo 世界是 ENU（x=东、y=北）：投放时 -y 3N → 3 架沿南北向排成一列，
# 所以平移走"东"（改经度）才有"整列一起横移"的视觉效果。
# 注意：这不是编队控制算法——每架是独立飞控，本脚本只是统一发 MAVLink 指令。
#
# 穿刺结论（issue 012）：
#   - 起飞/降落用 px4-commander --instance N（与演示 A 的 pxh 路径同源，已验证）。
#   - 平移用 MAV_CMD_DO_REPOSITION（param5/6 是"十进制度数"经纬度，不是 degE7！）。
#   - 必须持续给每架发 MAVLink 心跳：不发心跳 PX4 认为 datalink 丢失，
#     failsafe 旗挂上后 DO_REPOSITION 会被 ACK(0) 但不执行（穿刺实测）。

import math
import subprocess
import sys
import threading
import time

from pymavlink import mavutil

PX4I = "/root/px4-sitl-src/build/px4_sitl_default/bin/px4-commander"
N = int(sys.argv[1]) if len(sys.argv) > 1 else 3
EAST_M = 15.0
HB_TYPE_GCS = mavutil.mavlink.MAV_TYPE_GCS
HB_AP_INVALID = mavutil.mavlink.MAV_AUTOPILOT_INVALID


def say(s):
    print(s, flush=True)


def hb_loop(conn):
    """每秒一发 GCS 心跳，让 PX4 认为 datalink 在线。"""
    while True:
        try:
            conn.mav.heartbeat_send(HB_TYPE_GCS, HB_AP_INVALID, 0, 0, 0)
        except Exception:
            return
        time.sleep(1.0)


def commander(instance, action):
    subprocess.run([PX4I, "--instance", str(instance), action], check=False)


def get_pos(conn):
    return conn.recv_match(type="GLOBAL_POSITION_INT", blocking=True, timeout=10)


def main():
    say("正在连接各架飞机…")
    conns = []
    for i in range(N):
        c = mavutil.mavlink_connection(f"udpin:0.0.0.0:{14540 + i}", autoreconnect=False)
        if not c.wait_heartbeat(timeout=30):
            say("出问题了：第 %d 架 30 秒内没连上（没收到心跳）" % (i + 1))
            sys.exit(1)
        conns.append(c)
        threading.Thread(target=hb_loop, args=(c,), daemon=True).start()
        say("第 %d 架已连接（系统号 %d）" % (i + 1, c.target_system))

    time.sleep(3)  # 让 PX4 认到 datalink（清掉"无数据链"的 failsafe 旗）

    say("全体起飞！")
    for i in range(N):
        commander(i, "takeoff")

    # 等都离地：relative_alt > 1.5 m（60 秒超时）
    deadline = time.time() + 60
    airborne = [False] * N
    while time.time() < deadline and not all(airborne):
        for i, c in enumerate(conns):
            if airborne[i]:
                continue
            m = c.recv_match(type="GLOBAL_POSITION_INT", blocking=True, timeout=0.5)
            if m and m.relative_alt > 1500:
                airborne[i] = True
                say("第 %d 架已离地" % (i + 1))
    if not all(airborne):
        say("出问题了：有飞机 60 秒内没能离地")
        sys.exit(1)
    say("%d 架全部离地。" % N)

    # 集体东移：目标 = 各自当前位置 +15m 东（lat 不变 → 整列横移），高度抬 ~2m
    positions = [get_pos(c) for c in conns]
    say("集体向东平移 %d 米…" % int(EAST_M))
    targets = []
    for i, (c, m) in enumerate(zip(conns, positions)):
        lat_deg = m.lat / 1e7
        tlat = lat_deg
        tlon = m.lon / 1e7 + EAST_M / (111320.0 * math.cos(math.radians(lat_deg)))
        talt = m.alt / 1000.0 + 2.0
        targets.append((tlat, tlon))
        c.mav.command_long_send(
            c.target_system, c.target_component,
            mavutil.mavlink.MAV_CMD_DO_REPOSITION, 0,
            -1, 0, 0, float("nan"), tlat, tlon, talt)

    # 等到达（距目标 < 1.5 m 或 40 秒超时）
    deadline = time.time() + 40
    arrived = [False] * N
    while time.time() < deadline and not all(arrived):
        for i, c in enumerate(conns):
            if arrived[i]:
                continue
            m = c.recv_match(type="GLOBAL_POSITION_INT", blocking=True, timeout=0.5)
            if not m:
                continue
            tlat, tlon = targets[i]
            dn = (m.lat / 1e7 - tlat) * 111320.0
            de = (m.lon / 1e7 - tlon) * 111320.0 * math.cos(math.radians(tlat))
            if dn * dn + de * de < 1.5 * 1.5:
                arrived[i] = True
                say("第 %d 架到达目标点" % (i + 1))
    if not all(arrived):
        say("注意：有飞机 40 秒内没完全到位，继续演示")

    # 汇报每架实际位移（相对起飞点，米）——应为 dE≈15、dN≈0
    finals = [get_pos(c) for c in conns]
    for i, (m0, m1) in enumerate(zip(positions, finals)):
        dn = (m1.lat - m0.lat) / 1e7 * 111320.0
        de = (m1.lon - m0.lon) / 1e7 * 111320.0 * math.cos(math.radians(m0.lat / 1e7))
        say("第 %d 架位移：东 %+0.1f m / 北 %+0.1f m" % (i + 1, de, dn))

    say("目标点悬停 5 秒…")
    time.sleep(5)

    say("全体降落…")
    for c in conns:
        c.mav.command_long_send(
            c.target_system, c.target_component,
            mavutil.mavlink.MAV_CMD_NAV_LAND, 0,
            0, 0, 0, float("nan"), 0, 0, 0)

    # 等都落地（rel_alt < 0.3 m，60 秒超时）
    deadline = time.time() + 60
    landed = [False] * N
    while time.time() < deadline and not all(landed):
        for i, c in enumerate(conns):
            if landed[i]:
                continue
            m = c.recv_match(type="GLOBAL_POSITION_INT", blocking=True, timeout=0.5)
            if m and m.relative_alt < 300:
                landed[i] = True
                say("第 %d 架已落地" % (i + 1))
    if not all(landed):
        say("出问题了：有飞机 60 秒内没落地")
        sys.exit(1)

    say("演示完成：全部降落。")


if __name__ == "__main__":
    main()
