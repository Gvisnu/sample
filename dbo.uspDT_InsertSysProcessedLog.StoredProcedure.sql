USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_InsertSysProcessedLog]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[uspDT_InsertSysProcessedLog]
(
	@NightlyCycle bit	
)
AS
BEGIN
	
	Declare @SystemID int
	SELECT @SystemID=SystemID FROM MC_SourceSystem WHERE EndDate IS NULL

	IF NOT EXISTS (SELECT 1 FROM MC_SysProcessedLog
               WHERE Finished = 'F'
               AND SystemID = @SystemID)

	BEGIN
		IF(@SystemID = 13)
		BEGIN
			EXEC dbo.Proc_EasyPay_Set_Core_Cycle_Date
			EXEC dbo.Proc_EasyPay_Load_Source_Cycle_Date
		END

		IF(@SystemID = 14)
		BEGIN
			EXEC dbo.Proc_MCS_Set_Core_Cycle_Date
			EXEC dbo.Proc_MCS_Load_Source_Cycle_Date
		END

		INSERT INTO MC_SysProcessedLog
		(
			SystemID,
			CycleDate,
			Started,
			StartDateTimeStamp,
			Finished,
			EndDateTimeStamp,
			NightlyCycle
			
		)
		SELECT
			@SystemID,
			CYCLEDATE,
			'T',
			GETDATE(),
			'F',
			NULL,
			@NightlyCycle
		FROM SourceSystemCycleDate
		WHERE SystemID = @SystemID

	END

RETURN
END
GO
