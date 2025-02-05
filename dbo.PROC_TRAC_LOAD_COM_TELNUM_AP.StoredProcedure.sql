USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[PROC_TRAC_LOAD_COM_TELNUM_AP]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PROC_TRAC_LOAD_COM_TELNUM_AP] AS    
  
SET NOCOUNT ON    
SET LOCK_TIMEOUT -1    
BEGIN    
 INSERT INTO CORE1.dbo.COM_TELNUM (    
  [ADU],    
  [UNFORMATTED_TELNUM],    
  [SRC_CYCLE_DATE],    
  [TELNUM_ASSOC_TYPE_CODE],    
  [TELNUM_TYPE_CODE],    
  [RECORD_TYPE_DESC],    
  [MNTC_SYSTEM_CODE],    
  [CONTACT_RESTRICTED_IND],    
  [TELNUM_FROM_DATE],    
  [TELNUM_THRU_DATE],    
  [TELNUM_SRC_TEXT],    
  [TELNUM1_KEY],    
  [TELNUM2_KEY],    
  [TELNUM3_KEY],    
  [TELNUM4_KEY],   
  [TELNUM5_KEY],  
  [TELNUM6_KEY],  
  [PARTY_SRC_TEXT],    
  [PARTY1_KEY],    
  [PARTY2_KEY],    
  [PARTY3_KEY],   
  [PARTY4_KEY],  
  [PARTY5_KEY],  
  [MNTC_SYS_ATTR_SRC_TEXT],    
  [MNTC_SYS_ATTR1_KEY],    
  [MNTC_SYS_ATTR2_KEY])    
 SELECT     
  'U',    
  UNFRMTTD_PHONE_NUM,    
  GETDATE(),    
  'AGRMNT' [TELNUM_ASSOC_TYPE_CODE],    
  'HTELE' [TELNUM_TYPE_CODE],    
  'AI' [RECORD_TYPE_DESC],    
  MNTC_SYS_CODE [MNTC_SYSTEM_CODE],    
  0 [CONTACT_RESTRICTED_IND],    
  PHONE_FROM_DATE,  
  CASE WHEN ISNULL(PHONE_THRU_DATE,'1900-01-01') = '1900-01-01' THEN '2999-12-31' ELSE  PHONE_THRU_DATE END AS PHONE_THRU_DATE,  
  MNTC_SYS_CODE [TELNUM_SRC_TEXT],    
  APPhone_Sys_Attr_Key1_Text  [TELNUM1_KEY],   
  APPhone_Sys_Attr_Key2_Text  [TELNUM2_KEY],   
  APPhone_Sys_Attr_Key3_Text  [TELNUM3_KEY],    
  APPhone_Sys_Attr_Key4_Text  [TELNUM4_KEY],   
  APPhone_Sys_Attr_Key5_Text  [TELNUM5_KEY],  
  APPhone_Sys_Attr_Key6_Text  [TELNUM6_KEY],  
  MNTC_SYS_CODE [PARTY_SRC_TEXT],    
  AgreementParty_Sys_Attr_Key1_Text  [PARTY1_KEY],   
  AgreementParty_Sys_Attr_Key2_Text  [PARTY2_KEY],    
  AgreementParty_Sys_Attr_Key3_Text  [PARTY3_KEY],   
  AgreementParty_Sys_Attr_Key4_Text  [PARTY4_KEY],  
  AgreementParty_Sys_Attr_Key5_Text  [PARTY5_KEY],  
  MNTC_SYS_CODE [MNTC_SYS_ATTR_SRC_TEXT],    
  'v_AgreementPartyPhone' [LIT-SRC-ENT-NAME],    
  'COR_AGRMNT_PARTY_PHONE' [LIT-ATTRID-TAB]    
 FROM DBO.TRACAgreementPartyPhone    
RETURN    
END    
GO
