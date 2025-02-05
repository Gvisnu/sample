USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Load_COM_X_AGRMNT_PARTY_AOS]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[Proc_TRAC_Load_COM_X_AGRMNT_PARTY_AOS] AS                  
                  
SET NOCOUNT ON                  
SET LOCK_TIMEOUT -1                 
            	    
                
INSERT INTO [Core1].[dbo].[COM_X_AGRMNT_PARTY_AOS]                
   (                
 [AGRMNT_PARTY_FROM_DATE]                
   ,[AGRMNT_PARTY_PCT]                
   ,[AGRMNT_PARTY_ROLE_TYPE_CODE]    
   ,[AGRMNT_PARTY_STAT_CODE]    
   ,[AGRMNT_PARTY_THRU_DATE]                
   ,[RECORD_TYPE_DESC]                
   ,[MNTC_SYSTEM_CODE]                
   ,[ADU]                
   ,[ACCESS_RSTRCTN]                
   ,[BUS_PARTY_SRC_TEXT]                
   ,[BUS_PARTY1_KEY]                
   ,[BUS_PARTY2_KEY]                
   ,[BUS_PARTY3_KEY]                
   ,[BUS_PARTY4_KEY]  
   ,[BUS_PARTY5_KEY]     
   ,[AGRMNT_PARTY_SRC_TEXT]                
   ,[AGRMNT_PARTY1_KEY]                
   ,[AGRMNT_PARTY2_KEY]                
   ,[AGRMNT_PARTY3_KEY]                
   ,[AGRMNT_PARTY4_KEY]                
   ,[AGRMNT_PARTY5_KEY]                
   ,[AGRMNT_PARTY6_KEY]      
   ,[AGRMNT_SRC_TEXT]                
   ,[AGRMNT1_KEY]                
   ,[AGRMNT2_KEY]                
   ,[AGRMNT3_KEY]                
   ,[AGRMNT4_KEY]         
   ,[MNTC_SYS_ATTR_SRC_TEXT]                
   ,[MNTC_SYS_ATTR1_KEY]                
   ,[MNTC_SYS_ATTR2_KEY]                
   ,[MNTC_SYS_ATTR3_KEY]           
   ,[MNTC_SYS_ATTR4_KEY]          
)                
Select                   
 FROMDATE as "AGRMNT_PARTY_FROM_DATE",                  
 PERCENTAGE as "AGRMNT_PARTY_PCT",                   
 ROLEID as "AGRMNT_PARTY_ROLE_TYPE_CODE",     
 --CASE AgreementParty_Sys_Attr_Key4_Text    
 -- WHEN 'PRIM OWNER' THEN Agrmnt_Party_Stat_Code    
 -- WHEN 'PRIM PART' THEN 'ACT'    
 --END AS "AGRMNT_PARTY_STAT_CODE",               
 Agrmnt_Party_Stat_Code,  
 CASE WHEN ISNULL(EndDATE,'1900-01-01 00:00:00.000') = '1900-01-01 00:00:00.000' THEN '2999-12-31 00:00:00.000' ELSE  ENDDATE END as "AGRMNT_PARTY_THRU_DATE",                   
 MNTC_SYS_CODE as "RECORD_TYPE_DESC",                   
 MNTC_SYS_CODE as "MNTC_SYSTEM_CODE",                   
 'U' as "ADU",                  
 DBO.TRAC_ACCESS_RESTRICTION([ACCSS_RSTRCT_ID])  as "ACCESS_RSTRCTN",                  
 MNTC_SYS_CODE as "BUS_PARTY_SRC_TEXT",                 
 BusParty_Sys_Attr_Key1_Text  as "BUS_PARTY1_KEY",                 
 BusParty_Sys_Attr_Key2_Text  as "BUS_PARTY2_KEY",                 
 BusParty_Sys_Attr_Key3_Text  as "BUS_PARTY3_KEY",                 
 BusParty_Sys_Attr_Key4_Text  as "BUS_PARTY4_KEY",   
 BusParty_Sys_Attr_Key5_Text  as "BUS_PARTY5_KEY",   
 MNTC_SYS_CODE as "AGRMNT_PARTY_SRC_TEXT",                  
 AgreementParty_Sys_Attr_Key1_Text as "AGRMNT_PARTY1_KEY",                 
 AgreementParty_Sys_Attr_Key2_Text as "AGRMNT_PARTY2_KEY",                  
 AgreementParty_Sys_Attr_Key3_Text as "AGRMNT_PARTY3_KEY",                  
 AgreementParty_Sys_Attr_Key4_Text as "AGRMNT_PARTY4_KEY",                  
 AgreementParty_Sys_Attr_Key5_Text as "AGRMNT_PARTY5_KEY",   
 AgreementParty_Sys_Attr_Key6_Text as "AGRMNT_PARTY6_KEY",            
 MNTC_SYS_CODE as "AGRMNT_SRC_TEXT",                  
 Agreement_Sys_Attr_Key1_Text as "AGRMNT1_KEY",                 
 Agreement_Sys_Attr_Key2_Text as "AGRMNT2_KEY",                  
 Agreement_Sys_Attr_Key3_Text as "AGRMNT3_KEY",                  
 Agreement_Sys_Attr_Key4_Text as "AGRMNT4_KEY",          
 MNTC_SYS_CODE as "MNTC_SYS_ATTR_SRC_TEXT",                  
 'v_Agreementparty' as "MNTC_SYS_ATTR1_KEY",                 
 'COR_X_AGRMNT_PARTY' as "MNTC_SYS_ATTR2_KEY",          
 '^' as "MNTC_SYS_ATTR3_KEY",          
 '^' as "MNTC_SYS_ATTR4_KEY"           
FROM dbo.TRACAgreementParty_AOS  
GO
