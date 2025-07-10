#!/bin/bash
# Script to connect to the SQL Server container and run the timebilling restore script
# Make sure the container is running with docker-compose up -d before running this script

# Run the restore script using sqlcmd with SSL certificate validation disabled
echo "Running TimeBilling restore script..."
echo "Extracting file information and dynamically restoring the TimeBilling database..."
docker exec -it timetracker-sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P StrongPassword123! -i /var/opt/mssql/script/timebilling-restore.sql -C -N

echo "TimeBilling restore process completed!"
