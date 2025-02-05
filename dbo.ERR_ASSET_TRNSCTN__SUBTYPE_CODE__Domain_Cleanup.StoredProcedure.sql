USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[ERR_ASSET_TRNSCTN__SUBTYPE_CODE__Domain_Cleanup]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [dbo].[ERR_ASSET_TRNSCTN__SUBTYPE_CODE__Domain_Cleanup]
As
Declare

@AGREEMENT_ID NUMERIC(12), @ACCOUNTING_DATE DATETIME, @TRANSACTION_ID NUMERIC(12), 
@RepErrNo Int,
@ProcErrNo Int,
@SQL1 NVARCHAR(4000),
@Text NVARCHAR(255)

--SET @TEXT = 'osql -SSBGETL -E -Q "" -o "E:Coretrans\MCP\Domain_Cleanup\ERR_ASSET_TRNSCTN__SUBTYPE_CODE.txt" -l500 '
SET @TEXT = 'sqlcmd -SSBGETL -E -Q "" -o "E:Coretrans\MCP\Domain_Cleanup\ERR_ASSET_TRNSCTN__SUBTYPE_CODE.txt" -l500 '
EXEC MASTER..XP_CMDSHELL @TEXT, NO_OUTPUT

Create Table #Core ( AGREEMENT_ID NUMERIC(12), ACCOUNTING_DATE DATETIME, TRANSACTION_ID NUMERIC(12), SUBTYPE_CODEX VARCHAR(12) )

Declare RepErrCursor Cursor Local Fast_Forward For
Select Distinct RepErrorID
From CoreErrLog.dbo.ERR_ASSET_TRNSCTN E
Inner Join CoreErrLog.dbo.RepErrorLog R
ON E.RepErrorID = R.ErrorID 
Where ErrorSource = 'DOM'
  and ErrorMessage Like '%COR_ASSET_TRNSCTN.SUBTYPE_CODE%'

Open RepErrCursor
Fetch Next From RepErrCursor Into @RepErrNo

While (@@Fetch_Status <> -1)
Begin

	Declare ErrorCursor Cursor Local Fast_Forward For

        Select Distinct AGREEMENT_ID, ACCOUNTING_DATE, TRANSACTION_ID
	From CoreErrLog.dbo.ERR_ASSET_TRNSCTN
	Where RepErrorID = @RepErrNo

	Open ErrorCursor
        Fetch Next From ErrorCursor Into @AGREEMENT_ID, @ACCOUNTING_DATE, @TRANSACTION_ID
	While (@@Fetch_Status <> -1)
	Begin

		Set @SQL1 = 'INSERT INTO #CORE SELECT AGREEMENT_ID, ACCOUNTING_DATE, TRANSACTION_ID, SUBTYPE_CODE FROM OPENQUERY(CORE,''SELECT AGREEMENT_ID, ACCOUNTING_DATE, TRANSACTION_ID, SUBTYPE_CODE FROM COR_ASSET_TRNSCTN WHERE AGREEMENT_ID = ' + CAST(@AGREEMENT_ID AS CHAR(12))+ ' And ACCOUNTING_DATE = ''''' + CONVERT(VARCHAR(100), @ACCOUNTING_DATE,106) + ''''' And TRANSACTION_ID = ' + CAST(@TRANSACTION_ID AS CHAR(12))+ ''')'
		Exec SP_EXECUTESQL @SQL1

		Delete CoreErrLog.dbo.ERR_ASSET_TRNSCTN
		From #Core T
		Inner Join CoreErrLog.dbo.ERR_ASSET_TRNSCTN E
		On  E.RepErrorID = @RepErrNo
		And T.AGREEMENT_ID = E.AGREEMENT_ID
		And T.ACCOUNTING_DATE = E.ACCOUNTING_DATE
		And T.TRANSACTION_ID = E.TRANSACTION_ID
                Where T.AGREEMENT_ID = @AGREEMENT_ID
		  And T.ACCOUNTING_DATE = @ACCOUNTING_DATE
		  And T.TRANSACTION_ID = @TRANSACTION_ID
		  And T.SUBTYPE_CODEX Not Like 'XXXX%'

		IF @@ROWCOUNT = 1
		BEGIN

			SET @TEXT = 'ECHO AGREEMENT_ID = ' + CAST(@AGREEMENT_ID AS CHAR(12)) + ' >> E:Coretrans\MCP\Domain_Cleanup\ERR_ASSET_TRNSCTN__SUBTYPE_CODE.txt'
			EXEC MASTER..XP_CMDSHELL @TEXT, NO_OUTPUT

			SET @TEXT = 'ECHO ACCOUNTING_DATE = ' + CONVERT(VARCHAR(100), @ACCOUNTING_DATE,101) + ' >> E:Coretrans\MCP\Domain_Cleanup\ERR_ASSET_TRNSCTN__SUBTYPE_CODE.txt'
			EXEC MASTER..XP_CMDSHELL @TEXT, NO_OUTPUT

			SET @TEXT = 'ECHO TRANSACTION_ID = ' + CAST(@TRANSACTION_ID AS CHAR(12)) + ' >> E:Coretrans\MCP\Domain_Cleanup\ERR_ASSET_TRNSCTN__SUBTYPE_CODE.txt'
			EXEC MASTER..XP_CMDSHELL @TEXT, NO_OUTPUT

		End

		Truncate Table #Core

		Fetch Next From ErrorCursor Into @AGREEMENT_ID, @ACCOUNTING_DATE, @TRANSACTION_ID

	End

	Close ErrorCursor
	Deallocate ErrorCursor

	If (Select Count(*) From CoreErrLog.dbo.ERR_ASSET_TRNSCTN Where RepErrorID = @RepErrNo) = 0

		Begin

			Update CoreErrLog.dbo.RepErrorLog
			Set Status = 'C'
			Where ErrorID = @RepErrNo

		End

	Fetch Next From RepErrCursor Into @RepErrNo

End

Drop Table #Core

Close RepErrCursor
Deallocate RepErrCursor

RETURN
GO
