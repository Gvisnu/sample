USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_Finish_MC_SysProcessedLog]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE  PROCEDURE [dbo].[Proc_Finish_MC_SysProcessedLog] AS

UPDATE MC_SysProcessedLog
SET Finished = 'T',
    EndDateTimeStamp = GETDATE()
WHERE SystemID = (SELECT SystemID FROM MC_SourceSystem WHERE EndDate IS NULL)
  AND Finished = 'F'

RETURN




GO
