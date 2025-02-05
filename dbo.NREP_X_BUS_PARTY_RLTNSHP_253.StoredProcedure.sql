USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[NREP_X_BUS_PARTY_RLTNSHP_253]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NREP_X_BUS_PARTY_RLTNSHP_253] (@SYSTEMID INT, @CONNECTIONID INT) AS
        SET NOCOUNT ON

        DECLARE @CTLTEXT VARCHAR(8000)
        DECLARE @CMD NVARCHAR(4000)
        DECLARE @CMD1 VARCHAR(4000)
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
		DECLARE @sql varchar(8000) 
		DECLARE @SYSPROCESSEDLOGID INT
		DECLARE @ORACLECONNECTION VARCHAR(255)
		DECLARE @USERID VARCHAR(255)
		DECLARE @PASSWORD VARCHAR(255)
		DECLARE @SERVERNAME VARCHAR(255)
		DECLARE @CONNSTRING VARCHAR(1000)

    SELECT @SEQUENCE = 0
	
	if not object_id('tempdb..##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253') is null
	    drop table ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253

	CREATE TABLE ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253(EVENTTEXT VARCHAR(1000))

	  SELECT    @sql = 'bcp "select EVENTTEXT FROM ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 " queryout e:\coretrans\mcp\LC2\repfiles\SQLLDR_LOG\X_BUS_PARTY_RLTNSHP_253.LOG -SSBGETL -T -c'
	  -- execute BCP
	  Exec master..xp_cmdshell @sql

        ------------------------------------------------------------------------------------
        --100
        --RECORD SPID FOR TRACKING PURPOSES
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[100-->BEG RECORD SPID]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        UPDATE CORE1.DBO.PRM_REPLOADTABLES
        SET SPID_1 = @@SPID
        WHERE REPLOADTABLEID = 253

        IF (@@ERROR <> 0) GOTO E_ERROR

	--RETRIEVE THE CURRENT SYSPROCESSEDLOGID
	
	SET @SYSPROCESSEDLOGID = (select MAX(SYSPROCESSEDLOGID) FROM MC_SYSPROCESSEDLOG WHERE SYSTEMID = @SYSTEMID
								and isnull(subsystemid,-1)=-1 )

        IF (@@ERROR <> 0) GOTO E_ERROR

        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[100-->END RECORD SPID]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP

        
        ------------------------------------------------------------------------------------
        --300
        --CHECK SEGMENT TO SEE IF WE HAVE ALREADY COMPLETED THIS PACKAGE
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[300-->BEG CHECK SEGMENT STATUS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP

        --SEE IF WE ARE ALREADY DONE
        IF (CASE WHEN EXISTS (SELECT 1 FROM MC_SEGMENT WITH(NOLOCK) WHERE COMPLETED = 'T' AND SEGMENT = 'REPLICA TRANSFER' AND SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID AND SEGMENTINSTANCE = 'X_BUS_PARTY_RLTNSHP_253') THEN 1 ELSE 0 END) = 1 
        BEGIN
                PRINT 'ALREADY COMPLETE'
                GOTO E_ERROR
        END 

        IF (@@ERROR <> 0) GOTO E_ERROR

        --SEE IF THERE IS ANY DATA TO LOAD
        
        SELECT @ZDATASTATUS = CASE WHEN COUNT(*) = 0 THEN 'T' ELSE 'F' END, 
        @ZDATAENDDATE = CASE WHEN COUNT(*) = 0 THEN GETDATE() ELSE NULL END,
        @ZRECORDSPROCESSED = CASE WHEN COUNT(*) = 0 THEN 0 ELSE NULL END
        FROM COREETL.DBO.COR_X_BUS_PARTY_RLTNSHP


        IF (@@ERROR <> 0) GOTO E_ERROR

        --LOG SEGMENT
        INSERT INTO MC_SEGMENT (StartDateTimeStamp, EndDateTimeStamp, SegmentInstance, Completed, SourceFileID, Segment, RecordsProcessed, SysProcessedLogID)
        SELECT GETDATE(),@ZDATAENDDATE,'X_BUS_PARTY_RLTNSHP_253',@ZDATASTATUS,390, 'REPLICA TRANSFER',@ZRECORDSPROCESSED,@SYSPROCESSEDLOGID
        WHERE NOT EXISTS (SELECT 1 FROM MC_SEGMENT WITH(NOLOCK) WHERE SEGMENT = 'REPLICA TRANSFER' AND SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID AND SEGMENTINSTANCE = 'X_BUS_PARTY_RLTNSHP_253')
         
        IF (@@ERROR <> 0) GOTO E_ERROR

        IF @ZDATAENDDATE IS NOT NULL
        BEGIN
  		INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('COMPLETE.  NO DATA TO LOAD');
              GOTO E_ERROR
        END

        --<BEG>----------------LOG STEP
        --PRINT '[300-->END CHECK SEGMENT STATUS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114)
 	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[300-->END CHECK SEGMENT STATUS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP

        
        ------------------------------------------------------------------------------------
        --400
        --BUILD BAD TEXT FILE
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
 	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[400-->BEG BUILD SQLLDR BAD]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP

        --SET @TEXT = 'osql -SSBGETL -E -Q "" -o "e:\coretrans\mcp\LC2\repfiles\SQLLDR_BAD\X_BUS_PARTY_RLTNSHP_253.BAD" -l500 '
		SET @TEXT = 'SQLCMD -SSBGETL -E -Q "" -o "e:\coretrans\mcp\LC2\repfiles\SQLLDR_BAD\X_BUS_PARTY_RLTNSHP_253.BAD" -l500 '
        EXEC MASTER..XP_CMDSHELL @TEXT, NO_OUTPUT

        --<BEG>----------------LOG STEP
 	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[400-->END BUILD SQLLDR BAD]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        ------------------------------------------------------------------------------------
        --450
        --GET CONNECTION INFO
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
 	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[450-->BEG GET CONNECTION INFO]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP

	SET  @ORACLECONNECTION  = (SELECT ConnectionString FROM DT_Connection WHERE ConnectionId = @CONNECTIONID)            
	
	--Get UserID
	SET @USERID = (SELECT SUBSTRING(@ORACLECONNECTION,1,CHARINDEX('/',@ORACLECONNECTION,1)-1))

	--Get Password
	SET @PASSWORD = (SELECT SUBSTRING(@ORACLECONNECTION,CHARINDEX('/',@ORACLECONNECTION,1)+1,
	(CHARINDEX('@',@ORACLECONNECTION,1)-1) - (CHARINDEX('/',@ORACLECONNECTION,1)))) 

	--Get Server
	SET @SERVERNAME =  (SELECT SUBSTRING(@ORACLECONNECTION,CHARINDEX('@',@ORACLECONNECTION,1)+1,
	LEN(@ORACLECONNECTION) - (CHARINDEX('@',@ORACLECONNECTION,1))))
    
	SET @CONNSTRING = ''''+ @SERVERNAME + ''';''' + @USERID + ''';''' + @PASSWORD + ''''



        --<BEG>----------------LOG STEP
        --PRINT '[450-->END GET CONNECTION INFO]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114)
 	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[450-->END GET CONNECTION INFO]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP




        ------------------------------------------------------------------------------------
        --500
        --BUILD CTL FILE
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
 	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[500-->BEG BUILD SQLLDR CTL]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP

        SET @CTLTEXT = 'ECHO LOAD DATA > e:\coretrans\mcp\LC2\repfiles\SQLLDR_CTL\X_BUS_PARTY_RLTNSHP_253.CTL'
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = 'ECHO INFILE ''e:\coretrans\mcp\LC2\repfiles\SQLLDR_TXT\X_BUS_PARTY_RLTNSHP_253.txt'' >> e:\coretrans\mcp\LC2\repfiles\SQLLDR_CTL\X_BUS_PARTY_RLTNSHP_253.CTL'
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = 'ECHO BADFILE ''e:\coretrans\mcp\LC2\repfiles\SQLLDR_BAD\X_BUS_PARTY_RLTNSHP_253.bad'' >> e:\coretrans\mcp\LC2\repfiles\SQLLDR_CTL\X_BUS_PARTY_RLTNSHP_253.CTL'
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = 'ECHO DISCARDFILE ''e:\coretrans\mcp\LC2\repfiles\SQLLDR_DIS\X_BUS_PARTY_RLTNSHP_253.dis'' >> e:\coretrans\mcp\LC2\repfiles\SQLLDR_CTL\X_BUS_PARTY_RLTNSHP_253.CTL'
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = 'ECHO INSERT >> e:\coretrans\mcp\LC2\repfiles\SQLLDR_CTL\X_BUS_PARTY_RLTNSHP_253.CTL'
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = 'ECHO INTO TABLE SBGSTAGE.X_BUS_PARTY_RLTNSHP_253 >> e:\coretrans\mcp\LC2\repfiles\SQLLDR_CTL\X_BUS_PARTY_RLTNSHP_253.CTL'
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = 'ECHO FIELDS TERMINATED BY ''^<--REPDLMTR--^>'' >> e:\coretrans\mcp\LC2\repfiles\SQLLDR_CTL\X_BUS_PARTY_RLTNSHP_253.CTL'
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = 'ECHO  TRAILING NULLCOLS >> e:\coretrans\mcp\LC2\repfiles\SQLLDR_CTL\X_BUS_PARTY_RLTNSHP_253.CTL'
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = 'ECHO ( >> e:\coretrans\mcp\LC2\repfiles\SQLLDR_CTL\X_BUS_PARTY_RLTNSHP_253.CTL'
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT


 	SET @CTLTEXT = 'ECHO BUS_PARTY_ID,RLTD_BUS_PARTY_ID,RLTNSHP_TYPE_CODE,JOB_ID,RLTNSHP_FROM_DATE,RLTNSHP_THRU_DATE,MNTC_SYS_CODE,MNTC_SYS_ATTR_ID,MNTC_SYS_ATTR_KEY1_TEXT,MNTC_SYS_ATTR_KEY2_TEXT,MNTC_SYS_ATTR_KEY3_TEXT,MNTC_SYS_ATTR_KEY4_TEXT >> e:\coretrans\mcp\LC2\repfiles\SQLLDR_CTL\X_BUS_PARTY_RLTNSHP_253.CTL'
	EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT
	
        SET @CTLTEXT = 'ECHO ) >> e:\coretrans\mcp\LC2\repfiles\SQLLDR_CTL\X_BUS_PARTY_RLTNSHP_253.CTL'
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        IF (@@ERROR <> 0) GOTO E_ERROR

        --<BEG>----------------LOG STEP
 	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[500-->END BUILD SQLLDR CTL]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        ------------------------------------------------------------------------------------
        --700
        --BUILD ORACLE STAGING OBJECTS
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
 	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[700-->BEG BUILD ORA OBJECTS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP

        CREATE TABLE #OUTPUT (RESULT VARCHAR(255))
        --BUILD COMMAND TO EXECUTE ORACLE PROC


        SELECT @CMD =  'ECHO EXEC SBGSTAGE.CR_STAGE_OBJECTS ( 253, ''COR_X_BUS_PARTY_RLTNSHP'', ''BUS_PARTY_ID,RLTD_BUS_PARTY_ID,RLTNSHP_TYPE_CODE,JOB_ID,RLTNSHP_FROM_DATE,RLTNSHP_THRU_DATE,MNTC_SYS_CODE,MNTC_SYS_ATTR_ID,MNTC_SYS_ATTR_KEY1_TEXT,MNTC_SYS_ATTR_KEY2_TEXT,MNTC_SYS_ATTR_KEY3_TEXT,MNTC_SYS_ATTR_KEY4_TEXT'' );| SQLPLUS ' + @ORACLECONNECTION 

        --EXECUTE COMMAND INTO TEMP TABLE
        INSERT INTO #OUTPUT EXEC @RSLTS = MASTER..XP_CMDSHELL @CMD

        IF (@@ERROR <> 0) GOTO E_ERROR

        --SEARCH FOR ERRORS
        IF (SELECT COUNT(*) FROM #OUTPUT WHERE RESULT LIKE '%ORA-%') <> 0 OR @RSLTS <> 0
        BEGIN
                DECLARE CRSR_RESULTS CURSOR FOR SELECT RESULT FROM #OUTPUT
                OPEN CRSR_RESULTS
                SELECT @ERRORRESULTS = ''
                FETCH Next FROM CRSR_RESULTS INTO @OUTPUT
                WHILE @@FETCH_STATUS=0
                BEGIN
                        SELECT @ERRORRESULTS = @ERRORRESULTS + CASE WHEN @OUTPUT IS NOT NULL THEN @OUTPUT + CHAR(13) + CHAR(10) ELSE '' END
                        FETCH Next FROM CRSR_RESULTS INTO @OUTPUT
                END
                CLOSE CRSR_RESULTS
                DEALLOCATE CRSR_RESULTS

	  	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES (@ERRORRESULTS);

                RAISERROR ('REP_X_BUS_PARTY_RLTNSHP_253 FAILED AT 700.  ORACLE PROCEDURE CR_STAGE_OBJECTS FAILED.', 16, 1)
                GOTO E_ERROR
        END

        --<BEG>----------------LOG STEP
 	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[700-->END BUILD ORA OBJECTS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        ------------------------------------------------------------------------------------
        --800
        --FILTER AND LOG DUPLICATES
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
 	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[800-->BEG LOG DUPLICATES]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        CREATE TABLE [#TEMP2] ( [CNT] VARCHAR(150) ) 
        
        --LOAD DUPS INTO TEMP TABLE
        INSERT INTO #TEMP2 SELECT COUNT(*) AS CNT FROM (SELECT BUS_PARTY_ID,RLTD_BUS_PARTY_ID,RLTNSHP_TYPE_CODE FROM COREETL.DBO.COR_X_BUS_PARTY_RLTNSHP where REC_INSRT_NAME = '253' group by BUS_PARTY_ID,RLTD_BUS_PARTY_ID,RLTNSHP_TYPE_CODE having count(*) > 1) JJ

        IF (@@ERROR <> 0) GOTO E_ERROR

        --LOG RECORDS FOUND IN THE REPERRORLOG
        SELECT @CNT = CNT FROM #TEMP2
        
        IF (@@ERROR <> 0) GOTO E_ERROR

        IF @CNT > 0         BEGIN
                BEGIN TRAN T1

                INSERT INTO COREERRLOG.DBO.REPERRORLOG (ERRORDATE,ERRORMESSAGE,ERRORDATA,LOGID,ERRORSOURCE,SYSTEM)VALUES(GETDATE(),'DUPLICATE RECORDS DETECTED IN COR_X_BUS_PARTY_RLTNSHP','REFER TO ERR TABLE','253','REP','LC2'); 

                INSERT INTO COREERRLOG.DBO.ERR_X_BUS_PARTY_RLTNSHP SELECT A.*, (SELECT TOP 1 @@IDENTITY FROM COREERRLOG.DBO.REPERRORLOG) FROM COREETL.DBO.COR_X_BUS_PARTY_RLTNSHP A INNER JOIN (SELECT BUS_PARTY_ID,RLTD_BUS_PARTY_ID,RLTNSHP_TYPE_CODE FROM COREETL.DBO.COR_X_BUS_PARTY_RLTNSHP WHERE REC_INSRT_NAME = 253 GROUP BY BUS_PARTY_ID,RLTD_BUS_PARTY_ID,RLTNSHP_TYPE_CODE HAVING COUNT(*) > 1) B ON A.BUS_PARTY_ID = B.BUS_PARTY_ID  and A.RLTD_BUS_PARTY_ID = B.RLTD_BUS_PARTY_ID  and A.RLTNSHP_TYPE_CODE = B.RLTNSHP_TYPE_CODE  WHERE A.REC_INSRT_NAME = 253; 

                DELETE COREETL.DBO.COR_X_BUS_PARTY_RLTNSHP FROM COREETL.DBO.COR_X_BUS_PARTY_RLTNSHP A INNER JOIN (SELECT BUS_PARTY_ID,RLTD_BUS_PARTY_ID,RLTNSHP_TYPE_CODE FROM COREETL.DBO.COR_X_BUS_PARTY_RLTNSHP WHERE REC_INSRT_NAME = 253 GROUP BY BUS_PARTY_ID,RLTD_BUS_PARTY_ID,RLTNSHP_TYPE_CODE HAVING COUNT(*) > 1) B ON A.BUS_PARTY_ID = B.BUS_PARTY_ID  and A.RLTD_BUS_PARTY_ID = B.RLTD_BUS_PARTY_ID  and A.RLTNSHP_TYPE_CODE = B.RLTNSHP_TYPE_CODE  WHERE A.REC_INSRT_NAME = 253;

                COMMIT TRAN T1

                IF (@@ERROR <> 0) GOTO E_ERROR
        END 

        DROP TABLE #TEMP2


        --<BEG>----------------LOG STEP
  	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[800-->END LOG DUPLICATES]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        ------------------------------------------------------------------------------------
        --900
        --EXPORT ETL TO TEXT FILES
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
  	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[900-->BEG EXTRACT TO TEXT]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP

        
        
        --EXECUTE BCP
        CREATE TABLE #BCPOUTPUT (RESULT VARCHAR(255))

        set @CMD = 'bcp "SELECT * from CORE1.DBO.REP_X_BUS_PARTY_RLTNSHP_253" queryout e:\coretrans\mcp\LC2\repfiles\SQLLDR_TXT\X_BUS_PARTY_RLTNSHP_253.TXT -SSBGETL -T -c -t"<--REPDLMTR-->"'

        INSERT INTO #BCPOUTPUT EXEC @RSLTS = MASTER..XP_CMDSHELL @CMD

        IF (@@ERROR <> 0) GOTO E_ERROR


        IF @RSLTS <> 0
        BEGIN

                DECLARE CRSR_RESULTS CURSOR FOR SELECT RESULT FROM #BCPOUTPUT
                OPEN CRSR_RESULTS
                SELECT @ERRORRESULTS = ''
                FETCH Next FROM CRSR_RESULTS INTO @OUTPUT
                WHILE @@FETCH_STATUS=0
                BEGIN
                        SELECT @ERRORRESULTS = @ERRORRESULTS + CASE WHEN @OUTPUT IS NOT NULL THEN @OUTPUT + CHAR(13) + CHAR(10) ELSE '' END
                        FETCH Next FROM CRSR_RESULTS INTO @OUTPUT
                END
                CLOSE CRSR_RESULTS
                DEALLOCATE CRSR_RESULTS

	  	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES (@ERRORRESULTS);

                RAISERROR ('REP_X_BUS_PARTY_RLTNSHP_253 FAILED AT 900.  BCP FAILED.', 16, 1)
                GOTO E_ERROR
        END


        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[900-->END EXTRACT TO TEXT]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP
        ------------------------------------------------------------------------------------
        --950
        --RUN SQLLDR
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[950-->BEG RUN SQLLDR]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        CREATE TABLE #SQLLDROUTPUT (RESULT VARCHAR(255))
        CREATE TABLE #SQLLDRINPUT (RESULT VARCHAR(2555))

        --BUILD COMMAND TO EXECUTE ORACLE PROC
        SELECT @CMD = 'E:\Coretrans\MCP\sqlldr.exe ' + @ORACLECONNECTION + ' errors=100 direct=true control=e:\coretrans\mcp\LC2\repfiles\SQLLDR_CTL\X_BUS_PARTY_RLTNSHP_253.CTL log=e:\coretrans\mcp\LC2\repfiles\SQLLDR_LOG\X_BUS_PARTY_RLTNSHP_253.log'
        

        --EXECUTE COMMAND INTO TEMP TABLE
        INSERT INTO #SQLLDROUTPUT EXEC @RSLTS = MASTER..XP_CMDSHELL @CMD


        IF (@@ERROR <> 0) GOTO E_ERROR

        --SEARCH FOR ERRORS
        IF  @RSLTS in (0,2)
        BEGIN

                SELECT @CMD = 'BULK INSERT #SQLLDRINPUT FROM ''e:\coretrans\mcp\LC2\repfiles\SQLLDR_LOG\X_BUS_PARTY_RLTNSHP_253.LOG'' WITH (ROWTERMINATOR = ''\n'')'
                EXEC SP_EXECUTESQL @CMD

                IF (@@ERROR <> 0) GOTO E_ERROR

                SELECT @RECORDSLOADED = CASE WHEN result like '%Rows successfully loaded.' THEN CAST(ltrim(rtrim(replace(result,'Rows successfully loaded.',''))) AS INT) WHEN result like '%Row successfully loaded.' THEN CAST(ltrim(rtrim(replace(result,'Row successfully loaded.',''))) AS INT) END FROM #SQLLDRINPUT where result like '%Rows successfully loaded.' OR  result like '%Row successfully loaded.'

                IF (@@ERROR <> 0) GOTO E_ERROR

                SELECT @RECORDSERRORED = CASE WHEN result like '%Rows not loaded due to data errors.' THEN CAST(ltrim(rtrim(replace(result,'Rows not loaded due to data errors.',''))) AS INT) WHEN result like '%Row not loaded due to data errors.' THEN CAST(ltrim(rtrim(replace(result,'Row not loaded due to data errors.',''))) AS INT) END FROM #SQLLDRINPUT where result like '%Rows not loaded due to data errors.' OR  result like '%Row not loaded due to data errors.'

                IF (@@ERROR <> 0) GOTO E_ERROR

                IF @RECORDSLOADED IS NULL
                BEGIN
                        RAISERROR ('REP_X_BUS_PARTY_RLTNSHP_253 FAILED AT 950.  SQLLDR FAILED 001', 16, 1)
                        GOTO E_ERROR
                END

                IF @RECORDSERRORED > 100
                BEGIN
                        RAISERROR ('REP_X_BUS_PARTY_RLTNSHP_253 FAILED AT 950.  SQLLDR EXCEEDED ALLOWED NUMBER OF ERRORS AS SPECIFIED IN PRM_REPLOADTABLES.', 16, 1)
                        GOTO E_ERROR
                END

        END 
        ELSE
        BEGIN

                DECLARE CRSR_RESULTS CURSOR FOR SELECT RESULT FROM #SQLLDROUTPUT
                OPEN CRSR_RESULTS
                SELECT @ERRORRESULTS = ''
                FETCH Next FROM CRSR_RESULTS INTO @OUTPUT
                WHILE @@FETCH_STATUS=0
                BEGIN
                        SELECT @ERRORRESULTS = @ERRORRESULTS + CASE WHEN @OUTPUT IS NOT NULL THEN @OUTPUT + CHAR(13) + CHAR(10) ELSE '' END
                        FETCH Next FROM CRSR_RESULTS INTO @OUTPUT
                END
                CLOSE CRSR_RESULTS
                DEALLOCATE CRSR_RESULTS

		INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES (@ERRORRESULTS);

                IF (@@ERROR <> 0) GOTO E_ERROR

                RAISERROR ('REP_X_BUS_PARTY_RLTNSHP_253 FAILED AT 950.  SQLLDR FAILED 002.', 16, 1)
                GOTO E_ERROR
        END

        DROP TABLE #SQLLDROUTPUT
        DROP TABLE #SQLLDRINPUT

        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[950-->END RUN SQLLDR]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        ------------------------------------------------------------------------------------

        --1000
        --CHECK FOR SQLLDR ERRORS
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[1000-->BEG LOG SQLLDR ERRORS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP

        SELECT TOP 0 BUS_PARTY_ID,RLTD_BUS_PARTY_ID,RLTNSHP_TYPE_CODE,JOB_ID,RLTNSHP_FROM_DATE,RLTNSHP_THRU_DATE,MNTC_SYS_CODE,MNTC_SYS_ATTR_ID,MNTC_SYS_ATTR_KEY1_TEXT,MNTC_SYS_ATTR_KEY2_TEXT,MNTC_SYS_ATTR_KEY3_TEXT,MNTC_SYS_ATTR_KEY4_TEXT INTO #TEMPSQLLDRERROR FROM COREETL.DBO.COR_X_BUS_PARTY_RLTNSHP

        IF (@@ERROR <> 0) GOTO E_ERROR

        BULK INSERT #TEMPSQLLDRERROR FROM 'e:\coretrans\mcp\LC2\repfiles\SQLLDR_BAD\X_BUS_PARTY_RLTNSHP_253.bad' WITH (FIELDTERMINATOR = '<--REPDLMTR-->',ROWTERMINATOR = '\n')
	
        IF (@@ERROR <> 0) GOTO E_ERROR

        INSERT INTO COREERRLOG.DBO.REPERRORLOG (ERRORDATE, ERRORMESSAGE, ERRORDATA,ERRORSOURCE,SYSTEM) SELECT GETDATE(),'SQLLDR WAS UNABLE TO LOAD ' + CAST(COUNT(*) AS VARCHAR(100)) + ' RECORD(S) INTO COR_X_BUS_PARTY_RLTNSHP DUE TO A SQLLDR ERROR','REFER TO ERR TABLE FOR DETAIL','REP','LC2' FROM #TEMPSQLLDRERROR HAVING COUNT(*) > 0
                                                                                                                                                                                                                
        IF (@@ERROR <> 0) GOTO E_ERROR

        SELECT @ERRORID = @@IDENTITY FROM coreerrlog.dbo.reperrorlog

        IF (@@ERROR <> 0) GOTO E_ERROR

        INSERT INTO COREERRLOG.DBO.ERR_X_BUS_PARTY_RLTNSHP
        (BUS_PARTY_ID,RLTD_BUS_PARTY_ID,RLTNSHP_TYPE_CODE,JOB_ID,RLTNSHP_FROM_DATE,RLTNSHP_THRU_DATE,MNTC_SYS_CODE,MNTC_SYS_ATTR_ID,MNTC_SYS_ATTR_KEY1_TEXT,MNTC_SYS_ATTR_KEY2_TEXT,MNTC_SYS_ATTR_KEY3_TEXT,MNTC_SYS_ATTR_KEY4_TEXT,ADU,DATETIMESTAMP,REPERRORID)
	SELECT BUS_PARTY_ID,RLTD_BUS_PARTY_ID,RLTNSHP_TYPE_CODE,JOB_ID,RLTNSHP_FROM_DATE,RLTNSHP_THRU_DATE,MNTC_SYS_CODE,MNTC_SYS_ATTR_ID,MNTC_SYS_ATTR_KEY1_TEXT,MNTC_SYS_ATTR_KEY2_TEXT,MNTC_SYS_ATTR_KEY3_TEXT,MNTC_SYS_ATTR_KEY4_TEXT,'A',GETDATE(),@ERRORID 
        FROM #TEMPSQLLDRERROR
	

        IF (@@ERROR <> 0) GOTO E_ERROR

        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[1000-->END LOG SQLLDR ERRORS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        ------------------------------------------------------------------------------------
        --1100
        --WAIT FOR PARENTS TO COMPLETE
        ------------------------------------------------------------------------------------

        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[1100-->BEG WAIT FOR PARENTS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
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
                and b.parentid in (select repcoretableid from prm_reploadtables with(nolock) where systemid = 9)
                inner join
                prm_repcoretables c
                on b.parentid = c.repcoretableid
                inner join
                prm_reploadtables d
                on c.repcoretableid = d.repcoretableid
		and d.systemid = 9
                and isnull(d.subsystemid,-1)= -1
                where
                not exists(select 1 from mc_segment z with(nolock) where z.segmentinstance = dbo.REP_STAGENAME(c.coretablename,d.reploadtableid) and z.segment = 'REPLICA TRANSFER' and z.sysprocessedlogid = @SYSPROCESSEDLOGID and z.completed = 'T')
                and a.reploadtableid = 253
                
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
                not exists(select 1 from mc_segment z with(nolock) where z.segmentinstance = dbo.REP_STAGENAME(b.coretablename,a.tablelevelprecedence) and z.segment = 'REPLICA TRANSFER' and z.sysprocessedlogid = @SYSPROCESSEDLOGID and z.completed = 'T')
                and a.reploadtableid = 253
                
                IF (@@ERROR <> 0) GOTO E_ERROR

                IF  @iPendingTableParent + @iPendingParent > 0 
                BEGIN
                        select @PARENTSCOMPLETE = 0
                        WAITFOR DELAY '00:00:30'
                END 
                ELSE
                BEGIN
                        SELECT @PARENTSCOMPLETE = 1
                END
        
               
        END


        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[1100-->END WAIT FOR PARENTS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP



        ------------------------------------------------------------------------------------
        --1200
        --FILTER ORACLE ERRORS
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[1200-->BEG FILTER ORACLE ERRORS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP

        -- UPDATE STARTDATETIMESTAMP IN MC_SEGMENT TO REFLECT WHEN ERROR CHECKING BEGINS
        UPDATE MC_SEGMENT
        SET STARTDATETIMESTAMP = GETDATE()
        WHERE SEGMENT = 'REPLICA TRANSFER' AND SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID AND SEGMENTINSTANCE = 'X_BUS_PARTY_RLTNSHP_253'

                
                CREATE TABLE #LOAD0RAOUTPUT (RESULT VARCHAR(255))
                CREATE TABLE #ERRCOUNT (RESULT VARCHAR(255))

                --BUILD COMMAND TO EXECUTE ORACLE PROC
                SELECT @CMD =  'ECHO EXEC SBGSTAGE.SPE_X_BUS_PARTY_RLTNSHP_253;| SQLPLUS ' + @ORACLECONNECTION 

                IF (@@ERROR <> 0) GOTO E_ERROR
        
                --EXECUTE COMMAND INTO TEMP TABLE
                INSERT INTO #LOAD0RAOUTPUT EXEC @RSLTS = MASTER..XP_CMDSHELL @CMD
        
                IF (@@ERROR <> 0) GOTO E_ERROR
        
                --SEARCH FOR ERRORS 
                IF (SELECT COUNT(*) FROM #LOAD0RAOUTPUT WHERE RESULT LIKE '%ORA-%') = 0 AND @RSLTS = 0
                BEGIN
        
                        --SELECT @CMD = N'SELECT CNT FROM OPENQUERY(CORE,''SELECT COUNT(*) AS CNT FROM SBGSTAGE.BAD_X_BUS_PARTY_RLTNSHP_253'')'
                        SELECT @CMD = N'SELECT CNT FROM OPENROWSET(''OraOLEDB.Oracle'',' + @CONNSTRING + ',''SELECT COUNT(*) AS CNT FROM SBGSTAGE.BAD_X_BUS_PARTY_RLTNSHP_253'')'
                        INSERT INTO #ERRCOUNT EXEC SP_EXECUTESQL @CMD                
        
                        IF (@@ERROR <> 0) GOTO E_ERROR

                        IF (SELECT RESULT FROM #ERRCOUNT) > 100
                        BEGIN
                                RAISERROR ('REP_X_BUS_PARTY_RLTNSHP_253 FAILED AT 1200.  ORACLE SPE PROC FAILED.  EXCEEDED MAX ALLOWED ERRORS', 16, 1)
                                GOTO E_ERROR
                        END
                END 
                ELSE
                BEGIN


                        DECLARE CRSR_RESULTS CURSOR FOR SELECT RESULT FROM #LOAD0RAOUTPUT
                        OPEN CRSR_RESULTS
                        SELECT @ERRORRESULTS = ''
                        FETCH Next FROM CRSR_RESULTS INTO @OUTPUT
                        WHILE @@FETCH_STATUS=0
                        BEGIN
                                SELECT @ERRORRESULTS = @ERRORRESULTS + CASE WHEN @OUTPUT IS NOT NULL THEN @OUTPUT + CHAR(13) + CHAR(10) ELSE '' END
                                FETCH Next FROM CRSR_RESULTS INTO @OUTPUT
                        END
                        CLOSE CRSR_RESULTS
                        DEALLOCATE CRSR_RESULTS
        
			INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES (@ERRORRESULTS);

                        IF (@@ERROR <> 0) GOTO E_ERROR

                        RAISERROR ('REP_X_BUS_PARTY_RLTNSHP_253 FAILED AT 1200.  ORACLE SPE PROC FAILED.', 16, 1)
                        GOTO E_ERROR
                END

                DROP TABLE #LOAD0RAOUTPUT
                DROP TABLE #ERRCOUNT
        --DROP TABLE #LOAD0RAOUTPUT
        --DROP TABLE #ERRCOUNT

        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[1200-->END FILTER ORACLE ERRORS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        ------------------------------------------------------------------------------------
        --1300
        --LOAD ORACLE
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[1300-->BEG LOAD CORE]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        CREATE TABLE #LOUTPUT (RESULT VARCHAR(255))
        CREATE TABLE #LLOADCOUNT (RESULT VARCHAR(255))


        --BUILD COMMAND TO EXECUTE ORACLE PROC
        SELECT @CMD =  'ECHO EXEC SBGSTAGE.SPM_X_BUS_PARTY_RLTNSHP_253;| SQLPLUS ' + @ORACLECONNECTION 
 
        IF (@@ERROR <> 0) GOTO E_ERROR

        --EXECUTE COMMAND INTO TEMP TABLE
        INSERT INTO #LOUTPUT EXEC @RSLTS = MASTER..XP_CMDSHELL @CMD

        IF (@@ERROR <> 0) GOTO E_ERROR

        --SEARCH FOR ERRORS 
        IF (SELECT COUNT(*) FROM #LOUTPUT WHERE RESULT LIKE '%ORA-%') = 0 AND @RSLTS = 0
        BEGIN

                --SELECT @CMD = N'SELECT CNT FROM OPENQUERY(CORE,''SELECT COUNT(*) AS CNT FROM SBGSTAGE.X_BUS_PARTY_RLTNSHP_253'')'
				SELECT @CMD = N'SELECT CNT FROM OPENROWSET(''OraOLEDB.Oracle'',' + @CONNSTRING + ',''SELECT COUNT(*) AS CNT FROM SBGSTAGE.X_BUS_PARTY_RLTNSHP_253'')'
                INSERT INTO #LLOADCOUNT EXEC SP_EXECUTESQL @CMD             

                IF (@@ERROR <> 0) GOTO E_ERROR

                --UPDATE MASTERGENID.COREMASTER.DBO.REP_TABLELOCK SET LOCKFLAG = 0,SUBSYSTEM = NULL WHERE CORETABLENAME = 'COR_X_BUS_PARTY_RLTNSHP' AND SUBSYSTEM = @@SERVERNAME
                
                --IF (@@ERROR <> 0) GOTO E_ERROR

        END 
        ELSE
        BEGIN


                DECLARE CRSR_RESULTS CURSOR FOR SELECT RESULT FROM #LOUTPUT
                OPEN CRSR_RESULTS
                SELECT @ERRORRESULTS = ''
                FETCH Next FROM CRSR_RESULTS INTO @OUTPUT
                WHILE @@FETCH_STATUS=0
                BEGIN
                        SELECT @ERRORRESULTS = @ERRORRESULTS + CASE WHEN @OUTPUT IS NOT NULL THEN @OUTPUT + CHAR(13) + CHAR(10) ELSE '' END
                        FETCH Next FROM CRSR_RESULTS INTO @OUTPUT
                END
                CLOSE CRSR_RESULTS
                DEALLOCATE CRSR_RESULTS

		INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES (@ERRORRESULTS);

                IF (@@ERROR <> 0) GOTO E_ERROR

                RAISERROR ('REP_X_BUS_PARTY_RLTNSHP_253 FAILED AT 1300.  ORACLE LOAD PROC FAILED.', 16, 1)
                GOTO E_ERROR
        END



        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[1300-->END LOAD CORE]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP



        ------------------------------------------------------------------------------------
        --1350
        --LOG ORACLE LOAD ERRORS DETECTED BY FILTER ERROR STEP
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[1350-->BEG LOG ORA ERRORS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        CREATE TABLE #QLOADCOUNT (RESULT VARCHAR(255))


        --SELECT @CMD = 'INSERT INTO COREERRLOG.DBO.REPERRORLOG (ERRORDATE, ERRORMESSAGE, ERRORDATA,ERRORSOURCE,SYSTEM) SELECT GETDATE(),''UNABLE TO LOAD '' + CAST(CNT AS VARCHAR(100)) + '' RECORD(S) INTO COR_X_BUS_PARTY_RLTNSHP DUE TO A PARENT KEY CONSTRAINT ERROR'',''REFER TO ERR TABLE FOR DETAIL'',''REP'',''LC2'' FROM OPENQUERY(CORE,''SELECT COUNT(*) AS CNT FROM SBGSTAGE.BAD_X_BUS_PARTY_RLTNSHP_253'') WHERE CNT > 0'
		SELECT @CMD = 'INSERT INTO COREERRLOG.DBO.REPERRORLOG (ERRORDATE, ERRORMESSAGE, ERRORDATA,ERRORSOURCE,SYSTEM) SELECT GETDATE(),''UNABLE TO LOAD '' + CAST(CNT AS VARCHAR(100)) + '' RECORD(S) INTO COR_X_BUS_PARTY_RLTNSHP DUE TO A PARENT KEY CONSTRAINT ERROR'',''REFER TO ERR TABLE FOR DETAIL'',''REP'',''LC2'' FROM OPENROWSET(''OraOLEDB.Oracle'',' + @CONNSTRING + ',''SELECT COUNT(*) AS CNT FROM SBGSTAGE.BAD_X_BUS_PARTY_RLTNSHP_253'') WHERE CNT > 0'
        EXEC SP_EXECUTESQL @CMD

        IF (@@ERROR <> 0) GOTO E_ERROR

        SELECT @ERRORID = @@IDENTITY FROM COREERRLOG.DBO.REPERRORLOG

        IF (@@ERROR <> 0) GOTO E_ERROR


        SELECT @CMD1 = 'INSERT INTO COREERRLOG.DBO.ERR_X_BUS_PARTY_RLTNSHP
        (BUS_PARTY_ID,RLTD_BUS_PARTY_ID,RLTNSHP_TYPE_CODE,JOB_ID,RLTNSHP_FROM_DATE,RLTNSHP_THRU_DATE,MNTC_SYS_CODE,MNTC_SYS_ATTR_ID,MNTC_SYS_ATTR_KEY1_TEXT,MNTC_SYS_ATTR_KEY2_TEXT,MNTC_SYS_ATTR_KEY3_TEXT,MNTC_SYS_ATTR_KEY4_TEXT,ADU,DATETIMESTAMP,REPERRORID)SELECT BUS_PARTY_ID,RLTD_BUS_PARTY_ID,RLTNSHP_TYPE_CODE,JOB_ID,RLTNSHP_FROM_DATE,RLTNSHP_THRU_DATE,MNTC_SYS_CODE,MNTC_SYS_ATTR_ID,MNTC_SYS_ATTR_KEY1_TEXT,MNTC_SYS_ATTR_KEY2_TEXT,MNTC_SYS_ATTR_KEY3_TEXT,MNTC_SYS_ATTR_KEY4_TEXT,''A'',GETDATE(),' + cast(@ERRORID as varchar(100)) + ' FROM OPENROWSET(''OraOLEDB.Oracle'',' + @CONNSTRING + ',''SELECT * FROM SBGSTAGE.BAD_X_BUS_PARTY_RLTNSHP_253'')'

	SELECT @CMD1 =  REPLACE(@CMD1,'''','''''') 

	EXEC (N'EXEC SP_EXECUTESQL N''' +  @CMD1  + '''')

        IF (@@ERROR <> 0) GOTO E_ERROR

        DROP TABLE #QLOADCOUNT

        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[1350-->END LOG ORA ERRORS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        ------------------------------------------------------------------------------------
        --1400
        --COMPLETE SEGMENT
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
        --PRINT '[1400-->BEG COMPLETE SEGMENT]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,253,'X_BUS_PARTY_RLTNSHP_253',GETDATE(),'[1400-->BEG COMPLETE SEGMENT]')
        --<END>----------------LOG STEP


        UPDATE MC_SEGMENT
        SET ENDDATETIMESTAMP = GETDATE(),COMPLETED = 'T', RECORDSPROCESSED = (SELECT RESULT FROM #LLOADCOUNT)
        WHERE SEGMENT = 'REPLICA TRANSFER' AND SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID AND SEGMENTINSTANCE = 'X_BUS_PARTY_RLTNSHP_253'

        IF (@@ERROR <> 0) GOTO E_ERROR


        --<BEG>----------------LOG STEP
        --PRINT '[1400-->END COMPLETE SEGMENT]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,253,'X_BUS_PARTY_RLTNSHP_253',GETDATE(),'[1400-->END COMPLETE SEGMENT]')
        --<END>----------------LOG STEP


        ------------------------------------------------------------------------------------
        --1500
        --RESET SPID FOR TRACKING PURPOSES
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[1500-->BEG RESET SPID]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP

        UPDATE CORE1.DBO.PRM_REPLOADTABLES
        SET SPID_1 = NULL, PROCESSID = NULL
        WHERE REPLOADTABLEID = 253

        IF (@@ERROR <> 0) GOTO E_ERROR

        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('[1500-->END RESET SPID]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP

CLEANUP:
  SELECT    @sql = 'bcp "select EVENTTEXT FROM ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 " queryout e:\coretrans\mcp\LC2\repfiles\DTS_LOG\X_BUS_PARTY_RLTNSHP_253.TXT -SSBGETL -T -c'
  -- execute BCP
  Exec master..xp_cmdshell @sql

  DROP TABLE ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253
  
  RETURN

E_ERROR:
UPDATE CORE1.DBO.PRM_REPLOADTABLES
SET SPID_1 = NULL, PROCESSID = NULL
WHERE REPLOADTABLEID = 253
INSERT INTO ##TEMP_NREP_X_BUS_PARTY_RLTNSHP_253 VALUES ('ERROR IS AS FOLLOWS: ' + @ERRORRESULTS);

GOTO CLEANUP

RETURN

GO
