USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[USP_TempIDFAAutoTran_Trac]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_TempIDFAAutoTran_Trac] AS            
            
DECLARE @JobID INT;            
            
SET @JobID = (SELECT MAX(JobID)            
              FROM MC_JobID            
              INNER JOIN MC_SourceFile            
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID            
              WHERE logicalName = 'TRACAutoTransaction'            
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)            
                                       FROM MC_SysProcessedLog            
                                       WHERE SystemID = 49));            
      
INSERT INTO TempIDFAAutoTran            
(            
 SourceSystem,            
SourceSystemKey1,    
SourceSystemKey2,    
SourceSystemKey3,    
SourceSystemKey4,    
SourceSystemKey5,    
SourceSystemKey6,          
 JobID            
)            
SELECT            
 'TRAC' AS SourceSystem,            
AutoTransaction_Sys_Attr_Key1_Text,    
AutoTransaction_Sys_Attr_Key2_Text,    
AutoTransaction_Sys_Attr_Key3_Text,    
AutoTransaction_Sys_Attr_Key4_Text,    
AutoTransaction_Sys_Attr_Key5_Text,    
AutoTransaction_Sys_Attr_Key6_Text,         
 @JobID            
FROM TRACAutoTransaction    
    
GO
