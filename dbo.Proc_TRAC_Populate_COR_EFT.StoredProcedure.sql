USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_EFT]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Proc_TRAC_Populate_COR_EFT] AS        
  
DECLARE @JobID INT;                                
DECLARE @CurrDateTime DATETIME  
  
set nocount on  
  
SET @JobID = (SELECT MAX(JobID)                              
              FROM MC_JobID                              
              INNER JOIN MC_SourceFile                              
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID                              
              WHERE logicalName = 'TRACFAEFT'  
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)                              
                                       FROM MC_SysProcessedLog                              
                                       WHERE SystemID = 49));   
                                         
SET @CurrDateTime = GETDATE()  
  
INSERT INTO COREETL.DBO.COR_EFT(  
 [AGREEMENT_ID],  
 [AUTO_TRAN_ID],  
 [EFT_ID],  
 [DATETIMESTAMP],  
 [JOB_ID],  
 [BANK_ACCOUNT_TYPE_CODE],  
 [EFT_TYPE_CODE],  
 [BANK_ACCOUNT_NUMBER],  
 [MAINTENANCE_SYSTEM_KEY],  
 [TRANSIT_NUMBER],  
 [REC_INSRT_NAME],  
 [ADU])  
SELECT  
GenID.AgreementId,  
 AutoTran.AutoTranID,  
 EFT.EFTID,  
 @CurrDateTime AS DateTimeStamp,  
 @JobID,  
 TRACEFT.BANK_ACCOUNT_TYPE_CODE,  
 TRACEFT.EFT_TYPE_CODE,  
 TRACEFT.BANK_ACCOUNT_NUMBER,  
 '' as MAINTENANCE_SYSTEM_KEY,        
 TRACEFT.TRANSIT_NUMBER,         
 '430' AS REC_INSRT_NAME,        
 'U'  
FROM        
 TRACEFT  
inner JOIN   GenIDFAAutoTran AutoTran  
ON  AutoTran.SourceSystemKey1 = TRACEFT.AutoTransaction_Sys_Attr_Key1_Text        
 AND AutoTran.SourceSystemKey2  = TRACEFT.AutoTransaction_Sys_Attr_Key2_Text        
 AND AutoTran.SourceSystemKey3  = TRACEFT.AutoTransaction_Sys_Attr_Key3_Text     
 AND AutoTran.SourceSystemKey4 = TRACEFT.AutoTransaction_Sys_Attr_Key4_Text     
 AND AutoTran.SourceSystemKey5 = TRACEFT.AutoTransaction_Sys_Attr_Key5_Text     
 AND AutoTran.SourceSystemKey6 = TRACEFT.AutoTransaction_Sys_Attr_Key6_Text     
 AND AutoTran.SourceSystem    = Mntc_Sys_Code  
INNER JOIN   GenIDFAEFT  EFT      
ON  EFT.SourceSystem = TRACEFT.Mntc_Sys_Code  
AND EFT.SourceSystemKey1 = TRACEFT.EFT_Sys_Attr_Key1_Text  
AND EFT.SourceSystemKey2 = TRACEFT.EFT_Sys_Attr_Key2_Text  
AND EFT.SourceSystemKey3 = TRACEFT.EFT_Sys_Attr_Key3_Text  
AND EFT.SourceSystemKey4 = TRACEFT.EFT_Sys_Attr_Key4_Text  
AND EFT.SourceSystemKey5 = TRACEFT.EFT_Sys_Attr_Key5_Text  
AND EFT.SourceSystem = Mntc_Sys_Code  
INNER JOIN GenIDFAAgreement GenID ON  GenID.SourceSystemKey1 = TRACEFT.Agreement_Sys_Attr_Key1_Text  
AND GenID.SourceSystemKey2 = TRACEFT.Agreement_Sys_Attr_Key2_Text  
AND GenID.SourceSystemKey3 = TRACEFT.Agreement_Sys_Attr_Key3_Text  
AND GenID.SourceSystem = Mntc_Sys_Code  
WHERE Mntc_Sys_Code = 'TRAC'  
set nocount off        
RETURN
GO
