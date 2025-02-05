USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[ERR_X_AGRMNT_INVSTMNT_SBGRP__INVSTMNT_ASSET_SRC_TYPE_CODE__Domain_Cleanup]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

Create Procedure [dbo].[ERR_X_AGRMNT_INVSTMNT_SBGRP__INVSTMNT_ASSET_SRC_TYPE_CODE__Domain_Cleanup]
As
Declare

@AGRMNT_INVSTMNT_SBGRP_ID NUMERIC(12), 
@RepErrNo Int,
@ProcErrNo Int,
@SQL1 NVARCHAR(4000),
@Text NVARCHAR(255)

SET @TEXT = 'osql -SSBGETL -E -Q "" -o "E:Coretrans\MCP\Domain_Cleanup\ERR_X_AGRMNT_INVSTMNT_SBGRP__INVSTMNT_ASSET_SRC_TYPE_CODE.txt" -l500 '
EXEC MASTER..XP_CMDSHELL @TEXT, NO_OUTPUT

Create Table #Core ( AGRMNT_INVSTMNT_SBGRP_ID NUMERIC(12), INVSTMNT_ASSET_SRC_TYPE_CODEX VARCHAR(12) )

Declare RepErrCursor Cursor Local Fast_Forward For
Select Distinct RepErrorID
From CoreErrLog.dbo.ERR_X_AGRMNT_INVSTMNT_SBGRP E
Inner Join CoreErrLog.dbo.RepErrorLog R
ON E.RepErrorID = R.ErrorID 
Where ErrorSource = 'DOM'
  and ErrorMessage Like '%COR_X_AGRMNT_INVSTMNT_SBGRP.INVSTMNT_ASSET_SRC_TYPE_CODE%'

Open RepErrCursor
Fetch Next From RepErrCursor Into @RepErrNo

While (@@Fetch_Status <> -1)
Begin

	Declare ErrorCursor Cursor Local Fast_Forward For

        Select Distinct AGRMNT_INVSTMNT_SBGRP_ID
	From CoreErrLog.dbo.ERR_X_AGRMNT_INVSTMNT_SBGRP
	Where RepErrorID = @RepErrNo

	Open ErrorCursor
        Fetch Next From ErrorCursor Into @AGRMNT_INVSTMNT_SBGRP_ID
	While (@@Fetch_Status <> -1)
	Begin

		Set @SQL1 = 'INSERT INTO #CORE SELECT AGRMNT_INVSTMNT_SBGRP_ID, INVSTMNT_ASSET_SRC_TYPE_CODE FROM OPENQUERY(CORE,''SELECT AGRMNT_INVSTMNT_SBGRP_ID, INVSTMNT_ASSET_SRC_TYPE_CODE FROM COR_X_AGRMNT_INVSTMNT_SBGRP WHERE AGRMNT_INVSTMNT_SBGRP_ID = ' + CAST(@AGRMNT_INVSTMNT_SBGRP_ID AS CHAR(12))+ ''')'
		Exec SP_EXECUTESQL @SQL1

		Delete CoreErrLog.dbo.ERR_X_AGRMNT_INVSTMNT_SBGRP
		From #Core T
		Inner Join CoreErrLog.dbo.ERR_X_AGRMNT_INVSTMNT_SBGRP E
		On  E.RepErrorID = @RepErrNo
		And T.AGRMNT_INVSTMNT_SBGRP_ID = E.AGRMNT_INVSTMNT_SBGRP_ID
                Where T.AGRMNT_INVSTMNT_SBGRP_ID = @AGRMNT_INVSTMNT_SBGRP_ID
		  And T.INVSTMNT_ASSET_SRC_TYPE_CODEX Not Like 'XXXX%'

		IF @@ROWCOUNT = 1
		BEGIN

			SET @TEXT = 'ECHO AGRMNT_INVSTMNT_SBGRP_ID = ' + CAST(@AGRMNT_INVSTMNT_SBGRP_ID AS CHAR(12)) + ' >> E:Coretrans\MCP\Domain_Cleanup\ERR_X_AGRMNT_INVSTMNT_SBGRP__INVSTMNT_ASSET_SRC_TYPE_CODE.txt'
			EXEC MASTER..XP_CMDSHELL @TEXT, NO_OUTPUT

		End

		Truncate Table #Core

		Fetch Next From ErrorCursor Into @AGRMNT_INVSTMNT_SBGRP_ID

	End

	Close ErrorCursor
	Deallocate ErrorCursor

	If (Select Count(*) From CoreErrLog.dbo.ERR_X_AGRMNT_INVSTMNT_SBGRP Where RepErrorID = @RepErrNo) = 0

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
