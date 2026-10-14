#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
source .env

mkdir -p db_backups
# Baza ma taką samą nazwę jak użytkownik (domyślne zachowanie obrazu postgres bez POSTGRES_DB)
docker compose exec -T db pg_dump -U "${REDMINE_DB_USERNAME}" "${REDMINE_DB_USERNAME}" > "db_backups/backup-$(date +%F).sql"
