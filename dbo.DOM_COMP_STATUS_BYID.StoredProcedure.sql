USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[DOM_COMP_STATUS_BYID]    Script Date: 12/31/2024 8:49:43 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[DOM_COMP_STATUS_BYID](@aSysProcessedLogID int, @aSystemID int, @DomainChildrenID int, @aDone char(1) OUTPUT) as


        SELECT
                @aDone = CASE WHEN SEGMENTID IS NULL THEN 'F' ELSE 'T' END
        FROM 
                MC_SEGMENT
        WHERE 
                SEGMENT = 'DOMAIN'
                AND SEGMENTINSTANCE = (SELECT 'DOM_' + CORETABLENAME + '__' + COREFIELDNAME FROM PRM_DOMAINCHILDREN WITH(NOLOCK) WHERE DOMAINCHILDRENID = @DomainChildrenID)
                AND SYSPROCESSEDLOGID = @aSysProcessedLogID
                AND COMPLETED = 'T'

RETURN


GO
