USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[DTS_CHECK_COMPLETION]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[DTS_CHECK_COMPLETION] (@SYSPROCESSEDLOGID INT, @DTSPARAMID INT) AS

DECLARE @PARENTSCOMPLETE INT
SET @PARENTSCOMPLETE = 100

--LOOP UNTIL ALL PARENT'S ARE COMPLETED
WHILE @PARENTSCOMPLETE > 0
BEGIN



        --SEE IF ANY PARENT TABLES ARE STILL RUNNING
        SELECT @PARENTSCOMPLETE = COUNT(*) FROM PRM_DTSPACKAGES A
        INNER JOIN PRM_DTSPRECEDENCE B
        ON A.DTSPARAMID  = B.DTSPARAMID
        INNER JOIN PRM_DTSPACKAGES C
        ON B.PARENTDTSPARAMID = C.DTSPARAMID
        WHERE A.DTSPARAMID = @DTSPARAMID
        AND NOT EXISTS (SELECT 1 FROM 
                        MC_SEGMENT E
                        WHERE E.SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID
                        AND E.SEGMENT = 'DTS'
                        AND E.SEGMENTINSTANCE = C.FILENAME
                        AND E.COMPLETED = 'T'
                     )


        IF @PARENTSCOMPLETE > 0 
        BEGIN
                WAITFOR DELAY '00:00:30'
        END
END

RETURN


GO
