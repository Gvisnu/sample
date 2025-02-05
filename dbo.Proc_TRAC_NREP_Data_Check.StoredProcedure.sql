USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_NREP_Data_Check]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[Proc_TRAC_NREP_Data_Check] 
AS    
BEGIN
SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

Set Nocount on 
SET ANSI_WARNINGS OFF -- #INC000007112064 - added for mitigating error - "Warning: Null value is eliminated by an aggregate or other SET operation"

DECLARE @SysProcesslogId int;
DECLARE @RowsProcessed int;
DECLARE @ErrorMessage VARCHAR(200);

SET @SysProcesslogId = (SELECT MAX(SysProcessedLogID) from Core1.dbo.MC_SysProcessedLog
					   WHERE Finished = 'T'
					   and SystemID = 49
					   and SubSystemID = '-1'
					   )


TRUNCATE TABLE Core1.dbo.MC_Segment_Daily

INSERT into Core1.dbo.MC_Segment_Daily
Select * from Core1.dbo.MC_Segment
Where SysProcessedLogID = @SysProcesslogId

SET @RowsProcessed = (SELECT SUM(RecordsProcessed) from Core1.dbo.MC_Segment_Daily)

IF @RowsProcessed = 0
BEGIN
SET @ErrorMessage = 'THERE IS A MAJOR ISSUE IN NREP EXECUTION PROCESS. PLEASE CONTACT CORE ON-CALL SUPPORT PERSON. PLEASE DONT PROCEED WITH THE TRAC CYCLE'
 RAISERROR (@ErrorMessage, 16, 1)
 RETURN
 END
RETURN 0
END
GO
