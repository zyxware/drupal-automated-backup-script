#!/bin/bash

# Absolute path to the log file
log=/absolute/path/to/backups/backup.log
# Absolute path to the backup folder
backup_folder=/absolute/path/to/backups
# Remote SSH user info
remote_user=username@example.com

# Array of folders to be rsynced from the remote server
rsync_folder_paths=( \
  '/home/username/webroot' \
  '/home/username/repo' \
)
# Array of folders to be rsynced from the remote server
rsync_db_paths=( \
  '/home/username/backups/db' \
)

# Source config.sh with custom configurations for the above values
if [[ -e $backup_folder/config.sh ]]; then
  . $backup_folder/config.sh
fi

# Redirect error and output to log file
exec 2>>$log
exec 1>>$log
echo "------------------------"
echo "Backup started at `date`"

# Rsync files from remote server
for (( p=0; p<${#rsync_folder_paths[@]}; p++)); do
  rsync_folder_path=${rsync_folder_paths[${p}]}
  # Rsync the remote folder to the local snapshot files folder
  rsync -az -e ssh --log-file=$backup_folder/rsync.log $remote_user:$rsync_folder_path $backup_folder/snapshot/files
done

# Rsync db dumps from remote server
for (( p=0; p<${#rsync_db_paths[@]}; p++)); do
  rsync_db_path=${rsync_db_paths[${p}]}
  # Rsync the remote db folder to the local snapshot db folder
  rsync -az -e ssh --log-file=$backup_folder/rsync.log $remote_user:$rsync_db_path $backup_folder/snapshot/db
done

echo "Rsync completed at `date`"

# Function to backup a snapshot
# Usage: backup_snapshot type
function backup_snapshot {
  local backup_type
  local last_dir
  backup_type=$1
  if [[ "$backup_type" == "daily" ]]; then
    last_dir=`pwd`
    # cd to the rsynced dir so that tar uses relative paths from there
    cd $backup_folder/snapshot
    if [[ ! -e $backup_folder/backups/$backup_type/$cur_date.tar.gz ]]; then 
      echo "Creating $backup_type backup at `date`"
      tar zcf $backup_folder/backups/$backup_type/$cur_date.tar.gz -X $backup_folder/exclude.txt .
      echo "Created $backup_type backup at `date`"
    else
      echo "Backup type $backup_type already done for the day"
    fi
    cd $last_dir
  else
    echo "Copied daily backup as $backup_type backup at `date`"
    # For weekly and monthly backups just copy the current daily backup
    cp $backup_folder/backups/daily/$cur_date.tar.gz $backup_folder/backups/$backup_type/$cur_date.tar.gz
  fi
  trim_snapshots $backup_type 3
}

# Function to limit snapshots to n copies
# Usage: trim_snapshots type count
function trim_snapshots {
  local backup_type=$1
  local limit_copies=$2
  local last_dir
  local cur_dir=$backup_folder/backups/$backup_type/
  last_dir=`pwd`
  cd $cur_dir
  num_copies=`ls -1 | wc -l`
  # Delete all except the newest 'limit_copies' files
  if [[ $num_copies -gt $limit_copies ]]; then
    echo "Deleting older $backup_type backups"
    rm $(ls -t $cur_dir | tail -n +$(($limit_copies+1)))
  fi
  cd $last_dir
}

weekday=`date +%u`
day=`date +%d`
cur_date=`date +%Y-%m-%d`

# Run daily backup every day
backup_snapshot daily

#Run weekly backup every sunday
if [[ $weekday -eq 5 ]]; then
  backup_snapshot weekly
fi

# Run monthly backup on the first sunday of the month
if [[ $day -gt 8 && $weekday -eq 5 ]]; then
  backup_snapshot monthly
fi

echo "Completed backup at `date`"

