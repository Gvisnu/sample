USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_Delete_Dom_NRep_Dataprocess_Entries]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Proc_Delete_Dom_NRep_Dataprocess_Entries]  
(  
 @MASTERPROCESSID INT = NULL  
)  
 AS  
  
SET NOCOUNT ON;  
  
-- delete all the DOM & NREP generated storeprocedure entries from the Data process table  
-- except for the master process DST Dividend, Bank Information load  
IF @MASTERPROCESSID is null  
BEGIN  
 DELETE FROM DT_DATAPROCESS   
 WHERE  DataProcessName LIKE 'EXEC DOM_COR%'  
 AND MASTERPROCESSID NOT IN (23,26)  
  
 DELETE FROM DT_DATAPROCESS   
 WHERE  DataProcessName LIKE 'EXEC NREP%'  
 AND MASTERPROCESSID NOT IN (23,26)  
  
END  
ELSE  
BEGIN  
 DELETE FROM DT_DATAPROCESS   
 WHERE  DataProcessName LIKE 'EXEC DOM_COR%'  
 AND MASTERPROCESSID = @MASTERPROCESSID  
  
 DELETE FROM DT_DATAPROCESS   
 WHERE  DataProcessName LIKE 'EXEC NREP%'  
 AND MASTERPROCESSID = @MASTERPROCESSID  
END  
  
-- Reset   
UPDATE PRM_DomainChildren SET ProcessID = NULL;  
  
  
  
  
SET NOCOUNT ON;  
GO
