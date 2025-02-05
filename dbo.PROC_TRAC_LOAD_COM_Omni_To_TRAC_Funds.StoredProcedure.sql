USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[PROC_TRAC_LOAD_COM_Omni_To_TRAC_Funds]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[PROC_TRAC_LOAD_COM_Omni_To_TRAC_Funds]                 
AS            
INSERT INTO dbo.COM_Omni_To_TRAC_Funds            
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
GENIDSRCFUNDOMNI.SRC_FUND_ID AS [OMNI_COR_SRC_FUND_ID] ,
	[ICU] ,
	[DST_Ext_Price_Id] ,
	[External_Vehicle_Id] ,
GENIDSRCFUNDTRAC.SRC_FUND_ID AS [TRAC_COR_SRC_FUND_ID] ,
	[Investment_Vehicle_Long_name] ,
	[Cusip] ,
	[Share_Class] ,
	[Super_Omnibus_Account] ,
	[Vehicle_Effective_Date] ,
	[Vehicle_Close_Date] ,
	[Ticker_Symbol] ,
	[HubCode]          
          
FROM [Core1].[dbo].Omni_To_TRAC_Funds OMTF   

LEFT OUTER JOIN GenIDSRCFund  GENIDSRCFUNDOMNI ON OMTF.HubAdminChr  = GENIDSRCFUNDOMNI. SourceSystemKey1 AND 
OMTF.Omni_Fund_IV =GENIDSRCFUNDOMNI.SourceSystemKey2 AND OMTF.Pl025 = GENIDSRCFUNDOMNI.SourceSystemKey3 AND GENIDSRCFUNDOMNI. SourceSystem ='OMNI'

LEFT OUTER JOIN GenIDSRCFund  GENIDSRCFUNDTRAC  ON GENIDSRCFUNDTRAC. SourceSystemKey1 = OMTF.ICU 
AND GENIDSRCFUNDTRAC. SourceSystemKey2 = OMTF.DST_Ext_Price_ID AND GENIDSRCFUNDTRAC.SourceSystemKey3  = OMTF.PL025 AND GENIDSRCFUNDTRAC.SourceSystemKey4  = OMTF. External_Vehicle_ID
AND GENIDSRCFUNDTRAC.SourceSystem ='TRAC'
GO
