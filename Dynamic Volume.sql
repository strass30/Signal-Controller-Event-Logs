--Returns binned detector actuations for ALL detectors, with a single column for each detector, for a single signal--
--Last Updated by: SHS 2/5/2020--

--USER DEFINES THREE VARIABLES BELOW:
DECLARE @DeviceID INT = 101;--Specify signal DeviceID
DECLARE @DaysAgo AS INT = 1;--Query length in Days
DECLARE @BinSize AS INT = 15;--Bin size in minutes



--Temporary table with 4 columns: Timestamp, Bin Size, Detector#, Total Actuations
SELECT 
	Dateadd(minute, datediff(minute,0,TimeStamp)/@BinSize * @BinSize, 0) as TIMESTAMP, 
	@BinSize as BinSize, 
	Parameter as Detector, 
	Count(*) as Total
INTO #temp
FROM ASCEvents --This is the name of a view which combines all MaxView Event Tables
WHERE EventID=82 and TimeStamp >=(GETDATE()-@DaysAgo) and DeviceID=@DeviceID
GROUP BY dateadd(minute, datediff(minute,0,TimeStamp)/@BinSize * @BinSize, 0), Parameter

--Dynamic query to pivot above into a single column for each detector--
Declare @cols as NVARCHAR(MAX),
		@query as NVARCHAR(MAX);

SET @cols = STUFF((SELECT distinct ',' + QUOTENAME(c.Detector)  
            FROM #temp c
            FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,'')
SET @query = 'SELECT TIMESTAMP, BinSize, ' + @cols + ' from #temp
            pivot (
			max(Total) for Detector in (' + @cols + ')
            ) p '
EXECUTE(@query)
DROP TABLE #temp
