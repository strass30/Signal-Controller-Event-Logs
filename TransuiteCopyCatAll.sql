
/*This query copycats TransSuite style logs for individual controllers*/

USE MaxView_EventLog
--Set the TSSU ID# Below:
DECLARE @TSSU AS VARCHAR(5) = '23037';

--Set query length in Days
DECLARE @DaysAgo AS INT = 900;

--Set bin size in minutes
DECLARE @BinSize AS INT = 15;


--Run query!--
DECLARE @DeviceID AS INT 
SET @DeviceID= (
SELECT GroupableElements.ID
FROM [MaxView_1.9.0.744].[dbo].[GroupableElements]
WHERE Right(GroupableElements.Number,5) = @TSSU)
--select @DeviceID--
;WITH Volumes AS 
(
SELECT dateadd(minute, datediff(minute,0,TimeStamp)/@BinSize * @BinSize, 0) as VolumeTIMESTAMP, 
@BinSize as Vol_Period,
sum(case when Parameter=1 then 1 else 0 end) as MT01,
sum(case when Parameter=2 then 1 else 0 end) as MT02,
sum(case when Parameter=3 then 1 else 0 end) as MT03,
sum(case when Parameter=4 then 1 else 0 end) as MT04,
sum(case when Parameter=5 then 1 else 0 end) as MT05,
sum(case when Parameter=6 then 1 else 0 end) as MT06,
sum(case when Parameter=7 then 1 else 0 end) as MT07,
sum(case when Parameter=8 then 1 else 0 end) as MT08,
sum(case when Parameter=9 then 1 else 0 end) as MT09,
sum(case when Parameter=10 then 1 else 0 end) as MT10,
sum(case when Parameter=11 then 1 else 0 end) as MT11,
sum(case when Parameter=12 then 1 else 0 end) as MT12,
sum(case when Parameter=13 then 1 else 0 end) as MT13,
sum(case when Parameter=14 then 1 else 0 end) as MT14,
sum(case when Parameter=15 then 1 else 0 end) as MT15,
sum(case when Parameter=16 then 1 else 0 end) as MT16,
sum(case when Parameter=17 then 1 else 0 end) as MT17,
sum(case when Parameter=18 then 1 else 0 end) as MT18,
sum(case when Parameter=19 then 1 else 0 end) as MT19,
sum(case when Parameter=20 then 1 else 0 end) as MT20,
sum(case when Parameter=21 then 1 else 0 end) as MT21,
sum(case when Parameter=22 then 1 else 0 end) as MT22,
sum(case when Parameter=23 then 1 else 0 end) as MT23,
sum(case when Parameter=24 then 1 else 0 end) as MT24,
sum(case when Parameter=25 then 1 else 0 end) as MT25,
sum(case when Parameter=26 then 1 else 0 end) as MT26,
sum(case when Parameter=27 then 1 else 0 end) as MT27,
sum(case when Parameter=28 then 1 else 0 end) as MT28,
sum(case when Parameter=29 then 1 else 0 end) as MT29,
sum(case when Parameter=30 then 1 else 0 end) as MT30,
sum(case when Parameter=31 then 1 else 0 end) as MT31,
sum(case when Parameter=32 then 1 else 0 end) as MT32,
sum(case when Parameter=33 then 1 else 0 end) as MT33,
sum(case when Parameter=34 then 1 else 0 end) as MT34,
sum(case when Parameter=35 then 1 else 0 end) as MT35,
sum(case when Parameter=36 then 1 else 0 end) as MT36,
sum(case when Parameter=37 then 1 else 0 end) as MT37,
sum(case when Parameter=38 then 1 else 0 end) as MT38,
sum(case when Parameter=39 then 1 else 0 end) as MT39,
sum(case when Parameter=40 then 1 else 0 end) as MT40
FROM ASCEvents 
WHERE EventID=81 and 
(TimeStamp BETWEEN (dateadd(minute, datediff(minute,0,(GETDATE()-@DaysAgo))/@BinSize * @BinSize, 0)) and (dateadd(minute, datediff(minute,0,GETDATE())/@BinSize * @BinSize, 0))) and
DeviceID=@DeviceID

group by 
	grouping sets (dateadd(minute, datediff(minute,0,TimeStamp)/@BinSize * @BinSize, 0)) , (DeviceID)
),

MOE AS 
(
SELECT dateadd(minute, datediff(minute,0,TimeStamp)/@BinSize * @BinSize, 0) as moeTIMESTAMP,

sum(case when Parameter=1 and EventID =5 then 1 else 0 end) as MaxOut1,
sum(case when Parameter=2 and EventID =5 then 1 else 0 end) as MaxOut2,
sum(case when Parameter=3 and EventID =5 then 1 else 0 end) as MaxOut3,
sum(case when Parameter=4 and EventID =5 then 1 else 0 end) as MaxOut4,
sum(case when Parameter=5 and EventID =5 then 1 else 0 end) as MaxOut5,
sum(case when Parameter=6 and EventID =5 then 1 else 0 end) as MaxOut6,
sum(case when Parameter=7 and EventID =5 then 1 else 0 end) as MaxOut7,
sum(case when Parameter=8 and EventID =5 then 1 else 0 end) as MaxOut8,

sum(case when Parameter=1 and EventID =6 then 1 else 0 end) as ForceOff1,
sum(case when Parameter=2 and EventID =6 then 1 else 0 end) as ForceOff2,
sum(case when Parameter=3 and EventID =6 then 1 else 0 end) as ForceOff3,
sum(case when Parameter=4 and EventID =6 then 1 else 0 end) as ForceOff4,
sum(case when Parameter=5 and EventID =6 then 1 else 0 end) as ForceOff5,
sum(case when Parameter=6 and EventID =6 then 1 else 0 end) as ForceOff6,
sum(case when Parameter=7 and EventID =6 then 1 else 0 end) as ForceOff7,
sum(case when Parameter=8 and EventID =6 then 1 else 0 end) as ForceOff8,

sum(case when Parameter=1 and EventID =4 then 1 else 0 end) as GapOut1,
sum(case when Parameter=2 and EventID =4 then 1 else 0 end) as GapOut2,
sum(case when Parameter=3 and EventID =4 then 1 else 0 end) as GapOut3,
sum(case when Parameter=4 and EventID =4 then 1 else 0 end) as GapOut4,
sum(case when Parameter=5 and EventID =4 then 1 else 0 end) as GapOut5,
sum(case when Parameter=6 and EventID =4 then 1 else 0 end) as GapOut6,
sum(case when Parameter=7 and EventID =4 then 1 else 0 end) as GapOut7,
sum(case when Parameter=8 and EventID =4 then 1 else 0 end) as GapOut8

FROM ASCEvents 
WHERE EventID IN(4,5,6) and
(TimeStamp BETWEEN (dateadd(minute, datediff(minute,0,(GETDATE()-@DaysAgo))/@BinSize * @BinSize, 0)) and (dateadd(minute, datediff(minute,0,GETDATE())/@BinSize * @BinSize, 0))) and
DeviceID=@DeviceID

group by 
	grouping sets (dateadd(minute, datediff(minute,0,TimeStamp)/@BinSize * @BinSize, 0)) , (DeviceID)
),

AveGreen AS (
SELECT 
GreenTimestamp, 
AVG(CASE WHEN Parameter=1 THEN GreenTime END) AS AveGreenPh1,
AVG(CASE WHEN Parameter=2 THEN GreenTime END) AS AveGreenPh2,
AVG(CASE WHEN Parameter=3 THEN GreenTime END) AS AveGreenPh3,
AVG(CASE WHEN Parameter=4 THEN GreenTime END) AS AveGreenPh4,
AVG(CASE WHEN Parameter=5 THEN GreenTime END) AS AveGreenPh5,
AVG(CASE WHEN Parameter=6 THEN GreenTime END) AS AveGreenPh6,
AVG(CASE WHEN Parameter=7 THEN GreenTime END) AS AveGreenPh7,
AVG(CASE WHEN Parameter=8 THEN GreenTime END) AS AveGreenPh8,
SUM(CASE WHEN Parameter=1 THEN 1 Else 0 END) AS Ph1_Services,
SUM(CASE WHEN Parameter=2 THEN 1 Else 0 END) AS Ph2_Services,
SUM(CASE WHEN Parameter=3 THEN 1 Else 0 END) AS Ph3_Services,
SUM(CASE WHEN Parameter=4 THEN 1 Else 0 END) AS Ph4_Services,
SUM(CASE WHEN Parameter=5 THEN 1 Else 0 END) AS Ph5_Services,
SUM(CASE WHEN Parameter=6 THEN 1 Else 0 END) AS Ph6_Services,
SUM(CASE WHEN Parameter=7 THEN 1 Else 0 END) AS Ph7_Services,
SUM(CASE WHEN Parameter=8 THEN 1 Else 0 END) AS Ph8_Services
FROM 
	(
	SELECT dateadd(minute, datediff(minute,0,TimeStamp)/@BinSize * @BinSize, 0) as GreenTIMESTAMP,
	EventID, Parameter,
	DATEDIFF(SECOND, TimeStamp, LEAD(TimeStamp) OVER (PARTITION BY DeviceID, Parameter ORDER BY TimeStamp, Parameter DESC)) AS GreenTime
	From ASCEvents
	WHERE EventId IN(1,7) and 
	(TimeStamp BETWEEN (dateadd(minute, datediff(minute,0,(GETDATE()-@DaysAgo))/@BinSize * @BinSize, 0)) and (dateadd(minute, datediff(minute,0,GETDATE())/@BinSize * @BinSize, 0))) and
	DeviceID=@DeviceID
	) q
WHERE EventID=1 and GreenTime IS NOT NULL
GROUP BY GreenTimestamp
),

PEDS AS (
SELECT 
dateadd(minute, datediff(minute,0,TimeStamp)/@BinSize * @BinSize, 0) as PedTIMESTAMP, 
sum(case when Parameter=1 then 1 else 0 end) as Ped1,
sum(case when Parameter=2 then 1 else 0 end) as Ped2,
sum(case when Parameter=3 then 1 else 0 end) as Ped3,
sum(case when Parameter=4 then 1 else 0 end) as Ped4,
sum(case when Parameter=5 then 1 else 0 end) as Ped5,
sum(case when Parameter=6 then 1 else 0 end) as Ped6,
sum(case when Parameter=7 then 1 else 0 end) as Ped7,
sum(case when Parameter=8 then 1 else 0 end) as Ped8
FROM ASCEvents 
WHERE EventID=21 and 
(TimeStamp BETWEEN (dateadd(minute, datediff(minute,0,(GETDATE()-@DaysAgo))/@BinSize * @BinSize, 0)) and (dateadd(minute, datediff(minute,0,GETDATE())/@BinSize * @BinSize, 0))) and
DeviceID=@DeviceID
group by 
	grouping sets (dateadd(minute, datediff(minute,0,TimeStamp)/@BinSize * @BinSize, 0)) , (DeviceID)
),

AveFYA AS (
SELECT 
FYATimestamp,  
AVG(CASE WHEN Parameter=1 THEN FYA_Time END) AS AveFYA_Ph1,
AVG(CASE WHEN Parameter=3 THEN FYA_Time END) AS AveFYA_Ph3,
AVG(CASE WHEN Parameter=5 THEN FYA_Time END) AS AveFYA_Ph5,
AVG(CASE WHEN Parameter=7 THEN FYA_Time END) AS AveFYA_Ph7,
SUM(CASE WHEN Parameter=1 THEN 1 Else 0 END) AS Ph1_FYA_Services,
SUM(CASE WHEN Parameter=3 THEN 1 Else 0 END) AS Ph3_FYA_Services,
SUM(CASE WHEN Parameter=5 THEN 1 Else 0 END) AS Ph5_FYA_Services,
SUM(CASE WHEN Parameter=7 THEN 1 Else 0 END) AS Ph7_FYA_Services
FROM 
	(
	SELECT dateadd(minute, datediff(minute,0,TimeStamp)/@BinSize * @BinSize, 0) as FYATIMESTAMP,
	EventID, Parameter,
	DATEDIFF(SECOND, TimeStamp, LEAD(TimeStamp) OVER (PARTITION BY DeviceID, Parameter ORDER BY TimeStamp, Parameter DESC)) AS FYA_Time
	From ASCEvents
	WHERE EventId IN(32,33) and 
	(TimeStamp BETWEEN (dateadd(minute, datediff(minute,0,(GETDATE()-@DaysAgo))/@BinSize * @BinSize, 0)) and (dateadd(minute, datediff(minute,0,GETDATE())/@BinSize * @BinSize, 0))) and
	DeviceID=@DeviceID
	) q
WHERE EventID=32 and FYA_Time IS NOT NULL
GROUP BY FYATimestamp
)




SELECT 
VolumeTIMESTAMP AS TIMESTAMP, @TSSU as TSSU, MT01,	MT02,	MT03,	MT04,	MT05,	MT06,	MT07,	MT08,	MT09,	MT10,	
MT11,	MT12,	MT13,	MT14,	MT15,	MT16,	MT17,	MT18,	MT19,	MT20,	MT21,	MT22,	MT23,	MT24,	
MT25,	MT26,	MT27,	MT28,	MT29,	MT30,	MT31,	MT32,	VolumeTIMESTAMP as TIMESTAMP2,	Vol_Period,	MT33,	MT34,	
MT35,	MT36,	MT37,	MT38,	MT39,	MT40,
VolumeTIMESTAMP as TIMESTAMP3, Vol_Period,
Ph1_Services, Ph2_Services, Ph3_Services, Ph4_Services, Ph5_Services, Ph6_Services, Ph7_Services, Ph8_Services,
Ped1, Ped2, Ped3, Ped4, Ped5, Ped6, Ped7, Ped8, 
AveGreenPh1, AveGreenPh2, AveGreenPh3, AveGreenPh4, AveGreenPh5, AveGreenPh6, AveGreenPh7, AveGreenPh8,
MaxOut1,	MaxOut2,	MaxOut3,	MaxOut4,	MaxOut5,	
MaxOut6,	MaxOut7,	MaxOut8,	ForceOff1,	ForceOff2,	ForceOff3,	ForceOff4,	ForceOff5,	ForceOff6,	ForceOff7,
ForceOff8,	GapOut1,	GapOut2,	GapOut3,	GapOut4,	GapOut5,	GapOut6,	GapOut7,	GapOut8,
AveFYA_Ph1, AveFYA_Ph3, AveFYA_Ph5, AveFYA_Ph7, Ph1_FYA_Services, Ph3_FYA_Services, Ph5_FYA_Services, Ph7_FYA_Services


FROM Volumes
LEFT JOIN MOE ON Volumes.VolumeTIMESTAMP = MOE.moeTIMESTAMP
LEFT JOIN AveGreen ON Volumes.VolumeTIMESTAMP = AveGreen.GreenTIMESTAMP
LEFT JOIN PEDS ON Volumes.VolumeTIMESTAMP=PEDS.PedTIMESTAMP
LEFT JOIN AveFYA ON Volumes.VolumeTIMESTAMP=AveFYA.FYATIMESTAMP
ORDER BY TIMESTAMP