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
