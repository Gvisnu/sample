USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_X_Fund_DETAIL_Plan]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Proc_TRAC_Populate_COR_X_Fund_DETAIL_Plan] AS                                            
                                            
DECLARE @JobID INT;                                                
DECLARE @TempDate DATETIME;                                                
                                                
SET @TempDate = GETDATE();                                                
                                                
SET @JobID = (SELECT MAX(JobID)                                                                        
              FROM MC_JobID                                                                        
              INNER JOIN MC_SourceFile                                                                        
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID                                                                        
              WHERE logicalName = 'TRACFundDetail'                                                                        
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)                                                                        
                                       FROM MC_SysProcessedLog                                                                        
                                       WHERE SystemID = 49));                   
    
INSERT INTO COREETL.DBO.COR_X_FUND_DETAIL   
  (                    
  AGREEMENT_ID,    
SRC_FUND_ID,    
ACCOUNTING_DATE,    
DATETIMESTAMP,    
JOB_ID,    
DOLLAR_AMOUNT,    
VALUE_PER_UNIT,    
NUMBER_OF_SHARES,    
REC_INSRT_DATE,    
REC_INSRT_NAME,    
REC_UPDT_DATE,    
REC_UPDT_NAME,    
ADU                   
  )                                            
SELECT                                             
 GenIDFAAgreement.AgreementID   AS AGREEMENT_ID,                                                
 ISNULL(TF.SRC_FUND_ID,999999999)      AS SRC_FUND_ID,                                         
 ASD.LoadDate       AS ACCOUNTING_DATE,                                         
 @TempDate        AS DATETIMESTAMP,                                                
 @JobID         AS JOB_ID,                                                    
 CONVERT(DECIMAL(18,2),(SUM(CONVERT(DECIMAL(18,6),ASD.VEH_MNY_TYPE_SHARES) * CONVERT(DECIMAL(18,6),ASD.UNIT_PRC))))  AS DOLLAR_AMOUNT,                          
 MAX(CONVERT(DECIMAL(18,6),ASD.UNIT_PRC))    AS VALUE_PER_UNIT,                                    
 SUM(CONVERT(DECIMAL(18,6),ASD.VEH_MNY_TYPE_SHARES)) AS NUMBER_OF_SHARES,                         
 @TempDate AS REC_INSRT_DATE,    
 '425'             AS REC_INSRT_NAME,                    
 @TempDate AS REC_UPDT_DATE,    
 '425'             AS REC_UPDT_NAME,                                   
 MAX(ADU)            AS ADU    
FROM dbo.TRACAssetSourceDetailVariable_Plan ASD                                            
INNER JOIN dbo.GenIDFAAgreement on GenIDFAAgreement.SourceSystemKey1 = ASD.AGRMNT_SYS_ATTR_KEY1_TEXT                                            
        AND GenIDFAAgreement.SourceSystemKey2 = ASD.AGRMNT_SYS_ATTR_KEY2_TEXT                                            
        AND GenIDFAAgreement.SourceSystemKey3 = ASD.AGRMNT_SYS_ATTR_KEY3_TEXT                                            
        AND GenIDFAAgreement.SourceSystemKey4 = ASD.AGRMNT_SYS_ATTR_KEY4_TEXT                              
        AND GenIDFAAgreement.SourceSystemKey5 = ASD.AGRMNT_SYS_ATTR_KEY5_TEXT                           
        AND ASD.MNTC_SYS_CODE = GenIDFAAgreement.SourceSystem                                                                            
/*INNER JOIN  GENIDSRCFUND GENID    ON  GENID.SOURCESYSTEM = ASD.MNTC_SYS_CODE                                            
        AND GENID.SOURCESYSTEMKEY1 = SRC_SYS_ATTR_KEY1_TEXT                                           
        --AND GENID.SOURCESYSTEMKEY2 = SRC_SYS_ATTR_KEY2_TEXT                                            
        AND GENID.SOURCESYSTEMKEY3 = SRC_SYS_ATTR_KEY3_TEXT                                            
        AND GENID.SOURCESYSTEMKEY4 = SRC_SYS_ATTR_KEY4_TEXT                                      
*/INNER JOIN TRACFUNDS TF    ON rtrim(TF.KEY1) = rtrim(SRC_SYS_ATTR_KEY1_TEXT)                                            
        --- AND TF.KEY2 = SRC_SYS_ATTR_KEY2_TEXT                                            
         AND rtrim(TF.KEY3) = rtrim(SRC_SYS_ATTR_KEY3_TEXT)                                            
         AND rtrim(TF.KEY4) = rtrim(SRC_SYS_ATTR_KEY4_TEXT)                                          
         AND TF.FUND_TYPE = 'VARIABLE'                                  
WHERE ASD.MNTC_SYS_CODE = 'TRAC'            
--and (      
--    (rtrim(SRC_SYS_ATTR_KEY2_TEXT) <> '' AND rtrim(TF.KEY2) = rtrim(SRC_SYS_ATTR_KEY2_TEXT))       
--    OR (rtrim(SRC_SYS_ATTR_KEY2_TEXT) = ''))      
GROUP BY                                       
  GenIDFAAgreement.AgreementID,                                    
  --GENID.SRC_FUND_ID,        
  TF.SRC_FUND_ID,        
  ASD.LoadDate                             
                     
RETURN                                            
SET QUOTED_IDENTIFIER OFF 
GO
