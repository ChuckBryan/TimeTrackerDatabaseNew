1. Download SQL Server Image (latest version). Accept the Eula and create a password. 
2. Mount the bak folder so that a bak inside it can be restored in the container
3. Mount the script folder so that the script can be run
4. connect to the running container and run the restore script using ISQL
5. Be sure to get the file names inside the backup so that it can be restored.
6. SQL Server Docker Details: https://hub.docker.com/r/microsoft/mssql-server/