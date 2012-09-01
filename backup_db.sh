#!/bin/bash

# Absolute path to the drupal webroot 
drupal_root=/home/username/webroot
# Name of the drupal project
project_name=projectname
# Absolute path to the drush executable
drush_cmd=/home/username/bin/drush/drush
# Absolute path to the log file
log=/home/username/backups/backup.log
# Absolute path to the backup folder
backup_folder=/home/username/backups

exec 2>>$log
exec 1>>$log
cd $drupal_root
echo "Db backup started at `date`"
$drush_cmd sql-dump --gzip > $backup_folder/db/$project_name.sql.gz.tmp
mv $backup_folder/db/$project_name.sql.gz.tmp $backup_folder/db/$project_name.sql.gz
echo "Db backup ended at `date`"

