USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_UC4_GetEstimatedTimeToComplete]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[uspDT_UC4_GetEstimatedTimeToComplete](@shortname varchar(200))
AS

DECLARE @masterprocessid  int
DECLARE @dataprocessname varchar(50)
DECLARE @dataprocessid  int
DECLARE @currentStartDateTime datetime
DECLARE @LastMonthEndDate       DATETIME
DECLARE @LastQuaterEndDate      DATETIME
DECLARE @LastWeekEndDate		DATETIME
DECLARE @ETC_LWE				int
DECLARE @ETC_LME				int
DECLARE @ETC_LQE				int
DECLARE @PrevBusDate       DATETIME


--Get the masterprocessid based on masterProcessShortName 
SELECT @masterprocessid=masterprocessid FROM dt_masterprocess
WHERE masterProcessShortName=@shortname

--Get the current running dataprocess id, name
select top 1 @dataprocessid = b.dataprocessid,  
  @dataprocessname = b.dataprocessname,
  @currentStartDateTime = a.startdatetime 
from dt_dataprocesslog a, dt_dataprocess b
where  processstatusid in (1,2,3)
and masterprocesslogid in (
select top 1 masterprocesslogid from dt_masterprocesslog
where masterprocessid = @masterprocessid and processstatusid in (1,2,3)
order by masterprocesslogid desc
) and a.dataprocessid = b.dataprocessid
order by b.precedence, rowsprocessed desc

set @currentStartDateTime = CONVERT(datetime,(CAST(YEAR(@currentStartDateTime) AS VARCHAR(4)) + '/' + CAST(MONTH(@currentStartDateTime) AS VARCHAR(2)) + '/' +  CAST(DAY(@currentStartDateTime) AS VARCHAR(2))),101)
set  @PrevBusDate = (select max(bus_date) from CORE..SBGCORE.COR_BUS_DAY where bus_date < @currentStartDateTime)


--select @dataprocessid, @dataprocessname, @currentStartDateTime


--get the last weekend , month end, quater end dates

SET @LastMonthEndDate = CAST(YEAR(@currentStartDateTime) AS VARCHAR(4)) + '/' + 
           CAST(MONTH(@currentStartDateTime) AS VARCHAR(2)) + '/01'

Set @LastMonthEndDate = DATEADD(DD, -1, @LastMonthEndDate)


-- if the previous bus date is a month end then take a prev month end date
IF (Datediff(dd,@PrevBusDate, @LastMonthEndDate) = 0) 
BEGIN

	SET @LastMonthEndDate = CAST(YEAR(@PrevBusDate) AS VARCHAR(4)) + '/' + 
			   CAST(MONTH(@PrevBusDate) AS VARCHAR(2)) + '/01'

	Set @LastMonthEndDate = DATEADD(DD, -1, @LastMonthEndDate)

	SET @LastQuaterEndDate = CAST(YEAR(@PrevBusDate) AS VARCHAR(4)) +
			   CASE WHEN MONTH(@PrevBusDate) IN ( 1,  2,  3) THEN '/01/01'
					WHEN MONTH(@PrevBusDate) IN ( 4,  5,  6) THEN '/04/01'
					WHEN MONTH(@PrevBusDate) IN ( 7,  8,  9) THEN '/07/01'
					WHEN MONTH(@PrevBusDate) IN (10, 11, 12) THEN '/10/01'
			   END
	set @LastQuaterEndDate = DATEADD(DD,-1,@LastQuaterEndDate)
END
Else
BEGIN
	SET @LastQuaterEndDate = CAST(YEAR(@currentStartDateTime) AS VARCHAR(4)) +
			   CASE WHEN MONTH(@currentStartDateTime) IN ( 1,  2,  3) THEN '/01/01'
					WHEN MONTH(@currentStartDateTime) IN ( 4,  5,  6) THEN '/04/01'
					WHEN MONTH(@currentStartDateTime) IN ( 7,  8,  9) THEN '/07/01'
					WHEN MONTH(@currentStartDateTime) IN (10, 11, 12) THEN '/10/01'
			   END
	set @LastQuaterEndDate = DATEADD(DD,-1,@LastQuaterEndDate)
END


--if the last month end and quater end dates are same then get the previous quater end date
if (Datediff(dd,@LastMonthEndDate, @LastQuaterEndDate) = 0) 
begin
	SET @LastQuaterEndDate = CAST(YEAR(@LastMonthEndDate) AS VARCHAR(4)) +
			   CASE WHEN MONTH(@LastMonthEndDate) IN ( 1,  2,  3) THEN '/01/01'
					WHEN MONTH(@LastMonthEndDate) IN ( 4,  5,  6) THEN '/04/01'
					WHEN MONTH(@LastMonthEndDate) IN ( 7,  8,  9) THEN '/07/01'
					WHEN MONTH(@LastMonthEndDate) IN (10, 11, 12) THEN '/10/01'
			   END
	set @LastQuaterEndDate = DATEADD(DD,-1,@LastQuaterEndDate)
end 

SELECT  @LastWeekEndDate = @currentStartDateTime - (DATEPART(DW,  @currentStartDateTime) - 1) - 2 

--Issue 3762
--Get the correct business dates for weekend , monthend and Queterends



set  @LastWeekEndDate = (select max(bus_date) from CORE..SBGCORE.COR_BUS_DAY where bus_date <= @LastWeekEndDate)

set  @LastMonthEndDate = (select max(bus_date) from CORE..SBGCORE.COR_BUS_DAY where bus_date <= @LastMonthEndDate)

set  @LastQuaterEndDate = (select max(bus_date) from CORE..SBGCORE.COR_BUS_DAY where bus_date <= @LastQuaterEndDate)

--select @LastWeekEndDate, @LastMonthEndDate, @LastQuaterEndDate


-- Get the time taken to complete from this dataprocess step to the end of the master process step
-- Get the time taken to complete from this dataprocess step to the end of the master process step
SET @ETC_LWE = (select top 1  datediff(mi,a.startdatetime,c.enddatetime  ) 
from dt_dataprocesslog a, dt_masterprocesslog c
where a.dataprocessname  <> ''
and a.dataprocessname = @dataprocessname
--and a.dataprocessid = @dataprocessid
and a.startdatetime between dateadd(hh,12,@LastWeekEndDate) and dateadd(hh,12,dateadd(dd,1,@LastWeekEndDate))
and a.masterprocesslogid = c.masterprocesslogid
and c.masterprocessid = @masterprocessid
order by a.dataprocesslogid desc)

SET @ETC_LME = (select top 1  datediff(mi,a.startdatetime,c.enddatetime  ) 
from dt_dataprocesslog a, dt_masterprocesslog c
where a.dataprocessname  <> ''
and a.dataprocessname = @dataprocessname
--and a.dataprocessid = @dataprocessid
and a.startdatetime between dateadd(hh,12,@LastMonthEndDate) and dateadd(hh,12,dateadd(dd,1,@LastMonthEndDate))
and a.masterprocesslogid = c.masterprocesslogid
and c.masterprocessid = @masterprocessid
order by a.dataprocesslogid desc)

SET @ETC_LQE = (select top 1  datediff(mi,a.startdatetime,c.enddatetime  )
from dt_dataprocesslog a, dt_masterprocesslog c
where a.dataprocessname  <> ''
and a.dataprocessname = @dataprocessname
--and a.dataprocessid = @dataprocessid
and a.startdatetime between dateadd(hh,12,@LastQuaterEndDate) and dateadd(hh,12,dateadd(dd,1,@LastQuaterEndDate))
and a.masterprocesslogid = c.masterprocesslogid
and c.masterprocessid = @masterprocessid
order by a.dataprocesslogid desc)

select @ETC_LWE AS LWE_ETC, @ETC_LME AS LME_ETC, @ETC_LQE AS LQE_ETC





GO
