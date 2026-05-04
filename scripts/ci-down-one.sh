#!/bin/sh
set -e
MIGRATION_FILE=$1
VERSION=$(basename "$MIGRATION_FILE" | grep -o -E '^[0-9]+' | sed 's/^0*//')
TEST_DB_URL="postgres://${POSTGRES_USER}:${POSTGRES_PASSWORD}@haproxy:${POSTGRES_PORT}/${TEST_POSTGRES_DB}?sslmode=disable"
migrate -path /app/migrations -database "$TEST_DB_URL" down 1