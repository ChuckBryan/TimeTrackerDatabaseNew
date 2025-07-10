# Script to connect to the SQL Server container and run the timebilling restore script
# Make sure the container is running with docker-compose up -d before running this script

# Run the restore script using sqlcmd with SSL certificate validation disabled
Write-Host "Running TimeBilling restore script..."
Write-Host "Extracting file information and dynamically restoring the TimeBilling database..."
docker exec -it timetracker-sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P StrongPassword123! -i /var/opt/mssql/script/timebilling-restore.sql -C -N

Write-Host "TimeBilling restore process completed!"
