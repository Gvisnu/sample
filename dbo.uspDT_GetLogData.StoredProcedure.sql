USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_GetLogData]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspDT_GetLogData]
(
@masterprocessid int,	
@StartDateTime datetime
)
AS
BEGIN
	select LogData from dt_masterprocesslog 
	where masterprocessid=@masterprocessid
	and StartDateTime=@StartDateTime
END

SET ANSI_NULLS ON
GO
