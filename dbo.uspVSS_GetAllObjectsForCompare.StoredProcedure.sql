USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspVSS_GetAllObjectsForCompare]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[uspVSS_GetAllObjectsForCompare]
	
AS
BEGIN
	
	SELECT SC.Text,
	CASE WHEN SO.Type='TF' THEN 'FN'
	WHEN  SO.Type='IF' THEN 'FN'
	ELSE SO.Type END AS Type
	,So.Name FROM sysobjects SO (NOLOCK) 
	INNER JOIN syscomments SC (NOLOCK) 
	ON SO.Id = SC.ID AND Category=0
	WHERE 
	SO.Type IN ('FN','P','V','TF','IF')
	AND NOT (SO.Type = 'P' AND 
	( SO.Name LIKE 'NREP%' OR SO.Name  LIKE 'DOM_COR_%' 
	OR So.Name  LIKE 'ERR%' OR SO.NAME LIKE 'Z%' OR So.Name LIKE '%Diagram%' ))
	AND NOT (SO.Type='V' AND (SO.Name  LIKE 'REP%' OR NAME LIKE '%Diagram%'))
	AND NOT (SO.TYPE='FN' AND (SO.Name LIKE '%Diagram%'))
	OR NAME LIKE 'ERR_BUILD%'
	OR NAME LIKE 'NREP_MRNNGSTR_MTH%'
	OR NAME LIKE 'REP_MRNNGSTR_MTH%'
	Order by SO.Type,SO.Name
END

GO
