USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[ERR_AGRMNT__MARKET_SEGMENT_CODE__Domain_Cleanup]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [dbo].[ERR_AGRMNT__MARKET_SEGMENT_CODE__Domain_Cleanup]
As
Declare

@AGREEMENT_ID NUMERIC(12), 
@RepErrNo Int,
@ProcErrNo Int,
@SQL1 NVARCHAR(4000),
@Text NVARCHAR(255)

--SET @TEXT = 'osql -SSBGETL -E -Q "" -o "E:Coretrans\MCP\Domain_Cleanup\ERR_AGRMNT__MARKET_SEGMENT_CODE.txt" -l500 '
SET @TEXT = 'sqlcmd -SSBGETL -E -Q "" -o "E:Coretrans\MCP\Domain_Cleanup\ERR_AGRMNT__MARKET_SEGMENT_CODE.txt" -l500 '
EXEC MASTER..XP_CMDSHELL @TEXT, NO_OUTPUT

Create Table #Core ( AGREEMENT_ID NUMERIC(12), MARKET_SEGMENT_CODEX VARCHAR(12) )

Declare RepErrCursor Cursor Local Fast_Forward For
Select Distinct RepErrorID
From CoreErrLog.dbo.ERR_AGRMNT E
Inner Join CoreErrLog.dbo.RepErrorLog R
ON E.RepErrorID = R.ErrorID 
Where ErrorSource = 'DOM'
  and ErrorMessage Like '%COR_AGRMNT.MARKET_SEGMENT_CODE%'

Open RepErrCursor
Fetch Next From RepErrCursor Into @RepErrNo

While (@@Fetch_Status <> -1)
Begin

	Declare ErrorCursor Cursor Local Fast_Forward For

        Select Distinct AGREEMENT_ID
	From CoreErrLog.dbo.ERR_AGRMNT
	Where RepErrorID = @RepErrNo

	Open ErrorCursor
        Fetch Next From ErrorCursor Into @AGREEMENT_ID
	While (@@Fetch_Status <> -1)
	Begin

		Set @SQL1 = 'INSERT INTO #CORE SELECT AGREEMENT_ID, MARKET_SEGMENT_CODE FROM OPENQUERY(CORE,''SELECT AGREEMENT_ID, MARKET_SEGMENT_CODE FROM COR_AGRMNT WHERE AGREEMENT_ID = ' + CAST(@AGREEMENT_ID AS CHAR(12))+ ''')'
		Exec SP_EXECUTESQL @SQL1

		Delete CoreErrLog.dbo.ERR_AGRMNT
		From #Core T
		Inner Join CoreErrLog.dbo.ERR_AGRMNT E
		On  E.RepErrorID = @RepErrNo
		And T.AGREEMENT_ID = E.AGREEMENT_ID
                Where T.AGREEMENT_ID = @AGREEMENT_ID
		  And T.MARKET_SEGMENT_CODEX Not Like 'XXXX%'

		IF @@ROWCOUNT = 1
		BEGIN

			SET @TEXT = 'ECHO AGREEMENT_ID = ' + CAST(@AGREEMENT_ID AS CHAR(12)) + ' >> E:Coretrans\MCP\Domain_Cleanup\ERR_AGRMNT__MARKET_SEGMENT_CODE.txt'
			EXEC MASTER..XP_CMDSHELL @TEXT, NO_OUTPUT

		End

		Truncate Table #Core

		Fetch Next From ErrorCursor Into @AGREEMENT_ID

	End

	Close ErrorCursor
	Deallocate ErrorCursor

	If (Select Count(*) From CoreErrLog.dbo.ERR_AGRMNT Where RepErrorID = @RepErrNo) = 0

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
