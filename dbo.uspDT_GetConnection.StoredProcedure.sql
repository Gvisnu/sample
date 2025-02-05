USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_GetConnection]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  PROCEDURE [dbo].[uspDT_GetConnection](@ConnectionID int)
 AS

	SET NOCOUNT ON

If (@ConnectionID = 0)
	Begin
		Select * from DT_Connection
		Order by ConnectionName
	End
Else
	Begin
		Select * from DT_Connection
		Where ConnectionID = @ConnectionID
	End

RETURN 0
GO
