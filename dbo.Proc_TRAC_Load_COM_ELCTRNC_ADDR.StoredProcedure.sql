USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Load_COM_ELCTRNC_ADDR]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Proc_TRAC_Load_COM_ELCTRNC_ADDR]
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
  [ELCTRNC_ADDR1_KEY],  
  [MNTC_SYS_ATTR_SRC_TEXT],  
  [MNTC_SYS_ATTR1_KEY],  
  [MNTC_SYS_ATTR2_KEY],  
  [MNTC_SYS_ATTR3_KEY],  
  [MNTC_SYS_ATTR4_KEY],  
  [PARTY1_KEY]
  )  
 SELECT   
  [ADU],  
  'BUS',--[LIT-ELEC-ADDR-ASSOC-TYPE],  
  [ElectronicAddressTypeCode],  
  'TRAC', --[LIT-RECORD-TYPE-DESC],  
  'TRAC', --[LIT-SRC-SYSTEM],  
  [Address],  
  [FromDate],  
  [ThruDate],  
  '0', --[LIT-CNTCT-RSTRCT-IND],  
  [ElectronicAddressID],  
  'TRAC', --[LIT-RECORD-TYPE-DESC],  
  [ElectronicAddressID],  
  'TRAC', --[LIT-RECORD-TYPE-DESC],  
  'Core.v_BusPartyElectronicAddress', --[LIT-VIEW-NAME],  
  'COR_BUS_PARTY_ELCTRNC_ADDR', --[LIT-CORE-TABLE-NAME],  
  'N/A', --[LIT-NOT-APPLIC],  
  'N/A',--[LIT-NOT-APPLIC],  
  BusinessPartyID  
 FROM TRACBusPartyElecAddr
GO
