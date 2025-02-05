USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_ETL_Truncate_Com_Tables]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
create procedure [dbo].[Proc_ETL_Truncate_Com_Tables]
AS
--trucate the COM tables before night cycle starts.
--This proc will be executed as a first step from UC4 before the night cycle starts
Truncate table COM_AGRMNT_PARTY_ATHRZTN ; 
Truncate table COM_AGRMNT_PARTY_CMMNCTN ; 
Truncate table COM_BUS_PARTY ;   
Truncate table COM_BUS_PARTY_DSGNTN ;
Truncate table COM_ELCTRNC_ADDR ; 
Truncate table COM_INCMNG_XFER ; 
Truncate table COM_INT_RATE ; 
Truncate table COM_POSTAL_ADDR ; 
Truncate table COM_SRC_FUND_PRICE ; 
Truncate table COM_TELNUM ; 
Truncate table COM_X_BUS_PARTY_RLTNSHP ; 
Truncate table COM_X_SALES_PARTY_AGRMNT_COMM ;   
Truncate table COM_X_AGRMNT_PARTY ; 


Truncate table COM_SALES_PARTY ;
Truncate table COM_SALES_PARTY_ATHRZTN ;
Truncate table COM_SALES_PARTY_CMMNCTN ;
Truncate table COM_SALES_PARTY_LIC ;
Truncate table COM_SALES_PARTY_LIC_APPT ;
Truncate table COM_SALES_PARTY_OTHER_KEY ;
Truncate table COM_SALES_PARTY_PAY_CTRL ;
Truncate table COM_SALES_PARTY_VSTNG ;
Truncate table COM_X_SALES_PARTY_COMM_HIER ;
Truncate table COM_X_SALES_PARTY_LOB ;
Truncate table COM_X_SALES_PARTY_RPTG_HIER ;

GO
