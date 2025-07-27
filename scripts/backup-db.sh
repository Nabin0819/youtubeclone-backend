#!/bin/bash 
TIMESTAMP=$(date +"%Y%m%d_%H%M%S") 
BACKUP_DIR="$HOME/backups/database" 
mkdir -p "$BACKUP_DIR" 
PGPASSWORD=LlhyTlyxtfXarGySNQbsglVTdXxnHpQo pg_dump -h shuttle.proxy.rlwy.net -p 36287 -U postgres -d railway > "$BACKUP_DIR/db_backup_$TIMESTAMP.sql"
