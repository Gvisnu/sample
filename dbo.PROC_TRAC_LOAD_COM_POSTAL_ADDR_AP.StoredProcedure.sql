USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[PROC_TRAC_LOAD_COM_POSTAL_ADDR_AP]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PROC_TRAC_LOAD_COM_POSTAL_ADDR_AP]                  
AS                
INSERT INTO COM_POSTAL_ADDR(                  
RECORD_TYPE_DESC,                  
ADDRESS_ID,                  
PLAN_NUMBER,                  
SEQ_NUMBER,                  
POSTAL_ADDR_TYPE_CODE,                  
ADDR_LINE1,                  
ADDR_LINE2,                  
ADDR_LINE3,                  
ADDR_LINE4,                  
ADDR_LINE5,                  
ADDR_LINE6,                  
COUNTRYCODE,                  
STATE_COUNTRY_CODE,                  
STATE,                  
ADU,                  
CONTACT_RESTRICTED_IND,                  
POSTALCODE,                  
POSTAL_ADDR_FROM_DATE,                  
POSTAL_ADDR_THRU_DATE,                  
SRC_CYCLE_DATE,                  
CITY,                  
MNTC_SYSTEM_CODE,                  
POSTAL_ADDR_ASSOC_TYPE_CODE,                  
POSTAL_ADDRESS_ID,                  
PAYOR_KEY,          
POSTAL_ADDR_SRC_TEXT,          
POSTAL_ADDR1_KEY,                  
POSTAL_ADDR2_KEY,                  
POSTAL_ADDR3_KEY,                  
POSTAL_ADDR4_KEY,                  
POSTAL_ADDR5_KEY,                  
POSTAL_ADDR6_KEY,                  
PARTY_SRC_TEXT,                  
PARTY1_KEY,                  
PARTY2_KEY,                  
PARTY3_KEY,                  
PARTY4_KEY,                  
PARTY5_KEY,     
PARTY6_KEY,    
MNTC_SYS_ATTR_SRC_TEXT,      
MNTC_SYS_ATTR1_KEY,      
MNTC_SYS_ATTR2_KEY,      
MNTC_SYS_ATTR3_KEY,      
MNTC_SYS_ATTR4_KEY,
MAIL_IND
)                 
SELECT                   
MNTC_SYS_CODE RECORD_TYPE_DESC,                  
'' ADDRESS_ID,                  
'' PLAN_NUMBER,                  
APPOSTALADDRESS_SYS_ATTR_KEY6_TEXT SEQ_NUMBER,                  
PSTL_ADDR_TYPE_CODE POSTAL_ADDR_TYPE_CODE,                  
ADDR_LINE1_TEXT ADDR_LINE1,                  
ADDR_LINE2_TEXT ADDR_LINE2,                  
ADDR_LINE3_TEXT ADDR_LINE3,                  
ADDR_LINE4_TEXT ADDR_LINE4,                  
'' ADDR_LINE5,                  
'' ADDR_LINE6,                  
 replace(domaincode,'N/A','') as COUNTRYCODE,                     
LTRIM(RTRIM(STATE_CODE)) [STATE_COUNTRY_CODE],                  
CASE
    WHEN STATE_CODE = '' THEN 'FN'
	ELSE LTRIM(RTRIM(STATE_CODE)) 
END AS [STATE],                  
'U' ADU,                  
CNTCT_RSTRCT_IND CONTACT_RESTRICTED_IND,                  
PSTLCD_TEXT POSTALCODE,                  
CASE WHEN PSTL_ADDR_FROM_DATE  = '0001-01-01' THEN '1900-01-01' ELSE PSTL_ADDR_FROM_DATE   END POSTAL_ADDR_FROM_DATE,                  
CASE WHEN isnull(PSTL_ADDR_THRU_DATE,'1900-01-01') = '1900-01-01' THEN '2999-12-31' ELSE PSTL_ADDR_THRU_DATE   END AS POSTAL_ADDR_THRU_DATE,                  
'' SRC_CYCLE_DATE,                  
CITY CITY,                
Mntc_Sys_Code MNTC_SYSTEM_CODE,                  
'AGRMNT' POSTAL_ADDR_ASSOC_TYPE_CODE,                  
'' POSTAL_ADDRESS_ID,                  
'' PAYOR_KEY,                  
Mntc_Sys_Code POSTAL_ADDR_SRC_TEXT,                  
APPOSTALADDRESS_SYS_ATTR_KEY1_TEXT POSTAL_ADDR1_KEY,                  
APPOSTALADDRESS_SYS_ATTR_KEY2_TEXT POSTAL_ADDR2_KEY,                  
APPOSTALADDRESS_SYS_ATTR_KEY3_TEXT POSTAL_ADDR3_KEY,                  
APPOSTALADDRESS_SYS_ATTR_KEY4_TEXT POSTAL_ADDR4_KEY,                  
APPOSTALADDRESS_SYS_ATTR_KEY5_TEXT POSTAL_ADDR5_KEY,                  
APPOSTALADDRESS_SYS_ATTR_KEY6_TEXT POSTAL_ADDR6_KEY,                  
MNTC_SYS_CODE PARTY_SRC_TEXT,                  
AGREEMENTPARTY_SYS_ATTR_KEY1_TEXT PARTY1_KEY,                  
AGREEMENTPARTY_SYS_ATTR_KEY2_TEXT PARTY2_KEY,                  
AGREEMENTPARTY_SYS_ATTR_KEY3_TEXT PARTY3_KEY,                  
AGREEMENTPARTY_SYS_ATTR_KEY4_TEXT PARTY4_KEY,                  
AGREEMENTPARTY_SYS_ATTR_KEY5_TEXT PARTY5_KEY,                  
AGREEMENTPARTY_SYS_ATTR_KEY6_TEXT PARTY6_KEY,       
MNTC_SYS_CODE MNTC_SYS_ATTR_SRC_TEXT,      
'v_AgreementPartyPostalAddress' MNTC_SYS_ATTR1_KEY,      
'COR_AGRMNT_PARTY_PSTL_ADDR' MNTC_SYS_ATTR2_KEY,      
'^' MNTC_SYS_ATTR3_KEY,      
'^' MNTC_SYS_ATTR4_KEY,
MAIL_IND            
 FROM TRACAgreementPartyPostalAddress T
left outer join prm_domainsource S on S.SourceValue = T.CNTRY_CODE and S.SystemID = 49 
and DOMAINTABLENAME = 'DOM_CNTRY'  
AND ISNULL(PARAMETERSTARTDATE,GETDATE()) <= GETDATE() AND ISNULL(PARAMETERENDDATE,'1/1/2999') > GETDATE()  
GO
