USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[sp_Clean_OmniBrIAAssetTransaction]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_Clean_OmniBrIAAssetTransaction]
AS

   TRUNCATE TABLE dbo.OmniBrIAAssetTransaction_TEMP

   INSERT OmniBrIAAssetTransaction_TEMP
   SELECT DISTINCT obr.*
     FROM OmniBrIAAssetTransaction obr
    WHERE obr.[AHBR-ACTIVITY] != '041'
      AND obr.[AHBR-TRAN-CODE] NOT IN ('301', '366', '381', '495')
GO
