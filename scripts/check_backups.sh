#!/bin/sh

# Backup Monitoring Script

set -e

BACKUP_DIR="/backups"
MAX_AGE_HOURS=25  # Alert if backup is older than 25 hours
WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"  # Slack webhook for alerts

# Function to check if backup exists and is recent
check_backup() {
    local service_name=$1
    local backup_path="$BACKUP_DIR/$service_name"
    
    echo "Checking backups for $service_name..."
    
    if [ ! -d "$backup_path" ]; then
        echo "Backup directory for $service_name not found!"
        send_alert "Backup directory for $service_name not found!"
        return 1
    fi
    
    # Find the most recent backup
    latest_backup=$(find "$backup_path" -name "*.gz" -type f -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2-)
    
    if [ -z "$latest_backup" ]; then
        echo "No backup files found for $service_name!"
        send_alert "No backup files found for $service_name!"
        return 1
    fi
    
    # Check backup age
    backup_time=$(stat -c %Y "$latest_backup" 2>/dev/null || echo 0)
    current_time=$(date +%s)
    age_hours=$(( (current_time - backup_time) / 3600 ))
    
    echo "Latest backup: $(basename "$latest_backup")"
    echo "Backup age: $age_hours hours"
    
    if [ $age_hours -gt $MAX_AGE_HOURS ]; then
        echo "Backup for $service_name is too old ($age_hours hours)!"
        send_alert "Backup for $service_name is too old ($age_hours hours)!"
        return 1
    fi
    
    # Check backup integrity
    if gzip -t "$latest_backup" 2>/dev/null; then
        echo "Backup for $service_name is valid and recent"
        return 0
    else
        echo "Backup for $service_name is corrupted!"
        send_alert "Backup for $service_name is corrupted!"
        return 1
    fi
}

# Function to send alerts (Slack webhook example)
send_alert() {
    local message=$1
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "ALERT: $message"
    
    if [ -n "$WEBHOOK_URL" ]; then
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"Backup Alert [$timestamp]: $message\"}" \
            "$WEBHOOK_URL" 2>/dev/null || echo "Failed to send Slack alert"
    fi
}

# Function to generate backup report
generate_report() {
    local report_file="/backups/backup_report_$(date +%Y%m%d).txt"
    
    echo "=== Backup Report ===" > "$report_file"
    echo "Generated: $(date)" >> "$report_file"
    echo "" >> "$report_file"
    
    for service in mysql keycloak; do
        echo "--- $service ---" >> "$report_file"
        if [ -d "$BACKUP_DIR/$service" ]; then
            echo "Backup files:" >> "$report_file"
            ls -lah "$BACKUP_DIR/$service"/*.gz 2>/dev/null | tail -5 >> "$report_file" || echo "No backup files found" >> "$report_file"
            echo "" >> "$report_file"
            
            # Disk usage
            echo "Disk usage:" >> "$report_file"
            du -sh "$BACKUP_DIR/$service" >> "$report_file"
            echo "" >> "$report_file"
        else
            echo "Backup directory not found!" >> "$report_file"
            echo "" >> "$report_file"
        fi
    done
    
    echo "Report saved to: $report_file"
}

# Main execution
echo "Starting backup monitoring check..."
echo "Timestamp: $(date)"
echo "==============================="

# Check each service backup
mysql_ok=0
keycloak_ok=0

check_backup "mysql" && mysql_ok=1
echo ""
check_backup "keycloak" && keycloak_ok=1
echo ""

# Generate report
generate_report

# Summary
echo "==============================="
echo "Backup Check Summary:"
echo "MySQL: $([ $mysql_ok -eq 1 ] && echo 'OK' || echo 'FAILED')"
echo "Keycloak: $([ $keycloak_ok -eq 1 ] && echo 'OK' || echo 'FAILED')"

if [ $mysql_ok -eq 1 ] && [ $keycloak_ok -eq 1 ]; then
    echo "All backups are healthy!"
    exit 0
else
    echo "Some backups have issues!"
    exit 1
fi