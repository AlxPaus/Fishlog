docker compose stop/start pg1
docker compose logs -f pg1 pg2 pg3


docker compose exec backup sh scripts/backup.sh
docker compose exec -it backup bash
mc cp myminio/fishlogb/fishlog_backup_20260522_101949.sql.gz /tmp/restore_db.sql.gz
pg_restore -h haproxy -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c -1 /tmp/restore_db.sql.gz

docker compose run --rm -it --entrypoint sh migrator
export DB_URL="postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@haproxy:5432/${POSTGRES_DB}?sslmode=disable"
migrate -path /app/migrations -database "$DB_URL" down 1

C:\Users\paus2\.local\bin\pgcompare.exe run --config ./pgcompare.yaml --out ./report.html -v