USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[USP_GenIDTRACAutoTran]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_GenIDTRACAutoTran] AS      
      
DECLARE @JobID INT;      
    
SET @JobID = (SELECT MAX(JobID)      
              FROM MC_JobID      
              INNER JOIN MC_SourceFile      
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID      
              WHERE logicalName = 'TRACAutoTransaction'      
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)      
                                       FROM MC_SysProcessedLog      
                                       WHERE SystemID = 49));      
                                           
INSERT INTO dbo.GenIDFAAutoTran      
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
SELECT distinct      
 A.Mntc_Sys_Code,      
 A.AutoTransaction_Sys_Attr_Key1_Text,      
 A.AutoTransaction_Sys_Attr_Key2_Text,      
 A.AutoTransaction_Sys_Attr_Key3_Text,      
 A.AutoTransaction_Sys_Attr_Key4_Text,      
 A.AutoTransaction_Sys_Attr_Key5_Text,      
 A.AutoTransaction_Sys_Attr_Key6_Text,      
 @JobID      
FROM      
 dbo.TRACAutoTransaction A      
LEFT OUTER JOIN      
 dbo.GenIDFAAutoTran B      
 ON  A.Mntc_Sys_Code     = B.SourceSystem      
 AND A.AutoTransaction_Sys_Attr_Key1_Text = B.SourceSystemKey1      
 AND A.AutoTransaction_Sys_Attr_Key2_Text = B.SourceSystemKey2      
 AND A.AutoTransaction_Sys_Attr_Key3_Text = B.SourceSystemKey3      
 AND A.AutoTransaction_Sys_Attr_Key4_Text = B.SourceSystemKey4      
 AND A.AutoTransaction_Sys_Attr_Key5_Text = B.SourceSystemKey5      
 AND A.AutoTransaction_Sys_Attr_Key6_Text = B.SourceSystemKey6      
WHERE      
 B.SourceSystem IS NULL 
GO
