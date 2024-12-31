USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[ERR_BUS_PARTY_PSTL_ADDR__CNTRY_CODE__Domain_Cleanup]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create Procedure [dbo].[ERR_BUS_PARTY_PSTL_ADDR__CNTRY_CODE__Domain_Cleanup]
As
Declare

@BUS_PARTY_PSTL_ADDR_ID NUMERIC(12), 
@RepErrNo Int,
@ProcErrNo Int,
@SQL1 NVARCHAR(4000),
@Text NVARCHAR(255)

--SET @TEXT = 'osql -SSBGETL -E -Q "" -o "E:Coretrans\MCP\Domain_Cleanup\ERR_BUS_PARTY_PSTL_ADDR__CNTRY_CODE.txt" -l500 '
SET @TEXT = 'sqlcmd -SSBGETL -E -Q "" -o "E:Coretrans\MCP\Domain_Cleanup\ERR_BUS_PARTY_PSTL_ADDR__CNTRY_CODE.txt" -l500 '
EXEC MASTER..XP_CMDSHELL @TEXT, NO_OUTPUT

Create Table #Core ( BUS_PARTY_PSTL_ADDR_ID NUMERIC(12), CNTRY_CODEX VARCHAR(12) )

Declare RepErrCursor Cursor Local Fast_Forward For
Select Distinct RepErrorID
From CoreErrLog.dbo.ERR_BUS_PARTY_PSTL_ADDR E
Inner Join CoreErrLog.dbo.RepErrorLog R
ON E.RepErrorID = R.ErrorID 
Where ErrorSource = 'DOM'
  and ErrorMessage Like '%COR_BUS_PARTY_PSTL_ADDR.CNTRY_CODE%'

Open RepErrCursor
Fetch Next From RepErrCursor Into @RepErrNo

While (@@Fetch_Status <> -1)
Begin

	Declare ErrorCursor Cursor Local Fast_Forward For

        Select Distinct BUS_PARTY_PSTL_ADDR_ID
	From CoreErrLog.dbo.ERR_BUS_PARTY_PSTL_ADDR
	Where RepErrorID = @RepErrNo

	Open ErrorCursor
        Fetch Next From ErrorCursor Into @BUS_PARTY_PSTL_ADDR_ID
	While (@@Fetch_Status <> -1)
	Begin

		Set @SQL1 = 'INSERT INTO #CORE SELECT BUS_PARTY_PSTL_ADDR_ID, CNTRY_CODE FROM OPENQUERY(CORE,''SELECT BUS_PARTY_PSTL_ADDR_ID, CNTRY_CODE FROM COR_BUS_PARTY_PSTL_ADDR WHERE BUS_PARTY_PSTL_ADDR_ID = ' + CAST(@BUS_PARTY_PSTL_ADDR_ID AS CHAR(12))+ ''')'
		Exec SP_EXECUTESQL @SQL1

		Delete CoreErrLog.dbo.ERR_BUS_PARTY_PSTL_ADDR
		From #Core T
		Inner Join CoreErrLog.dbo.ERR_BUS_PARTY_PSTL_ADDR E
		On  E.RepErrorID = @RepErrNo
		And T.BUS_PARTY_PSTL_ADDR_ID = E.BUS_PARTY_PSTL_ADDR_ID
                Where T.BUS_PARTY_PSTL_ADDR_ID = @BUS_PARTY_PSTL_ADDR_ID
		  And T.CNTRY_CODEX Not Like 'XXXX%'

		IF @@ROWCOUNT = 1
		BEGIN

			SET @TEXT = 'ECHO BUS_PARTY_PSTL_ADDR_ID = ' + CAST(@BUS_PARTY_PSTL_ADDR_ID AS CHAR(12)) + ' >> E:Coretrans\MCP\Domain_Cleanup\ERR_BUS_PARTY_PSTL_ADDR__CNTRY_CODE.txt'
			EXEC MASTER..XP_CMDSHELL @TEXT, NO_OUTPUT

		End

		Truncate Table #Core

		Fetch Next From ErrorCursor Into @BUS_PARTY_PSTL_ADDR_ID

	End

	Close ErrorCursor
	Deallocate ErrorCursor

	If (Select Count(*) From CoreErrLog.dbo.ERR_BUS_PARTY_PSTL_ADDR Where RepErrorID = @RepErrNo) = 0

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
