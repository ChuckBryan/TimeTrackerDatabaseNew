-- Step 1: Display the logical file names from the backup file for information
PRINT '-- File list from backup:';
RESTORE FILELISTONLY FROM DISK = '/var/opt/mssql/backup/timebilling.bak';
GO

-- Step 2: Restore the database with explicit MOVE statements for data and log files
-- We'll extract the logical file names from the backup first
PRINT '-- Restoring database:';
RESTORE DATABASE TimeBilling 
FROM DISK = '/var/opt/mssql/backup/timebilling.bak' 
WITH 
    MOVE 'TimeBilling_Data' TO '/var/opt/mssql/data/TimeBilling.mdf',
    MOVE 'TimeBilling_Log' TO '/var/opt/mssql/data/TimeBilling_log.ldf',
    REPLACE, 
    STATS = 10,
    MAXTRANSFERSIZE = 1048576,
    RECOVERY;
GO

-- Step 3: Verify the database is restored
PRINT '-- Verifying database restoration:';
SELECT name, database_id, state_desc FROM sys.databases WHERE name = 'TimeBilling';
GO

-- Step 4: Show the tables in the restored database (only if the database exists)
PRINT '-- Listing tables in the restored database:';
IF DB_ID('TimeBilling') IS NOT NULL
BEGIN
    USE TimeBilling;
    SELECT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_SCHEMA, TABLE_NAME;
END
ELSE
BEGIN
    PRINT 'Database TimeBilling does not exist or was not restored successfully.';
END
GO
