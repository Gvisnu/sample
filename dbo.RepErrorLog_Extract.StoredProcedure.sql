USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[RepErrorLog_Extract]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE   PROCEDURE [dbo].[RepErrorLog_Extract]
AS

TRUNCATE TABLE LOG_RepErrors

IF @@SERVERNAME LIKE 'COREDEV%'
	BEGIN
	EXEC dbo.RepErrorLog_Spreadsheet @@SERVERNAME
	END
ELSE
IF @@SERVERNAME LIKE 'COREQA%'
	BEGIN
	EXEC dbo.RepErrorLog_Spreadsheet 'COREQA01'
	EXEC dbo.RepErrorLog_Spreadsheet 'COREQA02'
	END
ELSE
IF @@SERVERNAME LIKE 'COREPROD%'
	BEGIN
	EXEC dbo.RepErrorLog_Spreadsheet 'COREPROD01'
	EXEC dbo.RepErrorLog_Spreadsheet 'COREPROD02'
	EXEC dbo.RepErrorLog_Spreadsheet 'COREPROD03'
	END

RETURN


GO
