USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_AGRMNT_PARTY_ATHRZTN]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Proc_TRAC_Populate_COR_AGRMNT_PARTY_ATHRZTN] AS

DECLARE @JobID INT;                  
DECLARE @TEMPDATE DATETIME;                  
      
                  
SET @JobID = (SELECT isnull(MAX(JobID),0)                    
              FROM MC_JobID                    
              INNER JOIN MC_SourceFile                    
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID                    
              WHERE logicalName = 'TRACAgreementPartyAuthorization'                    
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)                    
                                       FROM MC_SysProcessedLog                    
                                       WHERE SystemID = 49));                      
                  
SET @TEMPDATE = GETDATE();  

INSERT INTO CoreETL.dbo.COR_AGRMNT_PARTY_ATHRZTN
                      (
                      AGRMNT_PARTY_ATHRZTN_ID, 
                      AGRMNT_PARTY_ID, 
                      AGRMNT_PARTY_ATHRZTN_TYPE_CODE, 
                      JOB_ID, 
                      DATETIMESTAMP, 
                      AGRMNT_PARTY_ATHRZTN_FROM_DATE, 
                      AGRMNT_PARTY_ATHRZTN_THRU_DATE, 
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
                      REC_FROM_DATE, 
                      REC_THRU_DATE, 
                      ADU
                      )
SELECT
APA.AgreementPartyAuthorizationID AS AGRMNT_PARTY_ATHRZTN_ID,
Ap.AgreementPartyID as AGRMNT_PARTY_ID,
COM.PARTY_ATHRZTN_TYPE_CODE as AGRMNT_PARTY_ATHRZTN_TYPE_CODE,
@JobID as JOB_ID,
@TEMPDATE as DATETIMESTAMP,
COM.AGRMNT_PARTY_ATHRZTN_FROM_DATE as AGRMNT_PARTY_ATHRZTN_FROM_DATE,
COM.AGRMNT_PARTY_ATHRZTN_THRU_DATE as AGRMNT_PARTY_ATHRZTN_THRU_DATE,
COM.MNTC_SYSTEM_CODE as MNTC_SYS_CODE,
MSA.MaintenanceSystemAttributeID as MNTC_SYS_ATTR_ID,
COM.MNTC_SYS_ATTR1_KEY as MNTC_SYS_ATTR_KEY1_TEXT,
COM.MNTC_SYS_ATTR2_KEY as MNTC_SYS_ATTR_KEY2_TEXT,
COM.MNTC_SYS_ATTR3_KEY as MNTC_SYS_ATTR_KEY3_TEXT,
COM.MNTC_SYS_ATTR4_KEY as MNTC_SYS_ATTR_KEY4_TEXT,
@TEMPDATE
,'453'
,@TEMPDATE
,NULL
,@TEMPDATE
,NULL
,COM.ADU
FROM
Core1.dbo.COM_AGRMNT_PARTY_ATHRZTN COM
INNER JOIN Core1.dbo.GenIDBPAgreementParty AP on Ap.SourceSystemKey1 = COM.AGRMNT_PARTY_ID1_KEY
											AND  Ap.SourceSystemKey2 = COM.AGRMNT_PARTY_ID2_KEY
											AND  Ap.SourceSystemKey3 = COM.AGRMNT_PARTY_ID3_KEY
											ANd  AP.SourceSystemKey4 = COM.AGRMNT_PARTY_ID4_KEY
											ANd  Ap.SourceSystemKey5 =  COM.AGRMNT_PARTY_ID5_KEY
INNER Join Core1.dbo.GenIDBPAgreementPartyAuthorization APA on APA.SourceSystemKey1 = COM.AGRMNT_PARTY_ATHRZTN1_KEY
																ANd APA.SourceSystemKey2 = COM.AGRMNT_PARTY_ATHRZTN2_KEY	
																AND APA.SourceSystemKey3 = COM.AGRMNT_PARTY_ATHRZTN3_KEY
																AND APA.SourceSystemKey4 = COM.AGRMNT_PARTY_ATHRZTN4_KEY
																ANd APA.SourceSystemKey5 = COM.AGRMNT_PARTY_ATHRZTN5_KEY
INNER JOIN Core1.dbo.GenIDSPMaintenanceSystemAttributeName MSA on MSA.SourceSystem = 'TRAC'
																AND MSA.SourceSystemKey1 = COM.MNTC_SYS_ATTR1_KEY
																AND MSA.SourceSystemKey2 = COM.MNTC_SYS_ATTR2_KEY
GO
