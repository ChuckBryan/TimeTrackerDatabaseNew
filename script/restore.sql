-- Step 1: Display the logical file names from the backup file for information
PRINT '-- File list from backup:';
RESTORE FILELISTONLY FROM DISK = '/var/opt/mssql/backup/timetracker.bak';
GO

-- Step 2: Restore the database with explicit MOVE statements for data and log files
PRINT '-- Restoring database:';
RESTORE DATABASE TimeTracker 
FROM DISK = '/var/opt/mssql/backup/timetracker.bak' 
WITH 
    MOVE 'TimeTracker_Data' TO '/var/opt/mssql/data/TimeTracker.mdf',
    MOVE 'TimeTracker_Log' TO '/var/opt/mssql/data/TimeTracker_log.ldf',
    REPLACE, 
    STATS = 10,
    MAXTRANSFERSIZE = 1048576,
    RECOVERY;
GO

-- Step 3: Verify the database is restored
PRINT '-- Verifying database restoration:';
SELECT name, database_id, state_desc FROM sys.databases WHERE name = 'TimeTracker';
GO

-- Step 4: Show the tables in the restored database (only if the database exists)
PRINT '-- Listing tables in the restored database:';
IF DB_ID('TimeTracker') IS NOT NULL
BEGIN
    USE TimeTracker;
    SELECT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_SCHEMA, TABLE_NAME;
END
ELSE
BEGIN
    PRINT 'Database TimeTracker does not exist or was not restored successfully.';
END
GO
