USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[PROC_TRAC_POPULATE_COR_INVSTR_ASSET_REC_OLD]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
------------------------------------------------------------------------------------
/*
This Populate procedure will have following steps 

1- To insert a records in Temp_IAR table from TracAssetSourceDetailVariable (Variable funds)
2- To insert a records in Temp_IAR table from TracAssetSourceDetailFixed (Fixed Funds)
3- To insert a records in Temp_IAR table from TracLoanAssetRec (Loan funds)
4- To insert a records in ETL table from Temp_IAR
5- To update the Current value in ETL table table 

*/
------------------------------------------------------------------------------------

CREATE procedure [dbo].[PROC_TRAC_POPULATE_COR_INVSTR_ASSET_REC_OLD] AS          
DECLARE @JobID INT;                          
DECLARE @TempDate DATETIME;                          
                          
SET @TempDate = GETDATE();                          
                          
SET @JobID = (SELECT isnull(MAX(JobID),0)                  
              FROM MC_JobID                  
              INNER JOIN MC_SourceFile                  
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID                  
              WHERE logicalName = 'TRACAssetSourceDetail'                  
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)                  
                                       FROM MC_SysProcessedLog                  
                                       WHERE SystemID = 49));     
                                                                
    
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[temp_IAR]') AND type in (N'U'))    
BEGIN    
DROP TABLE [dbo].[temp_IAR]    
END    
    
Select * into dbo.temp_IAR from COREETL.DBO.COR_INVSTR_ASSET_REC  WHERE 1=2   

--1    Variable funds - TracAssetSourceDetailVariable   
              
INSERT INTO dbo.temp_IAR         
  (AGREEMENT_ID,          
ACCOUNTING_DATE,          
DATETIMESTAMP,          
JOB_ID,          
LOAN_YES_OR_NO,          
CURRENT_VALUE,          
VARIABLE_FUNDS_VALUE,          
FIXED_FUNDS_VALUE,          
LOAN_FUNDS_VALUE,          
REC_INSRT_DATE,          
REC_INSRT_NAME,          
REC_UPDT_DATE,          
REC_UPDT_NAME,          
FACE_AMOUNT,          
EXTRNL_FUNDS_VALUE,          
LOAN_PAYOFF_AMT,          
ADU)          
SELECT           
XFD.AGREEMENT_ID,          
XFD.ACCOUNTING_DATE,          
@TempDate AS DATETIMESTAMP,          
@JobID AS JOB_ID,          
'N' AS LOAN_YES_OR_NO,          
--SUM(XFD.DOLLAR_AMOUNT) AS CURRENT_VALUE,-- Changed by Francis    
0 AS CURRENT_VALUE, -- Changed by Francis    
CONVERT(DECIMAL(18,2),SUM(XFD.DOLLAR_AMOUNT)) AS VARIABLE_FUNDS_VALUE,          
0 AS FIXED_FUNDS_VALUE,          
0 AS LOAN_FUNDS_VALUE,          
@TempDate AS REC_INSRT_DATE,          
'443',          
@TempDate AS REC_UPDT_DATE,          
'443',          
0 AS FACE_AMOUNT,          
0 AS EXTRNL_FUNDS_VALUE,          
0 AS LOAN_PAYOFF_AMT,          
MAX(ADU) As ADU            
FROM           
(
SELECT          
GenIDFAAgreement.AgreementID	AS AGREEMENT_ID,                          
GENID.SRC_FUND_ID				AS SRC_FUND_ID,                   
ASD.LoadDate					AS ACCOUNTING_DATE,                   
--SUM(CONVERT(DECIMAL(18,2),(ASD.VEH_MNY_TYPE_SHARES * ASD.UNIT_PRC))) AS DOLLAR_AMOUNT,                    
CONVERT(DECIMAL(18,2),SUM(ASD.VEH_MNY_TYPE_SHARES) * SUM(ASD.UNIT_PRC)) AS DOLLAR_AMOUNT,              
SUM(ASD.UNIT_PRC) AS VALUE_PER_UNIT,              
SUM(ASD.VEH_MNY_TYPE_SHARES) AS NUMBER_OF_SHARES ,                    
MAX(ADU)    ADU             
FROM dbo.TRACAssetSourceDetailVariable ASD                      
INNER JOIN dbo.GenIDFAAgreement      on GenIDFAAgreement.SourceSystemKey1 = ASD.AGRMNT_SYS_ATTR_KEY1_TEXT                      
									AND GenIDFAAgreement.SourceSystemKey2 = ASD.AGRMNT_SYS_ATTR_KEY2_TEXT                      
									AND GenIDFAAgreement.SourceSystemKey3 = ASD.AGRMNT_SYS_ATTR_KEY3_TEXT                      
									AND GenIDFAAgreement.SourceSystemKey4 = ASD.AGRMNT_SYS_ATTR_KEY4_TEXT                      
									AND GenIDFAAgreement.SourceSystemKey5 = ASD.AGRMNT_SYS_ATTR_KEY5_TEXT                      
									AND ASD.MNTC_SYS_CODE = GenIDFAAgreement.SourceSystem                      
INNER JOIN GENIDSRCFUND GENID        ON  GENID.SOURCESYSTEM = ASD.MNTC_SYS_CODE                      
									AND GENID.SOURCESYSTEMKEY1 = SRC_SYS_ATTR_KEY1_TEXT                      
									AND GENID.SOURCESYSTEMKEY2 = SRC_SYS_ATTR_KEY2_TEXT                      
									AND GENID.SOURCESYSTEMKEY3 = SRC_SYS_ATTR_KEY3_TEXT                      
									AND GENID.SOURCESYSTEMKEY4 = SRC_SYS_ATTR_KEY4_TEXT                
INNER JOIN TRACFUNDS TF              ON TF.FUND_TYPE = 'VARIABLE'                      
									AND TF.KEY1 = SRC_SYS_ATTR_KEY1_TEXT                      
									AND TF.KEY2 = SRC_SYS_ATTR_KEY2_TEXT                      
									AND TF.KEY3 = SRC_SYS_ATTR_KEY3_TEXT                      
									AND TF.KEY4 = SRC_SYS_ATTR_KEY4_TEXT                    
WHERE ASD.MNTC_SYS_CODE = 'TRAC'              
GROUP BY GenIDFAAgreement.AgreementID,              
		 GENID.SRC_FUND_ID,              
		 ASD.LoadDate
) XFD          
 GROUP BY           
	XFD.AGREEMENT_ID,          
	XFD.ACCOUNTING_DATE        
 
--2- Fixed Funds    - TracAssetSourceDetailFixed

INSERT INTO dbo.temp_IAR         
  (AGREEMENT_ID,          
ACCOUNTING_DATE,          
DATETIMESTAMP,          
JOB_ID,          
LOAN_YES_OR_NO,          
CURRENT_VALUE,          
VARIABLE_FUNDS_VALUE,          
FIXED_FUNDS_VALUE,          
LOAN_FUNDS_VALUE,          
REC_INSRT_DATE,          
REC_INSRT_NAME,          
REC_UPDT_DATE,          
REC_UPDT_NAME,          
FACE_AMOUNT,          
EXTRNL_FUNDS_VALUE,          
LOAN_PAYOFF_AMT,          
ADU)          
SELECT           
XFD.AGREEMENT_ID,          
XFD.ACCOUNTING_DATE,          
@TempDate			AS DATETIMESTAMP,          
@JobID				AS JOB_ID,          
'N'					AS LOAN_YES_OR_NO,          
--SUM(XFD.DOLLAR_AMOUNT) AS CURRENT_VALUE,-- Changed by Francis    
0					AS CURRENT_VALUE, -- Changed by Francis    
CONVERT(DECIMAL(18,2),SUM(XFD.DOLLAR_AMOUNT)) AS FIXED_FUNDS_VALUE,          
0					AS VARIABLE_FUNDS_VALUE,          
0					AS LOAN_FUNDS_VALUE,          
@TempDate			AS REC_INSRT_DATE,          
'443',          
@TempDate			AS REC_UPDT_DATE,          
'443',          
0					AS FACE_AMOUNT,          
0					AS EXTRNL_FUNDS_VALUE,          
0					AS LOAN_PAYOFF_AMT,          
MAX(ADU)			AS ADU            
FROM           
(
SELECT          
 GenIDFAAgreement.AgreementID	AS AGREEMENT_ID,                          
 GENID.SRC_FUND_ID				AS SRC_FUND_ID,                   
 ASD.LoadDate					AS ACCOUNTING_DATE,                   
 --SUM(CONVERT(DECIMAL(18,2),(ASD.VEH_MNY_TYPE_SHARES * ASD.UNIT_PRC))) AS DOLLAR_AMOUNT,                    
 CONVERT(DECIMAL(18,2),SUM(ASD.VEH_MNY_TYPE_SHARES) * SUM(ASD.UNIT_PRC)) AS DOLLAR_AMOUNT,   
 SUM(ASD.UNIT_PRC)				AS VALUE_PER_UNIT,              
 SUM(ASD.VEH_MNY_TYPE_SHARES)	AS NUMBER_OF_SHARES ,                    
 MAX(ADU)						AS ADU             
FROM dbo.TRACAssetSourceDetailFixed ASD                      
INNER JOIN dbo.GenIDFAAgreement  on GenIDFAAgreement.SourceSystemKey1 = ASD.AGRMNT_SYS_ATTR_KEY1_TEXT                      
								AND GenIDFAAgreement.SourceSystemKey2 = ASD.AGRMNT_SYS_ATTR_KEY2_TEXT                      
								AND GenIDFAAgreement.SourceSystemKey3 = ASD.AGRMNT_SYS_ATTR_KEY3_TEXT                      
								AND GenIDFAAgreement.SourceSystemKey4 = ASD.AGRMNT_SYS_ATTR_KEY4_TEXT                      
								AND GenIDFAAgreement.SourceSystemKey5 = ASD.AGRMNT_SYS_ATTR_KEY5_TEXT                      
								AND ASD.MNTC_SYS_CODE = GenIDFAAgreement.SourceSystem                      
INNER JOIN GENIDSRCFUND GENID   ON  GENID.SOURCESYSTEM = ASD.MNTC_SYS_CODE                  
								AND GENID.SOURCESYSTEMKEY1 = SRC_SYS_ATTR_KEY1_TEXT                  
								--AND GENID.SOURCESYSTEMKEY2 = SRC_SYS_ATTR_KEY2_TEXT                  
								AND GENID.SOURCESYSTEMKEY3 = SRC_SYS_ATTR_KEY3_TEXT                  
								AND GENID.SOURCESYSTEMKEY4 = SRC_SYS_ATTR_KEY4_TEXT            
INNER JOIN TRACFUNDS TF        ON TF.FUND_TYPE = 'FIXED'                  
								AND TF.KEY1 = SRC_SYS_ATTR_KEY1_TEXT                  
							--  AND TF.KEY2 = SRC_SYS_ATTR_KEY2_TEXT                  
								AND TF.KEY3 = SRC_SYS_ATTR_KEY3_TEXT                  
								AND TF.KEY4 = SRC_SYS_ATTR_KEY4_TEXT       
WHERE ASD.MNTC_SYS_CODE = 'TRAC'              
GROUP BY                 
 GenIDFAAgreement.AgreementID,              
 GENID.SRC_FUND_ID,              
 ASD.LoadDate 
) XFD     
where AGREEMENT_ID <> 4246101
 GROUP BY           
	XFD.AGREEMENT_ID,          
	XFD.ACCOUNTING_DATE 
                                       
--3- Loan funds     - TracLoanAssetRec



INSERT INTO dbo.temp_IAR         
  (AGREEMENT_ID,          
ACCOUNTING_DATE,          
DATETIMESTAMP,          
JOB_ID,          
LOAN_YES_OR_NO,          
CURRENT_VALUE,          
VARIABLE_FUNDS_VALUE,          
FIXED_FUNDS_VALUE,          
LOAN_FUNDS_VALUE,          
REC_INSRT_DATE,          
REC_INSRT_NAME,          
REC_UPDT_DATE,          
REC_UPDT_NAME,          
FACE_AMOUNT,          
EXTRNL_FUNDS_VALUE,          
LOAN_PAYOFF_AMT,          
ADU)          
SELECT           
XFD.AGREEMENT_ID,          
XFD.ACCOUNTING_DATE,          
@TempDate AS DATETIMESTAMP,          
@JobID AS JOB_ID,          
'N' AS LOAN_YES_OR_NO,          
--SUM(XFD.DOLLAR_AMOUNT) AS CURRENT_VALUE,-- Changed by Francis    
0 AS CURRENT_VALUE, -- Changed by Francis    
0 AS FIXED_FUNDS_VALUE,          
0 AS VARIABLE_FUNDS_VALUE,          
CONVERT(DECIMAL(18,2),SUM(XFD.DOLLAR_AMOUNT)) AS LOAN_FUNDS_VALUE,          
@TempDate AS REC_INSRT_DATE,          
'443',          
@TempDate AS REC_UPDT_DATE,          
'443',          
0 AS FACE_AMOUNT,          
0 AS EXTRNL_FUNDS_VALUE,          
0 AS LOAN_PAYOFF_AMT,          
MAX(ADU)    ADU            
FROM           
(
SELECT          
 GenIDFAAgreement.AgreementID	AS AGREEMENT_ID,                          
 GENID.SRC_FUND_ID				AS SRC_FUND_ID,                   
 ASD.ACCOUNTING_DATE			AS ACCOUNTING_DATE,                   
 SUM(CONVERT(DECIMAL(18,2),(ASD.OUTSTANDING_PRINCIPAL_BALANCE))) AS DOLLAR_AMOUNT,                    
 --CONVERT(DECIMAL(18,2),SUM(ASD.VEH_MNY_TYPE_SHARES) * SUM(ASD.UNIT_PRC)) AS DOLLAR_AMOUNT,   
 MAX(ADU)						AS ADU             
FROM dbo.[TRACLoanAssetRecord] ASD                      
INNER JOIN dbo.GenIDFAAgreement on GenIDFAAgreement.SourceSystemKey1 = ASD.AGRMNT_SYS_ATTR_KEY1_TEXT                      
								AND GenIDFAAgreement.SourceSystemKey2 = ASD.AGRMNT_SYS_ATTR_KEY2_TEXT                      
								AND GenIDFAAgreement.SourceSystemKey3 = ASD.AGRMNT_SYS_ATTR_KEY3_TEXT                      
								AND GenIDFAAgreement.SourceSystemKey4 = ASD.AGRMNT_SYS_ATTR_KEY4_TEXT                      
								AND GenIDFAAgreement.SourceSystemKey5 = ASD.AGRMNT_SYS_ATTR_KEY5_TEXT                      
								AND ASD.MNTC_SYS_CODE = GenIDFAAgreement.SourceSystem                      
INNER JOIN GENIDSRCFUND GENID   ON  GENID.SOURCESYSTEM = ASD.MNTC_SYS_CODE                  
								AND GENID.SOURCESYSTEMKEY1 = SRC_SYS_ATTR_KEY1_TEXT                  
								--AND GENID.SOURCESYSTEMKEY2 = SRC_SYS_ATTR_KEY2_TEXT                  
								AND GENID.SOURCESYSTEMKEY3 = SRC_SYS_ATTR_KEY3_TEXT                  
								AND GENID.SOURCESYSTEMKEY4 = SRC_SYS_ATTR_KEY4_TEXT            
INNER JOIN TRACFUNDS TF			ON TF.FUND_TYPE = 'LOAN'                  
								AND TF.KEY1 = SRC_SYS_ATTR_KEY1_TEXT                  
							--  AND TF.KEY2 = SRC_SYS_ATTR_KEY2_TEXT                  
								AND TF.KEY3 = SRC_SYS_ATTR_KEY3_TEXT                  
								AND TF.KEY4 = SRC_SYS_ATTR_KEY4_TEXT       
WHERE ASD.MNTC_SYS_CODE = 'TRAC'              
GROUP BY                 
 GenIDFAAgreement.AgreementID,              
 GENID.SRC_FUND_ID,              
 ASD.ACCOUNTING_DATE 
 ) XFD          
 GROUP BY           
 XFD.AGREEMENT_ID,          
XFD.ACCOUNTING_DATE 


--4 To Insert the Records in ETL table from TEMP_IAR

INSERT INTO  COREETL.DBO.COR_INVSTR_ASSET_REC         
SELECT AGREEMENT_ID
, ACCOUNTING_DATE
, @TempDate
, @JobID
, 'N'
, 0
, SUM(VARIABLE_FUNDS_VALUE)
, SUM(fixed_funds_value)
, SUM(loan_funds_value)
, @TempDate
, '443'
, @TempDate
, '443'
, 0
, 0
, 0
,'A'
FROM [dbo].[temp_IAR]       
group by AGREEMENT_ID
, ACCOUNTING_DATE

--5 To update the Current value in Temp_IAR table 

UPDATE COREETL.DBO.COR_INVSTR_ASSET_REC SET      
CURRENT_VALUE = CONVERT(DECIMAL(18,2),(LOAN_FUNDS_VALUE + FIXED_FUNDS_VALUE + VARIABLE_FUNDS_VALUE + EXTRNL_FUNDS_VALUE))  
       
                                       
/*-- Below Insert added by Francis to replace the update.
INSERT INTO dbo.temp_IAR         
  (AGREEMENT_ID,          
ACCOUNTING_DATE,          
DATETIMESTAMP,          
JOB_ID,          
LOAN_YES_OR_NO,          
CURRENT_VALUE,          
VARIABLE_FUNDS_VALUE,          
FIXED_FUNDS_VALUE,          
LOAN_FUNDS_VALUE,          
REC_INSRT_DATE,          
REC_INSRT_NAME,          
REC_UPDT_DATE,          
REC_UPDT_NAME,          
FACE_AMOUNT,          
EXTRNL_FUNDS_VALUE,          
LOAN_PAYOFF_AMT,          
ADU)          
SELECT           
XFD.AGREEMENT_ID,          
XFD.ACCOUNTING_DATE,          
@TempDate AS DATETIMESTAMP,          
@JobID AS JOB_ID,          
'N' AS LOAN_YES_OR_NO,          
--SUM(XFD.DOLLAR_AMOUNT) AS CURRENT_VALUE,-- Changed by Francis    
0 AS CURRENT_VALUE, -- Changed by Francis    
CONVERT(DECIMAL(18,2),SUM(XFD.DOLLAR_AMOUNT)) AS FIXED_FUNDS_VALUE,          
0 AS VARIABLE_FUNDS_VALUE,          
0 AS LOAN_FUNDS_VALUE,          
@TempDate AS REC_INSRT_DATE,          
'443',          
@TempDate AS REC_UPDT_DATE,          
'443',          
0 AS FACE_AMOUNT,          
0 AS EXTRNL_FUNDS_VALUE,          
0 AS LOAN_PAYOFF_AMT,          
MAX(ADU)    ADU            
FROM           
(
SELECT          
 GenIDFAAgreement.AgreementID AS AGREEMENT_ID,                          
 GENID.SRC_FUND_ID    AS SRC_FUND_ID,                   
 ASD.ACCOUNTING_DATE     AS ACCOUNTING_DATE,                   
 SUM(CONVERT(DECIMAL(18,2),(ASD.OUTSTANDING_PRINCIPAL_BALANCE))) AS DOLLAR_AMOUNT,                    
 MAX(ADU)    ADU             
FROM dbo.[TRACLoanAssetRecord] ASD                      
INNER JOIN dbo.GenIDFAAgreement                      
  on GenIDFAAgreement.SourceSystemKey1 = ASD.AGRMNT_SYS_ATTR_KEY1_TEXT                      
        AND GenIDFAAgreement.SourceSystemKey2 = ASD.AGRMNT_SYS_ATTR_KEY2_TEXT                      
        AND GenIDFAAgreement.SourceSystemKey3 = ASD.AGRMNT_SYS_ATTR_KEY3_TEXT                      
  AND GenIDFAAgreement.SourceSystemKey4 = ASD.AGRMNT_SYS_ATTR_KEY4_TEXT                      
  AND GenIDFAAgreement.SourceSystemKey5 = ASD.AGRMNT_SYS_ATTR_KEY5_TEXT                      
  AND ASD.MNTC_SYS_CODE = GenIDFAAgreement.SourceSystem                      
INNER JOIN GENIDSRCFUND GENID                  
  ON  GENID.SOURCESYSTEM = ASD.MNTC_SYS_CODE                  
        AND GENID.SOURCESYSTEMKEY1 = SRC_SYS_ATTR_KEY1_TEXT                  
        --AND GENID.SOURCESYSTEMKEY2 = SRC_SYS_ATTR_KEY2_TEXT                  
        AND GENID.SOURCESYSTEMKEY3 = SRC_SYS_ATTR_KEY3_TEXT                  
  AND GENID.SOURCESYSTEMKEY4 = SRC_SYS_ATTR_KEY4_TEXT            
  INNER JOIN TRACFUNDS TF  
  ON TF.FUND_TYPE = 'LOAN'                  
        AND TF.KEY1 = SRC_SYS_ATTR_KEY1_TEXT                  
     --   AND TF.KEY2 = SRC_SYS_ATTR_KEY2_TEXT                  
        AND TF.KEY3 = SRC_SYS_ATTR_KEY3_TEXT                  
  AND TF.KEY4 = SRC_SYS_ATTR_KEY4_TEXT       
WHERE ASD.MNTC_SYS_CODE = 'TRAC'              
GROUP BY                 
 GenIDFAAgreement.AgreementID,              
 GENID.SRC_FUND_ID,              
 ASD.ACCOUNTING_DATE ) XFD          
 GROUP BY           
 XFD.AGREEMENT_ID,          
XFD.ACCOUNTING_DATE 
*/
          
        
        
/*        Commented out by Francis 12/26/2013.. We need to do insert instead 
UPDATE IAR        
SET IAR.FIXED_FUNDS_VALUE = isnull(CONVERT(DECIMAL(18,2),B.FIXED_FUNDS_VALUE),0)        
 --IAR.CURRENT_VALUE = IAR.CURRENT_VALUE + isnull(B.FIXED_FUNDS_VALUE,0)    -- Changed by Francis    
FROM dbo.temp_IAR IAR INNER JOIN         
(SELECT        
XFD.AGREEMENT_ID,          
XFD.ACCOUNTING_DATE,          
--@TempDate AS DATETIMESTAMP,          
--@JobID AS JOB_ID,          
--'N' AS LOAN_YES_OR_NO,          
--0 AS CURRENT_VALUE,          
--0 AS VARIABLE_FUNDS_VALUE,          
SUM(CONVERT(DECIMAL(18,2),XFD.DOLLAR_AMOUNT)) AS FIXED_FUNDS_VALUE,          
----0 AS LOAN_FUNDS_VALUE,          
--@TempDate AS REC_INSRT_DATE,          
--'443',          
--@TempDate AS REC_UPDT_DATE,          
--'443',          
--0 AS FACE_AMOUNT,          
--0 AS EXTRNL_FUNDS_VALUE,          
--0 AS LOAN_PAYOFF_AMT,          
MAX(ADU)    ADU            
FROM           
(SELECT          
 GenIDFAAgreement.AgreementID AS AGREEMENT_ID,                          
 GENID.SRC_FUND_ID    AS SRC_FUND_ID,                   
 ASD.LoadDate     AS ACCOUNTING_DATE,                   
 SUM(CONVERT(DECIMAL(18,2),(ASD.VEH_MNY_TYPE_SHARES * ASD.UNIT_PRC))) AS DOLLAR_AMOUNT,                    
 SUM(ASD.UNIT_PRC) AS VALUE_PER_UNIT,              
 SUM(ASD.VEH_MNY_TYPE_SHARES) AS NUMBER_OF_SHARES ,                    
 MAX(ADU)    ADU             
FROM dbo.TRACAssetSourceDetailFixed ASD                      
INNER JOIN dbo.GenIDFAAgreement                      
  on GenIDFAAgreement.SourceSystemKey1 = ASD.AGRMNT_SYS_ATTR_KEY1_TEXT                      
        AND GenIDFAAgreement.SourceSystemKey2 = ASD.AGRMNT_SYS_ATTR_KEY2_TEXT                      
        AND GenIDFAAgreement.SourceSystemKey3 = ASD.AGRMNT_SYS_ATTR_KEY3_TEXT                      
  AND GenIDFAAgreement.SourceSystemKey4 = ASD.AGRMNT_SYS_ATTR_KEY4_TEXT                      
  AND GenIDFAAgreement.SourceSystemKey5 = ASD.AGRMNT_SYS_ATTR_KEY5_TEXT                      
  AND ASD.MNTC_SYS_CODE = GenIDFAAgreement.SourceSystem                      
--INNER JOIN GENIDSRCFUND GENID                      
--  ON  GENID.SOURCESYSTEM = ASD.MNTC_SYS_CODE                      
--        AND GENID.SOURCESYSTEMKEY1 = SRC_SYS_ATTR_KEY1_TEXT                      
--        AND GENID.SOURCESYSTEMKEY2 = SRC_SYS_ATTR_KEY2_TEXT                      
--        AND GENID.SOURCESYSTEMKEY3 = SRC_SYS_ATTR_KEY3_TEXT                      
--  AND GENID.SOURCESYSTEMKEY4 = SRC_SYS_ATTR_KEY4_TEXT                
--  INNER JOIN TRACFUNDS TF                  
--  ON TF.FUND_TYPE = 'FIXED'                      
--        AND TF.KEY1 = SRC_SYS_ATTR_KEY1_TEXT                      
--        AND TF.KEY2 = SRC_SYS_ATTR_KEY2_TEXT                      
--        AND TF.KEY3 = SRC_SYS_ATTR_KEY3_TEXT                      
--  AND TF.KEY4 = SRC_SYS_ATTR_KEY4_TEXT      
      
INNER JOIN GENIDSRCFUND GENID                  
  ON  GENID.SOURCESYSTEM = ASD.MNTC_SYS_CODE                  
        AND GENID.SOURCESYSTEMKEY1 = SRC_SYS_ATTR_KEY1_TEXT                  
        --AND GENID.SOURCESYSTEMKEY2 = SRC_SYS_ATTR_KEY2_TEXT                  
        AND GENID.SOURCESYSTEMKEY3 = SRC_SYS_ATTR_KEY3_TEXT                  
  AND GENID.SOURCESYSTEMKEY4 = SRC_SYS_ATTR_KEY4_TEXT            
  INNER JOIN TRACFUNDS TF              
  ON TF.FUND_TYPE = 'FIXED'                  
        AND TF.KEY1 = SRC_SYS_ATTR_KEY1_TEXT                  
     --   AND TF.KEY2 = SRC_SYS_ATTR_KEY2_TEXT                  
        AND TF.KEY3 = SRC_SYS_ATTR_KEY3_TEXT                  
  AND TF.KEY4 = SRC_SYS_ATTR_KEY4_TEXT       
                      
WHERE ASD.MNTC_SYS_CODE = 'TRAC'              
GROUP BY                 
 GenIDFAAgreement.AgreementID,              
 GENID.SRC_FUND_ID,              
 ASD.LoadDate) XFD          
 GROUP BY           
 XFD.AGREEMENT_ID,          
XFD.ACCOUNTING_DATE) B         
ON IAR.AGREEMENT_ID = B.AGREEMENT_ID         
AND IAR.ACCOUNTING_DATE = B.ACCOUNTING_DATE        
*/

  
                 
RETURN
GO
