USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_GetAppSettings]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE  PROCEDURE [dbo].[uspDT_GetAppSettings]
AS

SET NOCOUNT ON

Select * from DT_AppSetting

GO
