USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_AUTO_TRNSCTN]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Proc_TRAC_Populate_COR_AUTO_TRNSCTN] AS    
    
DECLARE @JobID INT;    
DECLARE @TempDate DateTime;    
    
SET @JobID = ( SELECT MAX(JobID)    
    FROM MC_JobID    
    INNER JOIN MC_SourceFile ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID    
    WHERE logicalName = 'TRACAutoTransaction'    
    AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)    
          FROM MC_SysProcessedLog    
          WHERE SystemID = 49));    
    
SET @TempDate = GETDATE();    
    
INSERT INTO COREETL.DBO.COR_AUTO_TRNSCTN    
(    
 AGREEMENT_ID,    
 AUTO_TRAN_ID,    
 DATETIMESTAMP,    
 JOB_ID,    
 AUTO_TRAN_FREQUENCY_CODE,    
 AUTO_TRAN_OPTION_CODE,    
 AUTO_MAIL_CONFIRM,    
 AUTO_TRAN_TYPE_CODE,    
 START_DATE,    
 LAST_ACTIVITY_DATE,    
 NEXT_ACTIVITY_DATE,    
 CEASE_DATE,    
 REC_INSRT_NAME,    
 ADU    
)    
SELECT    
 C.AgreementID,    
 B.AutoTranID,    
 @TempDate,    
 @JobID,    
 --ISNULL(Convert(nvarchar(12),A.AUTO_TRAN_FREQUENCY_CODE),'U'),    
 CASE WHEN A.AUTO_TRAN_FREQUENCY_CODE = '' THEN 'U'
 ELSE A.AUTO_TRAN_FREQUENCY_CODE 
 END AS AUTO_TRAN_FREQUENCY_CODE,
 'N',    
 'N',    
 ISNULL(Convert(nvarchar(12),A.AUTO_TRAN_TYPE_CODE),'UNK'),    
 A.[START_DATE],    
 A.[LAST_ACTIVITY_DATE],    
 A.[NEXT_ACTIVITY_DATE],    
 A.[CEASE_DATE],    
 '416',    
 'U'    
 FROM    
 TRACAutoTransaction A    
INNER JOIN    
 dbo.GenIDFAAutoTran B    
 ON  A.Mntc_Sys_Code     = B.SourceSystem    
 AND A.AutoTransaction_Sys_Attr_Key1_Text = B.SourceSystemKey1    
 AND A.AutoTransaction_Sys_Attr_Key2_Text = B.SourceSystemKey2    
 AND A.AutoTransaction_Sys_Attr_Key3_Text = B.SourceSystemKey3    
 AND A.AutoTransaction_Sys_Attr_Key4_Text = B.SourceSystemKey4    
 AND A.AutoTransaction_Sys_Attr_Key5_Text = B.SourceSystemKey5    
 AND A.AutoTransaction_Sys_Attr_Key6_Text = B.SourceSystemKey6    
INNER JOIN    
 GenIDFAAgreement C    
 ON  C.SourceSystem = A.Mntc_Sys_Code    
 AND C.SourceSystemKey1 = A.Agreement_Sys_Attr_Key1_Text    
 AND C.SourceSystemKey2 = A.Agreement_Sys_Attr_Key2_Text    
 AND C.SourceSystemKey3 = A.Agreement_Sys_Attr_Key3_Text    
 AND C.SourceSystemKey4 = A.Agreement_Sys_Attr_Key4_Text    
WHERE C.SourceSystem = 'TRAC'    
    
SET QUOTED_IDENTIFIER OFF
GO
