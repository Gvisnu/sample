USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_SRC_FUND_PRICE]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Proc_TRAC_Populate_COR_SRC_FUND_PRICE] AS                
                
DECLARE @JobID INT;                
DECLARE @CurrDateTime DATETIME                
set nocount on                
                
SET @CurrDateTime = GETDATE()                
                
SET @JobID = (SELECT isnull(MAX(JobID),0)                            
              FROM MC_JobID                            
              INNER JOIN MC_SourceFile                            
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID                            
              WHERE logicalName = 'TRACSrcFundPrice'                            
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)                            
                                       FROM MC_SysProcessedLog                            
                                       WHERE SystemID = 49));               
----- Populate ETL table       
    
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[COR_SRC_FUND_PRICE_TODAY]') AND type in (N'U'))                      
BEGIN                      
DROP TABLE [dbo].[COR_SRC_FUND_PRICE_TODAY]    
END                   
    
SELECT * INTO CORE1.DBO.[COR_SRC_FUND_PRICE_TODAY] FROM COREETL.DBO.COR_SRC_FUND_PRICE WHERE 1=2             
                
INSERT INTO CORE1.DBO.[COR_SRC_FUND_PRICE_TODAY]              
 (                
  SRC_FUND_ID,                
  JOB_ID,                
  DATETIMESTAMP,                
  PRICE_DATE,                 
  UNIT_VAL_PRICE_AMT,                
  DAILY_DIV_AMT,                
  REC_INSRT_NAME,                              
  ADU                
 )                
SELECT DISTINCT        
 IsNull(SRC_FUND_ID,999999999),                
 @JobID,                
 @CurrDateTime,                
 PRICE_DATE,                
 UNIT_VAL_PRICE_AMT,                
 DAILY_DIV_AMT,                
 --'442',                
 --COM_SRC_FUND_PRICE.SRC_FUND1_KEY As REC_INSRT_NAME,     
 CASE WHEN SRC_FUND_ID IS NULL THEN COM_SRC_FUND_PRICE.SRC_FUND1_KEY    
 ELSE '442'    
 END AS REC_INSRT_NAME,     
 'U' As ADU               
FROM dbo.COM_SRC_FUND_PRICE                
LEFT JOIN dbo.GenIDSrcFund  ON  rtrim(SRC_FUND_PRICE_SRC_TEXT) = rtrim(dbo.GenIDSrcFund.SourceSystem)                
       AND rtrim(SRC_FUND1_KEY) = rtrim(dbo.GenIDSrcFund.SourceSystemKey2) ;    
    
       
INSERT INTO COREERRLOG.DBO.REPERRORLOG (ERRORDATE, ERRORMESSAGE, ERRORDATA, ERRORSOURCE, SYSTEM)    
SELECT GETDATE(),    
 'UNABLE TO LOAD '+CAST(CNT AS VARCHAR)+' RECORD(S) INTO COR_SRC_FUND_PRICE DUE TO A SRC_FUND_ID OF 999999999',    
 'REFER TO ERR TABLE FOR DETAIL',    
 'REP',    
 'TRAC'    
FROM (SELECT COUNT(*) AS CNT FROM CORE1.DBO.[COR_SRC_FUND_PRICE_TODAY] WHERE SRC_FUND_ID = 999999999) Q    
WHERE CNT > 0    
    
INSERT INTO COREERRLOG.DBO.ERR_SRC_FUND_PRICE    
SELECT *,    
 (SELECT DISTINCT @@IDENTITY FROM COREERRLOG.DBO.REPERRORLOG)    
FROM CORE1.DBO.[COR_SRC_FUND_PRICE_TODAY]    
WHERE SRC_FUND_ID = 999999999;    
    
DELETE CORE1.DBO.[COR_SRC_FUND_PRICE_TODAY]    
WHERE SRC_FUND_ID =999999999;    
    
----- If a SRC_FUND_ID was 999999999 and has been corrected, move to COR table and delete ERR row    
    
INSERT INTO CORE1.DBO.[COR_SRC_FUND_PRICE_TODAY]    
 (    
    SRC_FUND_ID,                
    JOB_ID,                
    DATETIMESTAMP,                
    PRICE_DATE,                 
    UNIT_VAL_PRICE_AMT,                
    DAILY_DIV_AMT,                
    REC_INSRT_NAME,                
    REC_UPDT_NAME,                
    ADU     
 )    
SELECT    
    A.SRC_FUND_ID,                
    @JobID,           
    @CurrDateTime,    
    A.PRICE_DATE,                 
    A.UNIT_VAL_PRICE_AMT,                
    A.DAILY_DIV_AMT,                
    --A.REC_INSRT_NAME,                
    '442',    
    A.REC_UPDT_NAME,                
    A.ADU    
    
FROM COREERRLOG.DBO.ERR_SRC_FUND_PRICE A    
INNER JOIN COREERRLOG.DBO.REPERRORLOG B    
ON  A.REPERRORID = B.ERRORID    
WHERE B.ERRORMESSAGE LIKE '%DUE TO A SRC_FUND_ID OF 999999999'    
  AND A.SRC_FUND_ID <> 999999999;    
    
DELETE COREERRLOG.DBO.ERR_SRC_FUND_PRICE    
FROM COREERRLOG.DBO.ERR_SRC_FUND_PRICE A    
INNER JOIN COREERRLOG.DBO.REPERRORLOG B    
ON  A.REPERRORID = B.ERRORID  WHERE B.ERRORMESSAGE LIKE '%DUE TO A SRC_FUND_ID OF 999999999'    
  AND A.SRC_FUND_ID <> 999999999;    
      
--UPDATE COREETL.DBO.COR_SRC_FUND_PRICE SET REC_INSRT_NAME = '442';        
    
INSERT INTO COREETL.DBO.COR_SRC_FUND_PRICE SELECT DISTINCT * FROM CORE1.DBO.[COR_SRC_FUND_PRICE_TODAY]
GO
