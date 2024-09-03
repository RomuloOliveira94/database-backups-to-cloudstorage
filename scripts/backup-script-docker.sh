#!/bin/bash

FILENAME=$(date +%Y-%m-%dT%H:%M:%S).sql
DATABASE=database_name
BUCKET=bucket_name
CONTAINER=container
BK_PATH=~/backups
RCLONE_STORAGE=your_rclone_storage_name

docker exec $CONTAINER mysqldump --single-transaction --skip-lock-tables --quick $DATABASE > $BK_PATH/$FILENAME

gzip $BK_PATH/$FILENAME

rclone move $BK_PATH/$FILENAME.gz $RCLONE_STORAGE:$BUCKET/
rclone delete --min-age 90d $RCLONE_STORAGE:$BUCKET/

echo "backup made with success!"
