#!/bin/bash

# Backup Setup Script
# Run this script to set up the backup system

set -e

echo "Setting up automated backup system..."

# Create necessary directories
echo "Creating backup directories..."
mkdir -p backups/{mysql,keycloak}
mkdir -p scripts
mkdir -p logs

# Set permissions
chmod -R 755 backups
chmod -R 755 scripts

# Create backup monitoring script if it doesn't exist
if [ ! -f "scripts/check_backups.sh" ]; then
    echo "Creating backup monitoring script..."
    # The script content would be the check_backups.sh from above
    # Copy it to scripts/check_backups.sh and make it executable
    chmod +x scripts/check_backups.sh
fi

# Create a manual backup script
cat > scripts/manual_backup.sh << 'EOF'
#!/bin/bash

# Manual backup script
# Usage: ./scripts/manual_backup.sh [mysql|keycloak|all]

set -e

# Load environment variables
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found!"
    exit 1
fi

DATE=$(date +%Y%m%d_%H%M%S)

backup_mysql() {
    echo "Creating manual backup for MySQL (ticketing database)..."
    docker exec ticketing-mysql mysqldump \
        -u${MYSQL_USER} \
        -p${MYSQL_PASSWORD} \
        --routines \
        --triggers \
        --single-transaction \
        --lock-tables=false \
        ticketing | gzip > backups/mysql/manual_ticketing_${DATE}.sql.gz
    
    echo "MySQL backup completed: manual_ticketing_${DATE}.sql.gz"
}

backup_keycloak() {
    echo "Creating manual backup for Keycloak database..."
    docker exec keycloak-mysql mysqldump \
        -u${MYSQL_USER} \
        -p${MYSQL_PASSWORD} \
        --routines \
        --triggers \
        --single-transaction \
        --lock-tables=false \
        keycloak | gzip > backups/keycloak/manual_keycloak_${DATE}.sql.gz
    
    echo "Keycloak backup completed: manual_keycloak_${DATE}.sql.gz"
}

case ${1:-all} in
    "mysql")
        backup_mysql
        ;;
    "keycloak")
        backup_keycloak
        ;;
    "all")
        backup_mysql
        backup_keycloak
        ;;
    *)
        echo "Usage: $0 [mysql|keycloak|all]"
        exit 1
        ;;
esac

echo "Manual backup completed!"
EOF

chmod +x scripts/manual_backup.sh

# Create a restore script
cat > scripts/restore.sh << 'EOF'
#!/bin/bash

# Database Restore Script
# Usage: ./scripts/restore.sh [mysql|keycloak] <backup_file>

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 [mysql|keycloak] <backup_file>"
    exit 1
fi

SERVICE=$1
BACKUP_FILE=$2

if [ ! -f "$BACKUP_FILE" ]; then
    echo "Error: Backup file '$BACKUP_FILE' not found!"
    exit 1
fi

# Load environment variables
if [ -f .env ]; then
    source .env
else
    echo "Error: .env file not found!"
    exit 1
fi

restore_mysql() {
    echo "Restoring MySQL (ticketing) database from: $BACKUP_FILE"
    echo "WARNING: This will OVERWRITE the current ticketing database!"
    read -p "Are you sure you want to continue? (type 'yes' to confirm): " confirm
    
    if [ "$confirm" != "yes" ]; then
        echo "Restore cancelled"
        exit 0
    fi
    
    echo "Dropping and recreating ticketing database..."
    docker exec ticketing-mysql mysql \
        -u${MYSQL_USER} \
        -p${MYSQL_PASSWORD} \
        -e "DROP DATABASE IF EXISTS ticketing; CREATE DATABASE ticketing;"
    
    echo "Restoring from backup..."
    gunzip -c "$BACKUP_FILE" | docker exec -i ticketing-mysql mysql \
        -u${MYSQL_USER} \
        -p${MYSQL_PASSWORD} \
        ticketing
    
    echo "MySQL restore completed!"
}

restore_keycloak() {
    echo "Restoring Keycloak database from: $BACKUP_FILE"
    echo "WARNING: This will OVERWRITE the current keycloak database!"
    read -p "Are you sure you want to continue? (type 'yes' to confirm): " confirm
    
    if [ "$confirm" != "yes" ]; then
        echo "Restore cancelled"
        exit 0
    fi
    
    echo "Dropping and recreating keycloak database..."
    docker exec keycloak-mysql mysql \
        -u${MYSQL_USER} \
        -p${MYSQL_PASSWORD} \
        -e "DROP DATABASE IF EXISTS keycloak; CREATE DATABASE keycloak;"
    
    echo "Restoring from backup..."
    gunzip -c "$BACKUP_FILE" | docker exec -i keycloak-mysql mysql \
        -u${MYSQL_USER} \
        -p${MYSQL_PASSWORD} \
        keycloak
    
    echo "Keycloak restore completed!"
}

case $SERVICE in
    "mysql")
        restore_mysql
        ;;
    "keycloak")
        restore_keycloak
        ;;
    *)
        echo "Error: Service must be 'mysql' or 'keycloak'"
        exit 1
        ;;
esac
EOF

chmod +x scripts/restore.sh

# Create environment file template if it doesn't exist
if [ ! -f .env ]; then
    echo "Creating .env template..."
    cat > .env << 'EOF'
# Database Configuration
MYSQL_ROOT_PASSWORD=your_strong_root_password
MYSQL_USER=your_db_user
MYSQL_PASSWORD=your_strong_password

# Optional: Slack webhook for backup alerts
# SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
EOF
    echo "Please update the .env file with your actual database credentials!"
fi

# Create a backup status script
cat > scripts/backup_status.sh << 'EOF'
#!/bin/bash

# Backup Status Script - Shows current backup status

echo "=== Backup Status ==="
echo "Current time: $(date)"
echo ""

for service in mysql keycloak; do
    echo "--- $service backups ---"
    backup_dir="backups/$service"
    
    if [ -d "$backup_dir" ]; then
        echo "Recent backups:"
        ls -lht "$backup_dir"/*.gz 2>/dev/null | head -3 || echo "No backup files found"
        echo ""
        echo "Disk usage: $(du -sh "$backup_dir" 2>/dev/null || echo 'N/A')"
        echo ""
        
        # Check if backup is recent (within 25 hours)
        latest=$(find "$backup_dir" -name "*.gz" -type f -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2-)
        if [ -n "$latest" ]; then
            backup_time=$(stat -c %Y "$latest" 2>/dev/null || echo 0)
            current_time=$(date +%s)
            age_hours=$(( (current_time - backup_time) / 3600 ))
            
            if [ $age_hours -le 25 ]; then
                echo "Status: Recent backup available ($age_hours hours old)"
            else
                echo "Status: Backup is old ($age_hours hours old)"
            fi
        else
            echo "Status: No backups found"
        fi
    else
        echo "Status: Backup directory not found"
    fi
    echo ""
done

echo "=== Container Status ==="
docker ps --filter "name=backup" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
EOF

chmod +x scripts/backup_status.sh

echo ""
echo "Backup system setup completed!"
echo ""
echo "Next steps:"
echo "1. Update the .env file with your database credentials"
echo "2. Run: docker-compose up -d mysql-backup keycloak-backup"
echo "3. Check status: ./scripts/backup_status.sh"
echo "4. Test manual backup: ./scripts/manual_backup.sh"
echo ""
echo "Available scripts:"
echo "- scripts/backup_status.sh    - Check backup status"
echo "- scripts/manual_backup.sh    - Create manual backup"
echo "- scripts/restore.sh          - Restore from backup"
echo "- scripts/check_backups.sh    - Monitor backup health"
