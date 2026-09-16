#!/usr/bin/env bash
# Tar en tom Ubuntu 24.04-instans till färdigt Torget. Kör från repo-roten:
#
#   deploy/provision.sh <ip> [domän]          domän default: torget.bjarby.com
#
# Förutsätter: ssh root@<ip> med nyckel fungerar. Idempotent, går att köra om.
# Efteråt: peka A-posten för domänen på <ip>, sedan deploy/deploy.sh vid varje uppdatering.
set -euo pipefail
IP="${1:?användning: deploy/provision.sh <ip> [domän]}"
DOMAIN="${2:-torget.bjarby.com}"
HOST="root@$IP"
cd "$(dirname "$0")/.."

ssh -o StrictHostKeyChecking=accept-new "$HOST" bash -s "$DOMAIN" <<'REMOTE'
set -euo pipefail
DOMAIN="$1"
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq curl ufw rsync debian-keyring debian-archive-keyring apt-transport-https >/dev/null

# Node 22 (NodeSource)
if ! command -v node >/dev/null || [ "$(node -v | cut -c2-3)" -lt 20 ]; then
  curl -fsSL https://deb.nodesource.com/setup_22.x | bash - >/dev/null
  apt-get install -y -qq nodejs >/dev/null
fi

# Caddy (officiellt repo)
if ! command -v caddy >/dev/null; then
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' > /etc/apt/sources.list.d/caddy-stable.list
  apt-get update -qq && apt-get install -y -qq caddy >/dev/null
fi

# Brandvägg: bara ssh + http(s)
ufw allow OpenSSH >/dev/null; ufw allow 80/tcp >/dev/null; ufw allow 443/tcp >/dev/null
ufw --force enable >/dev/null

# Caddyfile: bara Torget
cat > /etc/caddy/Caddyfile <<CADDY
$DOMAIN {
        reverse_proxy localhost:8180 {
                flush_interval -1
        }
}
CADDY
systemctl enable --now caddy >/dev/null
systemctl reload caddy || true

mkdir -p /opt/torget /var/lib/torget
chown www-data:www-data /var/lib/torget
echo "node $(node -v), caddy $(caddy version | cut -d' ' -f1), ufw $(ufw status | head -1)"
REMOTE

# Koden + tjänsten via vanliga deploy-skriptet
HOST="$HOST" deploy/deploy.sh
echo
echo "Provisionerat. Nästa steg:"
echo "  1. A-post: $DOMAIN -> $IP (one.com: Domän → DNS-inställningar → DNS-post → A)"
echo "  2. Flytta tavlans logg om den ska med:"
echo "     ssh root@<gamla-ip> cat /var/lib/torget/messages.jsonl | ssh $HOST 'cat > /var/lib/torget/messages.jsonl && chown www-data:www-data /var/lib/torget/messages.jsonl && systemctl restart torget'"
echo "  3. Framöver: HOST=$HOST deploy/deploy.sh"
