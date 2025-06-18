-- Script to anonymize rate information and create a new backup file with anonymized data

PRINT '-- Begin anonymizing rate information and creating new backup';
USE TimeTracker;

-- First, check if the backup table exists and drop it to remove sensitive data
PRINT '-- Checking for and removing sensitive backup tables';
IF OBJECT_ID('TT_ProjectMembersRates_Backup', 'U') IS NOT NULL
BEGIN
    PRINT '-- Dropping TT_ProjectMembersRates_Backup table to remove sensitive data';
    DROP TABLE TT_ProjectMembersRates_Backup;
END
ELSE
BEGIN
    PRINT '-- No backup table found, proceeding with anonymization';
END

-- Now anonymize the data
PRINT '-- Anonymizing rate data:';
DECLARE @MinRate INT = 20;
DECLARE @MaxRate INT = 65;

-- Update rate columns based on the actual table structure
UPDATE TT_ProjectMembersRates
SET 
    -- Update the HourlyRate column with a random whole dollar amount between 20 and 65
    HourlyRate = @MinRate + (ABS(CHECKSUM(NEWID())) % (@MaxRate - @MinRate + 1)),
    
    -- Update the FlatFeeAmt column for any flat fee records
    -- Only randomize if it's not zero (assuming zero means "not used")
    FlatFeeAmt = CASE
                    WHEN FlatFeeAmt > 0 THEN @MinRate + (ABS(CHECKSUM(NEWID())) % (@MaxRate - @MinRate + 1)) * 8 -- Assuming a typical day rate
                    ELSE FlatFeeAmt -- Keep it as 0 if it was 0
                 END;

-- Show sample of updated rates
PRINT '-- Sample of anonymized rates:';
SELECT TOP 10 RateID, ProjectID, UserID, PayType_ID, HourlyRate, FlatFeeAmt, EffDate, EndDate 
FROM TT_ProjectMembersRates;

-- Show statistics on the randomized rates
PRINT '-- Rate statistics after anonymization:';
SELECT 
    COUNT(*) AS TotalRateRecords,
    AVG(HourlyRate) AS AvgHourlyRate,
    MIN(HourlyRate) AS MinHourlyRate,
    MAX(HourlyRate) AS MaxHourlyRate,
    COUNT(DISTINCT HourlyRate) AS UniqueHourlyRateValues
FROM TT_ProjectMembersRates;

-- Now create a backup of the anonymized database
PRINT '-- Creating backup of anonymized database:';
BACKUP DATABASE TimeTracker
TO DISK = '/var/opt/mssql/backup/timetracker_anonymized.bak'
WITH 
    COMPRESSION,
    STATS = 10,
    DESCRIPTION = 'Full backup of TimeTracker database with anonymized rate data';

PRINT '-- Backup of anonymized database completed!';
