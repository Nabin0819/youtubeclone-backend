#!/bin/bash 
TIMESTAMP=$(date +"%Y%m%d_%H%M%S") 
BACKUP_DIR="$HOME/backups/backend" 
mkdir -p "$BACKUP_DIR" 
tar -czvf "$BACKUP_DIR/backend_backup_$TIMESTAMP.tar.gz" /home/ vagrant/ youtubeclone-backend 
