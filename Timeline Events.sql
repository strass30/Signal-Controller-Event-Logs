

/*Returns timeline events for use in Power BI report, columns set up for that purpose.
Parameter column will be TOOLTIP for the timeline visual.
updated 11/23/2020
Splits, Phase Calls, FYA included only for signals/days with cycle faults
--Updated 11/4/2020 to include transitions where start and end showed up together with same timestamp.

*/


USE MaxView_EventLog
DECLARE @DaysAgo AS INT = 30;
DECLARE @Start AS DATETIME= CAST(GETDATE()-@DaysAgo AS DATE);
DECLARE @End AS DATETIME= CAST(GETDATE() AS DATE);
DECLARE @CushionTime AS INT=30;

WITH

Transition1 as 
	(
	SELECT *,
	LEAD(TimeStamp) OVER (PARTITION BY DeviceID ORDER BY TimeStamp, Parameter DESC) AS EndTime
	From ASCEvents               
	WHERE EventId=150 and Parameter IN(0,1,2,3,4) and TimeStamp >= @Start AND TimeStamp < @End --1=in step,2=long,3=short,4=dwell
	),
Transition as
	(
	SELECT *, 
	DATEDIFF(second, TimeStamp, EndTime) AS Seconds, 
	CAST(TimeStamp AS DATE) AS Date,
	'Transition' AS Category,
	CASE WHEN Parameter=2 THEN 'Longway' ELSE CASE WHEN Parameter=3 THEN 'Shortway' ELSE 'Dwell' END END AS Tooltip
	FROM Transition1
	WHERE Parameter IN(2,3,4) AND EndTime IS NOT NULL AND DATEDIFF(second, TimeStamp, EndTime)<3600
	),
Preempt1 as
	(
	SELECT *,
	LEAD(TimeStamp) OVER (PARTITION BY DeviceID, Parameter ORDER BY TimeStamp, EventId) AS EndTime
	From ASCEvents               
	WHERE EventId IN(102,104) and TimeStamp >= @Start AND TimeStamp < @End
	),
Preempt as
	(
	SELECT *,
	DATEDIFF(second, TimeStamp, EndTime) AS Seconds, 
	CAST(TimeStamp AS DATE) AS Date,
	CONCAT('Prempt ',Parameter) AS Category,
	NULL AS Tooltip
	FROM Preempt1
	WHERE EventID=102 AND EndTime IS NOT NULL AND DATEDIFF(second, TimeStamp, EndTime)<(3600*4)
	),
Fault1 as
	(
	SELECT *,
	LEAD(TimeStamp) OVER (PARTITION BY DeviceID, Parameter ORDER BY TimeStamp) AS EndTime
	From ASCEvents               
	WHERE EventId IN(83,87,88) and TimeStamp >= @Start AND TimeStamp < @End
	),
Fault as
	(
	SELECT *,
	DATEDIFF(second, TimeStamp, EndTime) AS Seconds, 
	CAST(TimeStamp AS DATE) AS Date,
	CASE WHEN EventID=87 THEN 'Fault-Stuck On' ELSE 'Fault-Erratic' END AS Category,
	CONCAT('MT#',Parameter) AS TOOLTIP
	FROM Fault1
	WHERE EventID IN(87,88) AND EndTime IS NOT NULL AND DATEDIFF(second, TimeStamp, EndTime)>0 AND DATEDIFF(second, TimeStamp, EndTime)<(3600*12)
	),
Ped as --does not factor in duration of ped service. next one does.
	(
	SELECT *, 
	DATEADD(SECOND,@CushionTime,TimeStamp) AS EndTime, 
	NULL as Seconds,
	CAST(TimeStamp AS DATE) AS Date,
	CONCAT('Ped ',Parameter) AS Category,
	NULL AS Tooltip
	From ASCEvents               
	WHERE EventId=21 and TimeStamp >= @Start AND TimeStamp < @End
	),
Ped2 as
	(
	SELECT *,
	LEAD(TimeStamp) OVER (PARTITION BY DeviceID, Parameter ORDER BY TimeStamp) AS EndTime
	From ASCEvents               
	WHERE EventId IN(21,23) and TimeStamp >= @Start AND TimeStamp < @End
	),
Ped3 as
	(
	SELECT *, 
	DATEDIFF(second, TimeStamp, EndTime) AS Seconds,
	CAST(TimeStamp AS DATE) AS Date,
	CONCAT('Ped ',Parameter) AS Category,
	NULL AS Tooltip
	From Ped2
	WHERE EventId=21 AND DATEDIFF(second, TimeStamp, EndTime)<120
	),
Coord as
	(
	SELECT *, 
	DATEADD(SECOND,@CushionTime*2,TimeStamp) AS EndTime, 
	NULL as Seconds,
	CAST(TimeStamp AS DATE) AS Date,
	'Pattern Change' AS Category,
	CONCAT('Pattern ', Parameter) AS Tooltip
	From ASCEvents               
	WHERE EventId=131 and TimeStamp >= @Start AND TimeStamp < @End
	),
CycleFault1 as
	(
	SELECT 
    [TimeStamp]
	,[GroupableElementID] as DeviceID
	,NULL AS EventID
	,CASE WHEN [Description] like '%triggered%' THEN 1 ELSE 0 END AS Parameter
	,LEAD(TimeStamp) OVER (PARTITION BY [GroupableElementID] ORDER BY TimeStamp) AS EndTime
	FROM [MaxView_1.9.0.744].[dbo].[Events]
	WHERE [Description] like '%cycle fault%' and TimeStamp >= @Start AND TimeStamp < @End
	),
CycleFault as
	(
	SELECT *,
	DATEDIFF(second, TimeStamp, EndTime) AS Seconds,
	CAST(TimeStamp AS DATE) AS Date,
	'Cycle Fault' AS Category,
	NULL AS Tooltip
	FROM CycleFault1
	WHERE Parameter=1
	),
Splits as
	(
	SELECT DATEADD(SECOND, ASCEvents.Parameter*-1, ASCEvents.TimeStamp) AS TimeStamp, 
	ASCEvents.DeviceID, 
	ASCEvents.EventID, 
	ASCEvents.Parameter,
	ASCEvents.TimeStamp AS EndTime,
	ASCEvents.Parameter as Seconds,
	CAST(ASCEvents.TimeStamp AS DATE) AS Date,
	CONCAT('Split Ph', ASCEvents.EventID-299) AS Category,
	NULL AS Tooltip
	From ASCEvents 
	JOIN CycleFault ON CycleFault.Date=CAST(ASCEvents.TimeStamp AS DATE) AND CycleFault.DeviceID=ASCEvents.DeviceID
	WHERE ASCEvents.EventId IN(300,301,302,303,304,305,306,307) and ASCEvents.TimeStamp >= @Start AND ASCEvents.TimeStamp < @End
	and ASCEvents.DeviceID IN(Select CycleFault.DeviceID FROM CycleFault)
	),
PhaseCall1 as
	(
	SELECT *,
	LEAD(TimeStamp) OVER (PARTITION BY DeviceID, Parameter ORDER BY TimeStamp) AS EndTime,
	CAST(TimeStamp AS DATE) AS Date
	From ASCEvents               
	WHERE EventId IN(43,44) and TimeStamp >= @Start AND TimeStamp < @End
	and DeviceID IN(Select DeviceID FROM CycleFault)
	),
PhaseCall as
	(
	SELECT PhaseCall1.TimeStamp, PhaseCall1.DeviceID, PhaseCall1.EventID, PhaseCall1.Parameter, PhaseCall1.EndTime,
	DATEDIFF(second, PhaseCall1.TimeStamp, PhaseCall1.EndTime) AS Seconds,
	PhaseCall1.Date,
	CONCAT('PhaseCall ', PhaseCall1.Parameter) AS Category,
	NULL AS Tooltip
	From PhaseCall1
	JOIN CycleFault ON CycleFault.Date=PhaseCall1.Date AND CycleFault.DeviceID=PhaseCall1.DeviceID
	WHERE PhaseCall1.EventId=43
	),
FYA1 as
	(
	SELECT *,
	LEAD(TimeStamp) OVER (PARTITION BY DeviceID, Parameter ORDER BY TimeStamp) AS EndTime,
	CAST(TimeStamp AS DATE) AS Date
	From ASCEvents               
	WHERE EventId IN(32,33) and TimeStamp >= @Start AND TimeStamp < @End 
	and DeviceID IN(Select DeviceID FROM CycleFault)
	),
FYA as
	(
	SELECT FYA1.TimeStamp, FYA1.DeviceID, FYA1.EventID, FYA1.Parameter, FYA1.EndTime,
	DATEDIFF(second, FYA1.TimeStamp, FYA1.EndTime) AS Seconds,
	FYA1.Date,
	CONCAT('FYA ', FYA1.Parameter) AS Category,
	NULL AS Tooltip
	From FYA1
	JOIN CycleFault ON CycleFault.Date=FYA1.Date AND CycleFault.DeviceID=FYA1.DeviceID
	WHERE FYA1.EventId=32
	)


SELECT * FROM Transition --0:17 for 10 days
UNION ALL
SELECT * FROM Preempt--0:01
UNION ALL 
SELECT * FROM Fault --0:55 
UNION ALL
SELECT * FROM Ped3 --0:25, and 0:42 with duration
UNION ALL
SELECT * FROM Coord--0:00
UNION ALL
SELECT * FROM Splits --slower 5:06
UNION ALL
SELECT * FROM PhaseCall
UNION ALL
SELECT * FROM FYA
UNION ALL 
SELECT * FROM CycleFault





--DATEPART(HOUR, TimeStamp) AS Hour