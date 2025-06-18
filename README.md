# TimeTracker Database Restoration

This project sets up SQL Server in a Docker container and restores the TimeTracker database from a backup file.

## Prerequisites

- Docker and Docker Compose installed on your system
- The TimeTracker database backup file (`timetracker.bak`) in the `bak` folder

## Database Contents

The restored TimeTracker database contains 58 tables including:
- User management (TT_Users, aspnet_Users, etc.)
- Projects (TT_Projects, TT_ProjectMembers, etc.)
- Time tracking (TT_TimeSheet, TT_TimeCard, etc.)
- Client data (TT_Clients, TT_BillTos, etc.)
- Various lookup tables

## Files Structure

```
TimeTrackerDatabase/
├── bak/
│   ├── timetracker.bak
│   └── timetracker_anonymized.bak (will be created)
├── script/
│   ├── restore.sql
│   ├── anonymize-rates.sql
│   └── create-anonymized-backup.sql
├── docker-compose.yml
├── run-restore.ps1
├── run-restore.sh
├── anonymize-rates.ps1
└── create-anonymized-backup.ps1
```

## Instructions

1. Start the SQL Server container:

```
docker compose up -d
```

2. Run the restore script:

On Windows:
```
.\run-restore.ps1
```

On Linux/macOS:
```
bash run-restore.sh
```

3. The script will:
   - Connect to the container
   - Execute the restore script using SQLCMD
   - Extract logical file names from the backup and display them
   - Dynamically generate the restore command based on actual file structure
   - Execute the restore operation
   - Verify that the database was restored successfully
   - Display all tables in the restored database
   
4. Optional: Anonymize sensitive rate information:
   ```
   .\anonymize-rates.ps1
   ```
   - This script will randomize all rates in the TT_ProjectMembersRates table
   - Rates will be set to random whole dollar values between $20 and $65
   - A backup of the original data is created in TT_ProjectMembersRates_Backup
   
5. Create a new backup file with anonymized data:
   ```
   .\create-anonymized-backup.ps1
   ```
   - This script will first drop the TT_ProjectMembersRates_Backup table that contains sensitive data
   - It will then anonymize the rates data in the current database
   - It will create a new backup file named `timetracker_anonymized.bak`
   - The backup file will be copied from the container to your local `bak/` folder

## Notes

- Default SA password is set to `StrongPassword123!`. You should change this to a more secure password in the `docker-compose.yml` file.
- The backup file is mounted from your local `bak` folder to `/var/opt/mssql/backup` in the container.
- The script folder is mounted from your local `script` folder to `/var/opt/mssql/script` in the container.
