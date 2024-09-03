# Initial server config

### creating db-credentials for mysql

```ini
nano ~/.my.cnf
```

### Put your credentials to access the database inside the file

```ini
[client]
user=your_username
password=your_password
```

### set the permissions

```ini
chmod 600 ~/.my.cnf
```

### Creating a folder to store the backups

```
mkdir ~/backups
```

### For docker

Replace "containerid" with your container id

```ini
docker cp ~/.my.cnf containerid:/root/.my.cnf
docker exec -it 1d77829b4bea chmod 600 ~/.my.cnf
```

# Configuring rclone

### Install rclone

```ini
curl <https://rclone.org/install.sh> | sudo bash
```

### Config rclone

follow the steps with your cloud provider credentials

```ini
rclone config 
```

After config you can see and edit the config file in **~/.config/rclone/rclone.conf**

# Creating the scripts

### You can see the script files on scripts folder to download, but if you want to copy follow the steps

### Create the script

```
nano ~/backups/db-backup.sh
```

### Script content

If not using Docker:

```
FILENAME=$(date +%Y-%m-%dT%H:%M:%S).sql
DATABASE=database_name
BUCKET=bucket_name
BK_PATH=~/backups
RCLONE_STORAGE=R2-STORAGE

mysqldump --single-transaction --skip-lock-tables --quick $DATABASE > $BK_PATH/$FILENAME

gzip $BK_PATH/$FILENAME

rclone move $BK_PATH/$FILENAME.gz $RCLONE_STORAGE:$BUCKET/

# Only if you want to delete the files older than 30 days

rclone delete --min-age 30d $RCLONE_STORAGE:$BUCKET/
```

With docker:

```
# !/bin/bash

FILENAME=$(date +%Y-%m-%dT%H:%M:%S).sql
DATABASE=database_name
BUCKET=bucket_name
CONTAINER=container
BK_PATH=~/backups
RCLONE_STORAGE=your_rclone_storage_name

docker exec -it $CONTAINER mysqldump --single-transaction --skip-lock-tables --quick $DATABASE > /home/db-backups/$FILENAME.sql

gzip $BK_PATH/$FILENAME

rclone move $BK_PATH/$FILENAME.gz $RCLONE_STORAGE:$BUCKET/
# Only if you want to delete the files older than 30 days
rclone delete --min-age 30d $RCLONE_STORAGE:$BUCKET/
```

### Set the permissions

```
chmod +x backup.sh
```

### Testing the script

```
~/backups/db-backup.sh
```

### Set a cron job

```
crontab -e
```

### Add a line

On this example this will run every day at midnight
I you want to configure another times, visit [Cron Tab Guru](https://crontab.guru) to help.

```
0 0 ** * ~/backups/db-backup.sh >/dev/null 2>&1
```
