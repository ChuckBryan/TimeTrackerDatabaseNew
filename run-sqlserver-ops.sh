#!/bin/bash
# Consolidated SQL Server operations script
# Usage: ./run-sqlserver-ops.sh [action]
# Available actions:
#   restore-timetracker - Restore TimeTracker database
#   restore-timebilling - Restore TimeBilling database
#   cleanup-timebilling - Drop all tables except tblBillableExpenses in TimeBilling
#   backup-timebilling  - Create backup of TimeBilling with only tblBillableExpenses
#   anonymize-rates     - Anonymize rate information in TimeTracker database
#   create-anon-backup  - Create anonymized backup of TimeTracker database
#   help                - Show this help message

# Make sure the container is running with docker-compose up -d before running this script

# Default container name
CONTAINER_NAME="timetracker-sqlserver"
# Default SQL credentials
SQL_USER="sa"
SQL_PASSWORD="StrongPassword123!"
# Script paths inside container
TIMETRACKER_SCRIPT="/var/opt/mssql/script/restore.sql"
TIMEBILLING_SCRIPT="/var/opt/mssql/script/timebilling-restore.sql"
CLEANUP_SCRIPT="/var/opt/mssql/script/drop-all-but-billable-expenses.sql"
BACKUP_TB_SCRIPT="/var/opt/mssql/script/backup-timebilling-billable-expenses.sql"
ANONYMIZE_RATES_SCRIPT="/var/opt/mssql/script/anonymize-rates.sql"
CREATE_ANON_BACKUP_SCRIPT="/var/opt/mssql/script/create-anonymized-backup.sql"

# Function to execute a SQL script
run_sql_script() {
    local script_path=$1
    local description=$2
    
    echo "Running $description..."
    docker exec -it $CONTAINER_NAME /opt/mssql-tools18/bin/sqlcmd -S localhost -U $SQL_USER -P $SQL_PASSWORD -i $script_path -C -N
    echo "$description completed!"
}

# Function to show help
show_help() {
    echo "SQL Server Operations Script"
    echo "Usage: ./run-sqlserver-ops.sh [action]"
    echo ""
    echo "Available actions:"
    echo "  restore-timetracker - Restore TimeTracker database"
    echo "  restore-timebilling - Restore TimeBilling database"
    echo "  cleanup-timebilling - Drop all tables except tblBillableExpenses in TimeBilling"
    echo "  backup-timebilling  - Create backup of TimeBilling with only tblBillableExpenses"
    echo "  anonymize-rates     - Anonymize rate information in TimeTracker database"
    echo "  create-anon-backup  - Create anonymized backup of TimeTracker database"
    echo "  help                - Show this help message"
}

# Check if action is provided
if [ $# -eq 0 ]; then
    echo "Error: No action specified."
    show_help
    exit 1
fi

# Execute action based on parameter
case "$1" in
    "restore-timetracker")
        run_sql_script "$TIMETRACKER_SCRIPT" "TimeTracker restore script"
        ;;
    "restore-timebilling")
        run_sql_script "$TIMEBILLING_SCRIPT" "TimeBilling restore script"
        ;;
    "cleanup-timebilling")
        run_sql_script "$CLEANUP_SCRIPT" "TimeBilling cleanup script (dropping all tables except tblBillableExpenses)"
        ;;
    "backup-timebilling")
        run_sql_script "$BACKUP_TB_SCRIPT" "TimeBilling backup script (creating backup with only tblBillableExpenses)"
        ;;
    "anonymize-rates")
        run_sql_script "$ANONYMIZE_RATES_SCRIPT" "Anonymize rate information in TimeTracker database"
        ;;
    "create-anon-backup")
        run_sql_script "$CREATE_ANON_BACKUP_SCRIPT" "Create anonymized backup of TimeTracker database"
        ;;
    "help")
        show_help
        ;;
    *)
        echo "Error: Unknown action '$1'"
        show_help
        exit 1
        ;;
esac

exit 0
