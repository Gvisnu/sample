USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_FIXED_ASSET_SRC_DTL_Error_Handling]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Proc_TRAC_Populate_COR_FIXED_ASSET_SRC_DTL_Error_Handling]                                        
AS                                 
DECLARE @JobID INT;                                        
DECLARE @TEMPTIME DateTime;                                        
                                        
SET @JobID = (SELECT isnull(MAX(JobID),0)                                        
              FROM MC_JobID                                        
              INNER JOIN MC_SourceFile                                        
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID                                        
              WHERE logicalName = 'TRACFixedAssetSrcDtl'                                        
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)                                        
                                       FROM MC_SysProcessedLog                                        
                                       WHERE SystemID = 49));                                        
SET @TEMPTIME = GETDATE();        
      
      
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[COR_FIXED_ASSET_SRC_DTL_TODAY]') AND type in (N'U'))                        
BEGIN                        
DROP TABLE [dbo].[COR_FIXED_ASSET_SRC_DTL_TODAY]      
END                     
      
SELECT * INTO CORE1.DBO.[COR_FIXED_ASSET_SRC_DTL_TODAY] FROM COREETL.DBO.COR_FIXED_ASSET_SRC_DTL WHERE 1=2      
      
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
WHERE A.MNTC_SYS_CODE = 'TRAC'        /*and (
    (rtrim(SRC_SYS_ATTR_KEY2_TEXT) <> '' AND rtrim(B.SourceSystemKey2) = rtrim(SRC_SYS_ATTR_KEY2_TEXT)) 
    OR (rtrim(SRC_SYS_ATTR_KEY2_TEXT) = ''))*/
 AND B.SRC_FUND_ID IS NULL      
         
                                        
  INSERT INTO CORE1.DBO.[COR_FIXED_ASSET_SRC_DTL_TODAY]                               
(                                        
   AGREEMENT_ID,                                
   ACCOUNTING_DATE,                                
   SRC_FUND_ID,                                
   INTEREST_RATE,                                
   DEPOSIT_DATE,                                
   FUND_ASSET_SOURCE_CODE,                                
   DATETIMESTAMP,                                
   JOB_ID,                                
   DOLLAR_AMOUNT,                                
   REC_INSRT_DATE,                                
   REC_INSRT_NAME,                                
   REC_UPDT_DATE,                                
   REC_UPDT_NAME,                                
   VEST_PCT,
   TIER,                                
   ADU      
)                     
SELECT                                         
  AGREEMENT_ID   AS AGREEMENT_ID,                                        
  ACCOUNTING_DATE   AS ACCOUNTING_DATE,                                
  SRC_FUND_ID    AS SRC_FUND_ID,                                        
  ISNULL(GIA_CNTR_INT_RTE ,0) INTEREST_RATE,                            
  CASE WHEN GIA_CNTR_START_DTE  IS NULL THEN @TEMPTIME                                
  ELSE GIA_CNTR_START_DTE         
  END DEPOSIT_DATE   ,                                
  FUND_ASSET_SOURCE_CODE,                                      
  @TEMPTIME    AS DATETIMESTAMP,                                        
  @JobID     AS JOB_ID,                                        
  --CONVERT(DECIMAL(18,2),(CONVERT(DECIMAL(18,2),NUMBER_OF_SHARES)*CONVERT(DECIMAL(18,2),UNIT_PRICE))) DOLLAR_AMOUNT,                    
  --CONVERT(DECIMAL(18,2),(SUM(CONVERT(DECIMAL(18,2),NUMBER_OF_SHARES) * CONVERT(DECIMAL(18,2),UNIT_PRICE)))) AS DOLLAR_AMOUNT,                                  
  DOLLAR_AMOUNT,                  
  @TEMPTIME    AS REC_INSRT_DATE,                                        
  X.REC_INSRT_NAME  AS REC_INSRT_NAME,                                         
  @TEMPTIME    AS REC_UPDT_DATE,                                        
  '445'     AS REC_UPDT_NAME,                                        
  VEST_PCT                AS VEST_PCT,   
  0 AS TIER,                      
  ADU      AS ADU                                         
FROM                               
(       
 SELECT                                         
 GenIDFAAgreement.AgreementID AS AGREEMENT_ID,                                        
 ASD.LoadDate     AS ACCOUNTING_DATE,                                
 '999999999'      AS SRC_FUND_ID,                                        
 GIA_CNTR_INT_RTE *100   AS GIA_CNTR_INT_RTE ,                                
 GIA_CNTR_START_DTE    AS GIA_CNTR_START_DTE,        
 (RTRIM(ASD.SRC_SYS_ATTR_KEY1_TEXT)+'+'+RTRIM(SRC_SYS_ATTR_KEY2_TEXT)+'+'+RTRIM(SRC_SYS_ATTR_KEY3_TEXT)+'+'+RTRIM(SRC_SYS_ATTR_KEY4_TEXT)) AS REC_INSRT_NAME,                              
 (CONVERT(nvarchar(20),ASD.CONTR_MONEY_TY_CDE)+'+'+CONVERT(nvarchar(20),ASD.PLAN_TYPE_CDE))  AS FUND_ASSET_SOURCE_CODE,                                      
 CONVERT(DECIMAL(18,2),SUM(CONVERT(DECIMAL(18,6),ASD.VEH_MNY_TYPE_SHARES) * CONVERT(DECIMAL(18,6),ASD.UNIT_PRC))) AS DOLLAR_AMOUNT,                                        
 SUM(CONVERT(DECIMAL(18,6),ASD.VEH_MNY_TYPE_SHARES)) AS NUMBER_OF_SHARES,                    
 MAX(CONVERT(DECIMAL(18,6),ASD.UNIT_PRC))   AS UNIT_PRICE,                      
 MAX(ASD.MNY_TYPE_VESTED_PERCENT)     AS VEST_PCT,                               
 MAX(ADU)           AS ADU                                      
 FROM #TRACAssetSourceDetailFixed ASD                                          
 INNER JOIN dbo.GenIDFAAgreement  on GenIDFAAgreement.SourceSystemKey1 = ASD.AGRMNT_SYS_ATTR_KEY1_TEXT                                          
           AND GenIDFAAgreement.SourceSystemKey2 = rtrim(ASD.AGRMNT_SYS_ATTR_KEY2_TEXT)      
          AND GenIDFAAgreement.SourceSystemKey3 = rtrim(ASD.AGRMNT_SYS_ATTR_KEY3_TEXT)      
          AND GenIDFAAgreement.SourceSystemKey4 = rtrim(ASD.AGRMNT_SYS_ATTR_KEY4_TEXT)                                               
          AND GenIDFAAgreement.SourceSystemKey5 = rtrim(ASD.AGRMNT_SYS_ATTR_KEY5_TEXT)                                    
         AND ASD.MNTC_SYS_CODE = GenIDFAAgreement.SourceSystem                                                                          
  GROUP BY  GenIDFAAgreement.AgreementID,                                
     ASD.LoadDate,                                                             
     GIA_CNTR_INT_RTE,                                
     GIA_CNTR_START_DTE,      
     (RTRIM(ASD.SRC_SYS_ATTR_KEY1_TEXT)+'+'+RTRIM(SRC_SYS_ATTR_KEY2_TEXT)+'+'+RTRIM(SRC_SYS_ATTR_KEY3_TEXT)+'+'+RTRIM(SRC_SYS_ATTR_KEY4_TEXT)),    
     (CONVERT(nvarchar(20),ASD.CONTR_MONEY_TY_CDE)+'+'+CONVERT(nvarchar(20),ASD.PLAN_TYPE_CDE))                                 
) X                                
      
INSERT INTO COREERRLOG.DBO.REPERRORLOG (ERRORDATE, ERRORMESSAGE, ERRORDATA, ERRORSOURCE, SYSTEM)      
SELECT GETDATE(),      
 'UNABLE TO LOAD '+CAST(CNT AS VARCHAR)+' RECORD(S) INTO COR_FIXED_ASSET_SRC_DTL DUE TO A SRC_FUND_ID OF 999999999',      
 'REFER TO ERR TABLE FOR DETAIL',      
 'REP',      
 'TRAC'      
FROM (SELECT COUNT(*) AS CNT FROM CORE1.DBO.[COR_FIXED_ASSET_SRC_DTL_TODAY] WHERE SRC_FUND_ID = 999999999) Q      
WHERE CNT > 0      
      
INSERT INTO COREERRLOG.DBO.ERR_FIXED_ASSET_SRC_DTL      
SELECT *,      
 (SELECT DISTINCT @@IDENTITY FROM COREERRLOG.DBO.REPERRORLOG)      
FROM CORE1.DBO.[COR_FIXED_ASSET_SRC_DTL_TODAY]      
WHERE SRC_FUND_ID = 999999999;      
      
DELETE CORE1.DBO.[COR_FIXED_ASSET_SRC_DTL_TODAY]      
WHERE SRC_FUND_ID =999999999;      
      
----- If a SRC_FUND_ID was 999999999 and has been corrected, move to COR table and delete ERR row      
      
INSERT INTO CORE1.DBO.[COR_FIXED_ASSET_SRC_DTL_TODAY]      
 (      
   AGREEMENT_ID,                                
   ACCOUNTING_DATE,                                
   SRC_FUND_ID,                                
   INTEREST_RATE,                                
   DEPOSIT_DATE,                                
   FUND_ASSET_SOURCE_CODE,                                
   DATETIMESTAMP,                                
   JOB_ID,                                
   DOLLAR_AMOUNT,                                
   REC_INSRT_DATE,                                
   REC_INSRT_NAME,                                
   REC_UPDT_DATE,                                
   REC_UPDT_NAME,                                
   VEST_PCT,
   TIER,                                
   ADU      
 )      
SELECT      
   A.AGREEMENT_ID,                                
   A.ACCOUNTING_DATE,                                
   A.SRC_FUND_ID,                                
   A.INTEREST_RATE,                                
   A.DEPOSIT_DATE,                                
   A.FUND_ASSET_SOURCE_CODE,                                
   @TEMPTIME,      
   @JobID,                             
   A.DOLLAR_AMOUNT,                                
   @TEMPTIME,                                
   '445',                                
   @TEMPTIME,                              
   A.REC_UPDT_NAME,                                
   A.VEST_PCT,
   0,                                
   A.ADU      
FROM COREERRLOG.DBO.ERR_FIXED_ASSET_SRC_DTL A      
INNER JOIN COREERRLOG.DBO.REPERRORLOG B      
ON  A.REPERRORID = B.ERRORID      
WHERE B.ERRORMESSAGE LIKE '%DUE TO A SRC_FUND_ID OF 999999999'      
  AND A.SRC_FUND_ID <> 999999999;      
        
      
DELETE COREERRLOG.DBO.ERR_FIXED_ASSET_SRC_DTL      
FROM COREERRLOG.DBO.ERR_FIXED_ASSET_SRC_DTL A      
INNER JOIN COREERRLOG.DBO.REPERRORLOG B      
ON  A.REPERRORID = B.ERRORID      
WHERE B.ERRORMESSAGE LIKE '%DUE TO A SRC_FUND_ID OF 999999999'      
  AND A.SRC_FUND_ID <> 999999999;      
        
--Update CoreETL.dbo.COR_FIXED_ASSET_SRC_DTL set REC_INSRT_NAME = '419';      
      
INSERT INTO COREETL.DBO.COR_FIXED_ASSET_SRC_DTL SELECT DISTINCT * FROM CORE1.DBO.[COR_FIXED_ASSET_SRC_DTL_TODAY]       
      
                          
RETURN                              
SET QUOTED_IDENTIFIER OFF      
         
        
GO
