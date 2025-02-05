USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Load_AGRMNT_COM_ELCTRNC_ADDR]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Proc_TRAC_Load_AGRMNT_COM_ELCTRNC_ADDR]        
AS          
 INSERT INTO CORE1.dbo.COM_ELCTRNC_ADDR (           
 [ADU],          
 [ELCTRNC_ADDR_ASSOC_TYPE_CODE],          
 [ELCTRNC_ADDR_TYPE_CODE],          
 [RECORD_TYPE_DESC],          
 [MNTC_SYSTEM_CODE],          
 [ELCTRNC_ADDR],          
 [ELCTRNC_ADDR_FROM_DATE],          
 [ELCTRNC_ADDR_THRU_DATE],          
 [CONTACT_RESTRICTED_IND],          
 [PAYOR_KEY],          
 [ELCTRNC_ADDR_SRC_TEXT],          
 ELCTRNC_ADDR1_KEY,      
 ELCTRNC_ADDR2_KEY,      
 ELCTRNC_ADDR3_KEY,      
 ELCTRNC_ADDR4_KEY,     
 ELCTRNC_ADDR5_KEY,      
 ELCTRNC_ADDR6_KEY,      
 [MNTC_SYS_ATTR_SRC_TEXT],          
 [MNTC_SYS_ATTR1_KEY],          
 [MNTC_SYS_ATTR2_KEY],          
 [MNTC_SYS_ATTR3_KEY],          
 [MNTC_SYS_ATTR4_KEY],         
 PARTY_SRC_TEXT,       
 PARTY1_KEY,      
 PARTY2_KEY,      
 PARTY3_KEY,      
 PARTY4_KEY,      
 PARTY5_KEY        
  )          
 SELECT           
  'A',          
  'AGRMNT',--[LIT-ELEC-ADDR-ASSOC-TYPE],          
  ELCTRNC_ADDR_TYPE_CODE,          
  'TRAC', --[LIT-RECORD-TYPE-DESC],          
  'TRAC', --[LIT-SRC-SYSTEM],          
  ELCTRNC_ADDR,          
  Elctrnc_Addr_From_Date as ELCTRNC_ADDR_FROM_DATE,          
  CASE WHEN ISNULL(Elctrnc_Addr_Thru_Date ,'1900-01-01') = '1900-01-01' THEN '2999-12-31' ELSE  Elctrnc_Addr_Thru_Date  END as ELCTRNC_ADDR_THRU_DATE,
  CNTCT_RSTRCT_IND, --[LIT-CNTCT-RSTRCT-IND],          
  '',          
  'TRAC', --[LIT-RECORD-TYPE-DESC],          
  A.AgreementPartyElectrncAddress_Sys_Attr_Key1_Text,      
  A.AgreementPartyElectrncAddress_Sys_Attr_Key2_Text,      
  A.AgreementPartyElectrncAddress_Sys_Attr_Key3_Text,      
  A.AgreementPartyElectrncAddress_Sys_Attr_Key4_Text,      
  A.AgreementPartyElectrncAddress_Sys_Attr_Key5_Text,      
  A.AgreementPartyElectrncAddress_Sys_Attr_Key6_Text,        
  'TRAC', --[LIT-RECORD-TYPE-DESC],          
  'v_AgreementPartyElectronicAddress', --[LIT-VIEW-NAME],          
  'COR_AGRMNT_PARTY_ELCTRNC_ADDR', --[LIT-CORE-TABLE-NAME],          
  '^', --[LIT-NOT-APPLIC],          
  '^',--[LIT-NOT-APPLIC],        
  'TRAC'  ,      
  A.AgreementParty_Sys_Attr_Key1_Text,      
  A.AgreementParty_Sys_Attr_Key2_Text,      
  A.AgreementParty_Sys_Attr_Key3_Text,      
  A.AgreementParty_Sys_Attr_Key4_Text,      
  A.AgreementParty_Sys_Attr_Key5_Text        
FROM TRACAgrmntPartyElectronicAddress  A
GO
