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
