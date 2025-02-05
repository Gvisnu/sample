USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[NREP_BUILD_ETL_OBJECTS]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE    PROCEDURE [dbo].[NREP_BUILD_ETL_OBJECTS] (@SYSTEMID INT,@AREPLOADTABLEID INT = NULL) AS

/*---------------------------------------------------------------------------------------
THIS PROCEDURE CREATES THE STORED PROCEDURES THAT LOAD COREETL DATA INTO CORE
THIS PROCEDURE IS USED BY REPLICA TRANSFER

MODIFICATION NOTES
11/4/2004 -->REMOVED LOGIC THAT CONVERTED COREETL DEFAULTS. THIS INCLUDED THE 
             IMPLEMENTATION OF USING BCP TO EXTRACT COREETL DATA TO TEXT
2/15/2005 -->ALTERED PROC TO SUPPORT 6.0 CHANGES TO THE AUDIT_TRAIL_ATTRIBUTES
---------------------------------------------------------------------------------------
*/

SET NOCOUNT ON


CREATE TABLE [#TEMP] ( [COLUMN_NAME] VARCHAR(150) ) 
DECLARE CRSR_CONSTS CURSOR FOR SELECT COLUMN_NAME FROM #TEMP

DECLARE @PROCSQL1 NVARCHAR(4000)
DECLARE @PROCSQL2 NVARCHAR(4000)
DECLARE @PROCSQL3 NVARCHAR(4000)
DECLARE @PROCSQL4 NVARCHAR(4000)
DECLARE @PROCSQL4_5 NVARCHAR(4000)
DECLARE @PROCSQL5 NVARCHAR(4000)
DECLARE @PROCSQL7 NVARCHAR(4000)
DECLARE @PROCSQL8 NVARCHAR(4000)
DECLARE @PROCSQL9 NVARCHAR(4000)
DECLARE @PROCSQL10 NVARCHAR(4000)
DECLARE @PROCSQL10_5 NVARCHAR(4000)
DECLARE @PROCSQL11 NVARCHAR(4000)
DECLARE @PROCSQL11_5 NVARCHAR(4000)
DECLARE @PROCSQL12 NVARCHAR(4000)
DECLARE @PROCSQL13 NVARCHAR(4000)
DECLARE @PROCSQL13_5 NVARCHAR(4000)
DECLARE @PROCSQL14 NVARCHAR(4000)
DECLARE @PROCSQL15 NVARCHAR(4000)
DECLARE @PROCSQL16 NVARCHAR(4000)

DECLARE @VIEWSQL1 NVARCHAR(4000)
DECLARE @VIEWSQL2 NVARCHAR(4000)
DECLARE @ERRORMESSAGE NVARCHAR(255)

DECLARE @SQL NVARCHAR(4000)
DECLARE @COLLISTSQL NVARCHAR(4000)
DECLARE @REPLOADTABLEID INT
DECLARE @CORTABLENAME VARCHAR(50)
DECLARE @REPTABLENAME VARCHAR(50)
DECLARE @SOURCEFILEID INT
DECLARE @BADPATH NVARCHAR(4000)
DECLARE @CTLPATH NVARCHAR(4000)
DECLARE @STAGEOUTPUTFOLDER NVARCHAR(255)
DECLARE @STAGECOLUMNS NVARCHAR(4000)
DECLARE @ERRORCOUNT INT
DECLARE @PROC NVARCHAR(100)
DECLARE @TABLELEVELLOADS INT
DECLARE @ORASQL NVARCHAR(4000)
DECLARE @COLS NVARCHAR(4000)
DECLARE @FINALSQL VARCHAR(8000)
DECLARE @COLUMN_SQL VARCHAR(8000)
DECLARE @COLUMN_NAME VARCHAR(8000)
DECLARE @COL_NAME NVARCHAR(4000)
DECLARE @REPLOADSUBSET TABLE (REPLOADTABLEID INT)
DECLARE @MULTIIND BIT
DECLARE @ALPHASYSTEM VARCHAR(50)
DECLARE @UPPERLOWERCASE NVARCHAR(1)

IF @AREPLOADTABLEID IS NULL
BEGIN
        INSERT INTO @REPLOADSUBSET SELECT REPLOADTABLEID FROM PRM_REPLOADTABLES WHERE SYSTEMID = @SYSTEMID
END
ELSE
BEGIN
        INSERT INTO @REPLOADSUBSET (REPLOADTABLEID) VALUES (@AREPLOADTABLEID)
END

SET @ALPHASYSTEM = (SELECT left(SYSTEMNAME,4) FROM MC_SOURCESYSTEM WHERE SYSTEMID = @SYSTEMID)

DECLARE CRSR_MAIN CURSOR FOR
SELECT 
        REPLOADTABLEID,
        CORETABLENAME, 
	B.ALLOWUPPERLOWERCASE,
        DBO.REP_STAGENAME(CORETABLENAME,REPLOADTABLEID), 
        SOURCEFILEID,
        STAGEOUTPUTFOLDER + '\SQLLDR_BAD\' + DBO.REP_STAGENAME(B.CORETABLENAME,REPLOADTABLEID) +  '.BAD',
        STAGEOUTPUTFOLDER + '\SQLLDR_CTL\' + DBO.REP_STAGENAME(B.CORETABLENAME,REPLOADTABLEID) +  '.CTL',
        A.STAGEOUTPUTFOLDER,
        STAGECOLUMNS, 
        ISNULL(MAXERRORCOUNT,1000),
        CASE WHEN INSERTIND = 1 AND UPDATEIND = 0 THEN 'SPI_' WHEN UPDATEIND = 1 THEN 'SPM_' END,
        (SELECT COUNT(*) FROM CORE1.DBO.PRM_REPLOADTABLES C WHERE C.REPCORETABLEID = A.REPCORETABLEID AND A.SYSTEMID = C.SYSTEMID),
        CASE WHEN C.REPCORETABLEID IS NOT NULL THEN 1 ELSE 0 END
FROM 
        PRM_REPLOADTABLES A  WITH(NOLOCK) 
        INNER JOIN 
        PRM_REPCORETABLES B  WITH(NOLOCK) 
        ON A.REPCORETABLEID = B.REPCORETABLEID 
        LEFT OUTER JOIN 
        (SELECT REPCORETABLEID, SYSTEMID FROM PRM_REPLOADTABLES GROUP BY REPCORETABLEID, SYSTEMID HAVING COUNT(*) > 1) C 
        ON A.REPCORETABLEID = C.REPCORETABLEID
	AND A.SYSTEMID = C.SYSTEMID
WHERE
        A.REPLOADTABLEID IN (SELECT REPLOADTABLEID FROM @REPLOADSUBSET)


OPEN CRSR_MAIN
FETCH Next FROM CRSR_MAIN INTO @REPLOADTABLEID,@CORTABLENAME,@UPPERLOWERCASE,@REPTABLENAME,@SOURCEFILEID,@BADPATH,@CTLPATH,@STAGEOUTPUTFOLDER,@STAGECOLUMNS,@ERRORCOUNT,@PROC,@TABLELEVELLOADS,@MULTIIND

WHILE @@FETCH_STATUS=0
BEGIN
                
--MAKE SURE THAT THERE ARE NO DEFAULTS ON THIS TABLE
IF (SELECT COUNT(*) FROM COREETL.INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = @CORTABLENAME AND COLUMN_DEFAULT IS NOT NULL) > 0
BEGIN
        SET @ERRORMESSAGE = N'NREP_BUILD_ETL_OBJECTS FAILED.  A COREETL DEFAULT WAS DETECTED IN ' + @CORTABLENAME + '.'
        RAISERROR (@ERRORMESSAGE, 16, 1)
	RETURN 1
END



SELECT @PROCSQL1 =''
SELECT @PROCSQL2 =''
SELECT @PROCSQL3 =''
SELECT @PROCSQL4 =''
SELECT @PROCSQL4_5 = ''
SELECT @PROCSQL5 =''
SELECT @PROCSQL7 =''
SELECT @PROCSQL8 =''
SELECT @PROCSQL9 =''
SELECT @PROCSQL10 =''
SELECT @PROCSQL11 =''
SELECT @PROCSQL11_5 = ''
SELECT @PROCSQL12 =''
SELECT @PROCSQL13 =''
SELECT @PROCSQL13_5 =''
SELECT @PROCSQL14 =''
SELECT @PROCSQL15 =''
SELECT @PROCSQL16 =''

SELECT @PROCSQL1 = '

CREATE PROCEDURE NREP_' + @REPTABLENAME + ' (@SYSPROCESSEDLOGID INT, @ORAUN VARCHAR(50) = '''', @ORASV VARCHAR(50)='''', @ORAPW VARCHAR(50)='''', @MANAGEDEXECUTIONIND BIT = 0 ) AS

        SET NOCOUNT ON

        DECLARE @CTLTEXT NVARCHAR(4000)
        DECLARE @CMD NVARCHAR(4000)
        DECLARE @RSLTS INT
        DECLARE @RESULTS INT
        DECLARE @ERRORID INT
        DECLARE @CNT INT
        DECLARE @RECORDSLOADED INT
        DECLARE @RECORDSERRORED INT
        DECLARE @PARENTSCOMPLETE BIT
        DECLARE @IPENDINGPARENT AS INT
        DECLARE @IPENDINGTABLEPARENT AS INT
        DECLARE @ZDATAENDDATE AS DATETIME
        DECLARE @ZDATASTATUS AS CHAR(1)
        DECLARE @STARTDATE AS DATETIME
        DECLARE @SEQUENCE AS INT
        DECLARE @OUTPUT VARCHAR(255)
        DECLARE @ERRORRESULTS VARCHAR(4000)
        DECLARE @TEXT NVARCHAR(255)
        DECLARE @ERR INT
        DECLARE @ZRECORDSPROCESSED INT

        SELECT @SEQUENCE = 0
'

SELECT @PROCSQL2 = '
        ------------------------------------------------------------------------------------
        --100
        --RECORD SPID FOR TRACKING PURPOSES
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
        PRINT ''[100-->BEG RECORD SPID]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[100-->BEG RECORD SPID]'')
        --<END>----------------LOG STEP


        UPDATE CORE1.DBO.PRM_REPLOADTABLES
        SET SPID_1 = @@SPID
        WHERE REPLOADTABLEID = ' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + '

        IF (@@ERROR <> 0) GOTO E_ERROR


        --<BEG>----------------LOG STEP
        PRINT ''[100-->END RECORD SPID]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[100-->END RECORD SPID]'')
        --<END>----------------LOG STEP

        '



SELECT @PROCSQL3 = '
        ------------------------------------------------------------------------------------
        --300
        --CHECK SEGMENT TO SEE IF WE HAVE ALREADY COMPLETED THIS PACKAGE
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
        PRINT ''[300-->BEG CHECK SEGMENT STATUS]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[300-->BEG CHECK SEGMENT STATUS]'')
        --<END>----------------LOG STEP

        --SEE IF WE ARE ALREADY DONE
        IF (CASE WHEN EXISTS (SELECT 1 FROM MC_SEGMENT WITH(NOLOCK) WHERE COMPLETED = ''T'' AND SEGMENT = ''REPLICA TRANSFER'' AND SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID AND SEGMENTINSTANCE = ''' + @REPTABLENAME + ''') THEN 1 ELSE 0 END) = 1 
        BEGIN
                PRINT ''ALREADY COMPLETE''
                GOTO E_ERROR
        END 

        IF (@@ERROR <> 0) GOTO E_ERROR

        --SEE IF THERE IS ANY DATA TO LOAD
        ' + CASE WHEN @MULTIIND = 1 THEN '
        SELECT @ZDATASTATUS = CASE WHEN COUNT(*) = 0 THEN ''T'' ELSE ''F'' END, 
        @ZDATAENDDATE = CASE WHEN COUNT(*) = 0 THEN GETDATE() ELSE NULL END,
        @ZRECORDSPROCESSED = CASE WHEN COUNT(*) = 0 THEN 0 ELSE NULL END
        FROM COREETL.DBO.' + @CORTABLENAME + '
        WHERE REC_INSRT_NAME = ''' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + '''
        ' ELSE '
        SELECT @ZDATASTATUS = CASE WHEN COUNT(*) = 0 THEN ''T'' ELSE ''F'' END, 
        @ZDATAENDDATE = CASE WHEN COUNT(*) = 0 THEN GETDATE() ELSE NULL END,
        @ZRECORDSPROCESSED = CASE WHEN COUNT(*) = 0 THEN 0 ELSE NULL END
        FROM COREETL.DBO.' + @CORTABLENAME 
        end + '
 

        IF (@@ERROR <> 0) GOTO E_ERROR

        --LOG SEGMENT
        INSERT INTO MC_SEGMENT (StartDateTimeStamp, EndDateTimeStamp, SegmentInstance, Completed, SourceFileID, Segment, RecordsProcessed, SysProcessedLogID)
        SELECT GETDATE(),@ZDATAENDDATE,''' + @REPTABLENAME + ''',@ZDATASTATUS,' + CAST(@SOURCEFILEID AS VARCHAR(100)) + ', ''REPLICA TRANSFER'',@ZRECORDSPROCESSED,@SYSPROCESSEDLOGID
        WHERE NOT EXISTS (SELECT 1 FROM MC_SEGMENT WITH(NOLOCK) WHERE SEGMENT = ''REPLICA TRANSFER'' AND SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID AND SEGMENTINSTANCE = ''' + @REPTABLENAME + ''')
         
        IF (@@ERROR <> 0) GOTO E_ERROR

        IF @ZDATAENDDATE IS NOT NULL
        BEGIN
                PRINT ''COMPLETE.  NO DATA TO LOAD''
                GOTO E_ERROR
        END


        --<BEG>----------------LOG STEP
        PRINT ''[300-->END CHECK SEGMENT STATUS]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[300-->END CHECK SEGMENT STATUS]'')
        --<END>----------------LOG STEP

        '

SELECT @PROCSQL4 = '
        ------------------------------------------------------------------------------------
        --400
        --BUILD BAD TEXT FILE
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
        PRINT ''[400-->BEG BUILD SQLLDR BAD]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[400-->BEG BUILD SQLLDR BAD]'')
        --<END>----------------LOG STEP

        IF @MANAGEDEXECUTIONIND = 0
        BEGIN
                SET @TEXT = ''osql -SSBGETL -E -Q "" -o "' + @BADPATH + '" -l500 ''
                EXEC MASTER..XP_CMDSHELL @TEXT, NO_OUTPUT
        END

        --<BEG>----------------LOG STEP
        PRINT ''[400-->END BUILD SQLLDR BAD]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[400-->END BUILD SQLLDR BAD]'')
        --<END>----------------LOG STEP

'

SELECT @PROCSQL4_5 = '
        ------------------------------------------------------------------------------------
        --450
        --GET CONNECTION INFO
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
        PRINT ''[450-->BEG GET CONNECTION INFO]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[450-->BEG GET CONNECTION INFO]'')
        --<END>----------------LOG STEP



        IF @MANAGEDEXECUTIONIND = 0
        BEGIN
                DECLARE @OBJECT INT
                DECLARE @HR INT
                DECLARE @PROPERTY VARCHAR(255)
                DECLARE @RETURN VARCHAR(255)
                DECLARE @SRC VARCHAR(255), @DESC VARCHAR(255)
                DECLARE @KEY VARCHAR(100)
                DECLARE @HERR VARCHAR(200)

                SELECT @KEY = CHAR(116) + CHAR(104) + CHAR(105) + CHAR(110) + CHAR(107) + CHAR(80) + CHAR(97) + CHAR(100)
                
                -- CREATE AN OBJECT.
                EXEC @HR = SP_OACREATE ''CORECONNECTIONMANAGER.CONNECTION'', @OBJECT OUT
                IF @HR <> 0
                BEGIN
                   EXEC SP_OAGETERRORINFO @OBJECT, @SRC OUT, @DESC OUT 
                   PRINT CONVERT(VARBINARY(4),@HR)
                   PRINT @SRC
                   PRINT @DESC
                   RAISERROR (''' + @REPTABLENAME + ' FAILED AT 450.  UNABLE TO GET ORA CONNECTION INFORMATION FROM CONNECTIONMANAGER DLL.'', 16, 1)
                   GOTO E_ERROR
                END
                

                -- CALL A METHOD THAT RETURNS A VALUE.
                EXEC @HR = SP_OAMETHOD @OBJECT, ''FNORAINF'', @RETURN OUT, @ORASV OUT, @ORAUN OUT, @ORAPW OUT, @HERR OUT, @KEY
 
                IF @HR <> 0
                BEGIN
                   EXEC SP_OAGETERRORINFO @OBJECT, @SRC OUT, @DESC OUT 
                   PRINT CONVERT(VARBINARY(4),@HR)
                   PRINT @SRC
                   PRINT @DESC
                   RAISERROR (''' + @REPTABLENAME + ' FAILED AT 450.  UNABLE TO GET ORA CONNECTION INFORMATION FROM CONNECTIONMANAGER DLL.'', 16, 1)
                   GOTO E_ERROR
                END

                IF @RETURN = ''False''
                BEGIN
                   PRINT @HERR
                   RAISERROR (''' + @REPTABLENAME + ' FAILED AT 450.  UNABLE TO GET ORA CONNECTION INFORMATION FROM CONNECTIONMANAGER DLL.'', 16, 1)
                   GOTO E_ERROR
                END
                
                -- DESTROY THE OBJECT.
                EXEC @HR = SP_OADESTROY @OBJECT
                IF @HR <> 0
                BEGIN
                   EXEC SP_OAGETERRORINFO @OBJECT, @SRC OUT, @DESC OUT 
                   PRINT CONVERT(VARBINARY(4),@HR)
                   PRINT @SRC
                   PRINT @DESC
                   RAISERROR (''' + @REPTABLENAME + ' FAILED AT 450.  UNABLE TO GET ORA CONNECTION INFORMATION FROM CONNECTIONMANAGER DLL.'', 16, 1)
                   GOTO E_ERROR
                END
                
        END

        --<BEG>----------------LOG STEP
        PRINT ''[450-->END GET CONNECTION INFO]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[450-->END GET CONNECTION INFO]'')
        --<END>----------------LOG STEP
'

SELECT @PROCSQL5 = '
        ------------------------------------------------------------------------------------
        --500
        --BUILD CTL FILE
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
        PRINT ''[500-->BEG BUILD SQLLDR CTL]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[500-->BEG BUILD SQLLDR CTL]'')
        --<END>----------------LOG STEP


        SET @CTLTEXT = ''ECHO LOAD DATA > ' + @CTLPATH + '''
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = ''ECHO INFILE ''''' + @STAGEOUTPUTFOLDER + '\SQLLDR_TXT\' + @REPTABLENAME + '.txt'''' >> ' + @CTLPATH + '''
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = ''ECHO BADFILE ''''' + @STAGEOUTPUTFOLDER + '\SQLLDR_BAD\' + @REPTABLENAME + '.bad'''' >> ' + @CTLPATH + '''
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = ''ECHO DISCARDFILE ''''' + @STAGEOUTPUTFOLDER + '\SQLLDR_DIS\' + @REPTABLENAME + '.dis'''' >> ' + @CTLPATH + '''
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = ''ECHO INSERT' + ' >> ' + @CTLPATH + '''
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = ''ECHO INTO TABLE SBGSTAGE.' + @REPTABLENAME + ' >> ' + @CTLPATH + '''
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = ''ECHO FIELDS TERMINATED BY ''''^<--REPDLMTR--^>''''' + ' >> ' + @CTLPATH + '''
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = ''ECHO  TRAILING NULLCOLS' + ' >> ' + @CTLPATH + '''
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = ''ECHO (' + ' >> ' + @CTLPATH + '''
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = ''ECHO ' + @STAGECOLUMNS + ' >> ' + @CTLPATH + '''
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = ''ECHO )' + ' >> ' + @CTLPATH + '''
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        IF (@@ERROR <> 0) GOTO E_ERROR

        --<BEG>----------------LOG STEP
        PRINT ''[500-->END BUILD SQLLDR CTL]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[500-->END BUILD SQLLDR CTL]'')
        --<END>----------------LOG STEP

'


SELECT @PROCSQL7 = '
        ------------------------------------------------------------------------------------
        --700
        --BUILD ORACLE STAGING OBJECTS
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
        PRINT ''[700-->BEG BUILD ORA OBJECTS]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[700-->BEG BUILD ORA OBJECTS]'')
        --<END>----------------LOG STEP

        CREATE TABLE #OUTPUT (RESULT VARCHAR(255))

        --BUILD COMMAND TO EXECUTE ORACLE PROC
        SELECT @CMD =  ''ECHO EXEC SBGSTAGE.CR_STAGE_OBJECTS ( ' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ', ''''' + @CORTABLENAME + ''''', ''''' + @STAGECOLUMNS + ''''' );| SQLPLUS '' + @ORAUN + ''/'' + @ORAPW + ''@'' + @ORASV 
 
        --EXECUTE COMMAND INTO TEMP TABLE
        INSERT INTO #OUTPUT EXEC @RSLTS = MASTER..XP_CMDSHELL @CMD

        IF (@@ERROR <> 0) GOTO E_ERROR

        --SEARCH FOR ERRORS
        IF (SELECT COUNT(*) FROM #OUTPUT WHERE RESULT LIKE ''%ORA-%'') <> 0 OR @RSLTS <> 0
        BEGIN


                DECLARE CRSR_RESULTS CURSOR FOR SELECT RESULT FROM #OUTPUT
                OPEN CRSR_RESULTS
                SELECT @ERRORRESULTS = ''''
                FETCH Next FROM CRSR_RESULTS INTO @OUTPUT
                WHILE @@FETCH_STATUS=0
                BEGIN
                        SELECT @ERRORRESULTS = @ERRORRESULTS + CASE WHEN @OUTPUT IS NOT NULL THEN @OUTPUT + CHAR(13) + CHAR(10) ELSE '''' END
                        FETCH Next FROM CRSR_RESULTS INTO @OUTPUT
                END
                CLOSE CRSR_RESULTS
                DEALLOCATE CRSR_RESULTS

                RAISERROR (''REP_' + @REPTABLENAME + ' FAILED AT 700.  ORACLE PROCEDURE CR_STAGE_OBJECTS FAILED.'', 16, 1)
                GOTO E_ERROR
        END


        --<BEG>----------------LOG STEP
        PRINT ''[700-->END BUILD ORA OBJECTS]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[700-->END BUILD ORA OBJECTS]'')
        --<END>----------------LOG STEP

'

SELECT @PROCSQL8 = '
        ------------------------------------------------------------------------------------
        --800
        --FILTER AND LOG DUPLICATES
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
        PRINT ''[800-->BEG LOG DUPLICATES]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[800-->BEG LOG DUPLICATES]'')
        --<END>----------------LOG STEP


        CREATE TABLE [#TEMP2] ( [CNT] VARCHAR(150) ) 
        '

        --BUILD SQL TO RETRIEVE SQL TO DETERMIN DUPLICATES
        TRUNCATE TABLE #TEMP
        set @ORASQL = N'INSERT INTO #TEMP SELECT * FROM OPENQUERY(CORE,''SELECT DISTINCT COLUMN_NAME FROM SYS.ALL_CONSTRAINTS A, ALL_CONS_COLUMNS B WHERE A.CONSTRAINT_NAME = B.CONSTRAINT_NAME AND A.CONSTRAINT_TYPE=''''P'''' AND A.TABLE_NAME = ''''' + @CORTABLENAME + ''''' '')'
        EXECUTE  sp_executesql @ORASQL


        --LOOP THROUGH RESULTS
        SET @SQL = ''
        SET @COLS = ''
        SET @FINALSQL = ''
        

        
        
        OPEN CRSR_CONSTS
        FETCH Next FROM CRSR_CONSTS INTO @COL_NAME
        
        WHILE @@FETCH_STATUS=0
        BEGIN

                SELECT @SQL = @SQL + @COL_NAME
                SELECT @COLS = @COLS + 'A.' + @COL_NAME + ' = B.' + @COL_NAME + ' '
        	FETCH Next FROM CRSR_CONSTS INTO @COL_NAME
                IF @@FETCH_STATUS=0
                BEGIN
                        SELECT @SQL = @SQL + ','
                        SELECT @COLS = @COLS + ' and '
                END 
        END
        CLOSE CRSR_CONSTS
        

        --BUILD FINAL SQL TO GRAB DUPLICATED RECORDS
        SELECT @PROCSQL8 = @PROCSQL8 + '
        --LOAD DUPS INTO TEMP TABLE
        INSERT INTO #TEMP2 SELECT COUNT(*) AS CNT FROM (SELECT ' + @SQL + ' FROM COREETL.DBO.' + @CORTABLENAME + ' where REC_INSRT_NAME = ''' +  CAST(@REPLOADTABLEID AS VARCHAR(100)) + ''' group by ' + @SQL + ' having count(*) > 1) JJ

        IF (@@ERROR <> 0) GOTO E_ERROR

        --LOG RECORDS FOUND IN THE REPERRORLOG
        SELECT @CNT = CNT FROM #TEMP2
        
        IF (@@ERROR <> 0) GOTO E_ERROR

        IF @CNT > 0 
        BEGIN
                BEGIN TRAN T1

                INSERT INTO COREERRLOG.DBO.REPERRORLOG (ERRORDATE,ERRORMESSAGE,ERRORDATA,LOGID,ERRORSOURCE,SYSTEM)VALUES(GETDATE(),''DUPLICATE RECORDS DETECTED IN ' + @CORTABLENAME + ''',''REFER TO ERR TABLE'',''' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ''',''REP'',''' + RTRIM(@ALPHASYSTEM) + '''); 

                INSERT INTO COREERRLOG.DBO.ERR_' + RIGHT(@CORTABLENAME, LEN(@CORTABLENAME) - 4) + ' SELECT A.*, (SELECT TOP 1 @@IDENTITY FROM COREERRLOG.DBO.REPERRORLOG) FROM COREETL.DBO.' + @CORTABLENAME + ' A INNER JOIN (SELECT ' + @SQL + ' FROM COREETL.DBO.' + @CORTABLENAME + ' WHERE REC_INSRT_NAME = ' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ' GROUP BY ' + @SQL + ' HAVING COUNT(*) > 1) B ON ' + @COLS + ' WHERE A.REC_INSRT_NAME = ' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + '; 

                DELETE COREETL.DBO.' + @CORTABLENAME + ' FROM COREETL.DBO.' + @CORTABLENAME + ' A INNER JOIN (SELECT ' + @SQL + ' FROM COREETL.DBO.' + @CORTABLENAME + ' WHERE REC_INSRT_NAME = ' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ' GROUP BY ' +  @SQL + ' HAVING COUNT(*) > 1) B ON ' + @COLS + ' WHERE A.REC_INSRT_NAME = ' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ';

                COMMIT TRAN T1

                IF (@@ERROR <> 0) GOTO E_ERROR
        END 

        DROP TABLE #TEMP2



        --<BEG>----------------LOG STEP
        PRINT ''[800-->END LOG DUPLICATES]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[800-->END LOG DUPLICATES]'')
        --<END>----------------LOG STEP

'

SELECT @PROCSQL9 = '
        ------------------------------------------------------------------------------------
        --900
        --EXPORT ETL TO TEXT FILES
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
        PRINT ''[900-->BEG EXTRACT TO TEXT]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[900-->BEG EXTRACT TO TEXT]'')
        --<END>----------------LOG STEP


        '

        SELECT @COLLISTSQL = DBO.REP_CTLFORMATCOLS(@STAGECOLUMNS,@CORTABLENAME,@UPPERLOWERCASE)


        SELECT @VIEWSQL1 = '
        --DROP OLD VIEW
        IF EXISTS (SELECT * FROM SYSOBJECTS WHERE ID = OBJECT_ID(N''REP_' + @REPTABLENAME + ''') AND OBJECTPROPERTY(ID, N''ISVIEW'') = 1)
        BEGIN
                DROP VIEW REP_' + @REPTABLENAME + '
        END'
        
        SELECT @VIEWSQL2 = '
        --BUILD NEW VIEW
        CREATE VIEW REP_' + @REPTABLENAME + ' AS SELECT ' + @COLLISTSQL + ' from COREETL.DBO.' + @CORTABLENAME + ' where REC_INSRT_NAME = ''' + cast(@REPLOADTABLEID as varchar(100)) + ''''

        SELECT @PROCSQL9 = @PROCSQL9 + '
        
        --EXECUTE BCP
        CREATE TABLE #BCPOUTPUT (RESULT VARCHAR(255))

        set @CMD = ''bcp "SELECT * from CORE1.DBO.REP_' + @REPTABLENAME + '" queryout ' + @STAGEOUTPUTFOLDER + '\SQLLDR_TXT\' + @REPTABLENAME + '.TXT -SSBGETL -T -c -t"<--REPDLMTR-->"''

        INSERT INTO #BCPOUTPUT EXEC @RSLTS = MASTER..XP_CMDSHELL @CMD

        IF (@@ERROR <> 0) GOTO E_ERROR


        IF @RSLTS <> 0
        BEGIN

                DECLARE CRSR_RESULTS CURSOR FOR SELECT RESULT FROM #BCPOUTPUT
                OPEN CRSR_RESULTS
                SELECT @ERRORRESULTS = ''''
                FETCH Next FROM CRSR_RESULTS INTO @OUTPUT
                WHILE @@FETCH_STATUS=0
                BEGIN
                        SELECT @ERRORRESULTS = @ERRORRESULTS + CASE WHEN @OUTPUT IS NOT NULL THEN @OUTPUT + CHAR(13) + CHAR(10) ELSE '''' END
                        FETCH Next FROM CRSR_RESULTS INTO @OUTPUT
                END
                CLOSE CRSR_RESULTS
                DEALLOCATE CRSR_RESULTS

                PRINT @ERRORRESULTS

                RAISERROR (''REP_' + @REPTABLENAME + ' FAILED AT 900.  BCP FAILED.'', 16, 1)
                GOTO E_ERROR
        END


        --<BEG>----------------LOG STEP
        PRINT ''[900-->END EXTRACT TO TEXT]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[900-->END EXTRACT TO TEXT]'')
        --<END>----------------LOG STEP'





SELECT @PROCSQL10 = '
        ------------------------------------------------------------------------------------
        --950
        --RUN SQLLDR
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
        PRINT ''[950-->BEG RUN SQLLDR]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[950-->BEG RUN SQLLDR]'')
        --<END>----------------LOG STEP


        CREATE TABLE #SQLLDROUTPUT (RESULT VARCHAR(255))
        CREATE TABLE #SQLLDRINPUT (RESULT VARCHAR(2555))

        --BUILD COMMAND TO EXECUTE ORACLE PROC
        SELECT @CMD = ''E:\Coretrans\MCP\sqlldr.exe '' +  @ORAUN + ''/'' + @ORAPW + ''@'' + @ORASV + '' errors=' + CAST(@ERRORCOUNT AS VARCHAR(100)) + ' direct=true control=' + @STAGEOUTPUTFOLDER + '\SQLLDR_CTL\' + @REPTABLENAME + '.CTL log=' + @STAGEOUTPUTFOLDER + '\SQLLDR_LOG\' + @REPTABLENAME + '.log''
        

        --EXECUTE COMMAND INTO TEMP TABLE
        INSERT INTO #SQLLDROUTPUT EXEC @RSLTS = MASTER..XP_CMDSHELL @CMD


        IF (@@ERROR <> 0) GOTO E_ERROR

        --SEARCH FOR ERRORS
        IF  @RSLTS in (0,2)
        BEGIN

                SELECT @CMD = ''BULK INSERT #SQLLDRINPUT FROM ''''' + @STAGEOUTPUTFOLDER + '\SQLLDR_LOG\' + @REPTABLENAME + '.LOG'''' WITH (ROWTERMINATOR = ''''\n'''')''
                EXEC SP_EXECUTESQL @CMD

                IF (@@ERROR <> 0) GOTO E_ERROR

                SELECT @RECORDSLOADED = CASE WHEN result like ''%Rows successfully loaded.'' THEN CAST(ltrim(rtrim(replace(result,''Rows successfully loaded.'',''''))) AS INT) WHEN result like ''%Row successfully loaded.'' THEN CAST(ltrim(rtrim(replace(result,''Row successfully loaded.'',''''))) AS INT) END FROM #SQLLDRINPUT where result like ''%Rows successfully loaded.'' OR  result like ''%Row successfully loaded.''

                IF (@@ERROR <> 0) GOTO E_ERROR

                SELECT @RECORDSERRORED = CASE WHEN result like ''%Rows not loaded due to data errors.'' THEN CAST(ltrim(rtrim(replace(result,''Rows not loaded due to data errors.'',''''))) AS INT) WHEN result like ''%Row not loaded due to data errors.'' THEN CAST(ltrim(rtrim(replace(result,''Row not loaded due to data errors.'',''''))) AS INT) END FROM #SQLLDRINPUT where result like ''%Rows not loaded due to data errors.'' OR  result like ''%Row not loaded due to data errors.''

                IF (@@ERROR <> 0) GOTO E_ERROR

                IF @RECORDSLOADED IS NULL
                BEGIN
                        RAISERROR (''REP_' + @REPTABLENAME + ' FAILED AT 950.  SQLLDR FAILED 001'', 16, 1)
                        GOTO E_ERROR
                END

                IF @RECORDSERRORED > ' + CAST(@ERRORCOUNT AS VARCHAR(100)) + '
                BEGIN
                        RAISERROR (''REP_' + @REPTABLENAME + ' FAILED AT 950.  SQLLDR EXCEEDED ALLOWED NUMBER OF ERRORS AS SPECIFIED IN PRM_REPLOADTABLES.'', 16, 1)
                        GOTO E_ERROR
                END

        END 
        ELSE
        BEGIN'
select @PROCSQL10_5 = '

                DECLARE CRSR_RESULTS CURSOR FOR SELECT RESULT FROM #SQLLDROUTPUT
                OPEN CRSR_RESULTS
                SELECT @ERRORRESULTS = ''''
                FETCH Next FROM CRSR_RESULTS INTO @OUTPUT
                WHILE @@FETCH_STATUS=0
                BEGIN
                        SELECT @ERRORRESULTS = @ERRORRESULTS + CASE WHEN @OUTPUT IS NOT NULL THEN @OUTPUT + CHAR(13) + CHAR(10) ELSE '''' END
                        FETCH Next FROM CRSR_RESULTS INTO @OUTPUT
                END
                CLOSE CRSR_RESULTS
                DEALLOCATE CRSR_RESULTS

                PRINT @ERRORRESULTS

                IF (@@ERROR <> 0) GOTO E_ERROR

                RAISERROR (''REP_' + @REPTABLENAME + ' FAILED AT 950.  SQLLDR FAILED 002.'', 16, 1)
                GOTO E_ERROR
        END



        DROP TABLE #SQLLDROUTPUT
        DROP TABLE #SQLLDRINPUT

        --<BEG>----------------LOG STEP
        PRINT ''[950-->END RUN SQLLDR]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[950-->END RUN SQLLDR]'')
        --<END>----------------LOG STEP

'

SELECT @PROCSQL11 = '
        ------------------------------------------------------------------------------------

        --1000
        --CHECK FOR SQLLDR ERRORS
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
        PRINT ''[1000-->BEG LOG SQLLDR ERRORS]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[1000-->BEG LOG SQLLDR ERRORS]'')
        --<END>----------------LOG STEP

        SELECT TOP 0 ' + @STAGECOLUMNS + ' INTO #TEMPSQLLDRERROR FROM COREETL.DBO.' + @CORTABLENAME + '

        IF (@@ERROR <> 0) GOTO E_ERROR

        BULK INSERT #TEMPSQLLDRERROR FROM ''' + @STAGEOUTPUTFOLDER + '\SQLLDR_BAD\' + @REPTABLENAME + '.bad''' + ' WITH (FIELDTERMINATOR = ''<--REPDLMTR-->'',ROWTERMINATOR = ''\n'')

        IF (@@ERROR <> 0) GOTO E_ERROR

        INSERT INTO COREERRLOG.DBO.REPERRORLOG (ERRORDATE, ERRORMESSAGE, ERRORDATA,ERRORSOURCE,SYSTEM) SELECT GETDATE(),''SQLLDR WAS UNABLE TO LOAD '' + CAST(COUNT(*) AS VARCHAR(100)) + '' RECORD(S) INTO ' + @CORTABLENAME + ' DUE TO A SQLLDR ERROR'',''REFER TO ERR TABLE FOR DETAIL'',''REP'',''' + RTRIM(@ALPHASYSTEM) + ''' FROM #TEMPSQLLDRERROR HAVING COUNT(*) > 0
                                                                                                                                                                                                                
        IF (@@ERROR <> 0) GOTO E_ERROR

        SELECT @ERRORID = @@IDENTITY FROM coreerrlog.dbo.reperrorlog

        IF (@@ERROR <> 0) GOTO E_ERROR
	'

SELECT @PROCSQL11_5 = '
        INSERT INTO COREERRLOG.DBO.' + REPLACE(@CORTABLENAME,'COR_','ERR_') + '
        (' + @STAGECOLUMNS + ',ADU,DATETIMESTAMP,REPERRORID)
        SELECT ' + @STAGECOLUMNS + ',''A'',GETDATE(),@ERRORID 
        FROM #TEMPSQLLDRERROR

        IF (@@ERROR <> 0) GOTO E_ERROR

        --<BEG>----------------LOG STEP
        PRINT ''[1000-->END LOG SQLLDR ERRORS]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[1000-->END LOG SQLLDR ERRORS]'')
        --<END>----------------LOG STEP

'

SELECT @PROCSQL12 = '
        ------------------------------------------------------------------------------------
        --1100
        --WAIT FOR PARENTS TO COMPLETE
        ------------------------------------------------------------------------------------

        --<BEG>----------------LOG STEP
        PRINT ''[1100-->BEG WAIT FOR PARENTS]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[1100-->BEG WAIT FOR PARENTS]'')
        --<END>----------------LOG STEP

        SET @PARENTSCOMPLETE = 0
        
        --LOOP UNTIL ALL PARENTS ARE COMPLETED
        WHILE @PARENTSCOMPLETE <> 1
        BEGIN
                --SEE IF ANY PARENT TABLES ARE STILL RUNNING
                select @iPendingParent = COUNT(*) 
                from 
                prm_reploadtables a
                inner join
                prm_repparentprecedence b
                on
                a.repcoretableid = b.repcoretableid
                and b.parentid in (select repcoretableid from prm_reploadtables with(nolock) where systemid = ' + CAST(@SYSTEMID AS VARCHAR(100)) + ')
                inner join
                prm_repcoretables c
                on b.parentid = c.repcoretableid
                inner join
                prm_reploadtables d
                on c.repcoretableid = d.repcoretableid
		and d.systemid = ' + CAST(@SYSTEMID AS VARCHAR(100)) + '
                where
                not exists(select 1 from mc_segment z with(nolock) where z.segmentinstance = dbo.REP_STAGENAME(c.coretablename,d.reploadtableid) and z.segment = ''REPLICA TRANSFER'' and z.sysprocessedlogid = @SYSPROCESSEDLOGID and z.completed = ''T'')
                and a.reploadtableid = ' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + '
                
                IF (@@ERROR <> 0) GOTO E_ERROR
                
                --SEE IF ANY TABLE LEVEL PRECEDENT-BASED TABLES ARE STILL RUNNING
                select @iPendingTableParent = count(*) 
                from 
                prm_reploadtables a
                inner join
                prm_reploadtables c
                on a.tablelevelprecedence = c.reploadtableid
                inner join
                prm_repcoretables b
                on c.repcoretableid = b.repcoretableid
                where
                not exists(select 1 from mc_segment z with(nolock) where z.segmentinstance = dbo.REP_STAGENAME(b.coretablename,a.tablelevelprecedence) and z.segment = ''REPLICA TRANSFER'' and z.sysprocessedlogid = @SYSPROCESSEDLOGID and z.completed = ''T'')
                and a.reploadtableid = ' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + '
                
                IF (@@ERROR <> 0) GOTO E_ERROR

                IF  @iPendingTableParent + @iPendingParent > 0 
                BEGIN
                        select @PARENTSCOMPLETE = 0
                        WAITFOR DELAY ''00:00:30''
                END 
                ELSE
                BEGIN
                        SELECT @PARENTSCOMPLETE = 1
                END
        
               
        END


        --<BEG>----------------LOG STEP
        PRINT ''[1100-->END WAIT FOR PARENTS]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[1100-->END WAIT FOR PARENTS]'')
        --<END>----------------LOG STEP


'

SELECT @PROCSQL13 = '
        ------------------------------------------------------------------------------------
        --1200
        --FILTER ORACLE ERRORS
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
        PRINT ''[1200-->BEG FILTER ORACLE ERRORS]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[1200-->BEG FILTER ORACLE ERRORS]'')
        --<END>----------------LOG STEP

	        -- UPDATE STARTDATETIMESTAMP IN MC_SEGMENT TO REFLECT WHEN ERROR CHECKING BEGINS
                UPDATE MC_SEGMENT
                SET STARTDATETIMESTAMP = GETDATE()
                WHERE SEGMENT = ''REPLICA TRANSFER'' AND SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID AND SEGMENTINSTANCE = ''' + @REPTABLENAME + '''

        '

        --DON'T FILTER ERRORS IF THIS IS CORE_JOB_ID
        --COR_JOB_ID HAS A CONSTRAINT THAT POINTS TO ITSELF.  THE FOLLOWING CODE ADDRESSES THIS.
	--COR_ASSET_SOURCE_DETAIL TAKES AN EXTRAORDINARY LONG TIME TO RUN.  DON'T FILTER ERRORS.
	--COR_X_FUND_DETAIL TAKES AN EXTRAORDINARY LONG TIME TO RUN.  DON'T FILTER ERRORS.

        IF @CORTABLENAME <> 'COR_JOB'
	AND @CORTABLENAME <> 'COR_ASSET_SOURCE_DETAIL'
	AND @CORTABLENAME <> 'COR_X_FUND_DETAIL'
        BEGIN

SELECT @PROCSQL13_5 = '        
                CREATE TABLE #LOAD0RAOUTPUT (RESULT VARCHAR(255))
                CREATE TABLE #ERRCOUNT (RESULT VARCHAR(255))

                --BUILD COMMAND TO EXECUTE ORACLE PROC
                SELECT @CMD =  ''ECHO EXEC SBGSTAGE.SPE_' + @REPTABLENAME + ';| SQLPLUS '' + @ORAUN + ''/'' + @ORAPW + ''@'' + @ORASV 

                IF (@@ERROR <> 0) GOTO E_ERROR
        
                --EXECUTE COMMAND INTO TEMP TABLE
                INSERT INTO #LOAD0RAOUTPUT EXEC @RSLTS = MASTER..XP_CMDSHELL @CMD
        
                IF (@@ERROR <> 0) GOTO E_ERROR
        
                --SEARCH FOR ERRORS 
                IF (SELECT COUNT(*) FROM #LOAD0RAOUTPUT WHERE RESULT LIKE ''%ORA-%'') = 0 AND @RSLTS = 0
                BEGIN
        
                        SELECT @CMD = N''SELECT CNT FROM OPENQUERY(CORE,''''SELECT COUNT(*) AS CNT FROM SBGSTAGE.BAD_' + @REPTABLENAME + ''''')''
                        INSERT INTO #ERRCOUNT EXEC SP_EXECUTESQL @CMD                
        
                        IF (@@ERROR <> 0) GOTO E_ERROR

                        IF (SELECT RESULT FROM #ERRCOUNT) > ' + CAST(@ERRORCOUNT AS VARCHAR(100)) + '
                        BEGIN
                                RAISERROR (''REP_' + @REPTABLENAME + ' FAILED AT 1200.  ORACLE SPE PROC FAILED.  EXCEEDED MAX ALLOWED ERRORS'', 16, 1)
                                GOTO E_ERROR
                        END
                END 
                ELSE
                BEGIN


                        DECLARE CRSR_RESULTS CURSOR FOR SELECT RESULT FROM #LOAD0RAOUTPUT
                        OPEN CRSR_RESULTS
                        SELECT @ERRORRESULTS = ''''
                        FETCH Next FROM CRSR_RESULTS INTO @OUTPUT
                        WHILE @@FETCH_STATUS=0
                        BEGIN
                                SELECT @ERRORRESULTS = @ERRORRESULTS + CASE WHEN @OUTPUT IS NOT NULL THEN @OUTPUT + CHAR(13) + CHAR(10) ELSE '''' END
                                FETCH Next FROM CRSR_RESULTS INTO @OUTPUT
                        END
                        CLOSE CRSR_RESULTS
                        DEALLOCATE CRSR_RESULTS
        
                        PRINT @ERRORRESULTS

                        IF (@@ERROR <> 0) GOTO E_ERROR

                        RAISERROR (''REP_' + @REPTABLENAME + ' FAILED AT 1200.  ORACLE SPE PROC FAILED.'', 16, 1)
                        GOTO E_ERROR
                END

                DROP TABLE #LOAD0RAOUTPUT
                DROP TABLE #ERRCOUNT'

        END

        SELECT @PROCSQL13_5 = @PROCSQL13_5 + '
        --DROP TABLE #LOAD0RAOUTPUT
        --DROP TABLE #ERRCOUNT



        --<BEG>----------------LOG STEP
        PRINT ''[1200-->END FILTER ORACLE ERRORS]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[1200-->END FILTER ORACLE ERRORS]'')
        --<END>----------------LOG STEP

'

SELECT @PROCSQL14 = '
        ------------------------------------------------------------------------------------
        --1300
        --LOAD ORACLE
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
        PRINT ''[1300-->BEG LOAD CORE]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[1300-->BEG LOAD CORE]'')
        --<END>----------------LOG STEP


        CREATE TABLE #LOUTPUT (RESULT VARCHAR(255))
        CREATE TABLE #LLOADCOUNT (RESULT VARCHAR(255))


        --BUILD COMMAND TO EXECUTE ORACLE PROC
        SELECT @CMD =  ''ECHO EXEC SBGSTAGE.' + @PROC + @REPTABLENAME +';| SQLPLUS '' + @ORAUN + ''/'' + @ORAPW + ''@'' + @ORASV 
 
        IF (@@ERROR <> 0) GOTO E_ERROR

        --EXECUTE COMMAND INTO TEMP TABLE
        INSERT INTO #LOUTPUT EXEC @RSLTS = MASTER..XP_CMDSHELL @CMD

        IF (@@ERROR <> 0) GOTO E_ERROR

        --SEARCH FOR ERRORS 
        IF (SELECT COUNT(*) FROM #LOUTPUT WHERE RESULT LIKE ''%ORA-%'') = 0 AND @RSLTS = 0
        BEGIN

                SELECT @CMD = N''SELECT CNT FROM OPENQUERY(CORE,''''SELECT COUNT(*) AS CNT FROM SBGSTAGE.' + @REPTABLENAME + ''''')''
                INSERT INTO #LLOADCOUNT EXEC SP_EXECUTESQL @CMD             

                IF (@@ERROR <> 0) GOTO E_ERROR

                --UPDATE MASTERGENID.COREMASTER.DBO.REP_TABLELOCK SET LOCKFLAG = 0,SUBSYSTEM = NULL WHERE CORETABLENAME = ''' + @CORTABLENAME + ''' AND SUBSYSTEM = @@SERVERNAME
                
                --IF (@@ERROR <> 0) GOTO E_ERROR

        END 
        ELSE
        BEGIN


                DECLARE CRSR_RESULTS CURSOR FOR SELECT RESULT FROM #LOUTPUT
                OPEN CRSR_RESULTS
                SELECT @ERRORRESULTS = ''''
                FETCH Next FROM CRSR_RESULTS INTO @OUTPUT
                WHILE @@FETCH_STATUS=0
                BEGIN
                        SELECT @ERRORRESULTS = @ERRORRESULTS + CASE WHEN @OUTPUT IS NOT NULL THEN @OUTPUT + CHAR(13) + CHAR(10) ELSE '''' END
                        FETCH Next FROM CRSR_RESULTS INTO @OUTPUT
                END
                CLOSE CRSR_RESULTS
                DEALLOCATE CRSR_RESULTS

                PRINT @ERRORRESULTS

                IF (@@ERROR <> 0) GOTO E_ERROR

                RAISERROR (''REP_' + @REPTABLENAME + ' FAILED AT 1300.  ORACLE LOAD PROC FAILED.'', 16, 1)
                GOTO E_ERROR
        END



        --<BEG>----------------LOG STEP
        PRINT ''[1300-->END LOAD CORE]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[1300-->END LOAD CORE]'')
        --<END>----------------LOG STEP

'

SELECT @PROCSQL15 = '

        ------------------------------------------------------------------------------------
        --1350
        --LOG ORACLE LOAD ERRORS DETECTED BY FILTER ERROR STEP
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
        PRINT ''[1350-->BEG LOG ORA ERRORS]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[1350-->BEG LOG ORA ERRORS]'')
        --<END>----------------LOG STEP


        CREATE TABLE #QLOADCOUNT (RESULT VARCHAR(255))


        SELECT @CMD = ''INSERT INTO COREERRLOG.DBO.REPERRORLOG (ERRORDATE, ERRORMESSAGE, ERRORDATA,ERRORSOURCE,SYSTEM) SELECT GETDATE(),''''UNABLE TO LOAD '''' + CAST(CNT AS VARCHAR(100)) + '''' RECORD(S) INTO ' + @CORTABLENAME + ' DUE TO A PARENT KEY CONSTRAINT ERROR'''',''''REFER TO ERR TABLE FOR DETAIL'''',''''REP'''',''''' + RTRIM(@ALPHASYSTEM) + ''''' FROM OPENQUERY(CORE,''''SELECT COUNT(*) AS CNT FROM SBGSTAGE.BAD_' + @REPTABLENAME + ''''') WHERE CNT > 0''
        EXEC SP_EXECUTESQL @CMD

        IF (@@ERROR <> 0) GOTO E_ERROR

        SELECT @ERRORID = @@IDENTITY FROM COREERRLOG.DBO.REPERRORLOG

        IF (@@ERROR <> 0) GOTO E_ERROR

        SELECT @CMD = ''INSERT INTO COREERRLOG.DBO.' + REPLACE(@CORTABLENAME,'COR_','ERR_') + '
        (' + @STAGECOLUMNS + ',ADU,DATETIMESTAMP,REPERRORID)' +
        ' SELECT ' + @STAGECOLUMNS + ',''''A'''',GETDATE(),'' + cast(@ERRORID as varchar(100)) + '' FROM OPENQUERY(CORE,''''SELECT * FROM SBGSTAGE.BAD_' + @REPTABLENAME + ''''')''
        EXEC SP_EXECUTESQL @CMD

        IF (@@ERROR <> 0) GOTO E_ERROR

        DROP TABLE #QLOADCOUNT



        --<BEG>----------------LOG STEP
        PRINT ''[1350-->END LOG ORA ERRORS]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[1350-->END LOG ORA ERRORS]'')
        --<END>----------------LOG STEP

'

SELECT @PROCSQL16 = '


        ------------------------------------------------------------------------------------
        --1400
        --COMPLETE SEGMENT
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
        PRINT ''[1400-->BEG COMPLETE SEGMENT]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[1400-->BEG COMPLETE SEGMENT]'')
        --<END>----------------LOG STEP


        UPDATE MC_SEGMENT
        SET ENDDATETIMESTAMP = GETDATE(),COMPLETED = ''T'', RECORDSPROCESSED = (SELECT RESULT FROM #LLOADCOUNT)
        WHERE SEGMENT = ''REPLICA TRANSFER'' AND SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID AND SEGMENTINSTANCE = ''' + @REPTABLENAME + '''

        IF (@@ERROR <> 0) GOTO E_ERROR


        --<BEG>----------------LOG STEP
        PRINT ''[1400-->END COMPLETE SEGMENT]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[1400-->END COMPLETE SEGMENT]'')
        --<END>----------------LOG STEP



        ------------------------------------------------------------------------------------
        --1500
        --RESET SPID FOR TRACKING PURPOSES
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
        PRINT ''[1500-->BEG RESET SPID]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[1500-->BEG RESET SPID]'')
        --<END>----------------LOG STEP


        UPDATE CORE1.DBO.PRM_REPLOADTABLES
        SET SPID_1 = NULL, PROCESSID = NULL
        WHERE REPLOADTABLEID = ' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + '

        IF (@@ERROR <> 0) GOTO E_ERROR

        --<BEG>----------------LOG STEP
        PRINT ''[1500-->END RESET SPID]' + CHAR(9) + ''' + CONVERT(VARCHAR(100),GETDATE(),101) + '' '' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + ',''' + @REPTABLENAME + ''',GETDATE(),''[1500-->END RESET SPID]'')
        --<END>----------------LOG STEP


CLEANUP:
RETURN

E_ERROR:
UPDATE CORE1.DBO.PRM_REPLOADTABLES
SET SPID_1 = NULL, PROCESSID = NULL
WHERE REPLOADTABLEID = ' + CAST(@REPLOADTABLEID AS VARCHAR(100)) + '
PRINT ''ERROR IS AS FOLLOWS: '' + @ERRORRESULTS

GOTO CLEANUP

RETURN
'

SELECT @SQL = '
IF EXISTS (SELECT * FROM SYSOBJECTS WHERE ID = OBJECT_ID(N''NREP_' + @REPTABLENAME + ''') AND OBJECTPROPERTY(ID, N''ISPROCEDURE'') = 1)
BEGIN
        DROP PROCEDURE ' + 'NREP_' + @REPTABLENAME + '
END'

-- 
-- PRINT @PROCSQL1
-- PRINT @PROCSQL2
-- PRINT @PROCSQL3
-- PRINT @PROCSQL4
-- PRINT @PROCSQL4_5
-- PRINT @PROCSQL5
-- PRINT @PROCSQL7
-- PRINT @PROCSQL8
-- PRINT @PROCSQL9
-- PRINT @PROCSQL10
-- PRINT @PROCSQL10_5
-- PRINT @PROCSQL11
-- PRINT @PROCSQL11_5
-- PRINT @PROCSQL12
-- PRINT @PROCSQL13
-- PRINT @PROCSQL13_5
-- PRINT @PROCSQL14
-- PRINT @PROCSQL15
-- PRINT @PROCSQL16


--MADE IT THIS FAR
SELECT @PROCSQL1 = REPLACE(@PROCSQL1,'''','''''') 
SELECT @PROCSQL2 = REPLACE(@PROCSQL2,'''','''''')
SELECT @PROCSQL3 = REPLACE(@PROCSQL3,'''','''''') 
SELECT @PROCSQL4 = REPLACE(@PROCSQL4,'''','''''') 
SELECT @PROCSQL4_5 = REPLACE(@PROCSQL4_5,'''','''''') 
SELECT @PROCSQL5 = REPLACE(@PROCSQL5,'''','''''') 
SELECT @PROCSQL7 = REPLACE(@PROCSQL7,'''','''''') 
SELECT @PROCSQL8 = REPLACE(@PROCSQL8,'''','''''')
SELECT @PROCSQL9 = REPLACE(@PROCSQL9,'''','''''') 
SELECT @PROCSQL10 = REPLACE(@PROCSQL10,'''','''''') 
SELECT @PROCSQL10_5 = REPLACE(@PROCSQL10_5,'''','''''') 
SELECT @PROCSQL11 = REPLACE(@PROCSQL11,'''','''''') 
SELECT @PROCSQL11_5 = REPLACE(@PROCSQL11_5,'''','''''') 
SELECT @PROCSQL12 = REPLACE(@PROCSQL12,'''','''''') 
SELECT @PROCSQL13 = REPLACE(@PROCSQL13,'''','''''') 
SELECT @PROCSQL13_5 = REPLACE(@PROCSQL13_5,'''','''''') 
SELECT @PROCSQL14 = REPLACE(@PROCSQL14,'''','''''') 
SELECT @PROCSQL15 =  REPLACE(@PROCSQL15,'''','''''') 
SELECT @PROCSQL16 =  REPLACE(@PROCSQL16,'''','''''') 


EXEC SP_EXECUTESQL @VIEWSQL1
EXEC SP_EXECUTESQL @VIEWSQL2
EXEC SP_EXECUTESQL @SQL

EXEC (N'EXEC SP_EXECUTESQL N''' + @PROCSQL1 +  @PROCSQL2 +  @PROCSQL3 +  @PROCSQL4 + @PROCSQL4_5 + @PROCSQL5 +  @PROCSQL7 +  @PROCSQL8 +  @PROCSQL9 +  @PROCSQL10 + @PROCSQL10_5 + @PROCSQL11 + @PROCSQL11_5 + @PROCSQL12 +  @PROCSQL13 +  @PROCSQL13_5 +  @PROCSQL14 +  @PROCSQL15 +  @PROCSQL16 + '''')

FETCH Next FROM CRSR_MAIN INTO @REPLOADTABLEID,@CORTABLENAME,@UPPERLOWERCASE,@REPTABLENAME,@SOURCEFILEID,@BADPATH,@CTLPATH,@STAGEOUTPUTFOLDER,@STAGECOLUMNS,@ERRORCOUNT,@PROC,@TABLELEVELLOADS,@MULTIIND
END
CLOSE CRSR_MAIN
DEALLOCATE CRSR_MAIN
DEALLOCATE CRSR_CONSTS


RETURN





GO
