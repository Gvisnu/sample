USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_ASSET_SOURCE_DETAIL_Plan]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Proc_TRAC_Populate_COR_ASSET_SOURCE_DETAIL_Plan]    
AS                          
DECLARE @JobID INT;                          
DECLARE @TEMPTIME DateTime;                          
                          
SET @JobID = (SELECT isnull(MAX(JobID),0)                          
              FROM MC_JobID                          
              INNER JOIN MC_SourceFile                          
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID                          
              WHERE logicalName = 'TRACAssetSourceDetail'                          
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)                          
                                       FROM MC_SysProcessedLog                          
                                       WHERE SystemID = 49));                          
SET @TEMPTIME = GETDATE();                          
--TRUNCATE TABLE COR_ASSET_SOURCE_DETAIL_08132014    
INSERT INTO COREETL.DBO.COR_ASSET_SOURCE_DETAIL(    
 AGREEMENT_ID,      
 SRC_FUND_ID,      
 ACCOUNTING_DATE,      
 FUND_ASSET_SOURCE_CODE,      
 DATETIMESTAMP,      
 JOB_ID,      
 AMOUNT,      
 NUMBER_OF_SHARES,      
 REC_INSRT_DATE,      
 REC_INSRT_NAME,      
 REC_UPDT_DATE,      
 REC_UPDT_NAME,      
 VEST_PCT,      
 ADU          
 )                          
Select                           
 GenIDFAAgreement.AgreementID AS AGREEMENT_ID,      
 ISNULL(TF.SRC_FUND_ID,999999999),    
 ASD.LoadDate     AS ACCOUNTING_DATE,      
 (CONVERT(nvarchar(20),ASD.CONTR_MONEY_TY_CDE)+'+'+CONVERT(nvarchar(20),ASD.PLAN_TYPE_CDE))  AS FUND_ASSET_SOURCE_CODE,    
 @TEMPTIME      AS DATETIMESTAMP,      
 @JobID       AS JOB_ID,      
 CONVERT(DECIMAL(18,2),SUM(CONVERT(DECIMAL(18,6),CONVERT(DECIMAL(18,6),ASD.VEH_MNY_TYPE_SHARES) * CONVERT(DECIMAL(18,6),ASD.UNIT_PRC)))) AS AMOUNT,          
 CONVERT(DECIMAL(18,6),SUM(CONVERT(DECIMAL(18,6),ASD.VEH_MNY_TYPE_SHARES)))  AS NUMBER_OF_SHARES,                 
 @TEMPTIME      AS REC_INSRT_DATE,      
 '424'       AS REC_INSRT_NAME,      
 @TEMPTIME      AS REC_UPDT_DATE,      
 '424'       AS REC_UPDT_NAME,      
 ASD.MNY_TYPE_VESTED_PERCENT AS VEST_PCT,      
 MAX(ADU)      AS ADU                           
FROM dbo.TRACAssetSourceDetailVariable_Plan ASD                          
INNER JOIN dbo.GenIDFAAgreement  on GenIDFAAgreement.SourceSystemKey1 = ASD.AGRMNT_SYS_ATTR_KEY1_TEXT                          
        AND GenIDFAAgreement.SourceSystemKey2 = ASD.AGRMNT_SYS_ATTR_KEY2_TEXT                          
        AND GenIDFAAgreement.SourceSystemKey3 = ASD.AGRMNT_SYS_ATTR_KEY3_TEXT                          
        AND GenIDFAAgreement.SourceSystemKey4 = ASD.AGRMNT_SYS_ATTR_KEY4_TEXT                          
        AND GenIDFAAgreement.SourceSystemKey5 = ASD.AGRMNT_SYS_ATTR_KEY5_TEXT                          
        AND ASD.MNTC_SYS_CODE = GenIDFAAgreement.SourceSystem                          
/*        
INNER  JOIN GENIDSRCFUND GENID   ON  GENID.SOURCESYSTEM = ASD.MNTC_SYS_CODE                          
        AND GENID.SOURCESYSTEMKEY1 = SRC_SYS_ATTR_KEY1_TEXT                          
    --  AND GENID.SOURCESYSTEMKEY2 = SRC_SYS_ATTR_KEY2_TEXT                          
        AND GENID.SOURCESYSTEMKEY3 = SRC_SYS_ATTR_KEY3_TEXT                          
        AND GENID.SOURCESYSTEMKEY4 = SRC_SYS_ATTR_KEY4_TEXT                    
*/        
 INNER JOIN TRACFUNDS TF    ON        
    rtrim(TF.KEY1) = rtrim(SRC_SYS_ATTR_KEY1_TEXT)                                                  
          --  AND TF.KEY2 = SRC_SYS_ATTR_KEY2_TEXT                                                  
           AND rtrim(TF.KEY3) = rtrim(SRC_SYS_ATTR_KEY3_TEXT)                                                  
           AND rtrim(TF.KEY4) = rtrim(SRC_SYS_ATTR_KEY4_TEXT)         
        and TF.FUND_TYPE = 'VARIABLE'                    
WHERE ASD.MNTC_SYS_CODE = 'TRAC'          
  --and (      
  --  (rtrim(SRC_SYS_ATTR_KEY2_TEXT) <> '' AND rtrim(TF.KEY2) = rtrim(SRC_SYS_ATTR_KEY2_TEXT))       
  --  OR (rtrim(SRC_SYS_ATTR_KEY2_TEXT) = ''))      
      
GROUP BY                  
GenIDFAAgreement.AgreementID,      
 --GENID.SRC_FUND_ID,      
 TF.SRC_FUND_ID,    
 ASD.LoadDate,                  
 (CONVERT(nvarchar(20),ASD.CONTR_MONEY_TY_CDE)+'+'+CONVERT(nvarchar(20),ASD.PLAN_TYPE_CDE)),                   
  ASD.MNY_TYPE_VESTED_PERCENT; 
GO
