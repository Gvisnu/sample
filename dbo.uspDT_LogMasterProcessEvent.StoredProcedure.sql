USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_LogMasterProcessEvent]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE                PROCEDURE [dbo].[uspDT_LogMasterProcessEvent]
(@MasterProcessLogID int,
  @MasterProcessID int,
  @LogDateTime datetime,
  @ProcessStatusID int) AS

SET NOCOUNT ON

DECLARE @COMPLETE_STATUS int
SET @COMPLETE_STATUS = 4

IF @MasterProcessLogID = 0
Begin
  INSERT INTO DT_MasterProcessLog
    (MasterProcessID, StartDateTime, LastUpdateDateTime, ProcessStatusID, EndDateTime)
  Values
    (@MasterProcessID, @LogDateTime, @LogDateTime, @ProcessStatusID,
     CASE @ProcessStatusID When @COMPLETE_STATUS Then @LogDateTime Else NULL End)

  SELECT @MasterProcessLogID = SCOPE_IDENTITY()
End
Else
Begin
   Update DT_MasterProcessLog
    Set LastUpdateDateTime = @LogDateTime,
      EndDateTime = CASE @ProcessStatusID When @COMPLETE_STATUS Then @LogDateTime Else EndDateTime End,
      ProcessStatusID = @ProcessStatusID
    Where MasterProcessLogID = @MasterProcessLogID
End

SELECT @MasterProcessLogID as MasterProcessLogID

GO
