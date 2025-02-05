USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_NREP_Data_Check]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
  ---select *  FROM  core1.dbo.dt_masterprocess

--exec [Proc_NREP_Data_Check] 122

CREATE  PROCEDURE [dbo].[Proc_NREP_Data_Check]  ( @MASTERPROCESSID INT , @Result varchar(100) output)
AS      
  
DECLARE @SysProcesslogId int;  
DECLARE @RowsProcessed int;  
Declare @systemid  int;

SET @systemid =(select MCSourceSystemID  FROM  core1.dbo.dt_masterprocess  
				where  MasterProcessID=@MASTERPROCESSID )
				
SET @SysProcesslogId = (SELECT MAX(SysProcessedLogID) from Core1.dbo.MC_SysProcessedLog  
        WHERE Finished = 'T' and  SystemID=@systemid )  
  
  
TRUNCATE TABLE Core1.dbo.MC_Segment_Daily  
  
INSERT into Core1.dbo.MC_Segment_Daily  
Select * from Core1.dbo.MC_Segment  
Where SysProcessedLogID = @SysProcesslogId  
  
SET @RowsProcessed = (SELECT SUM(RecordsProcessed) from Core1.dbo.MC_Segment_Daily)  
  
  
IF @RowsProcessed = 0  
  
BEGIN  
 RAISERROR ('THERE IS A MAJOR ISSUE IN NREP EXECUTION PROCESS. PLEASE CONTACT CORE ON-CALL SUPPORT PERSON. PLEASE DONT PROCEED WITH THE TRAC CYCLE ', 16, 1)  
 Return 
 
-- select 1   
 END  
   
  
    
  
  
  
GO
