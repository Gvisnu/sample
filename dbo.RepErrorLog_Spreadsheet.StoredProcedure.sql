USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[RepErrorLog_Spreadsheet]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO




CREATE    PROCEDURE [dbo].[RepErrorLog_Spreadsheet] (@SourceServer VARCHAR(10))
AS

DECLARE

@ERRTableName      NVARCHAR(4000),
@ERRID             INT,
@SQL1              NVARCHAR(4000)

CREATE TABLE [#TEMP1] ( [ErrorID] INT NULL, [ErrorMessage] VARCHAR(1000) NULL, [ETWErrorID] INT NULL, [Status] CHAR(1)  NULL) 
CREATE TABLE [#TEMP2] ( [ERROR_ID] INT NULL, [ERROR_DATE] DATETIME NULL, [ERROR_MESSAGE] VARCHAR(1000) NULL, [ERROR_COUNT] INT NULL, [ERROR_SOURCE] VARCHAR(50) NULL, [ERROR_DETAIL] VARCHAR(100)  NULL) 

---
-- Build cursor of errors, excluding domain errors.
---

Set @SQL1 =
N'INSERT INTO #TEMP1
SELECT DISTINCT ErrorID, ErrorMessage, ETWErrorID, Status
FROM ' + @SourceServer + '.CoreErrLog.dbo.RepErrorLog
WHERE (Status IS NULL OR Status <> ''C'')
  AND ETWErrorID IS NULL
  AND ErrorMessage LIKE ''% COR_%'''

EXECUTE  sp_executesql @SQL1

Declare RepErrCursor Cursor Local Fast_Forward For
SELECT	DISTINCT
	dbo.fn_Err_Table(ErrorMessage),
	ErrorID
FROM #TEMP1

Open RepErrCursor
Fetch Next From RepErrCursor Into @ERRTableName, @ERRID

---
-- Build a table of RepErrorLog messages.
---

While (@@Fetch_Status <> -1)
Begin

	Set @SQL1 = N'INSERT INTO #TEMP2 SELECT ErrorID, ErrorDate, ErrorMessage, (SELECT COUNT(*) FROM ' + @SourceServer + '.CoreErrLog.dbo.' + @ERRTableName + ' WHERE RepErrorID = ' + CAST(@ERRID AS CHAR(10)) +'), System, AccountNbr FROM ' + @SourceServer + '.CoreErrLog.dbo.RepErrorLog WHERE ErrorID = ' + CAST(@ERRID AS CHAR(10))

	EXECUTE sp_executesql @SQL1
	
	Fetch Next From RepErrCursor Into @ERRTableName, @ERRID

End

---
-- End of table build 
---

Close RepErrCursor
Deallocate RepErrCursor

INSERT INTO LOG_RepErrors SELECT * FROM #TEMP2

Drop Table #temp1
Drop Table #temp2

RETURN
GO
