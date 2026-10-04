# timeline

Self-hosted personal location history using [Dawarich](https://dawarich.app/) with an Oracle Cloud Always Free deployment target.

## Architecture

- Oracle Cloud Ampere A1 VM (ARM64)
- Docker Compose
- Dawarich web + Sidekiq worker
- PostgreSQL + PostGIS
- Redis
- Caddy reverse proxy with automatic HTTPS

Only ports 80/443 should be public. PostgreSQL and Redis remain private to the Docker network.

## Quick start

1. Provision an Oracle Cloud Ampere A1 Ubuntu VM. Recommended starting size: 2 OCPUs, 8 GB RAM, 50 GB boot volume.
2. Point a DNS name (for example `timeline.example.com`) at the VM public IP.
3. SSH into the VM and install Docker Engine + Docker Compose plugin.
4. Clone this repository to `/opt/timeline`.
5. Copy `.env.example` to `.env` and fill in strong secrets.
6. Edit `Caddyfile` and replace `timeline.example.com` with your hostname.
7. Run:

```bash
sudo docker compose pull
sudo docker compose up -d
```

8. Open your HTTPS hostname and create the initial Dawarich account.
9. Disable public registration in Dawarich after creating the intended account(s).

## Security

Do **not** commit `.env`, database files, backups, exports, or location-history data. This repository intentionally contains configuration only.

## Oracle notes

Use an ARM64 Ubuntu image on Ampere A1. In the Oracle VCN/security list, allow inbound TCP 22 from your own IP if practical, and TCP 80/443 from the internet. Do not expose ports 3000, 5432, or 6379 publicly.

## Backups

A basic PostgreSQL backup helper lives in `scripts/backup.sh`. Schedule it with cron once the service is running. Backups are written under `./backups` and retained for 7 days by default.
