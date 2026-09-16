#!/usr/bin/env bash
# Deploy av Torget till Vultr. Kör från repo-roten: deploy/deploy.sh
# Förutsätter: ssh root@70.34.220.159 fungerar, node finns på servern, Caddy kör.
# DNS (torget.bjarby.com -> 70.34.220.159) måste finnas innan Caddy kan hämta cert.
set -euo pipefail
HOST="${HOST:-root@70.34.220.159}"
cd "$(dirname "$0")/.."
rsync -az --delete --exclude data board/ "$HOST:/opt/torget/"
scp -q deploy/torget.service "$HOST:/etc/systemd/system/torget.service"
ssh "$HOST" 'set -e
  mkdir -p /var/lib/torget && chown www-data:www-data /var/lib/torget
  systemctl daemon-reload && systemctl enable --now torget && systemctl restart torget
  if ! grep -q "torget.bjarby.com" /etc/caddy/Caddyfile; then
    cat >> /etc/caddy/Caddyfile <<CADDY

torget.bjarby.com {
        reverse_proxy localhost:8180 {
                flush_interval -1
        }
}
CADDY
    systemctl reload caddy
  fi
  sleep 1; curl -s localhost:8180/api/health'
echo
echo "Klart. Sätt .board-url till https://torget.bjarby.com när DNS:en är på plats."
