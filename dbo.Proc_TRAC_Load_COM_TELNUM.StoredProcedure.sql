USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Load_COM_TELNUM]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Proc_TRAC_Load_COM_TELNUM]                    
AS      
INSERT INTO CORE1.dbo.COM_TELNUM (          
ADU,          
UNFORMATTED_TELNUM,                
SRC_CYCLE_DATE,                
TELNUM_ASSOC_TYPE_CODE,                
TELNUM_TYPE_CODE,                
RECORD_TYPE_DESC,                
MNTC_SYSTEM_CODE,                
CONTACT_RESTRICTED_IND,                
TELNUM_FROM_DATE,                
TELNUM_THRU_DATE,                
TELNUM_SRC_TEXT,                
TELNUM1_KEY,                
TELNUM2_KEY,                
TELNUM3_KEY,                
TELNUM4_KEY,                
TELNUM5_KEY,                
TELNUM6_KEY,                
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
select               
'U',                  
PHONE_NUMBER,            
NULL,          
'BUS',                  
PHONE_TYPE_CODE,              
'TRAC',        
Mntc_Sys_Code,            
--Based on MC_JobID,                      
0,                  
STARTDATE,                  
CASE WHEN ISNULL(ENDDATE,'1900-01-01') = '1900-01-01' THEN '2999-12-31' ELSE  ENDDATE END AS PHONE_THRU_DATE,
'TRAC',                  
[BusPartyPhone_Sys_Attr_Key1_Text],                  
[BusPartyPhone_Sys_Attr_Key2_Text],                  
[BusPartyPhone_Sys_Attr_Key3_Text],                  
[BusPartyPhone_Sys_Attr_Key4_Text],                  
[BusPartyPhone_Sys_Attr_Key5_Text],                  
[BusPartyPhone_Sys_Attr_Key6_Text],                  
'TRAC',                  
[BusParty_Sys_Attr_Key1_Text],                  
[BusParty_Sys_Attr_Key2_Text],                  
[BusParty_Sys_Attr_Key3_Text],                  
[BusParty_Sys_Attr_Key4_Text],                  
[BusParty_Sys_Attr_Key5_Text],                  
'TRAC',                  
'v_BusPartyPhone',              
'COR_BUS_PARTY_PHONE',              
'^',                  
'^'          
FROM dbo.TracBusPartyPhone  
GO
