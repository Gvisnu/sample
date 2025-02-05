USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[ERR_Build_Domain_Cleanup_Objects]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ERR_Build_Domain_Cleanup_Objects]
AS
DECLARE

@CORTableName      NVARCHAR(4000),
@ERRTableName      NVARCHAR(4000),
@ERRColumn         NVARCHAR(4000),
@KeyColumn         NVARCHAR(4000),
@KeyDataType       VARCHAR(100),
@KeyDataLength     VARCHAR(10),
@KeyDataPrecision  VARCHAR(10),
@BlockK1           NVARCHAR(4000),
@BlockK2           NVARCHAR(4000),
@BlockK3           NVARCHAR(4000),
@BlockK4           NVARCHAR(4000),
@BlockK5           NVARCHAR(4000),
@BlockK6           NVARCHAR(4000),
@BlockK7           NVARCHAR(4000),
@BlockS1           NVARCHAR(4000),
@BlockS2           NVARCHAR(4000),
@BlockS3           NVARCHAR(4000),
@BlockS4           NVARCHAR(4000),
@BlockS5           NVARCHAR(4000),
@BlockS6           NVARCHAR(4000),
@BlockT1           NVARCHAR(4000),
@BlockT2           NVARCHAR(4000),
@ORASQL            NVARCHAR(4000),
@SQL1              NVARCHAR(4000),
@SQL2              NVARCHAR(4000),
@Proc_Name         NVARCHAR(4000)

CREATE TABLE [#temp1] ( [Proc_Name] VARCHAR(4000) ) 

TRUNCATE TABLE #temp1

---
-- Build cursor of domain errors.
---

Declare RepErrCursor Cursor Local Fast_Forward For
SELECT	DISTINCT
	dbo.fn_COR_Table(ErrorMessage) AS COR_TABLE_NAME,
	dbo.fn_Err_Table(ErrorMessage) AS ERR_TABLE_NAME,
	dbo.fn_Err_Column(ErrorMessage) AS ERR_COLUMN
FROM CoreErrLog.dbo.RepErrorLog
WHERE ErrorSource = 'DOM'
  AND (Status IS NULL OR Status <> 'C')

Open RepErrCursor
Fetch Next From RepErrCursor Into @CORTableName, @ERRTableName, @ERRColumn

---
-- Build a proc from each distinct domain error.
---

While (@@Fetch_Status <> -1)
Begin

CREATE TABLE [#temp2] ( [COLUMN_NAME] VARCHAR(100), [DATA_TYPE] VARCHAR(100), [DATA_LENGTH] NUMERIC(10), [DATA_PRECISION] NUMERIC(10) ) 

TRUNCATE TABLE #temp2

Set @ORASQL = N'INSERT INTO #temp2 SELECT COLUMN_NAME, DATA_TYPE, CAST(DATA_LENGTH AS CHAR(10)) AS DATA_LENGTH, CASE WHEN DATA_PRECISION IS NULL THEN ''0'' ELSE CAST(DATA_PRECISION AS CHAR(10)) END AS DATA_PRECISION FROM OPENQUERY(CORE,''SELECT ACC.COLUMN_NAME, ATC.DATA_TYPE, ATC.DATA_LENGTH, ATC.DATA_PRECISION FROM ALL_CONS_COLUMNS ACC, ALL_CONSTRAINTS AC, ALL_TAB_COLUMNS ATC WHERE ACC.OWNER = ''''SBGCORE'''' AND AC.OWNER = ''''SBGCORE'''' AND ATC.OWNER = ''''SBGCORE'''' AND ACC.TABLE_NAME = ''''' + @CORTableName + ''''' AND AC.TABLE_NAME  = ''''' + @CORTableName + ''''' AND ATC.TABLE_NAME = ''''' + @CORTableName + ''''' AND ACC.CONSTRAINT_NAME = AC.CONSTRAINT_NAME AND AC.CONSTRAINT_TYPE = ''''P'''' AND ACC.COLUMN_NAME = ATC.COLUMN_NAME'')'
EXECUTE  sp_executesql @ORASQL

Delete from #temp2 where COLUMN_NAME = @ERRColumn

DECLARE KeyCursor CURSOR FOR SELECT COLUMN_NAME, DATA_TYPE, DATA_LENGTH, DATA_PRECISION FROM #temp2

SELECT @BlockS1 = '
Create Procedure dbo.' + @ERRTableName + '__' + @ERRColumn + '__Domain_Cleanup
As
Declare

'

SET @BlockK1 = ''

OPEN KeyCursor
FETCH Next FROM KeyCursor INTO @KeyColumn, @KeyDataType, @KeyDataLength, @KeyDataPrecision
WHILE @@FETCH_STATUS=0
BEGIN
        IF @KeyDataType = 'DATE'
                BEGIN SET @SQL1 = 'DATETIME' END
        ELSE
        IF @KeyDataType = 'NUMBER'
                BEGIN SET @SQL1 = 'NUMERIC(' + @KeyDataPrecision + ')' END
        ELSE
        IF @KeyDataType = 'CHAR'
                BEGIN SET @SQL1 = 'CHAR(' + @KeyDataLength + ')' END
        ELSE
                BEGIN SET @SQL1 = 'VARCHAR(' + @KeyDataLength + ')' END
        SELECT @BlockK1 = @BlockK1 + '@' + @KeyColumn + ' ' + @SQL1 + ', '
	FETCH Next FROM KeyCursor INTO @KeyColumn, @KeyDataType, @KeyDataLength, @KeyDataPrecision
END
Close KeyCursor

SELECT @BlockS2 = '
@RepErrNo Int,
@ProcErrNo Int,
@SQL1 NVARCHAR(4000),
@Text NVARCHAR(255)

--SET @TEXT = ''osql -SSBGETL -E -Q "" -o "E:Coretrans\MCP\Domain_Cleanup\' + @ERRTableName + '__' + @ERRColumn + '.txt" -l500 ''
SET @TEXT = ''sqlcmd -SSBGETL -E -Q "" -o "E:Coretrans\MCP\Domain_Cleanup\' + @ERRTableName + '__' + @ERRColumn + '.txt" -l500 ''
EXEC MASTER..XP_CMDSHELL @TEXT, NO_OUTPUT

'

SELECT @BlockT1 = 'Create Table #Core ( '

OPEN KeyCursor
FETCH Next FROM KeyCursor INTO @KeyColumn, @KeyDataType, @KeyDataLength, @KeyDataPrecision
WHILE @@FETCH_STATUS=0
BEGIN
        IF @KeyDataType = 'DATE'
                BEGIN SET @SQL1 = 'DATETIME' END
        ELSE
        IF @KeyDataType = 'NUMBER'
                BEGIN SET @SQL1 = 'NUMERIC(' + @KeyDataPrecision + ')' END
        ELSE
        IF @KeyDataType = 'CHAR'
                BEGIN SET @SQL1 = 'CHAR(' + @KeyDataLength + ')' END
        ELSE
                BEGIN SET @SQL1 = 'VARCHAR(' + @KeyDataLength + ')' END
        SELECT @BlockT1 = @BlockT1 + @KeyColumn + ' ' + @SQL1 + ', '
	FETCH Next FROM KeyCursor INTO @KeyColumn, @KeyDataType, @KeyDataLength, @KeyDataPrecision
END
Close KeyCursor

SELECT @BlockT1 = @BlockT1 + @ERRColumn + 'X VARCHAR(12) )'

SET @BlockK2 = '

Declare RepErrCursor Cursor Local Fast_Forward For
Select Distinct RepErrorID
From CoreErrLog.dbo.' + @ERRTableName + ' E
Inner Join CoreErrLog.dbo.RepErrorLog R
ON E.RepErrorID = R.ErrorID 
Where ErrorSource = ''DOM''
  and ErrorMessage Like ''%' + @CORTableName + '.' + @ERRColumn + '%''

Open RepErrCursor
Fetch Next From RepErrCursor Into @RepErrNo

While (@@Fetch_Status <> -1)
Begin

	Declare ErrorCursor Cursor Local Fast_Forward For

        Select Distinct '
SET @SQL1 = ''

OPEN KeyCursor
FETCH Next FROM KeyCursor INTO @KeyColumn, @KeyDataType, @KeyDataLength, @KeyDataPrecision
WHILE @@FETCH_STATUS=0
BEGIN
        SELECT @BlockK2 = @BlockK2 + @SQL1 + @KeyColumn
	FETCH Next FROM KeyCursor INTO @KeyColumn, @KeyDataType, @KeyDataLength, @KeyDataPrecision
	IF @@FETCH_STATUS=0
        BEGIN
                SELECT @SQL1 = ', '
        END 
END
Close KeyCursor

SELECT @BlockS3 = '
	From CoreErrLog.dbo.' + @ERRTableName + '
	Where RepErrorID = @RepErrNo

	Open ErrorCursor
'

SET @BlockK3 = '        Fetch Next From ErrorCursor Into '
SET @SQL1 = ''

OPEN KeyCursor
FETCH Next FROM KeyCursor INTO @KeyColumn, @KeyDataType, @KeyDataLength, @KeyDataPrecision
WHILE @@FETCH_STATUS=0
BEGIN
        SELECT @BlockK3 = @BlockK3 + @SQL1 + '@' + @KeyColumn
	FETCH Next FROM KeyCursor INTO @KeyColumn, @KeyDataType, @KeyDataLength, @KeyDataPrecision
	IF @@FETCH_STATUS=0
        BEGIN
                SELECT @SQL1 = ', '
        END 
END
Close KeyCursor

SELECT @BlockS4 = '
	While (@@Fetch_Status <> -1)
	Begin

'

SELECT @BlockT2 = '		Set @SQL1 = ''INSERT INTO #CORE SELECT '
OPEN KeyCursor
FETCH Next FROM KeyCursor INTO @KeyColumn, @KeyDataType, @KeyDataLength, @KeyDataPrecision
WHILE @@FETCH_STATUS=0
BEGIN
        SELECT @BlockT2 = @BlockT2 + @KeyColumn + ', '
	FETCH Next FROM KeyCursor INTO @KeyColumn, @KeyDataType, @KeyDataLength, @KeyDataPrecision
END
Close KeyCursor

SELECT @BlockT2 = @BlockT2 + @ERRColumn + ' FROM OPENQUERY(CORE,''''SELECT '

OPEN KeyCursor
FETCH Next FROM KeyCursor INTO @KeyColumn, @KeyDataType, @KeyDataLength, @KeyDataPrecision
WHILE @@FETCH_STATUS=0
BEGIN
        SELECT @BlockT2 = @BlockT2 + @KeyColumn + ', '
	FETCH Next FROM KeyCursor INTO @KeyColumn, @KeyDataType, @KeyDataLength, @KeyDataPrecision
END
Close KeyCursor

SELECT @BlockT2 = @BlockT2 + @ERRColumn + ' FROM ' + @CORTableName + ' WHERE '

SELECT @SQL2 = ''
OPEN KeyCursor
FETCH Next FROM KeyCursor INTO @KeyColumn, @KeyDataType, @KeyDataLength, @KeyDataPrecision
WHILE @@FETCH_STATUS=0
BEGIN
        IF @KeyDataType = 'DATE'
                BEGIN SET @SQL1 = ''''''''''' + CONVERT(VARCHAR(100), @' + @KeyColumn + ',106) + ''''''''''' END
        ELSE
        IF @KeyDataType = 'NUMBER'
                BEGIN SET @SQL1 = ''' + CAST(@' + @KeyColumn + ' AS CHAR(' + @KeyDataPrecision + '))+ ''' END
        ELSE
                BEGIN SET @SQL1 = ''''''''''' + @' + @KeyColumn + ' + ''''''''''' END
        SELECT @BlockT2 = @BlockT2 + @SQL2 + @KeyColumn + ' = ' + @SQL1
	FETCH Next FROM KeyCursor INTO @KeyColumn, @KeyDataType, @KeyDataLength, @KeyDataPrecision
	IF @@FETCH_STATUS=0
        BEGIN
                SELECT @SQL2 = ' And '        END END
Close KeyCursor

SELECT @BlockT2 = @BlockT2 + ''''')'''

SET @BlockK4 = '
		Exec SP_EXECUTESQL @SQL1

		Delete CoreErrLog.dbo.' + @ERRTableName + '
		From #Core T
		Inner Join CoreErrLog.dbo.' + @ERRTableName + ' E
		On  E.RepErrorID = @RepErrNo
		And '
SET @SQL1 = ''

OPEN KeyCursor
FETCH Next FROM KeyCursor INTO @KeyColumn, @KeyDataType, @KeyDataLength, @KeyDataPrecision
WHILE @@FETCH_STATUS=0
BEGIN
        SELECT @BlockK4 = @BlockK4 + @SQL1 + 'T.' + @KeyColumn + ' = E.' + @KeyColumn
	FETCH Next FROM KeyCursor INTO @KeyColumn, @KeyDataType, @KeyDataLength, @KeyDataPrecision
	IF @@FETCH_STATUS=0
        BEGIN
                SELECT @SQL1 = '
		And '
        END 
END
Close KeyCursor

SET @BlockK5 = '
                Where '
SET @SQL1 = ''

OPEN KeyCursor
FETCH Next FROM KeyCursor INTO @KeyColumn, @KeyDataType, @KeyDataLength, @KeyDataPrecision
WHILE @@FETCH_STATUS=0
BEGIN
        SELECT @BlockK5 = @BlockK5 + @SQL1 + 'T.' + @KeyColumn + ' = @' + @KeyColumn
	FETCH Next FROM KeyCursor INTO @KeyColumn, @KeyDataType, @KeyDataLength, @KeyDataPrecision
	IF @@FETCH_STATUS=0
        BEGIN
                SELECT @SQL1 = '
		  And '
        END 
END
Close KeyCursor

SELECT @BlockS5 = '
		  And T.' + @ERRColumn + 'X Not Like ''XXXX%''

		IF @@ROWCOUNT = 1
		BEGIN
'

SET @BlockK7 = ''
SET @SQL1 = ''

OPEN KeyCursor
FETCH Next FROM KeyCursor INTO @KeyColumn, @KeyDataType, @KeyDataLength, @KeyDataPrecision
WHILE @@FETCH_STATUS=0
BEGIN
        IF @KeyDataType = 'DATE'
                BEGIN SET @SQL1 = 'CONVERT(VARCHAR(100), @' + @KeyColumn + ',101)' END
        ELSE
        IF @KeyDataType = 'NUMBER'
                BEGIN SET @SQL1 = 'CAST(@' + @KeyColumn + ' AS CHAR(' + @KeyDataPrecision + '))' END
        ELSE
                BEGIN SET @SQL1 = '@'+ @KeyColumn END
        SELECT @BlockK7 = @BlockK7 + '
			SET @TEXT = ''ECHO ' + @KeyColumn + ' = '' + ' + @SQL1 + ' + '' >> E:Coretrans\MCP\Domain_Cleanup\' + @ERRTableName + '__' + @ERRColumn + '.txt''
			EXEC MASTER..XP_CMDSHELL @TEXT, NO_OUTPUT
'
	FETCH Next FROM KeyCursor INTO @KeyColumn, @KeyDataType, @KeyDataLength, @KeyDataPrecision
END
Close KeyCursor

SET @BlockK6 = '
		End

		Truncate Table #Core

		Fetch Next From ErrorCursor Into '
SET @SQL1 = ''

OPEN KeyCursor
FETCH Next FROM KeyCursor INTO @KeyColumn, @KeyDataType, @KeyDataLength, @KeyDataPrecision
WHILE @@FETCH_STATUS=0
BEGIN
        SELECT @BlockK6 = @BlockK6 + @SQL1 + '@' + @KeyColumn
	FETCH Next FROM KeyCursor INTO @KeyColumn, @KeyDataType, @KeyDataLength, @KeyDataPrecision
	IF @@FETCH_STATUS=0
        BEGIN
                SELECT @SQL1 = ', '
        END 
END
Close KeyCursor

Deallocate KeyCursor

SELECT @BlockS6 = '

	End

	Close ErrorCursor
	Deallocate ErrorCursor

	If (Select Count(*) From CoreErrLog.dbo.' + @ERRTableName + ' Where RepErrorID = @RepErrNo) = 0

		Begin

			Update CoreErrLog.dbo.RepErrorLog
			Set Status = ''C''
			Where ErrorID = @RepErrNo

		End

	Fetch Next From RepErrCursor Into @RepErrNo

End

Drop Table #Core

Close RepErrCursor
Deallocate RepErrCursor

RETURN'

SELECT @BlockS1 = REPLACE(@BlockS1,'''','''''') 
SELECT @BlockS2 = REPLACE(@BlockS2,'''','''''') 
SELECT @BlockS3 = REPLACE(@BlockS3,'''','''''') 
SELECT @BlockS4 = REPLACE(@BlockS4,'''','''''') 
SELECT @BlockS5 = REPLACE(@BlockS5,'''','''''') 
SELECT @BlockS6 = REPLACE(@BlockS6,'''','''''') 
SELECT @BlockT1 = REPLACE(@BlockT1,'''','''''') 
SELECT @BlockT2 = REPLACE(@BlockT2,'''','''''') 
SELECT @BlockK1 = REPLACE(@BlockK1,'''','''''') 
SELECT @BlockK2 = REPLACE(@BlockK2,'''','''''') 
SELECT @BlockK3 = REPLACE(@BlockK3,'''','''''') 
SELECT @BlockK4 = REPLACE(@BlockK4,'''','''''') 
SELECT @BlockK5 = REPLACE(@BlockK5,'''','''''') 
SELECT @BlockK6 = REPLACE(@BlockK6,'''','''''') 
SELECT @BlockK7 = REPLACE(@BlockK7,'''','''''') 

SELECT @SQL2 = '
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE ID = OBJECT_ID(N''dbo.' + @ERRTableName + '__' + @ERRColumn + '__Domain_Cleanup'') AND OBJECTPROPERTY(ID, N''ISPROCEDURE'') = 1)
BEGIN DROP PROCEDURE dbo.' + @ERRTableName + '__' + @ERRColumn + '__Domain_Cleanup END'

EXEC SP_EXECUTESQL @SQL2

/*
Print 'BlockS1'
Print @BlockS1
Print 'BlockK1'
Print @BlockK1
Print 'BlockS2'
Print @BlockS2
Print 'BlockT1'
Print @BlockT1
Print 'BlockK2'
Print @BlockK2
Print 'BlockS3'
Print @BlockS3
Print 'BlockK3'
Print @BlockK3
Print 'BlockS4'
Print @BlockS4
Print 'BlockT2'
Print @BlockT2
Print 'BlockK4'
Print @BlockK4
Print 'BlockK5'
Print @BlockK5
Print 'BlockS5'
Print @BlockS5
Print 'BlockK7'
Print @BlockK7
Print 'BlockK6'
Print @BlockK6
Print 'BlockS6'
Print @BlockS6
*/

EXEC (N'EXEC SP_EXECUTESQL N''' + @BlockS1 + @BlockK1 + @BlockS2 + @BlockT1 + @BlockK2 + @BlockS3 + @BlockK3 + @BlockS4 + @BlockT2 + @BlockK4 + @BlockK5 + @BlockS5 + @BlockK7 + @BlockK6 + @BlockS6 + '''')

Drop Table [#temp2]

Select @SQL2 = N'INSERT INTO #temp1 (Proc_Name) Values (N''dbo.' + @ERRTableName + '__' + @ERRColumn + '__Domain_Cleanup'')'
EXECUTE  sp_executesql @SQL2

Fetch Next From RepErrCursor Into @CORTableName, @ERRTableName, @ERRColumn

End

---
-- End of proc building 
---

Close RepErrCursor
Deallocate RepErrCursor

---
-- Build a cursor of Proc names and execute them.
---

Declare ExecCursor Cursor Local Fast_Forward For
SELECT Proc_Name FROM #temp1

Open ExecCursor
Fetch Next From ExecCursor Into @Proc_Name

While (@@Fetch_Status <> -1)
Begin

	Select @SQL2 = N'Exec ' + @Proc_Name
	EXECUTE  sp_executesql @SQL2

	Fetch Next From ExecCursor Into @Proc_Name

End

Close ExecCursor
Deallocate ExecCursor

Drop Table #temp1

RETURN



GO
