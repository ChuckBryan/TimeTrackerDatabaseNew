-- Script to backup TimeBilling database (with only tblBillableExpenses)
USE master;
GO

-- Set backup file path
DECLARE @BackupFilePath NVARCHAR(255) = '/var/opt/mssql/backup/timebilling-billable-expenses-only.bak';

-- Verify that the database exists
IF EXISTS (SELECT name
FROM sys.databases
WHERE name = 'TimeBilling')
BEGIN
    PRINT '-- Creating backup of TimeBilling database with only tblBillableExpenses table:';

    -- Create the backup
    BACKUP DATABASE TimeBilling 
    TO DISK = @BackupFilePath
    WITH 
        FORMAT, -- Overwrite any existing backup file
        COMPRESSION, -- Use compression for smaller backups
        STATS = 10, -- Show progress every 10%
        NAME = 'TimeBilling-BillableExpensesOnly-Full';
    -- Name of the backup set

    PRINT '-- Backup completed. File saved to: ' + @BackupFilePath;

    -- Verify the backup file
    RESTORE VERIFYONLY FROM DISK = @BackupFilePath;
END
ELSE
BEGIN
    PRINT 'Database TimeBilling does not exist.';
END
GO
