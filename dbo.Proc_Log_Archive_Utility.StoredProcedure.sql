USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_Log_Archive_Utility]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


/* This stored procedure is created to replace the DTS package Log_Archive_Utility.*/
/* 07/31/2008 - Kamal  */
CREATE PROCEDURE [dbo].[Proc_Log_Archive_Utility]
AS

begin
	set ANSI_NULLS on;
	set ANSI_WARNINGS on;
	set nocount on;
	set XACT_ABORT on;

	--Archive MC_Segment
	INSERT INTO [dbo].[MC_Segment_Hstry]
	([StartDateTimeStamp], 
	[EndDateTimeStamp], 
	[SegmentInstance], 
	[Completed], 
	[SourceFileID], 
	[SegmentID], 
	[Segment], 
	[RecordsProcessed], 
	[SysProcessedLogID],
	[ArchiveDateTimeStamp]
	)
	select [StartDateTimeStamp], 
	[EndDateTimeStamp], 
	[SegmentInstance], 
	[Completed], 
	[SourceFileID], 
	[SegmentID], 
	[Segment], 
	[RecordsProcessed], 
	[SysProcessedLogID],
	getdate()
	from [dbo].[MC_Segment]
	where [EndDateTimestamp] < (select getdate() - 30)
	and [SegmentID] not in (select [SegmentID] from [MC_Segment_Hstry]);

	--Remove Archived Rows From MC_Segment
	delete from [dbo].[MC_Segment]
	where [SegmentID] in (select [SegmentID] from [MC_Segment_Hstry]);

	--Archive MC_SysProcessedLog
	INSERT INTO [dbo].[MC_SysProcessedLog_Hstry]
	([SysProcessedLogID] ,
	[SystemID] ,
	[CycleDate] ,
	[Started] ,
	[StartDateTimeStamp] ,
	[Finished] ,
	[EndDateTimeStamp] ,
	[ArchiveDateTimeStamp]
	)
	select [SysProcessedLogID] ,
	[SystemID] ,
	[CycleDate] ,
	[Started] ,
	[StartDateTimeStamp] ,
	[Finished] ,
	[EndDateTimeStamp] ,
	getdate()
	from [MC_SysProcessedLog]
	where [EndDateTimestamp] < (select getdate() - 30)
	and [SysProcessedLogID] not in (select [SysProcessedLogID] from [MC_SysProcessedLog_Hstry]);

	--Remove Archived Rows From MC_SysProcessedLog
	delete from [MC_SysProcessedLog]
	where [SysProcessedLogID] in (select [SysProcessedLogID] from [MC_SysProcessedLog_Hstry]);

	--Validate Domain Errors
	EXEC ERR_Build_Domain_Cleanup_Objects;

	-- Close Fund ID Errors
	UPDATE COREERRLOG.DBO.REPERRORLOG SET Status = 'C'
	FROM COREERRLOG.DBO.REPERRORLOG
	LEFT OUTER JOIN COREERRLOG.DBO.ERR_ASSET_REALLOCTN ON ErrorID = RepErrorID
	WHERE ERRORMESSAGE LIKE      '%COR_ASSET_REALLOCTN DUE TO A SRC_FUND_ID OF 999999999' AND RepErrorID IS NULL;

	UPDATE COREERRLOG.DBO.REPERRORLOG SET Status = 'C'
	FROM COREERRLOG.DBO.REPERRORLOG
	LEFT OUTER JOIN COREERRLOG.DBO.ERR_ASSET_SOURCE_DETAIL ON ErrorID = RepErrorID
	WHERE ERRORMESSAGE LIKE      '%COR_ASSET_SOURCE_DETAIL DUE TO A SRC_FUND_ID OF 999999999' AND RepErrorID IS NULL;
	
	UPDATE COREERRLOG.DBO.REPERRORLOG SET Status = 'C'
	FROM COREERRLOG.DBO.REPERRORLOG
	LEFT OUTER JOIN COREERRLOG.DBO.ERR_AUTO_WTHDRWL_BY_VEH ON ErrorID = RepErrorID
	WHERE ERRORMESSAGE LIKE      '%COR_AUTO_WTHDRWL_BY_VEH DUE TO A SRC_FUND_ID OF 999999999' AND RepErrorID IS NULL;
	
	UPDATE COREERRLOG.DBO.REPERRORLOG SET Status = 'C'
	FROM COREERRLOG.DBO.REPERRORLOG
	LEFT OUTER JOIN COREERRLOG.DBO.ERR_DOLLAR_COST_AVG ON ErrorID = RepErrorID
	WHERE ERRORMESSAGE LIKE      '%COR_DOLLAR_COST_AVG DUE TO A SRC_FUND_ID OF 999999999' AND RepErrorID IS NULL;
	
	UPDATE COREERRLOG.DBO.REPERRORLOG SET Status = 'C'
	FROM COREERRLOG.DBO.REPERRORLOG
	LEFT OUTER JOIN COREERRLOG.DBO.ERR_DOLLAR_COST_AVRG_TO_FUND ON ErrorID = RepErrorID
	WHERE ERRORMESSAGE LIKE      '%COR_DOLLAR_COST_AVRG_TO_FUND DUE TO A SRC_FUND_ID OF 999999999' AND RepErrorID IS NULL;
	
	UPDATE COREERRLOG.DBO.REPERRORLOG SET Status = 'C'
	FROM COREERRLOG.DBO.REPERRORLOG
	LEFT OUTER JOIN COREERRLOG.DBO.ERR_FIXED_ASSET_SRC_DTL ON ErrorID = RepErrorID
	WHERE ERRORMESSAGE LIKE      '%COR_FIXED_ASSET_SRC_DTL DUE TO A SRC_FUND_ID OF 999999999' AND RepErrorID IS NULL;
	
	UPDATE COREERRLOG.DBO.REPERRORLOG SET Status = 'C'
	FROM COREERRLOG.DBO.REPERRORLOG
	LEFT OUTER JOIN COREERRLOG.DBO.ERR_INT_RATE_PORT ON ErrorID = RepErrorID
	WHERE ERRORMESSAGE LIKE      '%COR_INT_RATE_PORT DUE TO A SRC_FUND_ID OF 999999999' AND RepErrorID IS NULL;

	UPDATE COREERRLOG.DBO.REPERRORLOG SET Status = 'C'
	FROM COREERRLOG.DBO.REPERRORLOG
	LEFT OUTER JOIN COREERRLOG.DBO.ERR_INT_RATE_BASIC ON ErrorID = RepErrorID
	WHERE ERRORMESSAGE LIKE      '%COR_INT_RATE_BASIC DUE TO A SRC_FUND_ID OF 999999999' AND RepErrorID IS NULL;
	
	UPDATE COREERRLOG.DBO.REPERRORLOG SET Status = 'C'
	FROM COREERRLOG.DBO.REPERRORLOG
	LEFT OUTER JOIN COREERRLOG.DBO.ERR_INT_RATE_LOAN ON ErrorID = RepErrorID
	WHERE ERRORMESSAGE LIKE      '%COR_INT_RATE_LOAN DUE TO A SRC_FUND_ID OF 999999999' AND RepErrorID IS NULL;
	
	UPDATE COREERRLOG.DBO.REPERRORLOG SET Status = 'C'
	FROM COREERRLOG.DBO.REPERRORLOG
	LEFT OUTER JOIN COREERRLOG.DBO.ERR_INT_RATE_DUR_BASE ON ErrorID = RepErrorID
	WHERE ERRORMESSAGE LIKE      '%COR_INT_RATE_DUR_BASE DUE TO A SRC_FUND_ID OF 999999999' AND RepErrorID IS NULL;
	
	UPDATE COREERRLOG.DBO.REPERRORLOG SET Status = 'C'
	FROM COREERRLOG.DBO.REPERRORLOG
	LEFT OUTER JOIN COREERRLOG.DBO.ERR_FUTURE_ALLOCTN ON ErrorID = RepErrorID
	WHERE ERRORMESSAGE LIKE      '%COR_FUTURE_ALLOCTN DUE TO A SRC_FUND_ID OF 999999999' AND RepErrorID IS NULL;
	
	UPDATE COREERRLOG.DBO.REPERRORLOG SET Status = 'C'
	FROM COREERRLOG.DBO.REPERRORLOG
	LEFT OUTER JOIN COREERRLOG.DBO.ERR_LOAN_ASSET_REC ON ErrorID = RepErrorID
	WHERE ERRORMESSAGE LIKE      '%COR_LOAN_ASSET_REC DUE TO A SRC_FUND_ID OF 999999999' AND RepErrorID IS NULL;
	
	UPDATE COREERRLOG.DBO.REPERRORLOG SET Status = 'C'
	FROM COREERRLOG.DBO.REPERRORLOG
	LEFT OUTER JOIN COREERRLOG.DBO.ERR_LOAN_FUND_ASSET_SRC_DTL ON ErrorID = RepErrorID
	WHERE ERRORMESSAGE LIKE      '%COR_LOAN_FUND_ASSET_SRC_DTL DUE TO A SRC_FUND_ID OF 999999999' AND RepErrorID IS NULL;
	
	UPDATE COREERRLOG.DBO.REPERRORLOG SET Status = 'C'
	FROM COREERRLOG.DBO.REPERRORLOG
	LEFT OUTER JOIN COREERRLOG.DBO.ERR_SRC_FUND_PRICE ON ErrorID = RepErrorID
	WHERE ERRORMESSAGE LIKE      '%COR_SRC_FUND_PRICE DUE TO A SRC_FUND_ID OF 999999999' AND RepErrorID IS NULL;
	
	UPDATE COREERRLOG.DBO.REPERRORLOG SET Status = 'C'
	FROM COREERRLOG.DBO.REPERRORLOG
	LEFT OUTER JOIN COREERRLOG.DBO.ERR_TRNSCTN_DETAIL ON ErrorID = RepErrorID
	WHERE ERRORMESSAGE LIKE      '%COR_TRNSCTN_DETAIL DUE TO A SRC_FUND_ID OF 999999999' AND RepErrorID IS NULL;
	
	UPDATE COREERRLOG.DBO.REPERRORLOG SET Status = 'C'
	FROM COREERRLOG.DBO.REPERRORLOG
	LEFT OUTER JOIN COREERRLOG.DBO.ERR_X_CONTRIB_DETAIL ON ErrorID = RepErrorID
	WHERE ERRORMESSAGE LIKE      '%COR_X_CONTRIB_DETAIL DUE TO A SRC_FUND_ID OF 999999999' AND RepErrorID IS NULL;
	
	UPDATE COREERRLOG.DBO.REPERRORLOG SET Status = 'C'
	FROM COREERRLOG.DBO.REPERRORLOG
	LEFT OUTER JOIN COREERRLOG.DBO.ERR_X_FUND_DETAIL ON ErrorID = RepErrorID
	WHERE ERRORMESSAGE LIKE      '%COR_X_FUND_DETAIL DUE TO A SRC_FUND_ID OF 999999999' AND RepErrorID IS NULL;
	
	UPDATE COREERRLOG.DBO.REPERRORLOG SET Status = 'C'
	FROM COREERRLOG.DBO.REPERRORLOG
	LEFT OUTER JOIN COREERRLOG.DBO.ERR_X_LOAN_FUND_DTL ON ErrorID = RepErrorID
	WHERE ERRORMESSAGE LIKE      '%COR_X_LOAN_FUND_DTL DUE TO A SRC_FUND_ID OF 999999999' AND RepErrorID IS NULL;

	-- Remove rows from ERR table when the error is marked as "C"losed in RepErrorLog table

	DECLARE @Table_Name NVARCHAR(255)
	DECLARE @SQL NVARCHAR(4000)

	Declare ExecCursor Cursor Local Fast_Forward For
	SELECT TABLE_NAME FROM CoreErrLog.information_schema.tables
	WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME LIKE 'ERR[_]%'
	ORDER BY TABLE_NAME

	Open ExecCursor
	Fetch Next From ExecCursor Into @Table_Name

	While (@@Fetch_Status <> -1)
	Begin

		Select @SQL = N'DELETE CoreErrLog.dbo.' + @Table_Name + ' WHERE RepErrorID IN (SELECT ErrorID FROM CoreErrLog.dbo.RepErrorLog WHERE Status = ''C'')'
		EXECUTE  sp_executesql @SQL

		Select @SQL = N'DELETE CoreErrLog.dbo.' + @Table_Name + ' WHERE RepErrorID NOT IN (SELECT ErrorID FROM CoreErrLog.dbo.RepErrorLog)'
		EXECUTE  sp_executesql @SQL

		Fetch Next From ExecCursor Into @Table_Name

	End

	Close ExecCursor
	Deallocate ExecCursor

	-- Archive RepErrorLog
	INSERT INTO COREERRLOG.dbo.RepErrorLog_Hstry
	([ErrorID] ,
	[ETWErrorID] ,
	[ErrorDate] ,
	[ErrorMessage] ,
	[ErrorData] ,
	[LogID] ,
	[Status] ,
	[WorkflowStatus] ,
	[DateTimeStamp] ,
	[UpdatedBy] ,
	[ErrorSource] ,
	[IssueNumber] ,
	[WTransID] ,
	[System] ,
	[AccountNbr] ,
	[Details] ,
	[InvalidValue] ,
	[CTLDate] ,
	[ArchiveDateTimeStamp]
	)
	select 
	[ErrorID] ,
	[ETWErrorID] ,
	[ErrorDate] ,
	[ErrorMessage] ,
	[ErrorData] ,
	[LogID] ,
	[Status] ,
	[WorkflowStatus] ,
	[DateTimeStamp] ,
	[UpdatedBy] ,
	[ErrorSource] ,
	[IssueNumber] ,
	[WTransID] ,
	[System] ,
	[AccountNbr] ,
	[Details] ,
	[InvalidValue] ,
	[CTLDate] ,
	getdate()
	from COREERRLOG.dbo.RepErrorLog
	where [Status] = 'C'
	and [ErrorID] not in (select [ErrorID] from COREERRLOG.dbo.RepErrorLog_Hstry)

	-- Remove Archived Rows From RepErrorLog
	delete from COREERRLOG.dbo.RepErrorLog
	where [ErrorID] in (select [ErrorID] from COREERRLOG.dbo.RepErrorLog_Hstry)

	set XACT_ABORT off;
	set nocount off
	set ANSI_WARNINGS off;
	set ANSI_NULLS off;

end 
RETURN
GO
