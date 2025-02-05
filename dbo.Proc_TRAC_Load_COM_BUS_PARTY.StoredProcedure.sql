USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Load_COM_BUS_PARTY]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Proc_TRAC_Load_COM_BUS_PARTY] AS                    
                    
SET NOCOUNT ON                    
SET LOCK_TIMEOUT -1                    
                    
INSERT INTO CORE1.dbo.COM_BUS_PARTY (            
[RECORD_TYPE_DESC],            
[BUS_PARTY_TYPE_CODE],            
[GENDER_CODE],            
[MARITAL_STAT_CODE],            
[PROCESSING_COMPANY_ID],            
[PERSON_NAME_PREFIX_CODE],            
[TAXID_TYPE_CODE],            
[PERSON_NAME_SUFFIX_CODE],            
[TAXID_CONFIRM_IND],            
[VIP_IND],            
[BIRTHDATE],            
[DEATH_DATE],            
[MOTHERS_MAIDEN_NAME],            
[ORG_NAME],            
[ACCESS_RSTRCTN],            
[OTHER_PARTY_NAME],            
[PERSON_FIRST_NAME],            
[PERSON_LAST_NAME],            
[PERSON_MIDDLE_NAME],            
[PERSON_PREVIOUS_LAST_NAME],            
[TAXID],            
[UNFORMATTED_PERSON_NAME],            
[MNTC_SYSTEM_CODE],            
[BUS_PARTY_SRC_TEXT],            
[BUS_PARTY1_KEY],            
[BUS_PARTY2_KEY],            
[BUS_PARTY3_KEY],            
[BUS_PARTY4_KEY],  
[BUS_PARTY5_KEY],         
[MNTC_SYS_ATTR_SRC_TEXT],            
[MNTC_SYS_ATTR1_KEY],            
[MNTC_SYS_ATTR2_KEY],            
[MNTC_SYS_ATTR3_KEY],            
[MNTC_SYS_ATTR4_KEY],          
[ADU]           
 )                    
 SELECT                     
'TRAC',            
BUS_PARTY_TYPE_CODE,            
GNDR_CODE,       
MRTL_STAT_CODE,            
PRCSSNG_CO_ID,            
PRSN_NAME_PRFX_CODE,            
TAXID_TYPE_CODE,            
PRSN_NAME_SFX_CODE,            
TAXID_CNFRM_IND,     
VIP_IND,         
BIRTH_DATE,            
DEATH_DATE,            
MTHR_MDN_NAME,            
ORG_NAME,                  
DBO.TRAC_ACCESS_RESTRICTION([ACCSS_RSTRCT_ID])  as [ACCESS_RSTRCTN],
OTHER_PARTY_NAME,                  
PRSN_FIRST_NAME,                  
PRSN_LAST_NAME,                  
PRSN_MID_NAME,                  
PRSN_PREV_LAST_NAME,           
--TAXID_NUM,
STUFF(TAXID_NUM , 1, 0, REPLICATE('0', 9 - LEN(TAXID_NUM))) as TAXID_NUM,
UNFRMTTD_PRSN_NAME,        
'TRAC' AS [MNTC_SYS_CODE],            
'TRAC' AS [BUS_PARTY_SRC_TEXT],            
[MNTC_SYS_ATTR_KEY1_TEXT] AS [BUS_PARTY1_KEY],            
[MNTC_SYS_ATTR_KEY2_TEXT] AS [BUS_PARTY2_KEY],            
[MNTC_SYS_ATTR_KEY3_TEXT] AS [BUS_PARTY3_KEY],            
[MNTC_SYS_ATTR_KEY4_TEXT] AS [BUS_PARTY4_KEY], 
[MNTC_SYS_ATTR_KEY5_TEXT] AS [BUS_PARTY5_KEY],    
'TRAC'					  AS [MNTC_SYS_ATTR_SRC_TEXT],             
'v_Busparty'			  AS [MNTC_SYS_ATTR1_KEY],            
'COR_BUS_PARTY'			  AS [MNTC_SYS_ATTR2_KEY],            
'^'						  AS [MNTC_SYS_ATTR3_KEY],             
'^'						  AS[MNTC_SYS_ATTR4_KEY],          
[ADU]          
FROM DBO.TRACBUSPARTY
GO
