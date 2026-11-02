#!/bin/bash
# Railway start wrapper for Antirion: gateway on loopback (data 18080, admin 18081) + Caddy on Railway's PORT.
set -uo pipefail
mkdir -p "${ANTIRION_DATA_DIR:-/var/lib/antirion/data}"
if [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
  export ANTIRION_PUBLIC_ORIGIN="${ANTIRION_PUBLIC_ORIGIN:-https://$RAILWAY_PUBLIC_DOMAIN}"
  export ANTIRION_DATA_PLANE_URL="${ANTIRION_DATA_PLANE_URL:-https://$RAILWAY_PUBLIC_DOMAIN}"
fi
export PORT="${PORT:-8080}"
/usr/local/bin/antirion serve &
gw=$!
/usr/local/bin/caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &
edge=$!
trap 'kill -TERM $gw $edge 2>/dev/null' TERM INT
wait -n $gw $edge
code=$?
echo "[railway] a process exited (code $code); stopping" >&2
kill -TERM $gw $edge 2>/dev/null
wait
exit $code
