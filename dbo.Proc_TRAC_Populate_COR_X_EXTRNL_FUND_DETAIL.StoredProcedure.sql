USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_X_EXTRNL_FUND_DETAIL]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Proc_TRAC_Populate_COR_X_EXTRNL_FUND_DETAIL]        
AS        
DECLARE @JobID INT;        
DECLARE @TEMPTIME DateTime;        
        
SET @JobID = (SELECT isnull(MAX(JobID),0)        
  FROM MC_JobID        
  INNER JOIN MC_SourceFile        
  ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID        
  WHERE logicalName = 'TRACExternalFundDetail'        
  AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)        
 FROM MC_SysProcessedLog        
 WHERE SystemID = 49));        
SET @TEMPTIME = GETDATE();        
        
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[COR_X_EXTRNL_FUND_DETAIL_TODAY]') AND type in (N'U'))        
BEGIN        
DROP TABLE [dbo].COR_X_EXTRNL_FUND_DETAIL_TODAY        
END        
        
SELECT * INTO CORE1.DBO.COR_X_EXTRNL_FUND_DETAIL_TODAY FROM COREETL.DBO.COR_X_EXTRNL_FUND_DETAIL WHERE 1=2        
        
INSERT INTO COREETL.dbo.COR_X_EXTRNL_FUND_DETAIL(        
 AGREEMENT_ID,        
 ACCOUNTING_DATE,           
 SRC_FUND_ID,        
 JOB_ID,          
 DATETIMESTAMP,         
 DOLLAR_AMT,        
 REC_INSRT_DATE,        
 REC_INSRT_NAME,        
 REC_UPDT_DATE,        
 REC_UPDT_NAME,        
 ADU            
 )        
Select  distinct         
 GenIDFAAgreement.AgreementID AS AGREEMENT_ID,        
 ASD.LoadDate AS ACCOUNTING_DATE,        
 CASE WHEN TF.SRC_FUND_ID IS NULL  THEN '999999999' ELSE TF.SRC_FUND_ID  END AS SRC_FUND_ID,        
 @JobID AS JOB_ID,         
 @TEMPTIME AS DATETIMESTAMP,        
 CONVERT(DECIMAL(18,2),SUM(CONVERT(DECIMAL(18,6),CONVERT(DECIMAL(18,6),ASD.VEH_MNY_TYPE_SHARES) * CONVERT(DECIMAL(18,6),ASD.UNIT_PRC)))) AS AMOUNT,           
 @TEMPTIME AS REC_INSRT_DATE,        
 CASE WHEN TF.SRC_FUND_ID IS NULL  THEN (rtrim(SRC_SYS_ATTR_KEY1_TEXT)+'+'+rtrim(SRC_SYS_ATTR_KEY2_TEXT)+'+'+rtrim(SRC_SYS_ATTR_KEY3_TEXT)+'+'+rtrim(SRC_SYS_ATTR_KEY4_TEXT))        
 ELSE '448' END  AS REC_INSRT_NAME,        
 @TEMPTIME AS REC_UPDT_DATE,        
 '448' AS REC_UPDT_NAME,        
        
 MAX(ADU)    AS ADU         
FROM dbo.TRACAssetSourceDetailExternal ASD        
INNER JOIN dbo.GenIDFAAgreement  on GenIDFAAgreement.SourceSystemKey1 = ASD.AGRMNT_SYS_ATTR_KEY1_TEXT        
  AND GenIDFAAgreement.SourceSystemKey2 = ASD.AGRMNT_SYS_ATTR_KEY2_TEXT        
  AND GenIDFAAgreement.SourceSystemKey3 = ASD.AGRMNT_SYS_ATTR_KEY3_TEXT        
  AND GenIDFAAgreement.SourceSystemKey4 = ASD.AGRMNT_SYS_ATTR_KEY4_TEXT        
  AND GenIDFAAgreement.SourceSystemKey5 = ASD.AGRMNT_SYS_ATTR_KEY5_TEXT        
  AND ASD.MNTC_SYS_CODE = GenIDFAAgreement.SourceSystem            
/*inner    JOIN CORESQLHOST01.core1.dbo.GenIDSrcFund GENID   ON  GENID.SOURCESYSTEM = ASD.MNTC_SYS_CODE        
  AND GENID.SOURCESYSTEMKEY1 = SRC_SYS_ATTR_KEY1_TEXT        
    --  AND GENID.SOURCESYSTEMKEY2 = SRC_SYS_ATTR_KEY2_TEXT        
  AND GENID.SOURCESYSTEMKEY3 = SRC_SYS_ATTR_KEY3_TEXT        
  AND GENID.SOURCESYSTEMKEY4 = SRC_SYS_ATTR_KEY4_TEXT        
*/            
INNER JOIN TRACFUNDS TF   ON rtrim(TF.KEY1) = rtrim(SRC_SYS_ATTR_KEY1_TEXT)        
-- AND TF.KEY2 = SRC_SYS_ATTR_KEY2_TEXT        
  AND rtrim(TF.KEY3) = rtrim(SRC_SYS_ATTR_KEY3_TEXT)        
  AND rtrim(TF.KEY4) = rtrim(SRC_SYS_ATTR_KEY4_TEXT)            
  and TF.FUND_TYPE = 'EXT'    
WHERE ASD.MNTC_SYS_CODE = 'TRAC'        and (
    (rtrim(SRC_SYS_ATTR_KEY2_TEXT) <> '' AND rtrim(TF.KEY2) = rtrim(SRC_SYS_ATTR_KEY2_TEXT)) 
    OR (rtrim(SRC_SYS_ATTR_KEY2_TEXT) = ''))
GROUP BY        
GenIDFAAgreement.AgreementID,        
 --GENID.SRC_FUND_ID,        
TF.SRC_FUND_ID,           
 ASD.LoadDate,        
 (CONVERT(nvarchar(20),ASD.CONTR_MONEY_TY_CDE)+'+'+CONVERT(nvarchar(20),ASD.PLAN_TYPE_CDE)),        
  ASD.MNY_TYPE_VESTED_PERCENT,        
  (rtrim(SRC_SYS_ATTR_KEY1_TEXT)+'+'+rtrim(SRC_SYS_ATTR_KEY2_TEXT)+'+'+rtrim(SRC_SYS_ATTR_KEY3_TEXT)+'+'+rtrim(SRC_SYS_ATTR_KEY4_TEXT));        
        
INSERT INTO COREERRLOG.DBO.REPERRORLOG(ERRORDATE,ERRORMESSAGE,ERRORDATA,ERRORSOURCE,SYSTEM)        
SELECT GETDATE(),        
 'UNABLE TO LOAD '+CAST(CNT AS VARCHAR)+' RECORD(S) INTO COR_X_EXTRNL_FUND_DETAIL DUE TO A SRC_FUND_ID OF 999999999',        
 'REFER TO ERR TABLE FOR DETAIL',        
 'REP',        
 'TRAC'        
FROM (SELECT COUNT(*) AS CNT FROM CORE1.DBO.COR_X_EXTRNL_FUND_DETAIL_TODAY WHERE SRC_FUND_ID = 999999999) Q        
WHERE CNT > 0        
        
INSERT INTO COREERRLOG.DBO.ERR_X_EXTRNL_FUND_DETAIL        
SELECT *,        
 (SELECT DISTINCT @@IDENTITY FROM COREERRLOG.DBO.REPERRORLOG)        
FROM CORE1.DBO.COR_X_EXTRNL_FUND_DETAIL_TODAY        
WHERE SRC_FUND_ID = 999999999;        
        
DELETE CORE1.DBO.COR_X_EXTRNL_FUND_DETAIL_TODAY        
WHERE SRC_FUND_ID =999999999;        
        
----- If a SRC_FUND_ID was 999999999 and has been corrected,move to COR table and delete ERR row        
        
INSERT INTO CORE1.DBO.COR_X_EXTRNL_FUND_DETAIL_TODAY        
 (        
 AGREEMENT_ID,        
 ACCOUNTING_DATE,           
 SRC_FUND_ID,        
 JOB_ID,          
 DATETIMESTAMP,         
 DOLLAR_AMT,        
 REC_INSRT_DATE,        
 REC_INSRT_NAME,        
 REC_UPDT_DATE,        
 REC_UPDT_NAME,        
 ADU         
 )        
SELECT        
 A.AGREEMENT_ID,        
 A.ACCOUNTING_DATE,           
 A.SRC_FUND_ID,        
 @JOBID,          
 @TEMPTIME,         
 A.DOLLAR_AMT,        
 @TEMPTIME,        
 '448',        
 @TEMPTIME,        
 '448',        
 ADU         
FROM COREERRLOG.DBO.ERR_X_EXTRNL_FUND_DETAIL A        
INNER JOIN COREERRLOG.DBO.REPERRORLOG B        
ON  A.REPERRORID = B.ERRORID        
WHERE B.ERRORMESSAGE LIKE '%DUE TO A SRC_FUND_ID OF 999999999'        
  AND A.SRC_FUND_ID <> 999999999;        
        
DELETE A        
FROM COREERRLOG.DBO.ERR_X_EXTRNL_FUND_DETAIL A        
INNER JOIN COREERRLOG.DBO.REPERRORLOG B        
ON  A.REPERRORID = B.ERRORID        
WHERE B.ERRORMESSAGE LIKE '%DUE TO A SRC_FUND_ID OF 999999999'        
  AND A.SRC_FUND_ID <> 999999999;        
            
INSERT INTO COREETL.DBO.COR_X_EXTRNL_FUND_DETAIL SELECT DISTINCT * FROM CORE1.DBO.[COR_X_EXTRNL_FUND_DETAIL_TODAY]
GO
