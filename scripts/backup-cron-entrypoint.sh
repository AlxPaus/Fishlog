#!/bin/sh
echo "$BACKUP_INTERVAL /app/scripts/backup.sh > /proc/1/fd/1 2>/proc/1/fd/2" > /etc/crontabs/root
exec crond -f -l 2