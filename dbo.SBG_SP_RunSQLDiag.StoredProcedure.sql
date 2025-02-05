USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[SBG_SP_RunSQLDiag]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[SBG_SP_RunSQLDiag]  AS


/**************************************************************************************************************/
/* This procedure will run the sqldiag utility on the CoresqlProd server for the CoreSQLProd1    */
/* instance.  It is executed from UC4 when there is an error running a job to help determine     */
/* what activity is taking place on the server at the time of job failure.  Output is stored            */
/* in the C:\WINNT\system32\CoresqlProdDiag.txt.  There is also a .trc file by the same name. */
/*         Created by Kerry Schafer 6-6-2002                                                                               */
/*************************************************************************************************************/


declare @doscmd varchar(250)
declare @result int

SELECT @doscmd = '\\coresqlprod\c$\sqldiag.exe -I CORESQLPROD1 -U sqldiag -P trace -O CoresqlProdDiag.txt'

SELECT @result = 0  --still need to put error check in
EXEC @result = master..xp_cmdshell @doscmd
RETURN
GO
