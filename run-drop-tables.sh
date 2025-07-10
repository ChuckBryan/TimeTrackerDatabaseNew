#!/bin/bash
# Script to connect to the SQL Server container and run the drop tables script
# Make sure the container is running with docker-compose up -d before running this script

# Run the drop tables script using sqlcmd
echo "Running script to drop all tables except tblBillableExpenses..."
docker exec -it timetracker-sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P StrongPassword123! -i /var/opt/mssql/script/drop-all-but-billable-expenses.sql -C -N

echo "Table cleanup process completed!"
