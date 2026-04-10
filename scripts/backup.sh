#!/bin/sh
set -e

mc alias set myminio http://minio:9000 "$BACKUP_USER" "$BACKUP_PASSWORD"
FILENAME="fishlog_backup_$(date +%Y%m%d_%H%M%S).sql.gz"
export PGPASSWORD="$POSTGRES_PASSWORD"
    pg_dump -h db -U "$POSTGRES_USER" -d "$POSTGRES_DB" -F c -Z 9 -f "/tmp/$FILENAME"
mc cp "/tmp/$FILENAME" "myminio/$BUCKET_BACKUP_NAME/$FILENAME"
rm "/tmp/$FILENAME"

mc ls "myminio/$BUCKET_BACKUP_NAME/" | sort -r | tail -n +$((BACKUP_RETENTION_COUNT + 1)) | awk '{print $5}' | while read -r file; do
    if [ -n "$file" ]; then
        echo "Deletting old backup: $file"
        mc rm "myminio/$BUCKET_BACKUP_NAME/$file"
    fi
done
echo "Backup ended"