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
