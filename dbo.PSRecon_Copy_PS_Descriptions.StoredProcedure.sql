USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[PSRecon_Copy_PS_Descriptions]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[PSRecon_Copy_PS_Descriptions] @PSServerName Sysname, @PSDBName Sysname, @PSBusinessDate Varchar(80)

AS

TRUNCATE TABLE PSDLY_DST_Extracts_From_Core_GENERAL_LEDGER_DESCRIPTIONS

DECLARE @SQLString varchar(8000)

SET @SQLstring = ''

set @SQLString =
'INSERT INTO PSDLY_DST_Extracts_From_Core_GENERAL_LEDGER_DESCRIPTIONS ' +
'SELECT	T1.ACCOUNT, T1.DESCR ' +
'FROM ' + @PSServerName + '.' + @PSDBName + '.dbo.PS_GL_ACCOUNT_TBL T1 ' +
'INNER JOIN (SELECT ACCOUNT, MAX(EFFDT) AS EFFDT ' +
'	    FROM ' + @PSServerName + '.' + @PSDBName + '.dbo.PS_GL_ACCOUNT_TBL ' +
'	    GROUP BY ACCOUNT) T2 ' +
'ON  T1.ACCOUNT = T2.ACCOUNT ' +
'AND T1.EFFDT = T2.EFFDT ' +
'ORDER BY T1.ACCOUNT, T1.EFFDT '

execute(@SQLString)

GO
