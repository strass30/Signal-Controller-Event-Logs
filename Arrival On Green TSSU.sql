--Revised 2-11-2020 SHS. 
--Calculates percent arrival on green for a specified vehicle phase and detector number
--join green start/end table to detector table where detector timestamp column is between start and end timestamps of green table.

--Declare variable, including phase number and MaxTime detector number
	DECLARE @TSSU as VARCHAR(5) =10034;
	DECLARE @Phase as INT=2;
	DECLARE @MT as INT=53;
	DECLARE @BinSize AS INT = 15;
	DECLARE @DaysAgo AS INT = 180;


	--Run query!--
DECLARE @DeviceID AS INT 
SET @DeviceID= (
SELECT GroupableElements.ID
FROM [MaxView_1.9.0.744].[dbo].[GroupableElements]
WHERE Right(GroupableElements.Number,5) = @TSSU)

	;WITH 
	Green as (
	SELECT Lag(TimeStamp) OVER (PARTITION BY Parameter ORDER BY TimeStamp) as BeginGreen, TimeStamp as EndGreen, EventID
	FROM ASCEvents
	WHERE DeviceId=@DeviceID and (EventID=0 or EventID=7) and Parameter=@Phase and 
	(TimeStamp BETWEEN (dateadd(minute, datediff(minute,0,(GETDATE()-@DaysAgo))/@BinSize * @BinSize, 0)) and (dateadd(minute, datediff(minute,0,GETDATE())/@BinSize * @BinSize, 0)))
	),

	FilteredGreen as (
	SELECT BeginGreen, EndGreen, CONVERT(DATE,BeginGreen) as GreenDate FROM Green WHERE EventID=7
	),

	Actuations as (
	SELECT TimeStamp as ArrivalTime, dateadd(minute, datediff(minute,0,TimeStamp)/@BinSize * @BinSize, 0) as TimePeriod, CONVERT(DATE,TimeStamp) as ActuationDate
	FROM ASCEvents
	WHERE DeviceID=@DeviceID and EventID=82 and Parameter=@MT and
	(TimeStamp BETWEEN (dateadd(minute, datediff(minute,0,(GETDATE()-@DaysAgo))/@BinSize * @BinSize, 0)) and (dateadd(minute, datediff(minute,0,GETDATE())/@BinSize * @BinSize, 0)))
	), 

	Total as (
	SELECT TimePeriod, Count(TimePeriod) as TotalActuations FROM Actuations Group By TimePeriod
	),

	AOG_Table as (
	SELECT TimePeriod, COUNT(TimePeriod) as AOG
	FROM FilteredGreen, Actuations
	WHERE ActuationDate=GreenDate and (ArrivalTime Between BeginGreen and EndGreen)
	Group By TimePeriod
	)

	SELECT Total.TimePeriod, AOG*100/TotalActuations as Percent_AOG
	FROM Total
	LEFT JOIN AOG_Table ON AOG_Table.TimePeriod=Total.TimePeriod
	ORDER BY TimePeriod
	
	
