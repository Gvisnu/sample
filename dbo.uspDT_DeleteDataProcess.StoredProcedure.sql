USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_DeleteDataProcess]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE   PROCEDURE [dbo].[uspDT_DeleteDataProcess]
(@DataProcessID int
) AS

  SET NOCOUNT ON

  Update dbo.DT_DataProcess
  Set IsDeleted = 1 --True
  Where DataProcessID = @DataProcessID

RETURN 0

GO
