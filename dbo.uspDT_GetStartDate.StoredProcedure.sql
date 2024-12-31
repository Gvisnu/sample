USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_GetStartDate]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspDT_GetStartDate]
(
@masterprocessid int	
)
AS
BEGIN

	select distinct StartDateTime  from dt_masterprocesslog 
	where masterprocessid=@masterprocessid and StartDateTime is not null
	order by StartDatetime desc

END


GO
