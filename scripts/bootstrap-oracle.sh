#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="${INSTALL_DIR:-/opt/timeline}"
UPSTREAM_COMPOSE_URL="https://raw.githubusercontent.com/Freika/dawarich/master/docker/docker-compose.yml"

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo: sudo bash scripts/bootstrap-oracle.sh"
  exit 1
fi

apt-get update
apt-get install -y ca-certificates curl gnupg git caddy

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
. /etc/os-release
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${UBUNTU_CODENAME:-$VERSION_CODENAME} stable" > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker

mkdir -p "$INSTALL_DIR/backups"
cd "$INSTALL_DIR"

if [[ ! -f docker-compose.yml ]]; then
  curl -fsSL "$UPSTREAM_COMPOSE_URL" -o docker-compose.yml
  echo "Downloaded current official Dawarich docker-compose.yml"
else
  echo "Existing docker-compose.yml found; leaving it untouched."
fi

if [[ ! -f .env ]]; then
  cp .env.example .env
  chmod 600 .env
  echo "Created .env from template. Fill it before starting Dawarich."
fi

install -m 0644 Caddyfile /etc/caddy/Caddyfile
systemctl enable --now caddy

echo
echo "Bootstrap complete."
echo "Next: edit $INSTALL_DIR/.env and $INSTALL_DIR/Caddyfile hostname, then copy Caddyfile to /etc/caddy/Caddyfile and run:"
echo "  sudo systemctl reload caddy"
echo "  sudo docker compose pull"
echo "  sudo docker compose up -d"
