USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_SEC22C2_TRAC_Populate_COR_JOB]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE  PROCEDURE [dbo].[Proc_SEC22C2_TRAC_Populate_COR_JOB] AS

INSERT INTO COREETL.DBO.COR_JOB
(
	JOB_ID,
	DATETIMESTAMP,
	LONG_DESC,
	ADU,
	REC_INSRT_NAME
)
SELECT
	A.JobID,
	GETDATE(),
	RTRIM(C.SystemName) + ' - ' + RTRIM(B.logicalName),
	'A',
	'285'
FROM
	MC_JobID A
INNER JOIN
	MC_SourceFile B
	ON  A.SourceFileID = B.SourceFileID
	AND B.SystemID = 4
INNER JOIN
	MC_SourceSystem C
	ON  C.SystemID = B.SystemID
	AND C.SystemID = 4
WHERE
	(A.SysProcessedLogID = (SELECT	MAX(SYSPROCESSEDLOGID)
				FROM	MC_SYSPROCESSEDLOG
				WHERE	SYSTEMID = 4));

UPDATE MC_JobID SET ReplicatedToETL = 'Y' WHERE ReplicatedToETL <> 'Y';

RETURN




GO
