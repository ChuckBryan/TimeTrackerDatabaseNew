-- Script to drop all tables except tblBillableExpenses in the TimeBilling database
USE TimeBilling;
GO

-- Disable foreign key constraints to avoid dependency issues
EXEC sp_MSforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT ALL";
GO

-- Create a dynamic SQL statement to drop all tables except tblBillableExpenses
DECLARE @sql NVARCHAR(MAX) = '';
SELECT @sql = @sql + 'DROP TABLE ' + QUOTENAME(schema_name(schema_id)) + '.' + QUOTENAME(name) + '; '
FROM sys.tables
WHERE name != 'tblBillableExpenses'
  AND name NOT IN ('sysdiagrams'); -- Skip system tables

-- Print the generated SQL for inspection before execution
PRINT '-- Tables to be dropped:';
SELECT QUOTENAME(schema_name(schema_id)) + '.' + QUOTENAME(name) as TableName
FROM sys.tables
WHERE name != 'tblBillableExpenses'
  AND name NOT IN ('sysdiagrams')
ORDER BY name;

-- Execute the generated SQL to drop the tables
PRINT '-- Executing DROP statements:';
EXEC sp_executesql @sql;
GO

-- Verify that only tblBillableExpenses remains
PRINT '-- Tables remaining after cleanup:';
SELECT TABLE_SCHEMA, TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;
GO
