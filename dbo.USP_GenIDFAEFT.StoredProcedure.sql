USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[USP_GenIDFAEFT]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[USP_GenIDFAEFT] AS

INSERT INTO dbo.GenIDFAEFT
	(
	SourceSystem,
	SourceSystemKey1,
	SourceSystemKey2,
	SourceSystemKey3,
	SourceSystemKey4,
	SourceSystemKey5,
	SourceSystemKey6,
	SourceSystemKey7,
	SourceSystemKey8,
	JobID
	)
SELECT DISTINCT
	A.SourceSystem,
	A.SourceSystemKey1,
	A.SourceSystemKey2,
	A.SourceSystemKey3,
	A.SourceSystemKey4,
	A.SourceSystemKey5,
	A.SourceSystemKey6,
	A.SourceSystemKey7,
	A.SourceSystemKey8,
	MAX(A.JobID) AS JobID
FROM
	dbo.TempIDFAEFT A
LEFT OUTER JOIN
	dbo.GenIDFAEFT B
	ON  A.SourceSystem     = B.SourceSystem
	AND A.SourceSystemKey1 = B.SourceSystemKey1
	AND A.SourceSystemKey2 = B.SourceSystemKey2
	AND A.SourceSystemKey3 = B.SourceSystemKey3
	AND A.SourceSystemKey4 = B.SourceSystemKey4
	AND A.SourceSystemKey5 = B.SourceSystemKey5
	AND A.SourceSystemKey6 = B.SourceSystemKey6
	AND A.SourceSystemKey7 = B.SourceSystemKey7
	AND A.SourceSystemKey8 = B.SourceSystemKey8
WHERE
	B.SourceSystem IS NULL
GROUP BY
	A.SourceSystem,
	A.SourceSystemKey1,
	A.SourceSystemKey2,
	A.SourceSystemKey3,
	A.SourceSystemKey4,
	A.SourceSystemKey5,
	A.SourceSystemKey6,
	A.SourceSystemKey7,
	A.SourceSystemKey8


GO
