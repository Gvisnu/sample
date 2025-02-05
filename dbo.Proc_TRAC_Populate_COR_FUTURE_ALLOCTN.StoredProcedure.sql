USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_FUTURE_ALLOCTN]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

------------------------------------------------------------------------------------------------------
/*
1. Load the data from the View into staging table.
2. Compare with Yesterday table (copy of staging table with yesterdays records)
3. Create a delta table (copy of table structure with only delta i.e. records changed
4. Load ETL table from delta.
5. Copy todays records to yesterday table
6. Set Inactive if the records is not present in Today File
*/
--------------------------------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[Proc_TRAC_Populate_COR_FUTURE_ALLOCTN] AS

DECLARE @JobID INT;
DECLARE @TEMPTIME DATETIME;
DECLARE @Count INT;
SET @JobID = (SELECT isnull(MAX(JobID),0)
              FROM MC_JobID
              INNER JOIN MC_SourceFile
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID
              WHERE logicalName = 'TRACFutureAllocation'
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)
                                       FROM MC_SysProcessedLog
                                       WHERE SystemID = 49));
SET @TEMPTIME = GETDATE();

-- we have added three stage tables
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[COR_FUTURE_ALLOCTN_Today]') AND type in (N'U'))
BEGIN
DROP TABLE [dbo].COR_FUTURE_ALLOCTN_Today
END

SELECT * INTO CORE1.DBO.COR_FUTURE_ALLOCTN_Today FROM COREETL.DBO.COR_FUTURE_ALLOCTN WHERE 1=2

SELECT @Count = COUNT(1) from TRACFutureAlloctn_Yesterday

-- 1) Loading the delta records into ETL table
----------- START-------------------------------
IF(@Count > 1)
BEGIN

Insert into TRACFutureAlloctn_Delta (AGRMNT_SYS_ATTR_KEY1_TEXT,
AGRMNT_SYS_ATTR_KEY2_TEXT,
AGRMNT_SYS_ATTR_KEY3_TEXT,
SRC_SYS_ATTR_KEY1_TEXT,
--SRC_SYS_ATTR_KEY2_TEXT,
SRC_SYS_ATTR_KEY3_TEXT,
SRC_SYS_ATTR_KEY4_TEXT,
CONTR_MONEY_TY_CDE,
PLAN_TYPE_CDE,
AMOUNT)
Select AGRMNT_SYS_ATTR_KEY1_TEXT,
AGRMNT_SYS_ATTR_KEY2_TEXT,
AGRMNT_SYS_ATTR_KEY3_TEXT,
SRC_SYS_ATTR_KEY1_TEXT,
--SRC_SYS_ATTR_KEY2_TEXT,
SRC_SYS_ATTR_KEY3_TEXT,
SRC_SYS_ATTR_KEY4_TEXT,
CONTR_MONEY_TY_CDE,
PLAN_TYPE_CDE,
AMOUNT
from TRACFutureAlloctn
EXCEPT
SELECT
AGRMNT_SYS_ATTR_KEY1_TEXT,
AGRMNT_SYS_ATTR_KEY2_TEXT,
AGRMNT_SYS_ATTR_KEY3_TEXT,
SRC_SYS_ATTR_KEY1_TEXT,
--SRC_SYS_ATTR_KEY2_TEXT,
SRC_SYS_ATTR_KEY3_TEXT,
SRC_SYS_ATTR_KEY4_TEXT,
CONTR_MONEY_TY_CDE,
PLAN_TYPE_CDE,
AMOUNT
from TRACFutureAlloctn_Yesterday

INSERT INTO CORE1.dbo.COR_FUTURE_ALLOCTN_Today(
 AGREEMENT_ID,
 ALLOCATION_TYPE_CODE,
 SRC_FUND_ID,
 ASSET_SOURCE_CODE,
 REC_INSRT_DATE,
 REC_INSRT_NAME,
 REC_UPDT_DATE,
 REC_FROM_DATE,
 RECORD_STATUS_CODE,
 DATETIMESTAMP,
 JOB_ID,
 AMOUNT_TYPE_CODE,
 AMOUNT,
 MODEL_IND,
 ADU)
  SELECT
 GenIDFAAgreement.AgreementID,
 'PMT',
 ISNULL(GENID.SRC_FUND_ID,'999999999')  AS SRC_FUND_ID,
 convert(varchar(30),(TFA.CONTR_MONEY_TY_CDE+'+'+TFA.PLAN_TYPE_CDE)) AS ASSET_SOURCE_CODE,
 @TEMPTIME AS REC_INSRT_DATE,
 --'418' AS REC_INSRT_NAME,
 CASE WHEN GENID.SRC_FUND_ID IS NULL THEN (TFA.SRC_SYS_ATTR_KEY1_TEXT+'+'+TFA.SRC_SYS_ATTR_KEY2_TEXT+'+'+TFA.SRC_SYS_ATTR_KEY3_TEXT+'+'+TFA.SRC_SYS_ATTR_KEY4_TEXT)
 ELSE '418'
 END As REC_INSRT_NAME,-- Added on 01-30-2014 as per Santhosh feedback
 @TEMPTIME AS REC_UPDT_DATE,
 @TEMPTIME AS REC_FROM_DATE,
 NULL AS RECORD_STATUS_CODE,
 @TEMPTIME,
 @JobID,
 'PERCENT',
 TFA.AMOUNT,
 '0' AS MODEL_IND,
 'A'
 FROM dbo.TRACFutureAlloctn_Delta TFA
 INNER JOIN dbo.GenIDFAAgreement on GenIDFAAgreement.SourceSystemKey1 = TFA.AGRMNT_SYS_ATTR_KEY1_TEXT
        AND GenIDFAAgreement.SourceSystemKey2 = TFA.AGRMNT_SYS_ATTR_KEY2_TEXT
        AND GenIDFAAgreement.SourceSystemKey3 = TFA.AGRMNT_SYS_ATTR_KEY3_TEXT
        --AND TFA.MNTC_SYS_CODE = 'TRAC'
LEFT OUTER JOIN GENIDSRCFUND GENID  ON
         rtrim(GENID.SOURCESYSTEMKEY1) = rtrim(SRC_SYS_ATTR_KEY1_TEXT)
        AND rtrim(GENID.SOURCESYSTEMKEY3) = rtrim(SRC_SYS_ATTR_KEY3_TEXT)
        AND rtrim(GENID.SOURCESYSTEMKEY4) = rtrim(SRC_SYS_ATTR_KEY4_TEXT)
    where GENID.SOURCESYSTEM = 'TRAC'   and (
    (rtrim(ISNULL(SRC_SYS_ATTR_KEY2_TEXT,'')) <> '' AND rtrim(GENID.SOURCESYSTEMKEY2) = rtrim(ISNULL(SRC_SYS_ATTR_KEY2_TEXT,'')))
    OR (rtrim(ISNULL(SRC_SYS_ATTR_KEY2_TEXT,'')) = ''))
----------- END-------------------------------

-- 2) To Inactivate the records which is not present in Todays file

-------------START-------------------------------------

Insert into TRACFutureAlloctn_Delete (AGRMNT_SYS_ATTR_KEY1_TEXT,
AGRMNT_SYS_ATTR_KEY2_TEXT,
AGRMNT_SYS_ATTR_KEY3_TEXT,
SRC_SYS_ATTR_KEY1_TEXT,
--SRC_SYS_ATTR_KEY2_TEXT,
SRC_SYS_ATTR_KEY3_TEXT,
SRC_SYS_ATTR_KEY4_TEXT,
CONTR_MONEY_TY_CDE,
PLAN_TYPE_CDE)
Select AGRMNT_SYS_ATTR_KEY1_TEXT,
AGRMNT_SYS_ATTR_KEY2_TEXT,
AGRMNT_SYS_ATTR_KEY3_TEXT,
SRC_SYS_ATTR_KEY1_TEXT,
--SRC_SYS_ATTR_KEY2_TEXT,
SRC_SYS_ATTR_KEY3_TEXT,
SRC_SYS_ATTR_KEY4_TEXT,
CONTR_MONEY_TY_CDE,
PLAN_TYPE_CDE
from TRACFutureAlloctn_Yesterday
EXCEPT
SELECT
AGRMNT_SYS_ATTR_KEY1_TEXT,
AGRMNT_SYS_ATTR_KEY2_TEXT,
AGRMNT_SYS_ATTR_KEY3_TEXT,
SRC_SYS_ATTR_KEY1_TEXT,
--SRC_SYS_ATTR_KEY2_TEXT,
SRC_SYS_ATTR_KEY3_TEXT,
SRC_SYS_ATTR_KEY4_TEXT,
CONTR_MONEY_TY_CDE,
PLAN_TYPE_CDE
from TRACFutureAlloctn

INSERT INTO CORE1.dbo.COR_FUTURE_ALLOCTN_Today(
 AGREEMENT_ID,
 ALLOCATION_TYPE_CODE,
 SRC_FUND_ID,
 ASSET_SOURCE_CODE,
 REC_INSRT_DATE,
 REC_INSRT_NAME,
 REC_UPDT_DATE,
 REC_FROM_DATE,
 REC_THRU_DATE,
 RECORD_STATUS_CODE,
 DATETIMESTAMP,
 JOB_ID,
 AMOUNT_TYPE_CODE,
 MODEL_IND,
 ADU)
  SELECT
 GenIDFAAgreement.AgreementID,
 'PMT',
 ISNULL(GENID.SRC_FUND_ID,'999999999') as SRC_FUND_ID,
 convert(varchar(30),(TFA.CONTR_MONEY_TY_CDE+'+'+TFA.PLAN_TYPE_CDE)) AS ASSET_SOURCE_CODE,
 @TEMPTIME AS REC_INSRT_DATE,
 --'418' AS REC_INSRT_NAME,
 CASE WHEN GENID.SRC_FUND_ID IS NULL THEN (TFA.SRC_SYS_ATTR_KEY1_TEXT+'+'+TFA.SRC_SYS_ATTR_KEY2_TEXT+'+'+TFA.SRC_SYS_ATTR_KEY3_TEXT+'+'+TFA.SRC_SYS_ATTR_KEY4_TEXT)
 ELSE '418'
 END As REC_INSRT_NAME,-- Added on 01-30-2014 as per Santhosh feedback
 @TEMPTIME AS REC_UPDT_DATE,
 @TEMPTIME AS REC_FROM_DATE,
 @TEMPTIME AS REC_THRU_DATE,
 'INACT' AS RECORD_STATUS_CODE,
 @TEMPTIME,
 @JobID,
 'PERCENT',
 '0' AS MODEL_IND,
 'U'
 FROM dbo.TRACFutureAlloctn_Delete TFA
 INNER JOIN dbo.GenIDFAAgreement on GenIDFAAgreement.SourceSystemKey1 = TFA.AGRMNT_SYS_ATTR_KEY1_TEXT
        AND GenIDFAAgreement.SourceSystemKey2 = TFA.AGRMNT_SYS_ATTR_KEY2_TEXT
        AND GenIDFAAgreement.SourceSystemKey3 = TFA.AGRMNT_SYS_ATTR_KEY3_TEXT
LEFT OUTER JOIN GENIDSRCFUND GENID  ON
         rtrim(GENID.SOURCESYSTEMKEY1) = rtrim(SRC_SYS_ATTR_KEY1_TEXT)
        AND rtrim(GENID.SOURCESYSTEMKEY3) = rtrim(SRC_SYS_ATTR_KEY3_TEXT)
        AND rtrim(GENID.SOURCESYSTEMKEY4) = rtrim(SRC_SYS_ATTR_KEY4_TEXT)
    where GENID.SOURCESYSTEM = 'TRAC'   and (
    (rtrim(ISNULL(SRC_SYS_ATTR_KEY2_TEXT,'')) <> '' AND rtrim(GENID.SOURCESYSTEMKEY2) = rtrim(ISNULL(SRC_SYS_ATTR_KEY2_TEXT,'')))
    OR (rtrim(ISNULL(SRC_SYS_ATTR_KEY2_TEXT,'')) = ''))
AND AgreementID not in (SELECT Agreement_ID FROM VW_TRAC_AGREEMENTDELETE)
-------------END-------------------------------------
END

ELSE

--3)  To load the Todays record for the first time

------------------START-----------------------------------
   BEGIN

INSERT INTO CORE1.dbo.COR_FUTURE_ALLOCTN_Today(
 AGREEMENT_ID,
 ALLOCATION_TYPE_CODE,
 SRC_FUND_ID,
 ASSET_SOURCE_CODE,
 REC_INSRT_DATE,
 REC_INSRT_NAME,
 REC_UPDT_DATE,
 REC_UPDT_NAME,
 REC_FROM_DATE,
 REC_THRU_DATE,
 RECORD_STATUS_CODE,
 DATETIMESTAMP,
 JOB_ID,
 AMOUNT_TYPE_CODE,
 AMOUNT,
 MODEL_IND,
 ADU)
  SELECT
 GenIDFAAgreement.AgreementID,
 TFA.ALLOCATION_TYPE_CODE,
 ISNULL(GENID.SRC_FUND_ID,'999999999') as SRC_FUND_ID,
 convert(varchar(30),(TFA.CONTR_MONEY_TY_CDE+'+'+TFA.PLAN_TYPE_CDE)) AS ASSET_SOURCE_CODE,
 @TEMPTIME AS REC_INSRT_DATE,
 --'418' AS REC_INSRT_NAME,
 CASE WHEN GENID.SRC_FUND_ID IS NULL THEN (TFA.SRC_SYS_ATTR_KEY1_TEXT+'+'+TFA.SRC_SYS_ATTR_KEY2_TEXT+'+'+TFA.SRC_SYS_ATTR_KEY3_TEXT+'+'+TFA.SRC_SYS_ATTR_KEY4_TEXT)
 ELSE '418'
 END As REC_INSRT_NAME,-- Added on 01-30-2014 as per Santhosh feedback
 @TEMPTIME AS REC_UPDT_DATE,
 NULL,
 LoadDate AS REC_FROM_DATE,
 NULL,
 NULL AS RECORD_STATUS_CODE,
 @TEMPTIME,
 @JobID,
 TFA.AMOUNT_TYPE_CODE,
 TFA.AMOUNT,
 '0' AS MODEL_IND,
 'A'
 FROM dbo.TRACFutureAlloctn TFA
 INNER JOIN dbo.GenIDFAAgreement on GenIDFAAgreement.SourceSystemKey1 = TFA.AGRMNT_SYS_ATTR_KEY1_TEXT
        AND GenIDFAAgreement.SourceSystemKey2 = TFA.AGRMNT_SYS_ATTR_KEY2_TEXT
        AND GenIDFAAgreement.SourceSystemKey3 = TFA.AGRMNT_SYS_ATTR_KEY3_TEXT
        AND TFA.MNTC_SYS_CODE = 'TRAC'
LEFT OUTER JOIN GENIDSRCFUND GENID  ON
         rtrim(GENID.SOURCESYSTEMKEY1) = rtrim(SRC_SYS_ATTR_KEY1_TEXT)
        AND rtrim(GENID.SOURCESYSTEMKEY3) = rtrim(SRC_SYS_ATTR_KEY3_TEXT)
        AND rtrim(GENID.SOURCESYSTEMKEY4) = rtrim(SRC_SYS_ATTR_KEY4_TEXT)
    where GENID.SOURCESYSTEM = 'TRAC'   and (
    (rtrim(ISNULL(SRC_SYS_ATTR_KEY2_TEXT,'')) <> '' AND rtrim(GENID.SOURCESYSTEMKEY2) = rtrim(ISNULL(SRC_SYS_ATTR_KEY2_TEXT,'')))
    OR (rtrim(ISNULL(SRC_SYS_ATTR_KEY2_TEXT,'')) = ''))
------------------END-----------------------------------

----- If a SRC_Fund_ID is 999999999,create an error and move to ERR table

INSERT INTO COREERRLOG.DBO.REPERRORLOG (ERRORDATE,ERRORMESSAGE,ERRORDATA,ERRORSOURCE,SYSTEM)
SELECT GETDATE(),
 'UNABLE TO LOAD '+CAST(CNT AS VARCHAR)+' RECORD(S) INTO COR_FUTURE_ALLOCTN DUE TO A SRC_Fund_ID OF 999999999',
 'REFER TO ERR TABLE FOR DETAIL',
 'REP',
 'TRAC'
FROM (SELECT COUNT(*) AS CNT FROM CORE1.dbo.COR_FUTURE_ALLOCTN_Today WHERE SRC_Fund_ID = 999999999) Q
WHERE CNT > 0;
    
INSERT INTO COREERRLOG.DBO.ERR_FUTURE_ALLOCTN
SELECT *,
 (SELECT DISTINCT @@IDENTITY FROM COREERRLOG.DBO.REPERRORLOG)
FROM CORE1.dbo.COR_FUTURE_ALLOCTN_Today
WHERE SRC_Fund_ID = 999999999;

DELETE CORE1.dbo.COR_FUTURE_ALLOCTN_Today
WHERE SRC_Fund_ID IN (888888888,999999999);

----- If a SRC_Fund_ID was 999999999 and has been corrected,move to COR table and delete ERR row

INSERT INTO CORE1.dbo.COR_FUTURE_ALLOCTN_Today
 (
 AGREEMENT_ID,
 ALLOCATION_TYPE_CODE,
 SRC_Fund_ID,
 ASSET_SOURCE_CODE,
 DATETIMESTAMP,
 JOB_ID,
 AMOUNT,
 AMOUNT_TYPE_CODE,
 MODEL_IND,
 ADU,
 REC_FROM_DATE,
 REC_THRU_DATE,
 RECORD_STATUS_CODE,
 REC_INSRT_NAME,
 REC_UPDT_NAME)
SELECT
 A.AGREEMENT_ID,
 A.ALLOCATION_TYPE_CODE,
 A.SRC_Fund_ID,
 A.ASSET_SOURCE_CODE,
 @TEMPTIME,
 @JobID,
 A.AMOUNT,
 A.AMOUNT_TYPE_CODE,
 A.MODEL_IND,
 A.ADU,
 @TEMPTIME,
 A.REC_THRU_DATE,
 A.RECORD_STATUS_CODE,
 '418',
 A.REC_UPDT_NAME
FROM COREERRLOG.DBO.ERR_FUTURE_ALLOCTN A
INNER JOIN COREERRLOG.DBO.REPERRORLOG B
ON  A.REPERRORID = B.ERRORID       
WHERE B.ERRORMESSAGE LIKE '%DUE TO A SRC_Fund_ID OF 999999999'
  AND A.SRC_Fund_ID <> 999999999;

DELETE COREERRLOG.DBO.ERR_FUTURE_ALLOCTN
FROM COREERRLOG.DBO.ERR_FUTURE_ALLOCTN A
INNER JOIN COREERRLOG.DBO.REPERRORLOG B
ON  A.REPERRORID = B.ERRORID
WHERE B.ERRORMESSAGE LIKE '%DUE TO A SRC_Fund_ID OF 999999999'
  AND A.SRC_Fund_ID <> 999999999;
  
DELETE COREERRLOG.DBO.ERR_FUTURE_ALLOCTN WHERE AGREEMENT_ID IN (SELECT Agreement_ID FROM VW_TRAC_AGREEMENTDELETE);

END
INSERT INTO COREETL.dbo.COR_FUTURE_ALLOCTN SELECT DISTINCT * FROM CORE1.dbo.COR_FUTURE_ALLOCTN_Today

RETURN
GO
