USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_FIXED_ASSET_SRC_DTL_Plan]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Proc_TRAC_Populate_COR_FIXED_ASSET_SRC_DTL_Plan]    
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
  
INSERT INTO COREETL.DBO.COR_FIXED_ASSET_SRC_DTL  
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
tier,                                      
ADU              
              
)                                       
Select                                                 
 AGREEMENT_ID,                                                
 ACCOUNTING_DATE,                                        
 SRC_FUND_ID,                                                
 ISNULL(GIA_CNTR_INT_RTE ,0) INTEREST_RATE,                                        
 CASE WHEN GIA_CNTR_START_DTE  IS NULL THEN @TEMPTIME                                        
 ELSE GIA_CNTR_START_DTE   END DEPOSIT_DATE,                                        
 FUND_ASSET_SOURCE_CODE,                                              
 @TEMPTIME   AS DATETIMESTAMP,                                                
 @JobID    AS JOB_ID,                                                
 DOLLAR_AMOUNT,                          
 @TEMPTIME   AS REC_INSRT_DATE,                                                
 '445'    AS REC_INSRT_NAME,                                                
 @TEMPTIME   AS REC_UPDT_DATE,                                                
 '445'    AS REC_UPDT_NAME,                                                
 VEST_PCT,       
 0 tier,                                         
 ADU    AS ADU                                                 
FROM                                       
(               
 SELECT                                                 
 GenIDFAAgreement.AgreementID AS AGREEMENT_ID,                                                
 ASD.LoadDate     AS ACCOUNTING_DATE,                                        
     --GENID.SRC_FUND_ID,                                       
 TF.SRC_FUND_ID,                                                                            
 GIA_CNTR_INT_RTE *100 as  GIA_CNTR_INT_RTE ,                                        
 GIA_CNTR_START_DTE,                                        
 (CONVERT(nvarchar(20),ASD.CONTR_MONEY_TY_CDE)+'+'+CONVERT(nvarchar(20),ASD.PLAN_TYPE_CDE))  AS FUND_ASSET_SOURCE_CODE,     
 CONVERT(DECIMAL(18,2),SUM(CONVERT(DECIMAL(18,6),ASD.VEH_MNY_TYPE_SHARES) * CONVERT(DECIMAL(18,6),ASD.UNIT_PRC))) AS DOLLAR_AMOUNT,                       
 SUM(CONVERT(DECIMAL(18,6),ASD.VEH_MNY_TYPE_SHARES)) AS NUMBER_OF_SHARES,                            
 MAX(CONVERT(DECIMAL(18,6),ASD.UNIT_PRC)) AS UNIT_PRICE,                              
 MAX(ASD.MNY_TYPE_VESTED_PERCENT) AS VEST_PCT,                                      
 MAX(ADU) as ADU                                              
 FROM DBO.TRACAssetSourceDetailFixed_Plan ASD                                                  
 INNER JOIN dbo.GenIDFAAgreement  on GenIDFAAgreement.SourceSystemKey1 = ASD.AGRMNT_SYS_ATTR_KEY1_TEXT                                                  
          AND GenIDFAAgreement.SourceSystemKey2 = rtrim(ASD.AGRMNT_SYS_ATTR_KEY2_TEXT)        
          AND GenIDFAAgreement.SourceSystemKey3 = rtrim(ASD.AGRMNT_SYS_ATTR_KEY3_TEXT)        
          AND GenIDFAAgreement.SourceSystemKey4 = rtrim(ASD.AGRMNT_SYS_ATTR_KEY4_TEXT)                                                 
          AND GenIDFAAgreement.SourceSystemKey5 = rtrim(ASD.AGRMNT_SYS_ATTR_KEY5_TEXT)                                                 
          AND ASD.MNTC_SYS_CODE = GenIDFAAgreement.SourceSystem                                                  
 INNER JOIN TRACFUNDS TF    ON        
    rtrim(TF.KEY1) = rtrim(SRC_SYS_ATTR_KEY1_TEXT)                                                  
          --  AND TF.KEY2 = SRC_SYS_ATTR_KEY2_TEXT                                                  
           AND rtrim(TF.KEY3) = rtrim(SRC_SYS_ATTR_KEY3_TEXT)                                                  
           AND rtrim(TF.KEY4) = rtrim(SRC_SYS_ATTR_KEY4_TEXT)                                                
           AND TF.FUND_TYPE = 'FIXED'                                                
WHERE ASD.MNTC_SYS_CODE = 'TRAC'          
--and (      
--    (rtrim(SRC_SYS_ATTR_KEY2_TEXT) <> '' AND rtrim(TF.KEY2) = rtrim(SRC_SYS_ATTR_KEY2_TEXT))       
--    OR (rtrim(SRC_SYS_ATTR_KEY2_TEXT) = ''))              
 GROUP BY  GenIDFAAgreement.AgreementID,                                        
    ASD.LoadDate,                                        
    --GENID.SRC_FUND_ID,                                       
 TF.SRC_FUND_ID,                                       
    GIA_CNTR_INT_RTE,                                        
    GIA_CNTR_START_DTE,                                         
    (CONVERT(nvarchar(20),ASD.CONTR_MONEY_TY_CDE)+'+'+CONVERT(nvarchar(20),ASD.PLAN_TYPE_CDE))                                         
   ) X                                        
                          
   RETURN 
GO
