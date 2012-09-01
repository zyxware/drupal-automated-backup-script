Drupal Automated Backup Script
==============================

Installation instructions

The backup_db.sh has be to customized and set up on the server where the drupal installation is set up. It is assumed that drush is already installed on the server. It is also assumed that the required folders will be created by the user. The script must be configured to be run every day at a non-peak hour. You will probably have to add the relevant PATH variable in crontab to allow drush to run.

The backup_full.sh file has to be customized and set up on the backup server. The following paths are expected inside the main backups folder

snapshot
snapshot/files
snapshot/db
backups/daily
backups/weekly
backups/monthly

The snapshot folder will be used for rsyncing the content from the remote server. The snapshots are then tar.gz-ed and saved into the daily, weekly, monthly folders in the backups folder inside the main backups folder.

Author: Zyxware Technologies (www.zyxware.com)
License: GPL v3
