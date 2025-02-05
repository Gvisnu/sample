USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Create_RepErrorLog_Spreadsheet_Data]    Script Date: 12/31/2024 8:49:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[Create_RepErrorLog_Spreadsheet_Data]
AS

DECLARE

@ERRTableName      NVARCHAR(4000),
@ERRID             INT,
@SQL1              NVARCHAR(4000)

CREATE TABLE [#TEMP1] ( [ERROR_ID] INT, [ERROR_DATE] DATETIME, [ERROR_MESSAGE] VARCHAR(1000), [ERROR_COUNT] INT, [ERROR_SOURCE] VARCHAR(50), [ERROR_DETAIL] VARCHAR(50) ) 

---
-- Build cursor of errors, excluding domain errors.
---

Declare RepErrCursor Cursor Local Fast_Forward For
SELECT	DISTINCT
	dbo.fn_Err_Table(ErrorMessage),
	ErrorID
FROM CoreErrLog.dbo.RepErrorLog
WHERE (Status IS NULL OR Status <> 'C')
  AND ErrorSource <> 'DOM'
  AND ErrorMessage LIKE '% COR_%'

Open RepErrCursor
Fetch Next From RepErrCursor Into @ERRTableName, @ERRID

---
-- Build a table of RepErrorLog messages.
---

While (@@Fetch_Status <> -1)
Begin

	Set @SQL1 = N'INSERT INTO #TEMP1 SELECT ErrorID, ErrorDate, ErrorMessage, (SELECT COUNT(*) FROM CoreErrLog.dbo.' + @ERRTableName + ' WHERE RepErrorID = ' + @ERRID +'), ErrorSource, InvalidValue FROM CoreErrLog.dbo.RepErrorLog WHERE ErrorID = ' + @ERRID
	EXECUTE  sp_executesql @SQL1
	
	Fetch Next From RepErrCursor Into @ERRTableName, @ERRID

End

---
-- End of table build 
---

Close RepErrCursor
Deallocate RepErrCursor

INSERT INTO Log_Rep_Spreadsheet_Data SELECT * FROM #TEMP1

Drop Table #temp1

RETURN

GO
