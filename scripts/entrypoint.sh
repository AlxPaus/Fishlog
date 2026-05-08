#!/bin/sh
set -e

echo "Ожидание запуска PostgreSQL..."
while ! pg_isready -h haproxy -p 5432 -U "$POSTGRES_USER"; do
  sleep 1
done

export PGPASSWORD="$POSTGRES_PASSWORD"

psql -h haproxy -U "$POSTGRES_USER" -d postgres -tc "SELECT 1 FROM pg_database WHERE datname = '$POSTGRES_DB'" | grep -q 1 || psql -h haproxy -U "$POSTGRES_USER" -d postgres -c "CREATE DATABASE $POSTGRES_DB;"
psql -h haproxy -U "$POSTGRES_USER" -d postgres -tc "SELECT 1 FROM pg_database WHERE datname = '$TEST_POSTGRES_DB'" | grep -q 1 || psql -h haproxy -U "$POSTGRES_USER" -d postgres -c "CREATE DATABASE $TEST_POSTGRES_DB;"
psql -h haproxy -U "$POSTGRES_USER" -d postgres -tc "SELECT 1 FROM pg_roles WHERE rolname = 'postgres_exporter'" | grep -q 1 || psql -h haproxy -U "$POSTGRES_USER" -d postgres -c "CREATE USER postgres_exporter WITH PASSWORD 'exporter_password';"
psql -h haproxy -U "$POSTGRES_USER" -d postgres -c "GRANT pg_monitor TO postgres_exporter;"


TEST_DB_URL="postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@haproxy:${POSTGRES_PORT}/${TEST_POSTGRES_DB}?sslmode=disable"

seqwall staircase --postgres-url "$TEST_DB_URL" --migrations-path "/app/migrations" --migrations-extension=".up.sql" --test-snapshots=false --upgrade "/app/scripts/ci-up-one.sh {current_migration}" --downgrade "/app/scripts/ci-down-one.sh {current_migration}"

MAIN_DB_URL="postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@haproxy:${POSTGRES_PORT}/${POSTGRES_DB}?sslmode=disable"

if [ -n "$MIGRATION_VERSION" ]; then
    echo "Накатываем до версии: $MIGRATION_VERSION"
    migrate -path /app/migrations -database "$MAIN_DB_URL" goto "$MIGRATION_VERSION"
else
    migrate -path /app/migrations -database "$MAIN_DB_URL" up
fi

python /app/scripts/seed.py