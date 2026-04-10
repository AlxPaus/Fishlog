#!/bin/sh

until mc alias set myminio http://minio:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"; do
  echo "MinIO not initialized yet..."
  sleep 2
done

mc alias set myminio http://minio:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"
mc mb "myminio/$BUCKET_BACKUP_NAME" --ignore-existing

cat <<EOF > /tmp/backup_policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:PutObject", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket"],
      "Resource": ["arn:aws:s3:::$BUCKET_BACKUP_NAME", "arn:aws:s3:::$BUCKET_BACKUP_NAME/*"]
    }
  ]
}
EOF

mc admin policy create myminio backup_policy /tmp/backup_policy.json
mc admin user add myminio "$BACKUP_USER" "$BACKUP_PASSWORD"
mc admin policy attach myminio backup_policy --user "$BACKUP_USER"
