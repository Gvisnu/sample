USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_AGRMNT_PARTY_CMMNCTN]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[Proc_TRAC_Populate_COR_AGRMNT_PARTY_CMMNCTN] AS

DECLARE @JOBID int;
SET @JOBID = (SELECT  MAX(JOBID)
              FROM Core1.dbo.MC_JOBID
			  WHERE  SouRCEFILEID = 537 
			  AND sysprocessedlogid IN (SELECT  MAX(sysprocessedlogid)
									FROM Core1.dbo.MC_SysProcessedLog 
									WHERE SYSTEMID= 49
                  )
               )
               

INSERT INTO CoreETL.dbo.COR_AGRMNT_PARTY_CMMNCTN
(
AGRMNT_PARTY_CMMNCTN_ID, 
AGRMNT_PARTY_ID, 
CMMNCTN_TYPE_CODE, 
CMMNCTN_FREQ_CODE, 
CNFRM_TXN_CODE, 
JOB_ID, 
DATETIMESTAMP, 
CMMNCTN_FROM_DATE, 
CMMNCTN_THRU_DATE, 
MNTC_SYS_CODE, 
MNTC_SYS_ATTR_ID, 
MNTC_SYS_ATTR_KEY1_TEXT, 
MNTC_SYS_ATTR_KEY2_TEXT, 
MNTC_SYS_ATTR_KEY3_TEXT, 
MNTC_SYS_ATTR_KEY4_TEXT, 
REC_INSRT_DATE, 
REC_INSRT_NAME, 
REC_UPDT_DATE, 
REC_UPDT_NAME, 
ADU
)
SELECT DISTINCT 
GenIDC.AgreementPartyCommunicationID	AS AGRMNT_PARTY_CMMNCTN_ID, 
GenID.AgreementPartyID					AS AGRMNT_PARTY_ID, 
CASE WHEN TPC.CMMNCTN_TYPE_CODE = '-1' 
THEN 'SOA' 
WHEN TPC.CMMNCTN_TYPE_CODE      = '-2' 
THEN 'CORR' 
ELSE 'CNFRM' 
END										AS CMMNCTN_TYPE_CODE, 
CASE WHEN TPC.CMMNCTN_TYPE_CODE = '-1' 
THEN TPC.CMMNCTN_FREQ_CODE
ELSE 'DT OF TXN' 
END										AS CMMNCTN_FREQ_CODE, 
TPC.CNFRM_TXN_CODE						As CNFRM_TXN_CODE,
@JOBID									AS JOB_ID, 
GETDATE()								AS DATETIMESTAMP, 
ISNULL(TPC.CMMNCTN_FROM_DATE, GETDATE()) AS CMMNCTN_FROM_DATE, 
ISNULL(TPC.CMMNCTN_THRU_DATE, '31-DEC-2999') AS CMMNCTN_THRU_DATE, 
TPC.Mntc_Sys_Code				 AS MNTC_SYS_CODE, 
GenIDMS.MaintenanceSystemAttributeID AS MNTC_SYS_ATTR_ID, 
'v_AgreementPartyCmnctn'		     AS MNTC_SYS_ATTR_KEY1_TEXT, 
'COR_AGRMNT_PARTY_CMMNCTN'		     AS MNTC_SYS_ATTR_KEY2_TEXT, 
'N/A'								 AS MNTC_SYS_ATTR_KEY3_TEXT, 
'N/A'								 AS MNTC_SYS_ATTR_KEY4_TEXT, 
GETDATE()							 AS REC_INSRT_DATE, 
'435'								 AS REC_INSRT_NAME, 
GETDATE()							 AS REC_UPDT_DATE, 
NULL								 AS REC_UPDT_NAME, 
'A'									 AS ADU
FROM   Core1.dbo.TRACAgreementPartyCmnctn TPC
INNER JOIN Core1.dbo.GenIDBPAgreementPartyCommunication GenIDC ON 
GenIDC.SourceSystemKey1 = TPC.AgreementPartyCmnctn_Sys_Attr_Key1_Text
AND GenIDC.SourceSystemKey2 = TPC.AgreementPartyCmnctn_Sys_Attr_Key2_Text
AND GenIDC.SourceSystemKey3 = TPC.AgreementPartyCmnctn_Sys_Attr_Key3_Text
AND GenIDC.SourceSystemKey4 = TPC.AgreementPartyCmnctn_Sys_Attr_Key4_Text
ANd GenIDC.SourceSystemKey5 = TPC.AgreementPartyCmnctn_Sys_Attr_Key5_Text
and GenIDC.SourceSystemKey6 = TPC.AgreementPartyCmnctn_Sys_Attr_Key6_Text
INNER JOIN Core1.dbo.GenIDBPAgreementParty GenID ON 
GenID.SourceSystemKey1 = TPC.AgreementParty_Sys_Attr_Key1_Text
AND GenID.SourceSystemKey2 = TPC.AgreementParty_Sys_Attr_Key2_Text	
ANd GenID.SourceSystemKey3 = TPC.AgreementParty_Sys_Attr_Key3_Text
AND GenID.SourceSystemKey4 = TPC.AgreementParty_Sys_Attr_Key4_Text
and GenID.SourceSystemKey5 = TPC.AgreementParty_Sys_Attr_Key5_Text
INNER JOIN Core1.dbo.GenIDSPMaintenanceSystemAttributeName GenIDMS ON 
GenIDMS.SourceSystemKey1 = 'v_AgreementPartyCmnctn'
AND GenIDMS.SourceSystemKey2 = 'COR_AGRMNT_PARTY_CMMNCTN' 
WHERE  TPC.Mntc_Sys_Code = 'TRAC'





GO
