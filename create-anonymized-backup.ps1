# Script to anonymize data and create a new backup with anonymized data
# This script will:
# 1. Anonymize the sensitive rate information
# 2. Create a new backup file with the anonymized data

Write-Host "Starting to anonymize data and create new backup..." -ForegroundColor Cyan

# Run the script to anonymize data and create a new backup
Write-Host "Anonymizing rate data and creating backup..." -ForegroundColor Yellow
docker exec -it timetracker-sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P StrongPassword123! -i /var/opt/mssql/script/create-anonymized-backup.sql -C -N

# Copy the anonymized backup file from the container to the host (optional)
Write-Host "Copying anonymized backup from container to host..." -ForegroundColor Yellow
docker cp timetracker-sqlserver:/var/opt/mssql/backup/timetracker_anonymized.bak ./bak/

Write-Host "Process completed!" -ForegroundColor Green
Write-Host "The anonymized backup is available at: ./bak/timetracker_anonymized.bak" -ForegroundColor Green
