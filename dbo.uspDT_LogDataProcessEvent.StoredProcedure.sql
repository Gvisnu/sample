USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_LogDataProcessEvent]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[uspDT_LogDataProcessEvent]
(@DataProcessLogID int,
@MasterProcessLogID int,
@DataProcessID int,
@DataProcessActionID int,
@LogDateTime datetime,
@ProcessStatusID int,
@RowsProcessed int,
@ScalarValue int,
@QueryDelta int) AS

SET NOCOUNT ON

DECLARE @COMPLETE_STATUS int
DECLARE @DATAPROCESSNAME VARCHAR(75)
SET @COMPLETE_STATUS = 4

-- For Issue 3288 - UC4 Tracker the Dataprocessname is added to dataprocesslog to calculate the Core data extract 
-- Estimated Time to complete logic
If @DataProcessLogID = 0
Begin
  SET @DATAPROCESSNAME = (SELECT DATAPROCESSNAME FROM DT_DATAPROCESS WHERE DATAPROCESSID = @DataProcessID) 	
  INSERT INTO DT_DataProcessLog
    (MasterProcessLogID, DataProcessID, DataProcessActionID, ProcessStatusID, StartDateTime, LastUpdateDateTime, EndDateTime,DataProcessName)
  Values
    (@MasterProcessLogID, @DataProcessID, @DataProcessActionID, @ProcessStatusID, @LogDateTime, @LogDateTime, 
    CASE @ProcessStatusID When @COMPLETE_STATUS Then @LogDateTime Else NULL End,
	@DATAPROCESSNAME)
  
  SET @DataProcessLogID = SCOPE_IDENTITY()
End
Else
Begin
  Update DT_DataProcessLog
  Set 
      DataProcessActionID = @DataProcessActionID,
      LastUpdateDateTime = @LogDateTime,
      EndDateTime = CASE @ProcessStatusID When @COMPLETE_STATUS Then @LogDateTime Else NULL End,
      RowsProcessed = COALESCE(@RowsProcessed, RowsProcessed),
      QueryDelta = COALESCE(@QueryDelta, QueryDelta),
      ScalarValue = COALESCE(@ScalarValue, ScalarValue),    
      ProcessStatusID = @ProcessStatusID
    Where DataProcessLogID = @DataProcessLogID
End

SELECT @DataProcessLogID as DataProcessLogID

RETURN 0



GO
