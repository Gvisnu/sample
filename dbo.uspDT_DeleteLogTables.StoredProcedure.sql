USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_DeleteLogTables]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspDT_DeleteLogTables]
(
	@masterprocesslogid int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    delete from dt_masterprocesslog where masterprocesslogid=@masterprocesslogid
	delete from dt_dataprocesslog where masterprocesslogid=@masterprocesslogid
END


/****** Object:  StoredProcedure [dbo].[uspDT_UpdateLogData]    Script Date: 01/16/2009 14:30:52 ******/
SET ANSI_NULLS ON
GO
