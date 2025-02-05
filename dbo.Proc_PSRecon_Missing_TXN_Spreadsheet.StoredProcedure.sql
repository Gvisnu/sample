USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_PSRecon_Missing_TXN_Spreadsheet]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--This proc is converted from the DTS package PSRecon_Missing_TXN_Spreadsheet
CREATE PROCEDURE [dbo].[Proc_PSRecon_Missing_TXN_Spreadsheet]

AS
declare @sEnvironment as varchar(20)
declare @iCountDesc int
declare @iCountTxn int
declare @iCountDtl int
declare @Message varchar(200)
declare @subject varchar(40)


BEGIN	
	SET ANSI_NULLS  ON;
	SET ANSI_WARNINGS ON;
	SET NOCOUNT ON;


	-- Get the error logs and create an excel sheet
	EXEC USP_EXPORT_DATA_TO_EXCEL 'Core1','SELECT * FROM PRM_MSSNG_TXN_SSDATA','E:\Coretrans\PSRecon\Core_Missing_TXN_Combos.xls'


	-- send the email.
	IF @@SERVERNAME LIKE 'COREDEV%'
		set @sEnvironment='DEV'
	IF @@SERVERNAME LIKE 'COREQA%'
		set @sEnvironment='QA'
	IF @@SERVERNAME LIKE 'COREPROD%'
		set @sEnvironment='PROD'

	set @subject=@sEnvironment+' Core Transaction Descriptions'

	SET @iCountDesc = (SELECT COUNT(DISTINCT SUBSTRING(MNTC_SYSTEM_CODE,1,4)+DETAIL_TYPE_CODE+TRANSACTION_TYPE_CODE+SUBTYPE_CODE+TRANSACTION_REASON_CODE) AS CNT FROM CORE1.dbo.PRM_MSSNG_TXN_CMBNTN WHERE TRANSACTION_TYPE_CODE+SUBTYPE_CODE+TRANSACTION_REASON_CODE+DETAIL_TYPE_CODE NOT LIKE '%XXXX%')

	SET @iCountTxn = (SELECT COUNT(DISTINCT TRANSACTION_ID) AS CNT FROM CORE1.dbo.PRM_MSSNG_TXN_CMBNTN WHERE TRANSACTION_TYPE_CODE+SUBTYPE_CODE+TRANSACTION_REASON_CODE+DETAIL_TYPE_CODE NOT LIKE '%XXXX%' )

	SET @iCountDtl = (SELECT COUNT(1) AS CNT FROM CORE1.dbo.PRM_MSSNG_TXN_CMBNTN WHERE TRANSACTION_TYPE_CODE+SUBTYPE_CODE+TRANSACTION_REASON_CODE+DETAIL_TYPE_CODE NOT LIKE '%XXXX%')


	set @Message =  cast(@iCountDesc as varchar) + ' missing transaction description(s) were detected in COR_TRNSCTN_DSCRPTN and have been added.  The description(s) affect ' + cast(@iCountTxn as varchar) + ' rows in COR_ASSET_TRNSCTN and ' + cast(@iCountDtl as varchar) + ' rows in COR_TRNSCTN_DETAIL.'
	
	if(@iCountDesc > 0)
	begin
		--Exec USP_SQLEMAIL 'it-coreon-call@securitybenefit.com' ,'it-coreon-call@securitybenefit.com' , @subject,@Message, 'E:\Coretrans\PSRecon\Core_Missing_TXN_Combos.xls'
		Exec USP_SQLEMAIL 'it-coreon-call@securitybenefit.com','SP_Proc_PSRecon_Missing_TXN_Spreadsheet',@subject,@Message,'E:\Coretrans\PSRecon\Core_Missing_TXN_Combos.xls'
	end

END

GO
