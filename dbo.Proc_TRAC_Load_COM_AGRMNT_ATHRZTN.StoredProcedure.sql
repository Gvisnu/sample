USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Load_COM_AGRMNT_ATHRZTN]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Proc_TRAC_Load_COM_AGRMNT_ATHRZTN] AS                
                
SET NOCOUNT ON                
SET LOCK_TIMEOUT -1               
              
              
INSERT INTO [Core1].[dbo].[COM_AGRMNT_ATHRZTN]                
(                
	[MNTC_SYSTEM_CODE] ,
	agrmnt_Athrztn1_key,
	agrmnt_Athrztn2_key,
	agrmnt_Athrztn3_key,
	agrmnt_Athrztn4_key,
	agrmnt_Athrztn5_key,
	Agrmnt_Athrztn_from_date,
	Agrmnt_Athrztn_thru_date,
	Adu
)                
SELECT
	MNTC_SYS_CODE as "AGRMNT_ATHRZTN_SRC_TEXT", 
	Agrmnt_Sys_Attr_Key1_Text as "AGRMNT_ATHRZTN1_KEY",                 
	Agrmnt_sys_Attr_key2_text as "AGRMNT_ATHRZTN2_KEY",                  
	Agrmnt_Sys_Attr_Key3_Text as "AGRMNT_ATHRZTN3_KEY",                  
	Agrmnt_Sys_Attr_Key4_Text as "AGRMNT_ATHRZTN4_KEY",                  
	Agrmnt_Sys_Attr_Key5_Text as "AGRMNT_ATHRZTN5_KEY", 
	Effective_Date as "AGRMNT_ATHRZTN_FROM_DATE",                  
	Termination_Date as "AGRMNT_ATHRZTN_THRU_DATE",                   
	'U' as "ADU"                  
FROM DBO.TRACAgreementAuthorization
GO
