USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_PSRecon_TXN_Error_Spreadsheet]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--This proc is converted from the DTS package PSRecon_TXN_Error_Spreadsheet
CREATE PROCEDURE [dbo].[Proc_PSRecon_TXN_Error_Spreadsheet]

AS
declare @sEnvironment as varchar(20)
declare @iCount int
declare @Message varchar(200)
declare @subject varchar(40)


BEGIN	
	SET ANSI_NULLS  ON;
	SET ANSI_WARNINGS ON;
	SET NOCOUNT ON;


	-- Get the error logs and create an excel sheet
	EXEC USP_EXPORT_DATA_TO_EXCEL 'Core1','SELECT * FROM PRM_MSSNG_TXN_ERRORS','E:\Coretrans\PSRecon\Core_TXN_Errors.xls'


	-- send the email.
	IF @@SERVERNAME LIKE 'COREDEV%'
		set @sEnvironment='DEV'
	IF @@SERVERNAME LIKE 'COREQA%'
		set @sEnvironment='QA'
	IF @@SERVERNAME LIKE 'COREPROD%'
		set @sEnvironment='PROD'

	set @subject=@sEnvironment+' Core Transaction Type Errors'

	SET @iCount = (SELECT COUNT(*) AS CNT FROM Core1.dbo.PRM_MSSNG_TXN_CMBNTN WHERE TRANSACTION_TYPE_CODE+SUBTYPE_CODE+TRANSACTION_REASON_CODE+DETAIL_TYPE_CODE LIKE '%XXXX%' )

	set @Message =  cast(@iCount as varchar) + ' transaction type error(s) were detected in COR_ASSET_TRNSCTN and/or COR_TRNSCTN_DETAIL.'
	
	if(@iCount > 0)
	begin
		--Exec USP_SQLEMAIL 'it-coreon-call@securitybenefit.com' ,'it-coreon-call@securitybenefit.com' , @subject,@Message, 'E:\Coretrans\PSRecon\Core_TXN_Errors.xls'
		Exec USP_SQLEMAIL 'it-coreon-call@securitybenefit.com','SP_Proc_PSRecon_TXN_Error_Spreadsheet',@subject,@Message,'E:\Coretrans\PSRecon\Core_TXN_Errors.xls'		
	end

END

GO
