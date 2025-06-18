-- Script to anonymize rate information in the TimeTracker database
-- Randomizes rates in the TT_ProjectMembersRates table to values between $20 and $65 (whole dollar amounts)

PRINT '-- Begin anonymizing rate information';
USE TimeTracker;

-- First, let's see the structure of the table to identify the rate columns
PRINT '-- Table structure:';
EXEC sp_columns 'TT_ProjectMembersRates';

-- Make a backup of the original data (optional, comment out if not needed)
PRINT '-- Creating backup table for original rates:';
IF OBJECT_ID('TT_ProjectMembersRates_Backup', 'U') IS NOT NULL
    DROP TABLE TT_ProjectMembersRates_Backup;

SELECT * INTO TT_ProjectMembersRates_Backup FROM TT_ProjectMembersRates;

-- Now update the rates with random values between 20 and 65
PRINT '-- Updating rates with random values:';
DECLARE @MinRate INT = 20;
DECLARE @MaxRate INT = 65;

-- Update rate columns based on the actual table structure
-- This uses CHECKSUM with NEWID() to generate different random values for each row
BEGIN TRANSACTION;

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

-- Make sure the randomization worked as expected
PRINT '-- Sample of updated rates:';
SELECT TOP 10 RateID, ProjectID, UserID, PayType_ID, HourlyRate, FlatFeeAmt, EffDate, EndDate 
FROM TT_ProjectMembersRates;

-- Check for any hourly rates outside our target range (should be none)
PRINT '-- Verification - hourly rates outside target range:';
SELECT COUNT(*) AS OutOfRangeCountHourly
FROM TT_ProjectMembersRates 
WHERE HourlyRate < @MinRate OR HourlyRate > @MaxRate;

-- Check for any flat fee rates that should have been changed but weren't
PRINT '-- Verification - flat fee amounts that should have been changed:';
SELECT COUNT(*) AS OutOfRangeFlatFee
FROM TT_ProjectMembersRates 
WHERE FlatFeeAmt > 0 AND (FlatFeeAmt < (@MinRate * 8) OR FlatFeeAmt > (@MaxRate * 8));

-- Show statistics on the randomized rates
PRINT '-- Rate statistics after randomization:';
SELECT 
    COUNT(*) AS TotalRateRecords,
    AVG(HourlyRate) AS AvgHourlyRate,
    MIN(HourlyRate) AS MinHourlyRate,
    MAX(HourlyRate) AS MaxHourlyRate,
    COUNT(DISTINCT HourlyRate) AS UniqueHourlyRateValues
FROM TT_ProjectMembersRates;

-- Show statistics for flat fees (if any are non-zero)
PRINT '-- Flat fee statistics after randomization:';
SELECT 
    COUNT(*) AS TotalWithFlatFee,
    AVG(FlatFeeAmt) AS AvgFlatFeeAmt,
    MIN(FlatFeeAmt) AS MinFlatFeeAmt,
    MAX(FlatFeeAmt) AS MaxFlatFeeAmt
FROM TT_ProjectMembersRates
WHERE FlatFeeAmt > 0;

-- If everything looks good, commit the transaction
COMMIT TRANSACTION;

PRINT '-- Rate anonymization complete!';
