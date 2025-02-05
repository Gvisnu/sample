USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_UC4_GetDataProcessStatus]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspDT_UC4_GetDataProcessStatus]
(
@startdatetime varchar(20) ,
@shortname varchar(200)
)	
AS
declare @masterprocesslogid int
declare @masterprocessid int
declare @startDate Varchar(10)
BEGIN
set @masterprocessid=0
set @masterprocesslogid=0

SET @startDate=SUBSTRING(@startdatetime,0,CHARINDEX(' ',@startdatetime))
SET @startDate=CONVERT(CHAR(10),CAST(@startDate AS Datetime),101)


select @masterprocessid=masterprocessid from core1.dbo.dt_masterprocess where masterprocessshortname=@shortname

select top 1 @masterprocesslogid= masterprocesslogid from core1.dbo.dt_masterprocesslog where CONVERT(CHAR(10),startdatetime,101)   =  @startDate
and masterprocessid=@masterprocessid order by startdatetime DESC 

select top 1 startdatetime,enddatetime,m.masterprocessname,
Case when ml.processstatusid is null then 'InComplete' 
else DP.ProcessStatus end as ProcessStatus,LogData
from core1.dbo.dt_masterprocesslog ml 
inner join core1.dbo.dt_masterprocess m
on ml.masterprocessid=m.masterprocessid
left join DT_domProcessStatus DP on ml.processstatusid= DP.ProcessStatusID
where CONVERT(CHAR(10),startdatetime,101)   =  @startDate
and ml.masterprocessid=@masterprocessid order by startdatetime DESC

select Q.DataProcessid,
Q.dataprocessname,
Case when Q.Status is null then 'InComplete' 
else dp.ProcessStatus end as ProcessStatus,
Case when Q.Action is null then 'N/A'
else da.DataProcessAction
end as Action,
Q.QueryDelta,
Q.Rows,
Q.StartDateTime,
Q.Enddatetime,
Q.ProcessDelta
from
(
select 
A.DataProcessid,
A.dataprocessname,
null as Status,
A.precedence,
null as Action,
null as QueryDelta,
null as Rows, 
null as startdatetime ,
null as enddatetime ,
null as ProcessDelta
from core1.dbo.dt_dataprocess A
where 
A.dataprocessid not in 
(Select dataprocessid from core1.dbo.dt_dataprocesslog where
masterprocesslogid=@masterprocesslogid)
and A.IsActive=1 and IsDeleted=0
and A.masterprocessid=@masterprocessid 
union all
select A.dataprocessid,A.dataprocessname,B.ProcessStatusID as Status,A.precedence,
DataProcessActionID as Action,QueryDelta as QueryDelta,RowsProcessed as Rows,
B.startdatetime,B.Enddatetime,DateDiff(second, B.StartDateTime, B.LastUpdateDateTime) as ProcessDelta from core1.dbo.dt_dataprocess A 
inner join core1.dbo.dt_Dataprocesslog B on A.dataprocessid=B.dataprocessid
where B.masterprocesslogid=@masterprocesslogid
)Q
left join core1.dbo.DT_domProcessStatus DP on DP.ProcessStatusID=Q.Status
left join core1.dbo.DT_domDataProcessAction DA on DA.DataProcessActionID=Q.Action
order by Q.precedence

select max(enddatetime) as enddatetime from core1.dbo.dt_Dataprocesslog where masterprocesslogid=@masterprocesslogid

END
GO
