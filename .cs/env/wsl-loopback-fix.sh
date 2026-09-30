#!/bin/sh
# WSL virtioproxy fallback: UDP to 127.0.0.1 is routed to the Windows host (ip rule -> table 127),
# so Linux-internal UDP over localhost is lost. Keep PX4-related UDP ports local; everything else
# (e.g. PX4 -> QGC on Windows at 127.0.0.1:14550) still goes to Windows. No-op in nat/mirrored mode.
PORTS="8888 14540-14549 14557 14580-14589"
PREF=0
ip rule show | grep -q 'lookup 127' || exit 0
for p in $PORTS; do
  for dir in dport sport; do
    while ip rule del pref $PREF to 127.0.0.0/8 ipproto udp $dir $p lookup local 2>/dev/null; do :; done
    ip rule add pref $PREF to 127.0.0.0/8 ipproto udp $dir $p lookup local
  done
done
