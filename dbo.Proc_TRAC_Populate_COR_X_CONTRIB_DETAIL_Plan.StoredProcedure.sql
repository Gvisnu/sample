USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_X_CONTRIB_DETAIL_Plan]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Proc_TRAC_Populate_COR_X_CONTRIB_DETAIL_Plan] AS                                    
                                              
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
  
INSERT INTO   COREETL.DBO.COR_X_CONTRIB_DETAIL    
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
TIER  ,                                                     
ADU                    
)                                    
SELECT A.AGREEMENT_ID,                                    
A.ACCOUNTING_DATE,                                    
ISNULL(A.SRC_FUND_ID,999999999),    
ISNULL(A.INTEREST_RATE,0)    AS INTEREST_RATE,                                  
A.DEPOSIT_DATE,                                    
A.DATETIMESTAMP,                                    
A.JOB_ID,                                    
A.CONTRIBUTION_DETAIL_TYPE_CODE,                                  
A.INTEREST_RATE_START_DATE,                                  
A.INTEREST_RATE_END_DATE,                                  
DOLLAR_AMOUNT,                                    
A.VALUE_PER_UNIT,                                    
A.NUMBER_OF_SHARES,                                    
A.REC_INSRT_DATE,                                  
A.REC_INSRT_NAME,                                    
A.REC_UPDT_DATE,                                  
A.REC_UPDT_NAME, 
0 As TIER ,                                                       
A.ADU              
FROM             
(                      
 SELECT                         
 GenIDFAAgreement.AgreementID   AS AGREEMENT_ID,                                                  
 ASD.LoadDate       AS ACCOUNTING_DATE,                                    
 --GENID.SRC_FUND_ID      AS SRC_FUND_ID,                                           
 TF.SRC_FUND_ID      AS SRC_FUND_ID,                                           
 ISNULL(GIA_CNTR_INT_RTE,0) * 100 AS    INTEREST_RATE ,                               
 CASE WHEN isnull(GIA_CNTR_START_DTE,'') = ''  THEN @TempDate                                  
 ELSE GIA_CNTR_START_DTE                               
 END         AS DEPOSIT_DATE,                                     
 @TempDate     AS DATETIMESTAMP,                         
 @JobID         AS JOB_ID,                                  
 --CASE WHEN ISNULL(CONTR_MONEY_TY_CDE,'0') = '0' THEN 'N/A' ELSE 'FIX INT' END AS CONTRIBUTION_DETAIL_TYPE_CODE,                                  
 'FIX INT' AS CONTRIBUTION_DETAIL_TYPE_CODE,    
 CASE WHEN isnull(GIA_CNTR_START_DTE,'') = ''  THEN @TempDate                                    
 ELSE GIA_CNTR_START_DTE                               
 END         AS INTEREST_RATE_START_DATE,                                  
 max(GIA_CNTRCT_END_DTE)    AS INTEREST_RATE_END_DATE,    -- added max() by Francis 1/2/2014                              
 CONVERT(DECIMAL(18,2),(SUM (CONVERT(DECIMAL(18,6),ASD.VEH_MNY_TYPE_SHARES) * CONVERT(DECIMAL(18,6),ASD.UNIT_PRC))))  AS DOLLAR_AMOUNT,                            
 MAX(CONVERT(DECIMAL(18,6),ASD.UNIT_PRC))   AS VALUE_PER_UNIT,                         
 sum(CONVERT(DECIMAL(18,6),ASD.VEH_MNY_TYPE_SHARES)) AS NUMBER_OF_SHARES,                                            
 @TempDate           AS REC_INSRT_DATE,                                     
 '423'            AS REC_INSRT_NAME,                    
 @TempDate           AS REC_UPDT_DATE,                                  
 '423'            AS REC_UPDT_NAME,                                    
 MAX(ADU)           AS ADU                                  
 FROM dbo.TRACAssetSourceDetailFixed_PLAN ASD                                              
 INNER JOIN dbo.GenIDFAAgreement     on GenIDFAAgreement.SourceSystemKey1 = ASD.AGRMNT_SYS_ATTR_KEY1_TEXT                                       
         AND GenIDFAAgreement.SourceSystemKey2 = ASD.AGRMNT_SYS_ATTR_KEY2_TEXT                                              
         AND GenIDFAAgreement.SourceSystemKey3 = ASD.AGRMNT_SYS_ATTR_KEY3_TEXT                                              
         AND GenIDFAAgreement.SourceSystemKey4 = ASD.AGRMNT_SYS_ATTR_KEY4_TEXT                                              
         AND GenIDFAAgreement.SourceSystemKey5 = ASD.AGRMNT_SYS_ATTR_KEY5_TEXT                                              
         AND ASD.MNTC_SYS_CODE = GenIDFAAgreement.SourceSystem                                                                            
 /*INNER JOIN GENIDSRCFUND GENID       ON  GENID.SOURCESYSTEM = ASD.MNTC_SYS_CODE                                              
         AND GENID.SOURCESYSTEMKEY1 = SRC_SYS_ATTR_KEY1_TEXT                                              
        --  AND GENID.SOURCESYSTEMKEY2 = SRC_SYS_ATTR_KEY2_TEXT                                              
         AND GENID.SOURCESYSTEMKEY3 = SRC_SYS_ATTR_KEY3_TEXT                                 
         AND GENID.SOURCESYSTEMKEY4 = SRC_SYS_ATTR_KEY4_TEXT                                        
 */INNER JOIN TRACFUNDS TF    ON  rtrim(TF.KEY1) = rtrim(SRC_SYS_ATTR_KEY1_TEXT)                                              
         -- AND TF.KEY2 = SRC_SYS_ATTR_KEY2_TEXT                                              
         AND rtrim(TF.KEY3) = rtrim(SRC_SYS_ATTR_KEY3_TEXT)                                              
         AND rtrim(TF.KEY4 )= rtrim(SRC_SYS_ATTR_KEY4_TEXT )                                           
         AND TF.FUND_TYPE = 'FIXED'                             
 WHERE ASD.MNTC_SYS_CODE = 'TRAC'           
  --and (      
  --  (rtrim(SRC_SYS_ATTR_KEY2_TEXT) <> '' AND rtrim(TF.KEY2) = rtrim(SRC_SYS_ATTR_KEY2_TEXT))       
  --  OR (rtrim(SRC_SYS_ATTR_KEY2_TEXT) = ''))      
 GROUP BY                                         
 GenIDFAAgreement.AgreementID,                                      
 --GENID.SRC_FUND_ID,        
 TF.SRC_FUND_ID,        
 ASD.LoadDate,                                  
 ISNULL(GIA_CNTR_INT_RTE,0),          
 --CASE WHEN ISNULL(CONTR_MONEY_TY_CDE,'0') = '0' THEN 'N/A' ELSE 'FIX INT' END,                              
 CASE WHEN isnull(GIA_CNTR_START_DTE,'') = '' THEN @TempDate                               
 ELSE GIA_CNTR_START_DTE   END                               
 )A 
GO
