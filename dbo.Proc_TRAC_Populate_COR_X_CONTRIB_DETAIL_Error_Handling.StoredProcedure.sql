USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_X_CONTRIB_DETAIL_Error_Handling]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Proc_TRAC_Populate_COR_X_CONTRIB_DETAIL_Error_Handling] AS                                
                                          
DECLARE @JobID INT;                                              
DECLARE @TempDate DATETIME;                                              
                                              
SET @TempDate = GETDATE();                                              
                                              
SET @JobID = (SELECT MAX(JobID)                                                                      
              FROM MC_JobID                                                                      
              INNER JOIN MC_SourceFile                                                                      
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID                                                                      
              WHERE logicalName = 'TRACContributionDetail'                                                                      
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)                                                                      
                                       FROM MC_SysProcessedLog                                                                      
                                       WHERE SystemID = 49));          
      
CREATE TABLE [dbo].[#TRACAssetSourceDetailFixed]        
(        
 [AGRMNT_SYS_ATTR_KEY1_TEXT] [nvarchar](40) NULL,        
 [AGRMNT_SYS_ATTR_KEY2_TEXT] [nvarchar](40) NULL,        
 [AGRMNT_SYS_ATTR_KEY3_TEXT] [nvarchar](40) NULL,        
 [AGRMNT_SYS_ATTR_KEY4_TEXT] [nvarchar](40) NULL,        
 [AGRMNT_SYS_ATTR_KEY5_TEXT] [nvarchar](40) NULL,        
 [SRC_SYS_ATTR_KEY1_TEXT] [nvarchar](40) NULL,        
 [SRC_SYS_ATTR_KEY2_TEXT] [nvarchar](40) NULL,        
 [SRC_SYS_ATTR_KEY3_TEXT] [nvarchar](40) NULL,        
 [SRC_SYS_ATTR_KEY4_TEXT] [nvarchar](40) NULL,        
 [SRC_SYS_ATTR_KEY5_TEXT] [nvarchar](40) NULL,        
 [LoadDate] [date] NULL,        
 [VEH_MNY_TYPE_SHARES] [numeric](15, 4) NULL,        
 [UNIT_PRC] [numeric](15, 10) NULL,        
 [CONTR_MONEY_TY_CDE] [smallint] NULL,        
 [PLAN_TYPE_CDE] [varchar](8) NULL,        
 [MNY_TYPE_VESTED_PERCENT] [numeric](15, 10) NULL,        
 [GIA_CONTRACT_ID] [int] NULL,        
 [GIA_CNTR_START_DTE] [datetime] NULL,        
 [GIA_CNTRCT_END_DTE] [datetime] NULL,        
 [GIA_CNTR_MATUR_DTE] [datetime] NULL,        
 [GIA_CNTR_INT_RTE] [numeric](15, 10) NULL,        
 [GIA_PORT_IND] [char](1) NULL,        
 [MNTC_SYS_CODE] [varchar](4) NOT NULL,        
 [ADU] [char](1) NULL        
)                                        
           
           
INSERT INTO dbo.#TRACAssetSourceDetailFixed        
Select A.* from TRACAssetSourceDetailFixed A        
LEFT OUTER JOIN core1.dbo.GenIDSrcFund B        
ON rtrim(a.SRC_SYS_ATTR_KEY1_TEXT) = rtrim(B.SourceSystemKey1)        
ANd rtrim(a.SRC_SYS_ATTR_KEY3_TEXT) = rtrim(B.SourceSystemKey3)        
and rtrim(a.SRC_SYS_ATTR_KEY4_TEXT) = rtrim(B.SourceSystemKey4)  
and (    
    (rtrim(SRC_SYS_ATTR_KEY2_TEXT) <> '' AND rtrim(B.SourceSystemKey2) = rtrim(SRC_SYS_ATTR_KEY2_TEXT))     
    OR (rtrim(SRC_SYS_ATTR_KEY2_TEXT) = ''))      
WHERE A.MNTC_SYS_CODE = 'TRAC'      /* and (    
    (rtrim(SRC_SYS_ATTR_KEY2_TEXT) <> '' AND rtrim(B.SourceSystemKey2) = rtrim(SRC_SYS_ATTR_KEY2_TEXT))     
    OR (rtrim(SRC_SYS_ATTR_KEY2_TEXT) = '')) */  
AND B.SRC_FUND_ID IS NULL                          
      
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[COR_X_CONTRIB_DETAIL_TODAY]') AND type in (N'U'))                          
BEGIN                          
DROP TABLE [dbo].[COR_X_CONTRIB_DETAIL_TODAY]        
END                       
        
SELECT * INTO CORE1.DBO.[COR_X_CONTRIB_DETAIL_TODAY] FROM COREETL.DBO.COR_X_CONTRIB_DETAIL WHERE 1=2      
      
INSERT INTO CORE1.DBO.COR_X_CONTRIB_DETAIL_TODAY                                          
  (                                
 AGREEMENT_ID,                                
 ACCOUNTING_DATE,                                
 SRC_FUND_ID,                                
 INTEREST_RATE,                                
 DEPOSIT_DATE,                                
 DATETIMESTAMP,                                
 JOB_ID,                                
 CONTRIBUTION_DETAIL_TYPE_CODE,                              
 INTEREST_RATE_START_DATE,                              
 INTEREST_RATE_END_DATE,                              
 DOLLAR_AMOUNT,                                
 VALUE_PER_UNIT,                                
 NUMBER_OF_SHARES,                                
 REC_INSRT_DATE,                              
 REC_INSRT_NAME,                                
 REC_UPDT_DATE,                              
 REC_UPDT_NAME,                                
 ADU ,
 TIER               
)                                
SELECT         
 A.AGREEMENT_ID,                                
 A.ACCOUNTING_DATE,                                
 A.SRC_FUND_ID,                                
 A.INTEREST_RATE,                           
 A.DEPOSIT_DATE,                                
 A.DATETIMESTAMP,                                
 A.JOB_ID,                                
 A.CONTRIBUTION_DETAIL_TYPE_CODE,                              
 A.INTEREST_RATE_START_DATE,                              
 A.INTEREST_RATE_END_DATE,                              
 A.DOLLAR_AMOUNT,                                
 A.VALUE_PER_UNIT,                                
 A.NUMBER_OF_SHARES,                                
 A.REC_INSRT_DATE,                              
 A.REC_INSRT_NAME,                                
 A.REC_UPDT_DATE,                              
 A.REC_UPDT_NAME,                                
 A.ADU   ,
 0       
FROM         
(                  
 SELECT                     
 GenIDFAAgreement.AgreementID   AS AGREEMENT_ID,                                              
 ASD.LoadDate       AS ACCOUNTING_DATE,                                
 '999999999'        AS SRC_FUND_ID,                                       
 ISNULL(GIA_CNTR_INT_RTE,0)    AS INTEREST_RATE,                                
 CASE WHEN GIA_CNTR_START_DTE                          
 IS NULL THEN @TempDate                              
 ELSE GIA_CNTR_START_DTE                           
 END          AS DEPOSIT_DATE,                                 
 @TempDate        AS DATETIMESTAMP,                                              
 @JobID         AS JOB_ID,                              
 'FIX INT'        AS CONTRIBUTION_DETAIL_TYPE_CODE,                              
 CASE WHEN GIA_CNTR_START_DTE                          
 IS NULL THEN @TempDate                                
 ELSE GIA_CNTR_START_DTE                           
 END         AS INTEREST_RATE_START_DATE,                              
 max(GIA_CNTRCT_END_DTE)    AS INTEREST_RATE_END_DATE,    -- added max() by Francis 1/2/2014                          
 CONVERT(DECIMAL(18,2),(SUM (CONVERT(DECIMAL(18,6),ASD.VEH_MNY_TYPE_SHARES) * CONVERT(DECIMAL(18,6),ASD.UNIT_PRC))))  AS DOLLAR_AMOUNT,                        
 MAX(CONVERT(DECIMAL(18,6),ASD.UNIT_PRC))   AS VALUE_PER_UNIT,                     
 sum(CONVERT(DECIMAL(18,6),ASD.VEH_MNY_TYPE_SHARES)) AS NUMBER_OF_SHARES,                                        
 @TempDate           AS REC_INSRT_DATE,                                 
 --'423'            AS REC_INSRT_NAME,                
 (RTRIM(ASD.SRC_SYS_ATTR_KEY1_TEXT)+'+'+RTRIM(SRC_SYS_ATTR_KEY2_TEXT)+'+'+RTRIM(SRC_SYS_ATTR_KEY3_TEXT)+'+'+RTRIM(SRC_SYS_ATTR_KEY4_TEXT)) AS REC_INSRT_NAME,                              
 @TempDate           AS REC_UPDT_DATE,                              
 '423'            AS REC_UPDT_NAME,                                
 MAX(ADU)           AS ADU                              
 FROM dbo.#TRACAssetSourceDetailFixed ASD                                          
 INNER JOIN dbo.GenIDFAAgreement     on GenIDFAAgreement.SourceSystemKey1 = ASD.AGRMNT_SYS_ATTR_KEY1_TEXT                                   
         AND GenIDFAAgreement.SourceSystemKey2 = ASD.AGRMNT_SYS_ATTR_KEY2_TEXT                                          
         AND GenIDFAAgreement.SourceSystemKey3 = ASD.AGRMNT_SYS_ATTR_KEY3_TEXT                                          
         AND GenIDFAAgreement.SourceSystemKey4 = ASD.AGRMNT_SYS_ATTR_KEY4_TEXT                                          
         AND GenIDFAAgreement.SourceSystemKey5 = ASD.AGRMNT_SYS_ATTR_KEY5_TEXT                                          
         AND ASD.MNTC_SYS_CODE = GenIDFAAgreement.SourceSystem                                                                        
                         
 WHERE ASD.MNTC_SYS_CODE = 'TRAC'          
 GROUP BY                                  
  GenIDFAAgreement.AgreementID,                                                          
  ASD.LoadDate,                              
  GIA_CNTR_INT_RTE,                              
  CASE WHEN GIA_CNTR_START_DTE                            
  IS NULL THEN @TempDate                              
  ELSE GIA_CNTR_START_DTE   END,    
  (RTRIM(ASD.SRC_SYS_ATTR_KEY1_TEXT)+'+'+RTRIM(SRC_SYS_ATTR_KEY2_TEXT)+'+'+RTRIM(SRC_SYS_ATTR_KEY3_TEXT)+'+'+RTRIM(SRC_SYS_ATTR_KEY4_TEXT))                           
 )A                   
                         
INSERT INTO COREERRLOG.DBO.REPERRORLOG (ERRORDATE, ERRORMESSAGE, ERRORDATA, ERRORSOURCE, SYSTEM)                
SELECT GETDATE(),                
 'UNABLE TO LOAD '+CAST(CNT AS VARCHAR)+' RECORD(S) INTO COR_X_CONTRIB_DETAIL DUE TO A SRC_FUND_ID OF 999999999',                
 'REFER TO ERR TABLE FOR DETAIL',                
 'REP',                
 'TRAC'                
FROM (SELECT COUNT(*) AS CNT FROM CORE1.DBO.COR_X_CONTRIB_DETAIL_TODAY WHERE SRC_FUND_ID = 999999999) Q                
WHERE CNT > 0                
              
INSERT INTO COREERRLOG.DBO.ERR_X_CONTRIB_DETAIL                
SELECT *,                
 (SELECT DISTINCT @@IDENTITY FROM COREERRLOG.DBO.REPERRORLOG)                
FROM CORE1.DBO.COR_X_CONTRIB_DETAIL_TODAY                
WHERE SRC_FUND_ID = 999999999;                
                
DELETE CORE1.DBO.COR_X_CONTRIB_DETAIL_TODAY                
WHERE SRC_FUND_ID =999999999;                
                
----- If a SRC_FUND_ID was 999999999 and has been corrected, move to COR table and delete ERR row                
                
INSERT INTO CORE1.DBO.COR_X_CONTRIB_DETAIL_TODAY                
 (                
  AGREEMENT_ID,                                
  ACCOUNTING_DATE,                                
  SRC_FUND_ID,                                
  INTEREST_RATE,                                
  DEPOSIT_DATE,                              
  DATETIMESTAMP,                                
  JOB_ID,                                
  CONTRIBUTION_DETAIL_TYPE_CODE,                              
  INTEREST_RATE_START_DATE,                              
  INTEREST_RATE_END_DATE,                              
  DOLLAR_AMOUNT,                                
  VALUE_PER_UNIT,                              
  NUMBER_OF_SHARES,                                
  REC_INSRT_DATE,                              
  REC_INSRT_NAME,                                
  REC_UPDT_DATE,                              
  REC_UPDT_NAME,                                
  ADU  ,
  TIER              
 )                
SELECT                
                   
  A.AGREEMENT_ID,                                
  A.ACCOUNTING_DATE,                                
  A.SRC_FUND_ID,                                
  A.INTEREST_RATE,                                
  A.DEPOSIT_DATE,                                
  @TempDate,    
  @JobID,    
  A.CONTRIBUTION_DETAIL_TYPE_CODE,                              
  A.INTEREST_RATE_START_DATE,                              
  A.INTEREST_RATE_END_DATE,                              
  A.DOLLAR_AMOUNT,                                
  A.VALUE_PER_UNIT,                                
  A.NUMBER_OF_SHARES,                                
  @TempDate,    
  '423',                                
  @TempDate,    
  A.REC_UPDT_NAME,                                
  A.ADU, 0                
                
FROM COREERRLOG.DBO.ERR_X_CONTRIB_DETAIL A                
INNER JOIN COREERRLOG.DBO.REPERRORLOG B                
ON  A.REPERRORID = B.ERRORID                
WHERE B.ERRORMESSAGE LIKE '%DUE TO A SRC_FUND_ID OF 999999999'                
  AND A.SRC_FUND_ID <> 999999999;                
                  
                
DELETE COREERRLOG.DBO.ERR_X_CONTRIB_DETAIL                
FROM COREERRLOG.DBO.ERR_X_CONTRIB_DETAIL A                
INNER JOIN COREERRLOG.DBO.REPERRORLOG B                
ON  A.REPERRORID = B.ERRORID                
WHERE B.ERRORMESSAGE LIKE '%DUE TO A SRC_FUND_ID OF 999999999'                
  AND A.SRC_FUND_ID <> 999999999;                
                  
--Update CORE1.DBO.COR_X_CONTRIB_DETAIL_TODAY set REC_INSRT_NAME = '423';                
      
INSERT INTO COREETL.DBO.COR_X_CONTRIB_DETAIL SELECT DISTINCT * FROM CORE1.DBO.[COR_X_CONTRIB_DETAIL_TODAY]      
      
RETURN                                        
SET QUOTED_IDENTIFIER OFF 
GO
