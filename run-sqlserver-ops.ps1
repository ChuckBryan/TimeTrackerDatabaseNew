# Consolidated SQL Server operations script
# Usage: .\run-sqlserver-ops.ps1 [action]
# Available actions:
#   restore-timetracker - Restore TimeTracker database
#   restore-timebilling - Restore TimeBilling database
#   cleanup-timebilling - Drop all tables except tblBillableExpenses in TimeBilling
#   backup-timebilling  - Create backup of TimeBilling with only tblBillableExpenses
#   anonymize-rates     - Anonymize rate information in TimeTracker database
#   create-anon-backup  - Create anonymized backup of TimeTracker database
#   help                - Show this help message

# Make sure the container is running with docker-compose up -d before running this script

param (
    [Parameter(Position=0)]
    [string]$Action = "help"
)

# Default container name
$CONTAINER_NAME = "timetracker-sqlserver"
# Default SQL credentials
$SQL_USER = "sa"
$SQL_PASSWORD = "StrongPassword123!"
# Script paths inside container
$TIMETRACKER_SCRIPT = "/var/opt/mssql/script/restore.sql"
$TIMEBILLING_SCRIPT = "/var/opt/mssql/script/timebilling-restore.sql"
$CLEANUP_SCRIPT = "/var/opt/mssql/script/drop-all-but-billable-expenses.sql"
$BACKUP_TB_SCRIPT = "/var/opt/mssql/script/backup-timebilling-billable-expenses.sql"
$ANONYMIZE_RATES_SCRIPT = "/var/opt/mssql/script/anonymize-rates.sql"
$CREATE_ANON_BACKUP_SCRIPT = "/var/opt/mssql/script/create-anonymized-backup.sql"

# Function to execute a SQL script
function Invoke-SqlScript {
    param (
        [string]$ScriptPath,
        [string]$Description
    )
    
    Write-Host "Running $Description..."
    docker exec -it $CONTAINER_NAME /opt/mssql-tools18/bin/sqlcmd -S localhost -U $SQL_USER -P $SQL_PASSWORD -i $ScriptPath -C -N
    Write-Host "$Description completed!"
}

# Function to show help
function Show-Help {
    Write-Host "SQL Server Operations Script"
    Write-Host "Usage: .\run-sqlserver-ops.ps1 [action]"
    Write-Host ""
    Write-Host "Available actions:"
    Write-Host "  restore-timetracker - Restore TimeTracker database"
    Write-Host "  restore-timebilling - Restore TimeBilling database"
    Write-Host "  cleanup-timebilling - Drop all tables except tblBillableExpenses in TimeBilling"
    Write-Host "  backup-timebilling  - Create backup of TimeBilling with only tblBillableExpenses"
    Write-Host "  anonymize-rates     - Anonymize rate information in TimeTracker database"
    Write-Host "  create-anon-backup  - Create anonymized backup of TimeTracker database"
    Write-Host "  help                - Show this help message"
}

# Execute action based on parameter
switch ($Action) {
    "restore-timetracker" {
        Invoke-SqlScript -ScriptPath $TIMETRACKER_SCRIPT -Description "TimeTracker restore script"
    }
    "restore-timebilling" {
        Invoke-SqlScript -ScriptPath $TIMEBILLING_SCRIPT -Description "TimeBilling restore script"
    }
    "cleanup-timebilling" {
        Invoke-SqlScript -ScriptPath $CLEANUP_SCRIPT -Description "TimeBilling cleanup script (dropping all tables except tblBillableExpenses)"
    }
    "backup-timebilling" {
        Invoke-SqlScript -ScriptPath $BACKUP_TB_SCRIPT -Description "TimeBilling backup script (creating backup with only tblBillableExpenses)"
    }
    "anonymize-rates" {
        Invoke-SqlScript -ScriptPath $ANONYMIZE_RATES_SCRIPT -Description "Anonymize rate information in TimeTracker database"
    }
    "create-anon-backup" {
        Invoke-SqlScript -ScriptPath $CREATE_ANON_BACKUP_SCRIPT -Description "Create anonymized backup of TimeTracker database"
    }
    "help" {
        Show-Help
    }
    default {
        Write-Host "Error: Unknown action '$Action'"
        Show-Help
        exit 1
    }
}
