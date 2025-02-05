USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_COR_AGRMNT_PARTY_PHONE]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Proc_TRAC_Populate_COR_AGRMNT_PARTY_PHONE] AS    
DECLARE @CurrDateTime DATETIME    
set nocount on    
    
DECLARE @JobID INT;                        
    
SET @JobID = (SELECT isnull(MAX(JobID),0)                        
              FROM MC_JobID                        
              INNER JOIN MC_SourceFile                        
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID                        
              WHERE logicalName = 'TRACAgrmntPartyPhone'              
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)                        
                                       FROM MC_SysProcessedLog                        
                                       WHERE SystemID = 49));    
                                           
                                           
SET @CurrDateTime = GETDATE()    
INSERT INTO COREETL.DBO.COR_AGRMNT_PARTY_PHONE    
(    
AGRMNT_PARTY_PHONE_ID,    
AGRMNT_PARTY_ID,    
PHONE_TYPE_CODE,    
JOB_ID,    
DATETIMESTAMP,    
CNTCT_RSTRCT_IND,    
PHONE_FROM_DATE,    
PHONE_THRU_DATE,    
UNFRMTTD_PHONE_NUM,    
MNTC_SYS_CODE,    
MNTC_SYS_ATTR_ID,    
MNTC_SYS_ATTR_KEY1_TEXT,    
MNTC_SYS_ATTR_KEY2_TEXT,    
MNTC_SYS_ATTR_KEY3_TEXT,    
MNTC_SYS_ATTR_KEY4_TEXT,    
REC_INSRT_NAME,    
ADU,    
REC_FROM_DATE    
)    
SELECT    
AgreementPartyTelePhoneNumberID,    
AGREEMENTPARTYID,    
TELNUM_TYPE_CODE,    
@JobID,    
@CurrDateTime,    
CONTACT_RESTRICTED_IND,    
TELNUM_FROM_DATE,    
TELNUM_THRU_DATE,    
LEFT(UNFORMATTED_TELNUM,18) As UNFRMTTD_PHONE_NUM,    
MNTC_SYSTEM_CODE,    
D.MAINTENANCESYSTEMATTRIBUTEID,    
ISNULL(TELNUM1_KEY,'N/A') AS MNTC_SYS_ATTR1_KEY,    
ISNULL(TELNUM2_KEY,'N/A') AS MNTC_SYS_ATTR2_KEY,    
ISNULL(TELNUM3_KEY,'N/A') AS MNTC_SYS_ATTR3_KEY,    
ISNULL(TELNUM6_KEY,'N/A') AS MNTC_SYS_ATTR4_KEY,    
'434',      
ADU,      
GetdatE()    
FROM       
dbo.COM_TELNUM A      
INNER JOIN GenIDBPAgreementPartyTelephoneNumber B      
ON A.TELNUM_SRC_TEXT = B.SOURCESYSTEM      
AND ISNULL(A.TELNUM1_KEY,'^') = B.SOURCESYSTEMKEY1      
AND ISNULL(A.TELNUM2_KEY,'^') = B.SOURCESYSTEMKEY2      
AND ISNULL(A.TELNUM3_KEY,'^') = B.SOURCESYSTEMKEY3      
AND ISNULL(A.TELNUM4_KEY,'^') = B.SOURCESYSTEMKEY4      
AND ISNULL(A.TELNUM5_KEY,'^') = B.SOURCESYSTEMKEY5    
AND ISNULL(A.TELNUM6_KEY,'^') = B.SOURCESYSTEMKEY6    
INNER JOIN GENIDBPAGREEMENTPARTY C      
ON A.PARTY_SRC_TEXT = C.SOURCESYSTEM      
AND ISNULL(A.PARTY1_KEY,'^') = C.SOURCESYSTEMKEY1      
AND ISNULL(A.PARTY2_KEY,'^') = C.SOURCESYSTEMKEY2      
AND ISNULL(A.PARTY3_KEY,'^') = C.SOURCESYSTEMKEY3      
AND ISNULL(A.PARTY4_KEY,'^') = C.SOURCESYSTEMKEY4      
AND ISNULL(A.PARTY5_KEY,'^') = C.SOURCESYSTEMKEY5    
INNER JOIN GENIDSPMAINTENANCESYSTEMATTRIBUTENAME D      
ON A.MNTC_SYS_ATTR_SRC_TEXT = D.SOURCESYSTEM      
AND ISNULL(A.MNTC_SYS_ATTR1_KEY,'^') = D.SOURCESYSTEMKEY1      
AND ISNULL(A.MNTC_SYS_ATTR2_KEY,'^') = D.SOURCESYSTEMKEY2      
AND ISNULL(A.MNTC_SYS_ATTR3_KEY,'^') = D.SOURCESYSTEMKEY3      
AND ISNULL(A.MNTC_SYS_ATTR4_KEY,'^') = D.SOURCESYSTEMKEY4      
WHERE A.TELNUM_ASSOC_TYPE_CODE = 'AGRMNT'      
AND A.MNTC_SYSTEM_CODE = 'TRAC';      
set nocount off      
return
GO
