USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_UpdateLogData]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspDT_UpdateLogData]
(
@MasterProcessLogID int,
@LogData text
) 
As
BEGIN
	update DT_MasterProcessLog set LogData=@LogData where MasterProcessLogID=@MasterProcessLogID
END




/****** Object:  StoredProcedure [dbo].[uspDT_GetDataProcessesbyID]    Script Date: 01/13/2009 13:49:23 ******/
SET ANSI_NULLS ON
GO
