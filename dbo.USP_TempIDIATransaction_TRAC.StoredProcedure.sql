USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[USP_TempIDIATransaction_TRAC]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_TempIDIATransaction_TRAC] AS    
              
DECLARE @JobID INT;              
              
SET @JobID = (SELECT MAX(JobID)                            
              FROM MC_JobID                            
              INNER JOIN MC_SourceFile                            
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID                            
              WHERE logicalName = 'TracAssetTrnsctn'                            
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)                            
                                       FROM MC_SysProcessedLog                            
                                       WHERE SystemID = 49));             
              
INSERT INTO TempIDIATransaction              
(              
 SourceSystem,              
 SourceSystemKey1,              
 SourceSystemKey2,              
 SourceSystemKey3,              
 SourceSystemKey4,              
 SourceSystemKey5,              
 SourceSystemKey6,              
 SourceSystemKey7,            
 SourceSystemKey8,      
 SourceSystemKey9,      
 JobID              
)              
SELECT              
 'TRAC' AS SourceSystem,      
 Transaction_Sys_Attr_Key1_Text,      
 Transaction_Sys_Attr_Key2_Text,      
 Transaction_Sys_Attr_Key3_Text,      
 Transaction_Sys_Attr_Key4_Text,      
 Transaction_Sys_Attr_Key5_Text,      
 Transaction_Sys_Attr_Key6_Text,      
 Transaction_Sys_Attr_Key7_Text,      
 Transaction_Sys_Attr_Key8_Text,      
 Transaction_Sys_Attr_Key9_Text,      
 @JobID              
FROM              
 dbo.TRACTransactionDetail
GO
