# Redmine

Konfiguracja uruchomieniowa [Redmine](https://www.myredmine.com/) w Dockerze (Redmine + PostgreSQL) wraz ze skryptami do zarządzania aplikacją i kopiami zapasowymi bazy.

## Zawartość

| Plik / katalog       | Opis                                                          |
|----------------------|---------------------------------------------------------------|
| `docker-compose.yaml`| Definicja usług `redmine` i `db` (PostgreSQL)                 |
| `.env`               | Konfiguracja: port, użytkownik i hasło bazy                   |
| `start.sh`           | Uruchamia aplikację                                           |
| `stop.sh`            | Zatrzymuje aplikację                                          |
| `backup.sh`          | Zapisuje zrzut bazy do `db_backups/backup-<data>.sql`         |
| `restore.sh`         | Przywraca bazę ze wskazanego pliku (patrz niżej)              |
| `db/`                | Dane PostgreSQL                                               |
| `web/`               | Pliki (załączniki) Redmine                                    |
| `db_backups/`        | Kopie zapasowe bazy                                           |

## Użycie

Przed użyciem należy zainstalować i uruchomić [Docker Desktop](https://www.docker.com/products/docker-desktop/).

```bash
./start.sh     # uruchomienie
./stop.sh      # zatrzymanie
./backup.sh    # kopia zapasowa bazy
./restore.sh backups/backup-YYYY-MM-DD.sql   # przywrócenie bazy
```

Aplikacja jest dostępna na porcie ustawionym w `.env` (`REDMINE_PORT`).

### Przywracanie bazy

`restore.sh` zatrzymuje aplikację (jeśli działała), robi kopię aktualnej bazy do `db_backups/pre-restore-*.sql`, czyści bazę, wczytuje wskazany plik i uruchamia aplikację z powrotem – o ile działała przed przywracaniem. Przywracana jest tylko baza; załączniki w `web/` pozostają bez zmian.

## Licencja

Materiał treningowy dla klientów [myRedmine.com](https://www.myredmine.com/)

Dozwolony użytek osobisty.
