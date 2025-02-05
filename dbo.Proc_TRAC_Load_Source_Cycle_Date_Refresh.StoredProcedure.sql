USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Load_Source_Cycle_Date_Refresh]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Proc_TRAC_Load_Source_Cycle_Date_Refresh] AS                
          
IF (SELECT COUNT(*) FROM MC_SourceSystem WHERE EndDate IS NULL) <> 1          
BEGIN          
 RAISERROR ('TRAC CYCLE DATE SETUP FAILED.  MORE THAN 1 SYSTEM OR NO SYSTEM IS ACTIVE.', 16, 1)          
END          
ELSE          
BEGIN          
  DELETE SourceSystemCycleDate          
  FROM SourceSystemCycleDate C          
  INNER JOIN MC_SourceSystem S          
  ON C.SystemID = S.SystemID          
  WHERE S.EndDate IS NULL          
          
  INSERT INTO SourceSystemCycleDate          
  (   SystemID,  
   CycleDate  
  )          
  SELECT   
  (SELECT SystemID FROM MC_SourceSystem WHERE EndDate IS NULL)  
  ,StartDate          
  FROM dbo.TRAC_Core_Extract_Range_Refresh          
  WHERE EndDate IS NULL     
     
END          
          
RETURN  


GO
