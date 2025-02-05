USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_TRAC_Populate_Omni_To_TRAC_Funds]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[Proc_TRAC_Populate_Omni_To_TRAC_Funds]                 
AS            
INSERT INTO COREETL.dbo.Omni_To_TRAC_Funds            
(            
	[HubAdminChr] ,
	[Omni_Fund_IV] ,
	[PL025],
	[OMNI_COR_SRC_FUND_ID] ,
	[ICU] ,
	[DST_Ext_Price_Id] ,
	[External_Vehicle_Id] ,
	[TRAC_COR_SRC_FUND_ID] ,
	[Investment_Vehicle_Long_name] ,
	[Cusip] ,
	[Share_Class] ,
	[Super_Omnibus_Account] ,
	[Vehicle_Effective_Date] ,
	[Vehicle_Close_Date] ,
	[Ticker_Symbol] ,
	[HubCode]           
)            
                  
SELECT            
  
  [HubAdminChr] ,
	[Omni_Fund_IV] ,
	[PL025],
	[OMNI_COR_SRC_FUND_ID] ,
	[ICU] ,
	[DST_Ext_Price_Id] ,
	[External_Vehicle_Id] ,
	[TRAC_COR_SRC_FUND_ID] ,
	[Investment_Vehicle_Long_name] ,
	[Cusip] ,
	[Share_Class] ,
	[Super_Omnibus_Account] ,
	[Vehicle_Effective_Date] ,
	[Vehicle_Close_Date] ,
	[Ticker_Symbol] ,
	[HubCode]   
FROM [Core1].[dbo].COM_Omni_To_TRAC_Funds
GO
