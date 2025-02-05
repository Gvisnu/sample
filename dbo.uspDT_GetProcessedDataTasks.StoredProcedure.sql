USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_GetProcessedDataTasks]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE    PROCEDURE [dbo].[uspDT_GetProcessedDataTasks]
(@MasterProcessLogID int,
@RetreiveAdditionalInfo bit) AS

SET NOCOUNT ON
	
IF @RetreiveAdditionalInfo = 0
Begin
	Select DPL.DataProcessLogID,
	DPL.DataProcessID,
	DPL.DataProcessActionID,
	DPL.ProcessStatusID
	From DT_DataProcessLog DPL (NOLOCK)
	Where DPL.MasterProcessLogID = @MasterProcessLogID
	Order by DPL.DataProcessID
End
Else
Begin
	SELECT DPL.DataProcessLogID,
		DPL.DataProcessID,
		DT_DataProcess.DataProcessName,
		DPL.DataProcessActionID,
		DT_domDataProcessAction.DataProcessAction + '(' + Cast(DPL.DataProcessActionID as varchar(5)) + ')' as DataProcessAction, 
		DPL.ProcessStatusID, 
		DT_domProcessStatus.ProcessStatus + '(' + Cast(DPL.ProcessStatusID as varchar(5)) + ')'  as ProcessStatus,
		DPL.QueryDelta,
		DPL.RowsProcessed,
		DPL.StartDateTime,
		DateDiff(second, DPL.StartDateTime, DPL.LastUpdateDateTime) as ProcessDelta
	FROM DT_DataProcessLog DPL 
	LEFT OUTER JOIN DT_DataProcess (NOLOCK) ON DPL.DataProcessID = DT_DataProcess.DataProcessID 
	LEFT OUTER JOIN DT_domDataProcessAction (NOLOCK) ON DPL.DataProcessActionID = DT_domDataProcessAction.DataProcessActionID 
	LEFT OUTER JOIN DT_domProcessStatus (NOLOCK) ON DPL.ProcessStatusID = DT_domProcessStatus.ProcessStatusID
	WHERE (DPL.MasterProcessLogID = @MasterProcessLogID)
	ORDER BY DPL.StartDateTime
End

GO
