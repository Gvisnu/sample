USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[USP_TempIDFAAgreement_Trac]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[USP_TempIDFAAgreement_Trac] AS        
        
DECLARE @JobID INT;        
        
SET @JobID = (SELECT MAX(JobID)        
              FROM MC_JobID        
              INNER JOIN MC_SourceFile        
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID        
              WHERE logicalName = 'TracAgreement'        
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)        
                                       FROM MC_SysProcessedLog        
                                       WHERE SystemID = 49));        
  
        
INSERT INTO TempIDFAAgreement        
(        
 SourceSystem,        
 SourceSystemKey1,        
 SourceSystemKey2,        
 SourceSystemKey3,        
 SourceSystemKey4,        
 JobID        
)        
SELECT        
 'TRAC' AS SourceSystem,        
Agrmnt_sys_attr_key1_text,    
Agrmnt_sys_attr_key2_text,    
Agrmnt_sys_attr_key3_text,      
Agrmnt_sys_attr_key4_text,      
 @JobID        
FROM TracAgreement



--INSERT INTO TempIDFAAgreement        
--(        
-- SourceSystem,        
-- SourceSystemKey1,        
-- SourceSystemKey2,        
-- SourceSystemKey3,        
-- SourceSystemKey4,        
-- JobID        
--)        
--SELECT        
-- 'TRAC' AS SourceSystem,        
--Agrmnt_sys_attr_key1_text,    
--Agrmnt_sys_attr_key2_text,    
--Agrmnt_sys_attr_key3_text,      
--Agrmnt_sys_attr_key4_text,
-- @JobID        
--FROM TRACPlanLevelTransaction
GO
