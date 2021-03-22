--Calculates Pearson Corelation Coeficient for all detector pair combinations at an intersection

DECLARE @DaysAgo AS INT = 15;
DECLARE @BinSize AS INT = 15;

--Create temp DateTime Table to have every minute accounted for even if a detector has no actuations during that minute
DECLARE @start DATETIME, @end DATETIME  
SET @start = CONVERT(DATE,GETDATE()-@DaysAgo);
SET @end = CONVERT(DATE,GETDATE());    

CREATE TABLE #T (TimeStamps DATETIME)

WHILE @start < @end
BEGIN
  INSERT INTO #T
  VALUES (@start)

  SET @start = DATEADD(MINUTE, @BinSize, @start)
END


;WITH

--1 minute bin total detector actuations grouped by device and detector
t1 as (Select dateadd(minute, datediff(minute,0,TimeStamp)/@BinSize * @BinSize, 0) as time1, DeviceID, Parameter as Det1, Count(*) as total1
From ASCEvents
Where EventID=81 and TimeStamp>(getdate()-@DaysAgo) and DeviceID IN(621) --and Parameter in(1,13)
Group by dateadd(minute, datediff(minute,0,TimeStamp)/@BinSize * @BinSize, 0), DeviceID, Parameter),

--get distinct deviceIDs and detectors
D as (Select Distinct DeviceID, Det1 From t1),

--crossjoin datetime table with distinct DeviceID/detectors to get a minute by minute timestamp for each one
D2 as (Select * From D cross join #T),

--join detector actuations table to the distinct detector timestamp table
D3 as (Select D2.TimeStamps, D2.DeviceID, D2.Det1, t1.total1
From D2
left join t1 on D2.TimeStamps=t1.time1 and D2.DeviceID=t1.DeviceID and D2.Det1=t1.Det1),

--join table to itself to add detector 2 column
D4 as ( Select A.TimeStamps, A.DeviceID, A.Det1, ISNULL(A.total1,0) as Total1, B.Det1 as Det2, ISNULL(B.total1,0) as Total2
From D3 as B
Inner Join D3 as A on a.TimeStamps=b.TimeStamps and a.DeviceID=b.DeviceID
Where a.Det1<b.Det1), --and (A.Total1 is not null and B.total1 is not null))

--remove rows where both detectors volumes were 0
D5 as (Select * From D4 Where NOT (Total1=0 and Total2=0))

--calculate pearson corelation coefficient! :-)
Select cast(TimeStamps as date) as TimeStamp, DeviceID, Det1, Det2,
(Avg(Convert(DECIMAL(18,2),Total1 * Total2)) - (Avg(Convert(DECIMAL(18,2),Total1)) * Avg(Convert(DECIMAL(18,2),Total2)))) / 
Nullif((StDevP(Total1) * StDevP(Total2)),0) as PearsonCoefficient
From D4
Group By cast(TimeStamps as date), DeviceID, Det1, Det2
Order By Det1, PearsonCoefficient desc

drop table #T --done with temp timestamp table so drop it