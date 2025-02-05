USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[USP_TempIDFAEFT_TRAC]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_TempIDFAEFT_TRAC] AS
    
DECLARE @JobID INT;    

    
SET @JobID = (SELECT MAX(JobID)    
              FROM MC_JobID    
              INNER JOIN MC_SourceFile    
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID    
              WHERE Logicalname = 'TRACFAEFT'    
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)    
                                       FROM MC_SysProcessedLog    
                                       WHERE SystemID = 49));    
    
INSERT INTO TempIDFAEFT
(
SOURCESYSTEM, 
SOURCESYSTEMKEY1, 
SOURCESYSTEMKEY2, 
SOURCESYSTEMKEY3, 
SOURCESYSTEMKEY4, 
SOURCESYSTEMKEY5, 
SOURCESYSTEMKEY6, 
SOURCESYSTEMKEY7, 
JOBID
)
SELECT	'TRAC' AS SourceSystem,
EFT_Sys_Attr_Key1_Text,
EFT_Sys_Attr_Key2_Text,
EFT_Sys_Attr_Key3_Text,
EFT_Sys_Attr_Key4_Text,
EFT_Sys_Attr_Key5_Text,
'^',
'^',
@JobID    
FROM  Core1.dbo.TRACEFT
GO
