USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_INVSTR_ASSET_REC]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
------------------------------------------------------------------------------------  
/*  
This Populate procedure will have following steps   
  
1- To insert Distinct records from COR_X_FUND_DETAIL(Variable funds),COR_X_CONTRIB_DETAIL(Fixed Funds)and COR_X_LOAN_FUND_DTL (Loan funds)  
2- To update the VARIBALE_FUND_VALUE,FIXED_FUND_VALE and LOAN_FUND_VALUE   
  
*/  
------------------------------------------------------------------------------------  
    
CREATE procedure [dbo].[Proc_TRAC_Populate_COR_INVSTR_ASSET_REC] AS  
                             
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
  
IF NOT OBJECT_ID('tempdb..#COR_INVSTR_ASSET_REC_TEMP') IS  NULL   
 drop table #COR_INVSTR_ASSET_REC_TEMP  
  
-------------------------------------------------------------------  
-- To create A TEMP TABLE  
-------------------------------------------------------------------  
 create TABLE [dbo].[#COR_INVSTR_ASSET_REC_TEMP] (  
  [AGREEMENT_ID] numeric(12, 0) NOT NULL ,  
  [ACCOUNTING_DATE] datetime NOT NULL ,  
  [DATETIMESTAMP] datetime NOT NULL ,  
  [JOB_ID] numeric(18, 0) NOT NULL ,  
  [LOAN_YES_OR_NO] char (1)  NULL ,  
  [CURRENT_VALUE] decimal(18, 6) NULL ,  
  [VARIABLE_FUNDS_VALUE] decimal(18, 6) NULL ,  
  [FIXED_FUNDS_VALUE] decimal(18, 6) NULL ,  
  [LOAN_FUNDS_VALUE] decimal(18, 6) NULL ,  
  [EXTRNL_FUNDS_VALUE] decimal(18, 6) NULL ,  
  [ADU] [char] (1)  NOT NULL   
 )   
   
-------------------------------------------------------------------  
/* TO LOAD DISTINCT AGREEMENT_ID AND ACCOUNTING_DATE INFORMATION FROM  
COR_X_FUND_DETAIL  
COR_X_LOAN_FUND_DTL,   
COR_X_CONTRIB_DETAIL  
*/  
-------------------------------------------------------------------  
 INSERT INTO          #COR_INVSTR_ASSET_REC_TEMP   
 SELECT DISTINCT  
  AGREEMENT_ID,  
  ACCOUNTING_DATE,  
  @TempDate AS DATETIMESTAMP,  
  @JobID,  
  'N' AS LOAN_YES_OR_NO,  
  0,  
  0,  
  0,  
  0,  
  0,  
  'A' AS ADU  
 FROM ( SELECT AGREEMENT_ID, ACCOUNTING_DATE FROM COREETL.DBO.COR_X_LOAN_FUND_DTL  
   UNION  
   SELECT AGREEMENT_ID, ACCOUNTING_DATE FROM COREETL.DBO.COR_X_CONTRIB_DETAIL  
   UNION  
   SELECT AGREEMENT_ID, ACCOUNTING_DATE FROM COREETL.DBO.COR_X_FUND_DETAIL  
   UNION  
   SELECT AGREEMENT_ID, ACCOUNTING_DATE FROM COREETL.DBO.COR_X_EXTRNL_FUND_DETAIL
      ) AS BASETABLE  
  
-------------------------------------------------------------------  
--TO UPDATE VARIABLE_FUNDS_VALUE FROM COR_X_FUND_DETAIL  
-------------------------------------------------------------------  
  
 UPDATE  #COR_INVSTR_ASSET_REC_TEMP  
 SET  VARIABLE_FUNDS_VALUE = B.DOLLAR_AMOUNT  
 FROM #COR_INVSTR_ASSET_REC_TEMP A  
 INNER JOIN (SELECT SUM(DOLLAR_AMOUNT) AS DOLLAR_AMOUNT , AGREEMENT_ID, ACCOUNTING_DATE   
     FROM COREETL.DBO.COR_X_FUND_DETAIL   
     WHERE JOB_ID IN (SELECT JOBID FROM CORE1.DBO.MC_JOBID WHERE SOURCEFILEID = 530)  
     GROUP BY  AGREEMENT_ID, ACCOUNTING_DATE   
     ) B  
   ON A.AGREEMENT_ID = B.AGREEMENT_ID   
   AND A.ACCOUNTING_DATE = B.ACCOUNTING_DATE  
  
-------------------------------------------------------------------  
--TO UPDATE FIXED_FUNDS_VALUE FROM COR_X_CONTRIB_DETAIL  
-------------------------------------------------------------------  
 UPDATE  #COR_INVSTR_ASSET_REC_TEMP  
 SET  FIXED_FUNDS_VALUE = B.DOLLAR_AMOUNT  
 FROM #COR_INVSTR_ASSET_REC_TEMP A  
  INNER JOIN (SELECT SUM(DOLLAR_AMOUNT) AS DOLLAR_AMOUNT, AGREEMENT_ID, ACCOUNTING_DATE   
     FROM COREETL.DBO.COR_X_CONTRIB_DETAIL   
     WHERE JOB_ID IN (SELECT JOBID FROM CORE1.DBO.MC_JOBID WHERE SOURCEFILEID = 528)   
     GROUP BY  AGREEMENT_ID, ACCOUNTING_DATE   
     ) B  
  ON A.AGREEMENT_ID = B.AGREEMENT_ID AND A.ACCOUNTING_DATE = B.ACCOUNTING_DATE  
  
-------------------------------------------------------------------  
--TO UPDATE LOAN_FUNDS_VALUE FROM COR_X_LOAN_FUND_DTL  
-------------------------------------------------------------------  
  
 UPDATE  #COR_INVSTR_ASSET_REC_TEMP  
 SET  LOAN_FUNDS_VALUE = B.SUM_DOLLAR_AMOUNT  
 FROM #COR_INVSTR_ASSET_REC_TEMP A  
  INNER JOIN (SELECT SUM(DOLLAR_AMT) AS SUM_DOLLAR_AMOUNT, AGREEMENT_ID, ACCOUNTING_DATE   
     FROM COREETL.DBO.COR_X_LOAN_FUND_DTL   
     WHERE JOB_ID IN (SELECT JOBID FROM CORE1.DBO.MC_JOBID WHERE SOURCEFILEID = 526)   
     GROUP BY AGREEMENT_ID, ACCOUNTING_DATE) B  
  ON A.AGREEMENT_ID = B.AGREEMENT_ID AND A.ACCOUNTING_DATE = B.ACCOUNTING_DATE  

-------------------------------------------------------------------  
--TO UPDATE LOAN_FUNDS_VALUE FROM COR_X_EXTRNL_FUND_DETAIL  
-------------------------------------------------------------------  
  
 UPDATE #COR_INVSTR_ASSET_REC_TEMP  
 SET  EXTRNL_FUNDS_VALUE = B.SUM_DOLLAR_AMOUNT  
 FROM #COR_INVSTR_ASSET_REC_TEMP A  
  INNER JOIN (SELECT SUM(DOLLAR_AMT) AS SUM_DOLLAR_AMOUNT, AGREEMENT_ID, ACCOUNTING_DATE   
     FROM COREETL.DBO.COR_X_EXTRNL_FUND_DETAIL   
     WHERE JOB_ID IN (SELECT JOBID FROM CORE1.DBO.MC_JOBID WHERE SOURCEFILEID = 549)   
     GROUP BY AGREEMENT_ID, ACCOUNTING_DATE) B  
  ON A.AGREEMENT_ID = B.AGREEMENT_ID AND A.ACCOUNTING_DATE = B.ACCOUNTING_DATE  
    
-------------------------------------------------------------------  
--TO UPDATE CURRENT_VALUE_OR_FACE_VALUE FROM ALL THE TABLES  
------------------------------------------------------------------  
 UPDATE   #COR_INVSTR_ASSET_REC_TEMP  
 SET  CURRENT_VALUE = LOAN_FUNDS_VALUE + FIXED_FUNDS_VALUE + VARIABLE_FUNDS_VALUE + EXTRNL_FUNDS_VALUE  
 FROM  #COR_INVSTR_ASSET_REC_TEMP   
  
-------------------------------------------------------------------  
--TO LOAD THE RECORDS IN COREETL.DBO.COR_INVSTR_ASSET_REC  
-------------------------------------------------------------------  
  
INSERT INTO COREETL.DBO.COR_INVSTR_ASSET_REC  
 (  
  AGREEMENT_ID,  
  ACCOUNTING_DATE,  
  DATETIMESTAMP,  
  JOB_ID,  
  LOAN_YES_OR_NO,  
  CURRENT_VALUE,  
  VARIABLE_FUNDS_VALUE,  
  FIXED_FUNDS_VALUE,   
  LOAN_FUNDS_VALUE,  
  EXTRNL_FUNDS_VALUE,  
  ADU,  
  REC_INSRT_NAME  
  )  
SELECT   
DISTINCT AGREEMENT_ID  
,ACCOUNTING_DATE  
,DATETIMESTAMP  
,JOB_ID  
,LOAN_YES_OR_NO  
,CURRENT_VALUE  
,VARIABLE_FUNDS_VALUE  
,FIXED_FUNDS_VALUE  
,LOAN_FUNDS_VALUE  
,0  
,ADU  
,'443'  
FROM  #COR_INVSTR_ASSET_REC_TEMP  

----------------------------------------------------------------------------------

--TO UPDATE THE STATUS_CODE IN COREETL.DBO.COR_AGRMNT TABLE

----------------------------------------------------------------------------------
UPDATE CoreETL.dbo.COR_AGRMNT set STATUS_CODE = 'TERM WB'
WHERE AGREEMENT_ID in (SELECT Distinct AGREEMENT_ID from CoreETL.dbo.COR_INVSTR_ASSET_REC
						WHERE CURRENT_VALUE <> 0
					   )
AND STATUS_CODE = 'T'
  
return


GO
