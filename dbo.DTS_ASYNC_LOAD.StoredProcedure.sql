USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[DTS_ASYNC_LOAD]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[DTS_ASYNC_LOAD](@DTSPARAMID int,  @SYSPROCESSEDLOGID INT) AS
        

        SET NOCOUNT ON

        DECLARE @SOURCEFILEID INT
        DECLARE @DESTTABLE NVARCHAR(200)
        DECLARE @PACKAGENAME NVARCHAR(200)
        DECLARE @COMPLETEIND INT
        DECLARE @SQLString NVARCHAR(500)
        DECLARE @ParmDefinition NVARCHAR(500)
        DECLARE @CMD NVARCHAR(4000)
        DECLARE @RESULTS INT
        DECLARE @BEFORERECORDCOUNT INT
        DECLARE @AFTERRECORDCOUNT INT
        DECLARE @ERRORMESSAGE NVARCHAR(4000)

        -------------------------------------------------------------------
        --GET REQUIRED DATA
        -------------------------------------------------------------------
        SELECT @DESTTABLE = DESTINATIONTABLE, @PACKAGENAME = FILENAME, @SOURCEFILEID = SOURCEFILEID FROM PRM_DTSPACKAGES WHERE DTSPARAMID = @DTSPARAMID

        SELECT @COMPLETEIND = CASE WHEN EXISTS (SELECT 1 FROM MC_SEGMENT WITH(NOLOCK) WHERE COMPLETED = 'T' AND SEGMENT = 'DTS' AND SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID AND SEGMENTINSTANCE = @PACKAGENAME) THEN 1 ELSE 0 END

        -------------------------------------------------------------------
        --SEE IF WE ARE ALREADY DONE
        -------------------------------------------------------------------
        IF @COMPLETEIND = 1 
        BEGIN
                PRINT 'ALREADY COMPLETE'
                RETURN
        END 

        -------------------------------------------------------------------
        --WAIT FOR PARENT PACKAGES TO COMPLETE
        -------------------------------------------------------------------
        EXEC DTS_CHECK_COMPLETION @SYSPROCESSEDLOGID, @DTSPARAMID


        -------------------------------------------------------------------
        --LOG SEGMENT
        -------------------------------------------------------------------
        INSERT INTO MC_SEGMENT (StartDateTimeStamp, EndDateTimeStamp, SegmentInstance, Completed, SourceFileID, Segment, RecordsProcessed, SysProcessedLogID)
        SELECT GETDATE(),NULL,@PACKAGENAME,'F',@SOURCEFILEID, 'DTS',NULL,@SYSPROCESSEDLOGID
        WHERE NOT EXISTS (SELECT 1 FROM MC_SEGMENT WITH(NOLOCK) WHERE SEGMENT = 'DTS' AND SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID AND SEGMENTINSTANCE = @PACKAGENAME)
         

        -------------------------------------------------------------------
        --GET RECORDCOUNT
        -------------------------------------------------------------------
        set @SQLString = N'select @cntOUT = count(*) FROM ' + CAST(@DESTTABLE AS NVARCHAR(4000))
        SET @ParmDefinition = N'@cntOUT int OUTPUT'
        EXECUTE sp_executesql @SQLString, @ParmDefinition,@cntOUT=@BEFORERECORDCOUNT OUTPUT


        -------------------------------------------------------------------
        --BUILD COMMAND TO EXECUTE ORACLE PROC
        -------------------------------------------------------------------
        SELECT @CMD =  'dtsrun /Ssbgetl /Ucore1dbo /Pcore1dbo /N' + @PACKAGENAME
 

        -------------------------------------------------------------------
        --EXECUTE COMMAND
        -------------------------------------------------------------------
        EXEC  @RESULTS = MASTER..xp_cmdshell @CMD, no_output

        -------------------------------------------------------------------
        --SEARCH FOR ERRORS 
        -------------------------------------------------------------------
        IF @RESULTS = 0
        BEGIN
                EXECUTE sp_executesql @SQLString, @ParmDefinition,@cntOUT=@AFTERRECORDCOUNT OUTPUT

                UPDATE CORE1.DBO.MC_SEGMENT
                SET ENDDATETIMESTAMP = GETDATE(),COMPLETED = 'T', RECORDSPROCESSED = (@AFTERRECORDCOUNT - @BEFORERECORDCOUNT)
                WHERE SEGMENT = 'DTS' AND SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID AND SEGMENTINSTANCE = @PACKAGENAME
                RETURN
        END 
        ELSE
        BEGIN
                DECLARE @DBID INT
                DECLARE @DBNAME NVARCHAR(128)
                SET @DBID = DB_ID()
                SET @DBNAME = DB_NAME()
                SET @ERRORMESSAGE = @PACKAGENAME + N' FAILED. REFER TO CORE1.DBO.DTS_PACKAGELOG FOR MORE INFORMATION.'
                RAISERROR (@ERRORMESSAGE, 16, 1, @DBID, @DBNAME)
                RETURN
        END

RETURN




GO
