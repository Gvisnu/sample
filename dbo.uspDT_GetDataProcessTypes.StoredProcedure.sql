USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_GetDataProcessTypes]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE   PROCEDURE [dbo].[uspDT_GetDataProcessTypes]
AS

SET NOCOUNT ON

SELECT     *
FROM         dbo.DT_domDataProcessType

GO
