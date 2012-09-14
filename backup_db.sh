#!/bin/bash

# ----------------------------------------------------------------------
# Backup a drupal database
# Copyright (c) 2012 Anoop John, Zyxware Technologies (www.zyxware.com)
# https://github.com/zyxware/drupal-automated-backup-script
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# ----------------------------------------------------------------------

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

