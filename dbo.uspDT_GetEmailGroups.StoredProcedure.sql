USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_GetEmailGroups]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE  PROCEDURE [dbo].[uspDT_GetEmailGroups]
 AS

	SET NOCOUNT ON

	Select Distinct  EmailGroupID from DT_EmailGroups
	Order by EmailGroupID
		
	


RETURN 0
GO
