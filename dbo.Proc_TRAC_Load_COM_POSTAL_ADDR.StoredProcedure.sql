USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Load_COM_POSTAL_ADDR]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Proc_TRAC_Load_COM_POSTAL_ADDR]            
AS   

--Update TRACBUSPARTYPSTLADDR Set COUNTRY = '' where LEN(COUNTRY) > 5
          
INSERT INTO COM_POSTAL_ADDR(            
RECORD_TYPE_DESC,            
ADDRESS_ID,            
PLAN_NUMBER,            
POSTAL_ADDR_TYPE_CODE,            
ADDR_LINE1,            
ADDR_LINE2,            
ADDR_LINE3,            
ADDR_LINE4,            
ADDR_LINE5,            
ADDR_LINE6,            
COUNTRYCODE,            
--STATE_COUNTRY_CODE,            
STATE,            
ADU,            
MAIL_RETURNED_IND,            
CONTACT_RESTRICTED_IND,            
POSTALCODE,            
POSTAL_ADDR_FROM_DATE,            
MAIL_RETURNED_DATE,            
POSTAL_ADDR_THRU_DATE,            
SRC_CYCLE_DATE,            
CITY,            
MNTC_SYSTEM_CODE,            
POSTAL_ADDR_ASSOC_TYPE_CODE,            
POSTAL_ADDRESS_ID,            
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
MNTC_SYS_ATTR_SRC_TEXT,            
MNTC_SYS_ATTR1_KEY,            
MNTC_SYS_ATTR2_KEY,            
MNTC_SYS_ATTR3_KEY,            
MNTC_SYS_ATTR4_KEY)            
SELECT             
'TRAC' RECORD_TYPE_DESC,            
'' ADDRESS_ID,            
'' PLAN_NUMBER,            
ADDRESSTYPE POSTAL_ADDR_TYPE_CODE,            
Addr_Line1_Text ADDR_LINE1,            
Addr_Line2_Text ADDR_LINE2,            
Addr_Line3_Text ADDR_LINE3,            
Addr_Line4_Text ADDR_LINE4,            
NULL ADDR_LINE5,            
NULL ADDR_LINE6,            
 replace(domaincode,'N/A','') as COUNTRYCODE,            
--COUNTRY [STATE_COUNTRY_CODE],            
CASE
    WHEN ADDRESSSTATE = '' THEN 'FN'
	ELSE LTRIM(RTRIM(ADDRESSSTATE)) 
END AS [STATE],
--ADDRESSSTATE [STATE],            
'U' ADU,            
'' MAIL_RETURNED_IND,            
'' CONTACT_RESTRICTED_IND,            
PstlCD_Text POSTALCODE,            
STARTDATE POSTAL_ADDR_FROM_DATE,            
'' MAIL_RETURNED_DATE,            
ENDDATE POSTAL_ADDR_THRU_DATE,            
'' SRC_CYCLE_DATE,            
CITY CITY,          
Mntc_Sys_Code MNTC_SYSTEM_CODE,            
'BUS' POSTAL_ADDR_ASSOC_TYPE_CODE,            
'' POSTAL_ADDRESS_ID,            
Mntc_Sys_Code POSTAL_ADDR_SRC_TEXT,            
BusPartyPostalAddress_Sys_Attr_Key1_Text POSTAL_ADDR1_KEY,            
BusPartyPostalAddress_Sys_Attr_Key2_Text POSTAL_ADDR2_KEY,            
BusPartyPostalAddress_Sys_Attr_Key3_Text POSTAL_ADDR3_KEY,            
BusPartyPostalAddress_Sys_Attr_Key4_Text POSTAL_ADDR4_KEY,            
BusPartyPostalAddress_Sys_Attr_Key5_Text POSTAL_ADDR5_KEY,            
'' POSTAL_ADDR6_KEY,            
MNTC_SYS_CODE PARTY_SRC_TEXT,            
BusParty_Sys_Attr_Key1_Text PARTY1_KEY,            
BusParty_Sys_Attr_Key2_Text PARTY2_KEY,            
BusParty_Sys_Attr_Key3_Text PARTY3_KEY,            
BusParty_Sys_Attr_Key4_Text PARTY4_KEY,            
'' PARTY5_KEY,            
MNTC_SYS_CODE MNTC_SYS_ATTR_SRC_TEXT,            
'v_buspartypstladdr' MNTC_SYS_ATTR1_KEY,            
'COR_BUS_PARTY_PSTL_ADDR' MNTC_SYS_ATTR2_KEY,            
'N/A' MNTC_SYS_ATTR3_KEY,            
'N/A' MNTC_SYS_ATTR4_KEY            
FROM TRACBUSPARTYPSTLADDR T
left outer join prm_domainsource S on S.SourceValue = T.COUNTRY and S.SystemID = 49 
and DOMAINTABLENAME = 'DOM_CNTRY'  
AND ISNULL(PARAMETERSTARTDATE,GETDATE()) <= GETDATE() AND ISNULL(PARAMETERENDDATE,'1/1/2999') > GETDATE()  
  
GO
