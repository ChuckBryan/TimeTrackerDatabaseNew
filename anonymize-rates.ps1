# Script to anonymize rate information in the TimeTracker database
# Randomizes rates to values between $20 and $65

Write-Host "Running rate anonymization script..."
docker exec -it timetracker-sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P StrongPassword123! -i /var/opt/mssql/script/anonymize-rates.sql -C -N

Write-Host "Rate anonymization completed!"
