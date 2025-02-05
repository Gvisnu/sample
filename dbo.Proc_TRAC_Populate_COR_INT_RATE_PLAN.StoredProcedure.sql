USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_INT_RATE_PLAN]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Proc_TRAC_Populate_COR_INT_RATE_PLAN] AS        
        
DECLARE @CycleDate CHAR(10)          
DECLARE @Job_ID INT;        
DECLARE @CurrDateTime DATETIME        
set nocount on        
        
SET @CurrDateTime = GETDATE()        
        
SET @Job_ID = (SELECT isnull(MAX(JobID),0)        
              FROM MC_JobID        
              WHERE SourceFileID = '546'        
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)        
                                       FROM MC_SysProcessedLog        
                                       WHERE SystemID = 49        
                                       and SubSystemID='-1'        
                                       )        
                                       );                        
if(@Job_ID is null)        
begin        
 RAISERROR ('JobID not found in MC_JobID.', 16, 1)        
end        
else        
begin        
        
 SELECT @CycleDate =  CONVERT(CHAR(10),A.CycleStartDate,101) FROM        
                 (        
                SELECT MAX (CycleStartDate) AS CycleStartDate        
                FROM TRACMASTER.TRACMASTER.Core.Cycle_Date WHERE CycleEndDate IS NOT NULL          
                 )A        
 --create SRC_FUNDS THAT HAVE BEEN ADDED OR UPDATED        
     
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[COR_INT_RATE_PLAN_TODAY]') AND type in (N'U'))                      
BEGIN                      
DROP TABLE [dbo].[COR_INT_RATE_PLAN_TODAY]    
END     
  
SELECT * INTO CORE1.DBO.[COR_INT_RATE_PLAN_TODAY] FROM COREETL.DBO.COR_INT_RATE_PLAN WHERE 1=2  
    
 INSERT INTO CORE1.dbo.COR_INT_RATE_PLAN_TODAY  
 (        
 [SRC_FUND_ID]        
    ,[JOB_ID]        
    ,[DATETIMESTAMP]        
    ,[ACCOUNTING_DATE]        
    ,[INT_RATE_PCT]        
    ,ADU        
    ,REC_INSRT_NAME         
    ,REC_UPDT_NAME              
 )        
 SELECT DISTINCT        
 ISNULL(SF.SRC_FUND_ID,999999999) AS SRC_FUND_ID,        
 @Job_ID       AS JOB_ID,        
 @CurrDateTime      AS DATETIMESTAMP,        
 @CycleDate       AS ACCOUNTING_DATE,             
 IRP.INT_RATE_PCT*100    AS INT_RATE_PCT,        
 'U'        AS ADU,        
 '446'        AS REC_INSRT_NAME,        
 IRP.SRC_SYS_ATTR_KEY1_TEXT+'+'+SRC_SYS_ATTR_KEY4_TEXT As REC_UPDT_NAME        
 FROM Core1.dbo.TRACIntRatePlan IRP        
 LEFT  OUTER JOIN dbo.GenIDSrcFund SF ON  RTRIM(IRP.SRC_SYS_ATTR_KEY1_TEXT) = RTRIM(SF.SOURCESYSTEMKEY1)        
          AND RTRIM(IRP.SRC_SYS_ATTR_KEY4_TEXT) = RTRIM(SF.SOURCESYSTEMKEY4)        
WHERE  SF.SOURCESYSTEM='TRAC'       
      
INSERT INTO COREERRLOG.DBO.REPERRORLOG (ERRORDATE, ERRORMESSAGE, ERRORDATA, ERRORSOURCE, SYSTEM)        
SELECT GETDATE(),        
'UNABLE TO LOAD '+CAST(CNT AS VARCHAR)+' RECORD(S) INTO COR_INT_RATE_PLAN DUE TO A SRC_FUND_ID OF 999999999',        
'REFER TO ERR TABLE FOR DETAIL',        
'REP',        
'TRAC'        
FROM (SELECT COUNT(*) AS CNT FROM CORE1.DBO.[COR_INT_RATE_PLAN_TODAY] WHERE SRC_FUND_ID = '999999999') Q        
WHERE CNT > 0        
        
INSERT INTO COREERRLOG.DBO.ERR_INT_RATE_PLAN        
SELECT *,        
  (SELECT DISTINCT @@IDENTITY FROM COREERRLOG.DBO.REPERRORLOG)        
   FROM CORE1.dbo.COR_INT_RATE_PLAN_TODAY        
   WHERE SRC_FUND_ID = '999999999';        
        
   DELETE CORE1.dbo.COR_INT_RATE_PLAN_TODAY      
   WHERE SRC_FUND_ID ='999999999';        
        
   ----- If a SRC_FUND_ID was 999999999 and has been corrected, move to COR table and delete ERR row        
    INSERT INTO CORE1.dbo.COR_INT_RATE_PLAN_TODAY        
 (        
 [SRC_FUND_ID]        
    ,[JOB_ID]        
    ,[DATETIMESTAMP]        
    ,[ACCOUNTING_DATE]        
    ,[INT_RATE_PCT]        
    ,ADU        
    ,REC_INSRT_NAME         
 )        
  SELECT        
  DISTINCT A.[SRC_FUND_ID],  
  @Job_ID,  
  @CurrDateTime      
    ,A.[ACCOUNTING_DATE]        
    ,A.[INT_RATE_PCT]        
       ,A.ADU        
       ,A.REC_INSRT_NAME        
  FROM  COREERRLOG.DBO.ERR_INT_RATE_PLAN A        
  INNER JOIN COREERRLOG.DBO.REPERRORLOG B ON  A.REPERRORID = B.ERRORID        
  LEFT JOIN CORE1.dbo.COR_INT_RATE_PLAN_TODAY C ON A.SRC_FUND_ID = C.SRC_FUND_ID        
  AND A.ACCOUNTING_DATE = C.ACCOUNTING_DATE        
  WHERE B.ERRORMESSAGE LIKE '%COR_INT_RATE_PLAN DUE TO A SRC_FUND_ID OF 999999999'        
  AND A.SRC_FUND_ID <> '999999999' AND C.SRC_FUND_ID IS NULL;        
        
 DELETE A FROM COREERRLOG.DBO.ERR_INT_RATE_PLAN A        
 INNER JOIN COREERRLOG.DBO.REPERRORLOG B  ON  A.REPERRORID = B.ERRORID        
 WHERE B.ERRORMESSAGE LIKE '%COR_INT_RATE_PLAN DUE TO A SRC_FUND_ID OF 999999999'        
 AND A.SRC_FUND_ID <> '999999999';       
     
INSERT INTO COREETL.DBO.COR_INT_RATE_PLAN SELECT DISTINCT * FROM CORE1.DBO.[COR_INT_RATE_PLAN_TODAY]            
        
end
GO
