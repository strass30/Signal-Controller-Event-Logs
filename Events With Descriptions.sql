--This query joins hi-res events with event descriptions for a single signal using the TSSU ID
--It is used for fast troubleshooting/viewing of those events
--Updated: 2/13/19 SHS
use MaxView_EventLog
	
--Set the TSSU ID# Below:
DECLARE @TSSU AS VARCHAR(5) = '03061';

--Run query!--
DECLARE @DeviceID AS INT 
SET @DeviceID= (
SELECT GroupableElements.ID
FROM [MaxView_1.9.0.744].[dbo].[GroupableElements]
WHERE Right(GroupableElements.Number,5) = @TSSU)



	SELECT TimeStamp, DeviceID, EventID,  Parameter, Name, Description
	FROM ASCEvents
	

	left join ASCControllerEventTypes ON ASCEvents.EventId=ASCControllerEventTypes.ID
		WHERE DeviceID=@DeviceID and timestamp >(getdate()-.1)
		--between '2020-11-18 06:45' and '2020-11-18 07:00'
		--and eventid in(21,22,23,24)-- and parameter in(16,17,18,19)--and eventid in(1,8,10,21,22,23,24,32,33,45,61,63,64,89,90) --and parameter=4
		--and not eventID in(81,82,2,43,44,3,41,181,400,500,502,503,317,318,31,42,501,90,89,45,0,4,12) 
		--and eventid between 101 and 115
		--and eventid =150

		--looking for the overlaps terminating without the phase!
		and eventid in(7, 33, 0, 1,7,8,9,10,11) --7=phase green termination, 33=FYA end permissive, 63=OL begin yellow. FYA should always end permissive WITH phase green termination!
		and parameter in(5,6)

	ORDER BY DeviceID, Timestamp , EventID


--This returns descriptions of controller event types
--	USE MaxView_EventLog
--	SELECT * FROM ASCControllerEventTypes