USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[PSRecon_Copy_PS_Details]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[PSRecon_Copy_PS_Details] @PSServerName Sysname, @PSDBName Sysname, @PSBusinessDate Varchar(80)

AS

TRUNCATE TABLE PSRecon_PEOPLESOFT_DETAILS

DECLARE @SQLString varchar(8000)

SET @SQLstring = ''

set @SQLString =
'INSERT INTO PSRecon_PEOPLESOFT_DETAILS ' +
'SELECT	BUSINESS_UNIT , ' +
	'TRANSACTION_ID , ' +
	'TRANSACTION_LINE , ' +
	'LEDGER_GROUP , ' +
	'LEDGER , ' +
	'ACCOUNTING_DT AS ACCOUNTING_DT , ' +
	'APPL_JRNL_ID , ' +
	'BUSINESS_UNIT_GL , ' +
	'FISCAL_YEAR , ' +
	'ACCOUNTING_PERIOD , ' +
	'JOURNAL_ID , ' +
	'JOURNAL_DATE AS JOURNAL_DATE , ' +
	'JOURNAL_LINE , ' +
	'ACCOUNT , ' +
	'ALTACCT , ' +
	'DEPTID , ' +
	'OPERATING_UNIT , ' +
	'PRODUCT , ' +
	'FUND_CODE , ' +
	'CLASS_FLD , ' +
	'PROGRAM_CODE , ' +
	'BUDGET_REF , ' +
	'AFFILIATE , ' +
	'AFFILIATE_INTRA1 , ' +
	'AFFILIATE_INTRA2 , ' +
	'CHARTFIELD1 , ' +
	'CHARTFIELD2 , ' +
	'CHARTFIELD3 , ' +
	'PROJECT_ID , ' +
	'CURRENCY_CD , ' +
	'STATISTICS_CODE , ' +
	'FOREIGN_CURRENCY , ' +
	'RT_TYPE , ' +
	'RATE_MULT , ' +
	'RATE_DIV , ' +
	'MONETARY_AMOUNT , ' +
	'FOREIGN_AMOUNT , ' +
	'STATISTIC_AMOUNT , ' +
	'MOVEMENT_FLAG , ' +
	'DOC_TYPE , ' +
	'DOC_SEQ_NBR , ' +
	'DOC_SEQ_DATE AS DOC_SEQ_DATE , ' +
	'JRNL_LN_REF , ' +
	'LINE_DESCR , ' +
	'IU_SYS_TRAN_CD , ' +
	'IU_TRAN_CD , ' +
	'IU_ANCHOR_FLG , ' +
	'GL_DISTRIB_STATUS , ' +
	'PROCESS_INSTANCE ' +
'FROM ' + @PSServerName + '.' + @PSDBName + '.dbo.PS_SBG_JGEN_TEMP ' +
'WHERE ACCOUNTING_DT = ''' + @PSBusinessDate + '''' +
'  AND LINE_DESCR <> ''SUSPENSE''' +
'  AND NOT (APPL_JRNL_ID LIKE ''OMNI%'' AND LINE_DESCR LIKE ''190%'')'

execute(@SQLString)





GO
