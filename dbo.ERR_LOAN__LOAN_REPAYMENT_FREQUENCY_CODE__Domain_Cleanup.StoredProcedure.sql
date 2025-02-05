USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[ERR_LOAN__LOAN_REPAYMENT_FREQUENCY_CODE__Domain_Cleanup]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [dbo].[ERR_LOAN__LOAN_REPAYMENT_FREQUENCY_CODE__Domain_Cleanup]
As
Declare

@LOAN_ID NUMERIC(12), 
@RepErrNo Int,
@ProcErrNo Int,
@SQL1 NVARCHAR(4000),
@Text NVARCHAR(255)

--SET @TEXT = 'osql -SSBGETL -E -Q "" -o "E:Coretrans\MCP\Domain_Cleanup\ERR_LOAN__LOAN_REPAYMENT_FREQUENCY_CODE.txt" -l500 '
SET @TEXT = 'sqlcmd -SSBGETL -E -Q "" -o "E:Coretrans\MCP\Domain_Cleanup\ERR_LOAN__LOAN_REPAYMENT_FREQUENCY_CODE.txt" -l500 '
EXEC MASTER..XP_CMDSHELL @TEXT, NO_OUTPUT

Create Table #Core ( LOAN_ID NUMERIC(12), LOAN_REPAYMENT_FREQUENCY_CODEX VARCHAR(12) )

Declare RepErrCursor Cursor Local Fast_Forward For
Select Distinct RepErrorID
From CoreErrLog.dbo.ERR_LOAN E
Inner Join CoreErrLog.dbo.RepErrorLog R
ON E.RepErrorID = R.ErrorID 
Where ErrorSource = 'DOM'
  and ErrorMessage Like '%COR_LOAN.LOAN_REPAYMENT_FREQUENCY_CODE%'

Open RepErrCursor
Fetch Next From RepErrCursor Into @RepErrNo

While (@@Fetch_Status <> -1)
Begin

	Declare ErrorCursor Cursor Local Fast_Forward For

        Select Distinct LOAN_ID
	From CoreErrLog.dbo.ERR_LOAN
	Where RepErrorID = @RepErrNo

	Open ErrorCursor
        Fetch Next From ErrorCursor Into @LOAN_ID
	While (@@Fetch_Status <> -1)
	Begin

		Set @SQL1 = 'INSERT INTO #CORE SELECT LOAN_ID, LOAN_REPAYMENT_FREQUENCY_CODE FROM OPENQUERY(CORE,''SELECT LOAN_ID, LOAN_REPAYMENT_FREQUENCY_CODE FROM COR_LOAN WHERE LOAN_ID = ' + CAST(@LOAN_ID AS CHAR(12))+ ''')'
		Exec SP_EXECUTESQL @SQL1

		Delete CoreErrLog.dbo.ERR_LOAN
		From #Core T
		Inner Join CoreErrLog.dbo.ERR_LOAN E
		On  E.RepErrorID = @RepErrNo
		And T.LOAN_ID = E.LOAN_ID
                Where T.LOAN_ID = @LOAN_ID
		  And T.LOAN_REPAYMENT_FREQUENCY_CODEX Not Like 'XXXX%'

		IF @@ROWCOUNT = 1
		BEGIN

			SET @TEXT = 'ECHO LOAN_ID = ' + CAST(@LOAN_ID AS CHAR(12)) + ' >> E:Coretrans\MCP\Domain_Cleanup\ERR_LOAN__LOAN_REPAYMENT_FREQUENCY_CODE.txt'
			EXEC MASTER..XP_CMDSHELL @TEXT, NO_OUTPUT

		End

		Truncate Table #Core

		Fetch Next From ErrorCursor Into @LOAN_ID

	End

	Close ErrorCursor
	Deallocate ErrorCursor

	If (Select Count(*) From CoreErrLog.dbo.ERR_LOAN Where RepErrorID = @RepErrNo) = 0

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
