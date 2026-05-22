#!/bin/sh
set -e

mc alias set myminio http://minio:9000 "$BACKUP_USER" "$BACKUP_PASSWORD"
FILENAME="fishlog_backup_$(date +%Y%m%d_%H%M%S).sql.gz"
export PGPASSWORD="$POSTGRES_PASSWORD"
    pg_dump -h haproxy -U "$POSTGRES_USER" -d "$POSTGRES_DB" -F c -Z 9 -f "/tmp/$FILENAME"
mc cp "/tmp/$FILENAME" "myminio/$BUCKET_BACKUP_NAME/$FILENAME"
echo ""

BACKUP_TIME=$(date +%s)
BACKUP_SIZE=$(stat -c %s "/tmp/$FILENAME")

echo "# TYPE backup_last_success_timestamp_seconds gauge" > /tmp/metrics.txt
echo "backup_last_success_timestamp_seconds $BACKUP_TIME" >> /tmp/metrics.txt
echo "# TYPE backup_last_size_bytes gauge" >> /tmp/metrics.txt
echo "backup_last_size_bytes $BACKUP_SIZE" >> /tmp/metrics.txt
echo "" >> /tmp/metrics.txt

echo "Sending metrics to Pushgateway"
curl -f -sS -X POST --data-binary @/tmp/metrics.txt http://pushgateway:9091/metrics/job/pg_backup
echo "Metrics sent successfully"


rm "/tmp/$FILENAME"
rm "/tmp/metrics.txt"

mc ls "myminio/$BUCKET_BACKUP_NAME/" | sort -r | tail -n +$((BACKUP_RETENTION_COUNT + 1)) | awk '{print $NF}' | while read -r file; do
    if [ -n "$file" ]; then
        echo "Deletting old backup: $file"
        mc rm "myminio/$BUCKET_BACKUP_NAME/$file"
    fi
done
echo "Backup ended"