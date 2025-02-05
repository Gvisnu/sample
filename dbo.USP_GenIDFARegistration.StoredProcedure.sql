USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[USP_GenIDFARegistration]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO



CREATE PROCEDURE [dbo].[USP_GenIDFARegistration] AS

INSERT INTO dbo.GenIDFARegistration
	(
	SourceSystem,
	SourceSystemKey1,
	SourceSystemKey2,
	SourceSystemKey3,
	SourceSystemKey4,
	SourceSystemKey5,
	JobID
	)
SELECT DISTINCT
	A.SourceSystem,
	A.SourceSystemKey1,
	A.SourceSystemKey2,
	A.SourceSystemKey3,
	A.SourceSystemKey4,
	A.SourceSystemKey5,
	MAX(A.JobID) AS JobID
FROM
	dbo.TempIDFARegistration A
LEFT OUTER JOIN
	dbo.GenIDFARegistration B
	ON  A.SourceSystem     = B.SourceSystem
	AND A.SourceSystemKey1 = B.SourceSystemKey1
	AND A.SourceSystemKey2 = B.SourceSystemKey2
	AND A.SourceSystemKey3 = B.SourceSystemKey3
	AND A.SourceSystemKey4 = B.SourceSystemKey4
	AND A.SourceSystemKey5 = B.SourceSystemKey5
WHERE
	B.SourceSystem IS NULL
GROUP BY
	A.SourceSystem,
	A.SourceSystemKey1,
	A.SourceSystemKey2,
	A.SourceSystemKey3,
	A.SourceSystemKey4,
	A.SourceSystemKey5


GO
