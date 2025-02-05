USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_INVSTR_ASSET_DRVD_VALUE]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[Proc_TRAC_Populate_COR_INVSTR_ASSET_DRVD_VALUE] AS    
    
DECLARE @JobID INT;  
  
SET @JobID = (SELECT MAX(JobID)  
              FROM MC_JobID  
              INNER JOIN MC_SourceFile  
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID  
              WHERE FileName = 'TRACInvstrAssetDrvdValue.txt'  
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)  
                                       FROM MC_SysProcessedLog  
                                       WHERE SystemID = 49));  
                                       
                                       
----------------------------------------------------------------------------------------------------
-- We are loading following types of records

-- 1) Contribution
-- 2) Distribution
-- 3) Net Contribution Amount
-- 4) POST 88 AMNT
-- 5) Death Benefit
-- 6) PRE 87 AMNT
-- 7) THE 88 AMNT

---------------------------------------------------------------------------------------------------  

INSERT INTO CoreETL.dbo.COR_INVSTR_ASSET_DRVD_VALUE  
  (  
  AGREEMENT_ID,  
  ACCOUNTING_DATE,  
  IA_TYPE_CODE,  
  TIME_FRAME_CODE,  
  DATETIMESTAMP,  
  JOB_ID,  
  AMOUNT,  
  REC_INSRT_NAME,  
  ADU  
  )  
 SELECT  
	GenIDFAAgreement.AgreementID	as AGREEMENT_ID,
	IADV.ACCOUNTING_DATE			as ACCOUNTING_DATE,
	'INVSTMNT'						AS IATypeCode,
	'ITD'							AS TimeFrameCode,
	GETDATE()						AS DateTimeStamp,
	@JobID							AS JobID,
	IADV.CONTRIBUTIONS_AMOUNT		AS AMOUNT,
	'447'							AS REC_INSRT_NAME,
	'U'								AS ADU  
FROM dbo.TRACInvstrAssetDrvdValue IADV
INNER JOIN dbo.GenIDFAAgreement ON  GenIDFAAgreement.SourceSystemKey1 = IADV.Agrmnt_sys_attr_key1_text
								AND GenIDFAAgreement.SourceSystemKey2 = IADV.Agrmnt_sys_attr_key2_text
								AND GenIDFAAgreement.SourceSystemKey3 = IADV.Agrmnt_sys_attr_key3_text
								AND GenIDFAAgreement.SourceSystem = 'TRAC'
WHERE CONTRIBUTIONS_AMOUNT <> 0

INSERT INTO CoreETL.dbo.COR_INVSTR_ASSET_DRVD_VALUE  
  (  
  AGREEMENT_ID,  
  ACCOUNTING_DATE,  
  IA_TYPE_CODE,  
  TIME_FRAME_CODE,  
  DATETIMESTAMP,  
  JOB_ID,  
  AMOUNT,  
  REC_INSRT_NAME,  
  ADU  
  )  
 SELECT  
	GenIDFAAgreement.AgreementID	as AGREEMENT_ID,
	IADV.ACCOUNTING_DATE			as ACCOUNTING_DATE,
	'WDRL'							AS IATypeCode,
	'ITD'							AS TimeFrameCode,
	GETDATE()						AS DateTimeStamp,
	@JobID							AS JobID,
	IADV.DISTRIBUTIONS_AMOUNT		AS AMOUNT,
	'447'							AS REC_INSRT_NAME,
	'U'								AS ADU  
FROM dbo.TRACInvstrAssetDrvdValue IADV
INNER JOIN dbo.GenIDFAAgreement ON  GenIDFAAgreement.SourceSystemKey1 = IADV.Agrmnt_sys_attr_key1_text
								AND GenIDFAAgreement.SourceSystemKey2 = IADV.Agrmnt_sys_attr_key2_text
								AND GenIDFAAgreement.SourceSystemKey3 = IADV.Agrmnt_sys_attr_key3_text
								AND GenIDFAAgreement.SourceSystem = 'TRAC'
WHERE DISTRIBUTIONS_AMOUNT <> 0

INSERT INTO CoreETL.dbo.COR_INVSTR_ASSET_DRVD_VALUE  
  (  
  AGREEMENT_ID,  
  ACCOUNTING_DATE,  
  IA_TYPE_CODE,  
  TIME_FRAME_CODE,  
  DATETIMESTAMP,  
  JOB_ID,  
  AMOUNT,  
  REC_INSRT_NAME,  
  ADU  
  )  
 SELECT  
	GenIDFAAgreement.AgreementID	as AGREEMENT_ID,
	IADV.ACCOUNTING_DATE			as ACCOUNTING_DATE,
	'NETCONTRIB'					AS IATypeCode,
	'ITD'							AS TimeFrameCode,
	GETDATE()						AS DateTimeStamp,
	@JobID							AS JobID,
	IADV.NET_CONTRIB_AMOUNT			AS AMOUNT,
	'447'							AS REC_INSRT_NAME,
	'U'								AS ADU  
FROM dbo.TRACInvstrAssetDrvdValue IADV
INNER JOIN dbo.GenIDFAAgreement ON  GenIDFAAgreement.SourceSystemKey1 = IADV.Agrmnt_sys_attr_key1_text
								AND GenIDFAAgreement.SourceSystemKey2 = IADV.Agrmnt_sys_attr_key2_text
								AND GenIDFAAgreement.SourceSystemKey3 = IADV.Agrmnt_sys_attr_key3_text
								AND GenIDFAAgreement.SourceSystem = 'TRAC'
WHERE NET_CONTRIB_AMOUNT <> 0


INSERT INTO CoreETL.dbo.COR_INVSTR_ASSET_DRVD_VALUE  
  (  
  AGREEMENT_ID,  
  ACCOUNTING_DATE,  
  IA_TYPE_CODE,  
  TIME_FRAME_CODE,  
  DATETIMESTAMP,  
  JOB_ID,  
  AMOUNT,  
  REC_INSRT_NAME,  
  ADU  
  )  
 SELECT  
	GenIDFAAgreement.AgreementID	as AGREEMENT_ID,
	IADV.ACCOUNTING_DATE			as ACCOUNTING_DATE,
	'POST 88 AMNT'					AS IATypeCode,
	'ITD'							AS TimeFrameCode,
	GETDATE()						AS DateTimeStamp,
	@JobID							AS JobID,
	IADV.NET_CONTRIB_AMOUNT			AS AMOUNT,
	'447'							AS REC_INSRT_NAME,
	'U'								AS ADU  
FROM dbo.TRACInvstrAssetDrvdValue IADV
INNER JOIN dbo.GenIDFAAgreement ON  GenIDFAAgreement.SourceSystemKey1 = IADV.Agrmnt_sys_attr_key1_text
								AND GenIDFAAgreement.SourceSystemKey2 = IADV.Agrmnt_sys_attr_key2_text
								AND GenIDFAAgreement.SourceSystemKey3 = IADV.Agrmnt_sys_attr_key3_text
								AND GenIDFAAgreement.SourceSystem = 'TRAC'
WHERE NET_CONTRIB_AMOUNT <> 0

INSERT INTO CoreETL.dbo.COR_INVSTR_ASSET_DRVD_VALUE  
  (  
  AGREEMENT_ID,  
  ACCOUNTING_DATE,  
  IA_TYPE_CODE,  
  TIME_FRAME_CODE,  
  DATETIMESTAMP,  
  JOB_ID,  
  AMOUNT,  
  REC_INSRT_NAME,  
  ADU  
  )  
 SELECT  
	GenIDFAAgreement.AgreementID	as AGREEMENT_ID,
	IADV.ACCOUNTING_DATE			as ACCOUNTING_DATE,
	'STEPUPDTHBNF'					AS IATypeCode,
	'ITD'							AS TimeFrameCode,
	GETDATE()						AS DateTimeStamp,
	@JobID							AS JobID,
	convert(decimal (18,6),IADV.STEPUPDTHBNF)				AS AMOUNT,
	'447'							AS REC_INSRT_NAME,
	'U'								AS ADU  
FROM Core1.dbo.TRACInvstrAssetDrvdValue_DeathBenefit IADV
INNER JOIN dbo.GenIDFAAgreement ON  GenIDFAAgreement.SourceSystemKey1 = IADV.Agrmnt_sys_attr_key1_text
								AND GenIDFAAgreement.SourceSystemKey2 = IADV.Agrmnt_sys_attr_key2_text
								AND GenIDFAAgreement.SourceSystemKey3 = IADV.Agrmnt_sys_attr_key3_text
								AND GenIDFAAgreement.SourceSystem = 'TRAC'

INSERT INTO CoreETL.dbo.COR_INVSTR_ASSET_DRVD_VALUE  
  (  
  AGREEMENT_ID,  
  ACCOUNTING_DATE,  
  IA_TYPE_CODE,  
  TIME_FRAME_CODE,  
  DATETIMESTAMP,  
  JOB_ID,  
  AMOUNT,  
  REC_INSRT_NAME,  
  ADU  
  )  
 SELECT  
	GenIDFAAgreement.AgreementID	as AGREEMENT_ID,
	IADV.ACCOUNTING_DATE			as ACCOUNTING_DATE,
	'PRE 87 AMNT'					AS IATypeCode,
	'ITD'							AS TimeFrameCode,
	GETDATE()						AS DateTimeStamp,
	@JobID							AS JobID,
	IADV.PRE_87_AMNT				AS AMOUNT,
	'447'							AS REC_INSRT_NAME,
	'U'								AS ADU  
FROM Core1.dbo.TRACInvstrAssetDrvdValue_PRE87 IADV
INNER JOIN dbo.GenIDFAAgreement ON  GenIDFAAgreement.SourceSystemKey1 = IADV.Agrmnt_sys_attr_key1_text
								AND GenIDFAAgreement.SourceSystemKey2 = IADV.Agrmnt_sys_attr_key2_text
								AND GenIDFAAgreement.SourceSystemKey3 = IADV.Agrmnt_sys_attr_key3_text
								AND GenIDFAAgreement.SourceSystem = 'TRAC'
WHERE IADV.PRE_87_AMNT <> 0

INSERT INTO CoreETL.dbo.COR_INVSTR_ASSET_DRVD_VALUE  
  (  
  AGREEMENT_ID,  
  ACCOUNTING_DATE,  
  IA_TYPE_CODE,  
  TIME_FRAME_CODE,  
  DATETIMESTAMP,  
  JOB_ID,  
  AMOUNT,  
  REC_INSRT_NAME,  
  ADU  
  )  
 SELECT  
	GenIDFAAgreement.AgreementID	as AGREEMENT_ID,
	IADV.ACCOUNTING_DATE			as ACCOUNTING_DATE,
	'THE 88 AMNT'					AS IATypeCode,
	'ITD'							AS TimeFrameCode,
	GETDATE()						AS DateTimeStamp,
	@JobID							AS JobID,
	IADV.THE_88_AMNT 				AS AMOUNT,
	'447'							AS REC_INSRT_NAME,
	'U'								AS ADU  
FROM Core1.dbo.TRACInvstrAssetDrvdValue_PRE87 IADV
INNER JOIN dbo.GenIDFAAgreement ON  GenIDFAAgreement.SourceSystemKey1 = IADV.Agrmnt_sys_attr_key1_text
								AND GenIDFAAgreement.SourceSystemKey2 = IADV.Agrmnt_sys_attr_key2_text
								AND GenIDFAAgreement.SourceSystemKey3 = IADV.Agrmnt_sys_attr_key3_text
								AND GenIDFAAgreement.SourceSystem = 'TRAC'
WHERE IADV.THE_88_AMNT <> 0
GO
