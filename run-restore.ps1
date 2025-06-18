# Script to connect to the SQL Server container and run the restore script
# Make sure the container is running with docker-compose up -d before running this script

# Run the restore script using sqlcmd with SSL certificate validation disabled
Write-Host "Running restore script..."
Write-Host "Extracting file information and dynamically restoring the database..."
docker exec -it timetracker-sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P StrongPassword123! -i /var/opt/mssql/script/restore.sql -C -N

Write-Host "Restore process completed!"
