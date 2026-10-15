#!/usr/bin/env bash
# Użycie: ./restore.sh backups/backup-YYYY-MM-DD.sql
set -euo pipefail
cd "$(dirname "$0")"
source .env

if [ $# -ne 1 ]; then
  echo "Użycie: $0 <plik_backupu.sql>" >&2
  exit 1
fi

BACKUP_FILE="$1"
if [ ! -f "$BACKUP_FILE" ]; then
  echo "Nie znaleziono pliku: $BACKUP_FILE" >&2
  exit 1
fi

DB="${REDMINE_DB_USERNAME}"
PSQL=(docker compose exec -T db psql -v ON_ERROR_STOP=1 -U "${REDMINE_DB_USERNAME}" -d "${DB}")

RUNNING="$(docker compose ps --status running --services)"
APP_WAS_RUNNING=0
DB_WAS_RUNNING=0
grep -qx redmine <<< "${RUNNING}" && APP_WAS_RUNNING=1
grep -qx db <<< "${RUNNING}" && DB_WAS_RUNNING=1

if [ "${APP_WAS_RUNNING}" -eq 1 ]; then
  echo "==> Zatrzymywanie aplikacji"
  docker compose stop redmine
else
  echo "==> Aplikacja nie działa - po przywróceniu pozostanie wyłączona"
fi

if [ "${DB_WAS_RUNNING}" -eq 0 ]; then
  echo "==> Uruchamianie samej bazy"
  docker compose up -d db
fi
until docker compose exec -T db pg_isready -q -U "${REDMINE_DB_USERNAME}" -d "${DB}"; do
  sleep 1
done

mkdir -p backups
PRE_RESTORE="backups/pre-restore-$(date +%F-%H%M%S).sql"
echo "==> Backup aktualnej bazy do ${PRE_RESTORE}"
docker compose exec -T db pg_dump -U "${REDMINE_DB_USERNAME}" "${DB}" > "${PRE_RESTORE}"

echo "==> Czyszczenie bazy"
"${PSQL[@]}" -c 'DROP SCHEMA public CASCADE; CREATE SCHEMA public;'

echo "==> Przywracanie z ${BACKUP_FILE}"
"${PSQL[@]}" < "${BACKUP_FILE}" > /dev/null

if [ "${APP_WAS_RUNNING}" -eq 1 ]; then
  echo "==> Uruchamianie aplikacji"
  docker compose up -d
elif [ "${DB_WAS_RUNNING}" -eq 0 ]; then
  echo "==> Zatrzymywanie bazy (uruchomionej tylko na czas przywracania)"
  docker compose stop db
fi

echo "Gotowe."
