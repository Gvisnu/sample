USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_ETL_MC_SysProcessedLog]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Proc_ETL_MC_SysProcessedLog] 
AS    

DECLARE @ERRORMESSAGE NVARCHAR(255)  
    
IF NOT EXISTS (SELECT 1 FROM MC_SysProcessedLog    
               WHERE Finished = 'F'    
               AND SystemID = (SELECT SystemID FROM MC_SourceSystem WHERE EndDate IS NULL))    
    
 BEGIN    
    
  INSERT INTO MC_SysProcessedLog    
  (    
   SystemID,    
   CycleDate,    
   Started,    
   StartDateTimeStamp,    
   Finished,    
   EndDateTimeStamp    
       
  )    
  SELECT    
   --(SELECT SystemID FROM MC_SourceSystem WHERE EndDate IS NULL),    
   SystemID,  
   CYCLEDATE,    
   'T',    
   GETDATE(),    
   'F',    
   NULL    
  FROM SourceSystemCycleDate    
  WHERE SystemID = (SELECT SystemID FROM MC_SourceSystem WHERE EndDate IS NULL)    
    
 END    
 ELSE
 BEGIN
 SET	@ERRORMESSAGE = 'The Sysprocessedlog is incomplete. Please check the MC_SYSPROCESSEDLOG table for more information.'   
		RAISERROR (@ERRORMESSAGE, 16, 1)  
		RETURN 1  
 END 
RETURN 
GO
