USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[ERR_POSTAL_ADDR__COUNTRY_CODE__Domain_Cleanup]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

Create Procedure [dbo].[ERR_POSTAL_ADDR__COUNTRY_CODE__Domain_Cleanup]
As
Declare

@CONTACT_METHOD_ID NUMERIC(12), 
@RepErrNo Int,
@ProcErrNo Int,
@SQL1 NVARCHAR(4000),
@Text NVARCHAR(255)

SET @TEXT = 'osql -SSBGETL -E -Q "" -o "E:Coretrans\MCP\Domain_Cleanup\ERR_POSTAL_ADDR__COUNTRY_CODE.txt" -l500 '
EXEC MASTER..XP_CMDSHELL @TEXT, NO_OUTPUT

Create Table #Core ( CONTACT_METHOD_ID NUMERIC(12), COUNTRY_CODEX VARCHAR(12) )

Declare RepErrCursor Cursor Local Fast_Forward For
Select Distinct RepErrorID
From CoreErrLog.dbo.ERR_POSTAL_ADDR E
Inner Join CoreErrLog.dbo.RepErrorLog R
ON E.RepErrorID = R.ErrorID 
Where ErrorSource = 'DOM'
  and ErrorMessage Like '%COR_POSTAL_ADDR.COUNTRY_CODE%'

Open RepErrCursor
Fetch Next From RepErrCursor Into @RepErrNo

While (@@Fetch_Status <> -1)
Begin

	Declare ErrorCursor Cursor Local Fast_Forward For

        Select Distinct CONTACT_METHOD_ID
	From CoreErrLog.dbo.ERR_POSTAL_ADDR
	Where RepErrorID = @RepErrNo

	Open ErrorCursor
        Fetch Next From ErrorCursor Into @CONTACT_METHOD_ID
	While (@@Fetch_Status <> -1)
	Begin

		Set @SQL1 = 'INSERT INTO #CORE SELECT CONTACT_METHOD_ID, COUNTRY_CODE FROM OPENQUERY(CORE,''SELECT CONTACT_METHOD_ID, COUNTRY_CODE FROM COR_POSTAL_ADDR WHERE CONTACT_METHOD_ID = ' + CAST(@CONTACT_METHOD_ID AS CHAR(12))+ ''')'
		Exec SP_EXECUTESQL @SQL1

		Delete CoreErrLog.dbo.ERR_POSTAL_ADDR
		From #Core T
		Inner Join CoreErrLog.dbo.ERR_POSTAL_ADDR E
		On  E.RepErrorID = @RepErrNo
		And T.CONTACT_METHOD_ID = E.CONTACT_METHOD_ID
                Where T.CONTACT_METHOD_ID = @CONTACT_METHOD_ID
		  And T.COUNTRY_CODEX Not Like 'XXXX%'

		IF @@ROWCOUNT = 1
		BEGIN

			SET @TEXT = 'ECHO CONTACT_METHOD_ID = ' + CAST(@CONTACT_METHOD_ID AS CHAR(12)) + ' >> E:Coretrans\MCP\Domain_Cleanup\ERR_POSTAL_ADDR__COUNTRY_CODE.txt'
			EXEC MASTER..XP_CMDSHELL @TEXT, NO_OUTPUT

		End

		Truncate Table #Core

		Fetch Next From ErrorCursor Into @CONTACT_METHOD_ID

	End

	Close ErrorCursor
	Deallocate ErrorCursor

	If (Select Count(*) From CoreErrLog.dbo.ERR_POSTAL_ADDR Where RepErrorID = @RepErrNo) = 0

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
