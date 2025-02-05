USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[PROC_TRAC_POPULATE_COR_AGRMNT_PARTY_PSTL_ADDR_CDM]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[PROC_TRAC_POPULATE_COR_AGRMNT_PARTY_PSTL_ADDR_CDM]            
AS                    
DECLARE @JobID INT;                        
DECLARE @TEMPTIME DATETIME;                        
                        
SET NOCOUNT ON                        
SET XACT_ABORT ON                        
                        
SET @JobID = (SELECT isnull(MAX(JobID),0)                        
              FROM MC_JobID                        
              INNER JOIN MC_SourceFile                        
              ON MC_JobID.SourceFileID = MC_SourceFile.SourceFileID                        
              WHERE logicalName = 'TracAgreementPartyPostalAddress'              
              AND SysProcessedLogID = (SELECT MAX(SysProcessedLogID)                        
                                       FROM MC_SysProcessedLog                        
                                       WHERE SystemID = 49));                        
SET  @TEMPTIME = GETDATE();              
              
Insert into COREETL.DBO.COR_AGRMNT_PARTY_PSTL_ADDR(                    
AGRMNT_PARTY_PSTL_ADDR_ID,              
AGRMNT_PARTY_ID,              
PSTL_ADDR_TYPE_CODE,              
STATE_CODE,              
CNTRY_CODE,              
JOB_ID,              
DATETIMESTAMP,              
CNTCT_RSTRCT_IND,              
ADDR_LINE1_TEXT,              
ADDR_LINE2_TEXT,              
ADDR_LINE3_TEXT,              
ADDR_LINE4_TEXT,              
CITY,              
PSTLCD_TEXT,              
PSTL_ADDR_FROM_DATE,              
PSTL_ADDR_THRU_DATE,              
MAIL_RTRN_IND,              
MAIL_RTRN_DATE,              
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
ADU)                  
Select                     
Distinct [AgreementPartyPostalAddressID] AS AGRMNT_PARTY_PSTL_ADDR_ID,              
[AgreementPartyID] AS AGRMNT_PARTY_ID,              
[POSTAL_ADDR_TYPE_CODE] AS PSTL_ADDR_TYPE_CODE,              
CASE WHEN ISNULL ([STATE],'UNK') = '' THEN 'UNK'
ELSE [STATE] END AS STATE_CODE,              
--isnull([COUNTRYCODE] ,'USA') AS CNTRY_CODE,   -- Modifed on 10-14-2013           
--ISNULL(STATE_COUNTRY_CODE,'USA') AS CNTRY_CODE,  -- Modifed on 10-14-2013      
CASE WHEN ISNULL([COUNTRYCODE],'USA') = '' THEN 'USA'    
WHEN LTRIM(RTRIM(COUNTRYCODE)) = 'UNKNOWN COUNTRIES' THEN 'UNK'
ELSE  [COUNTRYCODE] END AS  CNTRY_CODE,      
@JobID AS JOB_ID,              
@TEMPTIME AS DATETIMESTAMP,              
isnull(CONTACT_RESTRICTED_IND,0) AS CNTCT_RSTRCT_IND,              
substring(ADDR_LINE1,1,40) AS ADDR_LINE1_TEXT,              
substring(ADDR_LINE2,1,40)  AS ADDR_LINE2_TEXT,              
substring(ADDR_LINE3,1,40)  AS ADDR_LINE3_TEXT,              
substring(ADDR_LINE4,1,40)  AS ADDR_LINE4_TEXT,              
substring(CITY,1,40)  AS CITY,              
POSTALCODE AS PSTLCD_TEXT,              
POSTAL_ADDR_FROM_DATE AS PSTL_ADDR_FROM_DATE,              
POSTAL_ADDR_THRU_DATE AS PSTL_ADDR_THRU_DATE,              
isnull(MAIL_RETURNED_IND,0) AS MAIL_RTRN_IND,              
MAIL_RETURNED_DATE AS MAIL_RTRN_DATE,              
MNTC_SYSTEM_CODE AS MNTC_SYS_CODE,              
MaintenanceSystemAttributeID AS MNTC_SYS_ATTR_ID,              
substring(POSTAL_ADDR1_KEY,1,40)  AS MNTC_SYS_ATTR_KEY1_TEXT,              
substring(POSTAL_ADDR2_KEY,1,40)  AS MNTC_SYS_ATTR_KEY2_TEXT,              
substring(POSTAL_ADDR3_KEY,1,40)  AS MNTC_SYS_ATTR_KEY3_TEXT,              
substring(POSTAL_ADDR6_KEY,1,40) AS MNTC_SYS_ATTR_KEY4_TEXT,                 
@TEMPTIME AS REC_INSRT_DATE,              
'432' AS REC_INSRT_NAME,              
@TEMPTIME AS REC_UPDT_DATE,              
'432' AS REC_UPDT_NAME,              
ADU AS ADU                
FROM COM_POSTAL_ADDR CPA              
Inner Join GenIDBPAgreementPartyPostalAddress GENIDAPP ON                     
GENIDAPP.SourceSystem = CPA.POSTAL_ADDR_SRC_TEXT                    
AND GENIDAPP.SourceSystemKey1 = CPA.POSTAL_ADDR1_KEY    
AND GENIDAPP.SourceSystemKey2 = CPA.POSTAL_ADDR2_KEY                
AND GENIDAPP.SourceSystemKey3 = CPA.POSTAL_ADDR3_KEY                
AND GENIDAPP.SourceSystemKey4 = CPA.POSTAL_ADDR4_KEY                
AND GENIDAPP.SourceSystemKey5 = CPA.POSTAL_ADDR5_KEY                
AND GENIDAPP.SourceSystemKey6 = CPA.POSTAL_ADDR6_KEY          
Inner Join GenIDBPAgreementParty GENIDAP ON              
GENIDAP.SourceSystem = CPA.PARTY_SRC_TEXT              
AND GENIDAP.SourceSystemKey1 = CPA.PARTY1_KEY              
AND GENIDAP.SourceSystemKey2 = CPA.PARTY2_KEY              
AND GENIDAP.SourceSystemKey3 = CPA.PARTY3_KEY              
AND GENIDAP.SourceSystemKey4 = CPA.PARTY4_KEY              
AND GENIDAP.SourceSystemKey5 = CPA.PARTY5_KEY 
AND GENIDAP.SourceSystemKey6 = CPA.PARTY6_KEY             
INNER JOIN dbo.GenIDSPMaintenanceSystemAttributeName              
ON CPA.MNTC_SYS_ATTR_SRC_TEXT = GenIDSPMaintenanceSystemAttributeName.SourceSystem              
AND CPA.MNTC_SYS_ATTR1_KEY = GenIDSPMaintenanceSystemAttributeName.SourceSystemKey1              
AND CPA.MNTC_SYS_ATTR2_KEY = GenIDSPMaintenanceSystemAttributeName.SourceSystemKey2              
WHERE CPA.RECORD_TYPE_DESC = 'TRAC'; 

GO
