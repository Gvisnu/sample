USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[PROC_TRAC_LOAD_COM_SRC_FUND_PRICE]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[PROC_TRAC_LOAD_COM_SRC_FUND_PRICE]               
AS          
INSERT INTO COM_SRC_FUND_PRICE          
(          
 [SRC_FUND1_KEY]    
 ,[PRICE_DATE]          
 ,[UNIT_VAL_PRICE_AMT]          
 ,[DAILY_DIV_AMT]          
 ,[ADU]          
 ,[MNTC_SYSTEM_CODE]          
 ,[SRC_FUND_PRICE_SRC_TEXT]          
)          
                
SELECT          
[SRC_SYS_ATTR_KEY1_TEXT],        
[PriceDate],        
[UNIT_VAL_PRICE_AMT],        
[DAILY_DIV_AMT],        
[ADU],        
[MNTC_SYS_CODE],        
'TRAC'        
FROM [Core1].[dbo].TRACSrcFundPrice
GO
