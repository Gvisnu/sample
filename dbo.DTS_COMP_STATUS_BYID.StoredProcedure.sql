USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[DTS_COMP_STATUS_BYID]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[DTS_COMP_STATUS_BYID](@aSysProcessedLogID int, @aSystemID int, @DTSParamID int, @aDone char(1) OUTPUT) as


        SELECT
                @aDone = CASE WHEN SEGMENTID IS NULL THEN 'F' ELSE 'T' END
        FROM 
                MC_SEGMENT
        WHERE 
                SEGMENT = 'DTS'
                AND SEGMENTINSTANCE = (SELECT FILENAME FROM PRM_DTSPACKAGES WHERE DTSPARAMID = @DTSParamID)
                AND SYSPROCESSEDLOGID = @aSysProcessedLogID
                AND COMPLETED = 'T'



RETURN



GO
