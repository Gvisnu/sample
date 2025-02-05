USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[NREP_TRNSCTN_DETAIL_419]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NREP_TRNSCTN_DETAIL_419] (@SYSTEMID INT, @CONNECTIONID INT) AS
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
		DECLARE @NREP_START_TIME AS DATETIME
		DECLARE @ROWSPROCESSED INT

    SELECT @SEQUENCE = 0
	SELECT @NREP_START_TIME = GETDATE()
	SELECT @ROWSPROCESSED = 0

	if not object_id('tempdb..##TEMP_NREP_TRNSCTN_DETAIL_419') is null
	    drop table ##TEMP_NREP_TRNSCTN_DETAIL_419

	CREATE TABLE ##TEMP_NREP_TRNSCTN_DETAIL_419(EVENTTEXT VARCHAR(1000))

	--changed from SBGETL to @@SERVERNAME for issue 7094  
	SELECT    @sql = 'bcp "select EVENTTEXT FROM ##TEMP_NREP_TRNSCTN_DETAIL_419 " queryout \\SETOPCOREAPP01Q\CORETRANS\MCP\TRAC\REPFILES\SQLLDR_LOG\TRNSCTN_DETAIL_419.LOG -SSETOPCORESQL20Q\COREQA02 -T -c'
	  -- execute BCP
	  Exec master..xp_cmdshell @sql,no_output

        ------------------------------------------------------------------------------------
        --100
        --RECORD SPID FOR TRACKING PURPOSES
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[100-->BEG RECORD SPID]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        UPDATE CORE1.DBO.PRM_REPLOADTABLES
        SET SPID_1 = @@SPID
        WHERE REPLOADTABLEID = 419

        IF (@@ERROR <> 0) GOTO E_ERROR

	--RETRIEVE THE CURRENT SYSPROCESSEDLOGID
	
	SET @SYSPROCESSEDLOGID = (select MAX(SYSPROCESSEDLOGID) FROM MC_SYSPROCESSEDLOG WHERE SYSTEMID = @SYSTEMID
								and isnull(subsystemid,-1)=-1 )

        IF (@@ERROR <> 0) GOTO E_ERROR

        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[100-->END RECORD SPID]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP

        
        ------------------------------------------------------------------------------------
        --300
        --CHECK SEGMENT TO SEE IF WE HAVE ALREADY COMPLETED THIS PACKAGE
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[300-->BEG CHECK SEGMENT STATUS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP

        --SEE IF WE ARE ALREADY DONE
        IF (CASE WHEN EXISTS (SELECT 1 FROM MC_SEGMENT WITH(NOLOCK) WHERE COMPLETED = 'T' AND SEGMENT = 'REPLICA TRANSFER' AND SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID AND SEGMENTINSTANCE = 'TRNSCTN_DETAIL_419') THEN 1 ELSE 0 END) = 1 
        BEGIN
                PRINT 'ALREADY COMPLETE'
                GOTO E_ERROR
        END 

        IF (@@ERROR <> 0) GOTO E_ERROR

        --SEE IF THERE IS ANY DATA TO LOAD
        
        SELECT @ZDATASTATUS = CASE WHEN COUNT(*) = 0 THEN 'T' ELSE 'F' END, 
        @ZDATAENDDATE = CASE WHEN COUNT(*) = 0 THEN GETDATE() ELSE NULL END,
        @ZRECORDSPROCESSED = CASE WHEN COUNT(*) = 0 THEN 0 ELSE NULL END
        FROM COREETL.DBO.COR_TRNSCTN_DETAIL


        IF (@@ERROR <> 0) GOTO E_ERROR

        --LOG SEGMENT
        INSERT INTO MC_SEGMENT (StartDateTimeStamp, EndDateTimeStamp, SegmentInstance, Completed, SourceFileID, Segment, RecordsProcessed, SysProcessedLogID)
        SELECT GETDATE(),@ZDATAENDDATE,'TRNSCTN_DETAIL_419',@ZDATASTATUS,525, 'REPLICA TRANSFER',@ZRECORDSPROCESSED,@SYSPROCESSEDLOGID
        WHERE NOT EXISTS (SELECT 1 FROM MC_SEGMENT WITH(NOLOCK) WHERE SEGMENT = 'REPLICA TRANSFER' AND SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID AND SEGMENTINSTANCE = 'TRNSCTN_DETAIL_419')
         
        IF (@@ERROR <> 0) GOTO E_ERROR

        IF @ZDATAENDDATE IS NOT NULL
        BEGIN
  		INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('COMPLETE.  NO DATA TO LOAD');
              GOTO E_ERROR
        END

        --<BEG>----------------LOG STEP
        --PRINT '[300-->END CHECK SEGMENT STATUS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114)
 	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[300-->END CHECK SEGMENT STATUS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP

        
        ------------------------------------------------------------------------------------
        --400
        --BUILD BAD TEXT FILE
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
 	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[400-->BEG BUILD SQLLDR BAD]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP

		--changed from SBGETL to @@SERVERNAME for issue 7094  
		SET @TEXT = 'SQLCMD -SSETOPCORESQL20Q\COREQA02 -E -Q "" -o "\\SETOPCOREAPP01Q\CORETRANS\MCP\TRAC\REPFILES\SQLLDR_BAD\TRNSCTN_DETAIL_419.BAD" -l500 '
        EXEC MASTER..XP_CMDSHELL @TEXT, NO_OUTPUT

        --<BEG>----------------LOG STEP
 	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[400-->END BUILD SQLLDR BAD]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        ------------------------------------------------------------------------------------
        --450
        --GET CONNECTION INFO
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
 	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[450-->BEG GET CONNECTION INFO]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
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
 	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[450-->END GET CONNECTION INFO]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP




        ------------------------------------------------------------------------------------
        --500
        --BUILD CTL FILE
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
 	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[500-->BEG BUILD SQLLDR CTL]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP

        SET @CTLTEXT = 'ECHO LOAD DATA > \\SETOPCOREAPP01Q\CORETRANS\MCP\TRAC\REPFILES\SQLLDR_CTL\TRNSCTN_DETAIL_419.CTL'
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = 'ECHO INFILE ''\\SETOPCOREAPP01Q\CORETRANS\MCP\TRAC\REPFILES\SQLLDR_TXT\TRNSCTN_DETAIL_419.txt'' >> \\SETOPCOREAPP01Q\CORETRANS\MCP\TRAC\REPFILES\SQLLDR_CTL\TRNSCTN_DETAIL_419.CTL'
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = 'ECHO BADFILE ''\\SETOPCOREAPP01Q\CORETRANS\MCP\TRAC\REPFILES\SQLLDR_BAD\TRNSCTN_DETAIL_419.bad'' >> \\SETOPCOREAPP01Q\CORETRANS\MCP\TRAC\REPFILES\SQLLDR_CTL\TRNSCTN_DETAIL_419.CTL'
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = 'ECHO DISCARDFILE ''\\SETOPCOREAPP01Q\CORETRANS\MCP\TRAC\REPFILES\SQLLDR_DIS\TRNSCTN_DETAIL_419.dis'' >> \\SETOPCOREAPP01Q\CORETRANS\MCP\TRAC\REPFILES\SQLLDR_CTL\TRNSCTN_DETAIL_419.CTL'
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = 'ECHO INSERT >> \\SETOPCOREAPP01Q\CORETRANS\MCP\TRAC\REPFILES\SQLLDR_CTL\TRNSCTN_DETAIL_419.CTL'
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = 'ECHO INTO TABLE SBGSTAGE.TRNSCTN_DETAIL_419 >> \\SETOPCOREAPP01Q\CORETRANS\MCP\TRAC\REPFILES\SQLLDR_CTL\TRNSCTN_DETAIL_419.CTL'
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = 'ECHO FIELDS TERMINATED BY ''^<--REPDLMTR--^>'' >> \\SETOPCOREAPP01Q\CORETRANS\MCP\TRAC\REPFILES\SQLLDR_CTL\TRNSCTN_DETAIL_419.CTL'
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = 'ECHO  TRAILING NULLCOLS >> \\SETOPCOREAPP01Q\CORETRANS\MCP\TRAC\REPFILES\SQLLDR_CTL\TRNSCTN_DETAIL_419.CTL'
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        SET @CTLTEXT = 'ECHO ( >> \\SETOPCOREAPP01Q\CORETRANS\MCP\TRAC\REPFILES\SQLLDR_CTL\TRNSCTN_DETAIL_419.CTL'
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT


 	SET @CTLTEXT = 'ECHO TRANSACTION_ID,DETAIL_SEQ_ID,ACCOUNTING_DATE,AGREEMENT_ID,JOB_ID,SRC_FUND_ID,TRAN_ASSET_SOURCE_CODE,DETAIL_TYPE_CODE,AMOUNT,NUMBER_OF_UNITS,VALUE_PER_UNIT,INTEREST_RATE,ORIGINAL_SOURCE_DTL_TYPE,DETAIL_GAIN_LOSS_AMT,LOAN_ID >> \\SETOPCOREAPP01Q\CORETRANS\MCP\TRAC\REPFILES\SQLLDR_CTL\TRNSCTN_DETAIL_419.CTL'
	EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT
	
        SET @CTLTEXT = 'ECHO ) >> \\SETOPCOREAPP01Q\CORETRANS\MCP\TRAC\REPFILES\SQLLDR_CTL\TRNSCTN_DETAIL_419.CTL'
        EXEC MASTER..XP_CMDSHELL @CTLTEXT, NO_OUTPUT

        IF (@@ERROR <> 0) GOTO E_ERROR

        --<BEG>----------------LOG STEP
 	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[500-->END BUILD SQLLDR CTL]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        ------------------------------------------------------------------------------------
        --700
        --BUILD ORACLE STAGING OBJECTS
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
 	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[700-->BEG BUILD ORA OBJECTS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP

        CREATE TABLE #OUTPUT (RESULT VARCHAR(255))
        --BUILD COMMAND TO EXECUTE ORACLE PROC


        SELECT @CMD =  'ECHO EXEC SBGSTAGE.CR_STAGE_OBJECTS ( 419, ''COR_TRNSCTN_DETAIL'', ''TRANSACTION_ID,DETAIL_SEQ_ID,ACCOUNTING_DATE,AGREEMENT_ID,JOB_ID,SRC_FUND_ID,TRAN_ASSET_SOURCE_CODE,DETAIL_TYPE_CODE,AMOUNT,NUMBER_OF_UNITS,VALUE_PER_UNIT,INTEREST_RATE,ORIGINAL_SOURCE_DTL_TYPE,DETAIL_GAIN_LOSS_AMT,LOAN_ID'' );| SQLPLUS ' + @ORACLECONNECTION 

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

	  	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES (@ERRORRESULTS);
				SELECT @ERRORRESULTS = 'REP_TRNSCTN_DETAIL_419 FAILED AT 700.  ORACLE PROCEDURE CR_STAGE_OBJECTS FAILED.' + CHAR(13) + CHAR(10) + @ERRORRESULTS
                RAISERROR (@ERRORRESULTS, 16, 1)

                GOTO E_ERROR
        END

        --<BEG>----------------LOG STEP
 	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[700-->END BUILD ORA OBJECTS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        ------------------------------------------------------------------------------------
        --800
        --FILTER AND LOG DUPLICATES
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
 	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[800-->BEG LOG DUPLICATES]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        CREATE TABLE [#TEMP2] ( [CNT] VARCHAR(150) ) 
        
        --LOAD DUPS INTO TEMP TABLE
        INSERT INTO #TEMP2 SELECT COUNT(*) AS CNT FROM (SELECT TRANSACTION_ID,ACCOUNTING_DATE,DETAIL_SEQ_ID,AGREEMENT_ID FROM COREETL.DBO.COR_TRNSCTN_DETAIL where REC_INSRT_NAME = '419' group by TRANSACTION_ID,ACCOUNTING_DATE,DETAIL_SEQ_ID,AGREEMENT_ID having count(*) > 1) JJ

        IF (@@ERROR <> 0) GOTO E_ERROR

        --LOG RECORDS FOUND IN THE REPERRORLOG
        SELECT @CNT = CNT FROM #TEMP2
        
        IF (@@ERROR <> 0) GOTO E_ERROR
        IF @CNT > 0 
        BEGIN
				--Added for issue 4030
				IF @CNT > 50000
				BEGIN
						SELECT @ERRORRESULTS = 'REP_TRNSCTN_DETAIL_419 FAILED AT 800.  DUPLICATE RECORDS CHECK FAILED.  EXCEEDED MAX ALLOWED ERRORS' + CHAR(13) + CHAR(10) 
						RAISERROR (@ERRORRESULTS, 16, 1)
						GOTO E_ERROR
				END

                BEGIN TRAN T1

                INSERT INTO COREERRLOG.DBO.REPERRORLOG (ERRORDATE,ERRORMESSAGE,ERRORDATA,LOGID,ERRORSOURCE,SYSTEM)VALUES(GETDATE(),'DUPLICATE RECORDS DETECTED IN COR_TRNSCTN_DETAIL','REFER TO ERR TABLE','419','REP','TRAC'); 

                INSERT INTO COREERRLOG.DBO.ERR_TRNSCTN_DETAIL SELECT A.*, (SELECT TOP 1 @@IDENTITY FROM COREERRLOG.DBO.REPERRORLOG) FROM COREETL.DBO.COR_TRNSCTN_DETAIL A INNER JOIN (SELECT TRANSACTION_ID,ACCOUNTING_DATE,DETAIL_SEQ_ID,AGREEMENT_ID FROM COREETL.DBO.COR_TRNSCTN_DETAIL WHERE REC_INSRT_NAME = 419 GROUP BY TRANSACTION_ID,ACCOUNTING_DATE,DETAIL_SEQ_ID,AGREEMENT_ID HAVING COUNT(*) > 1) B ON A.TRANSACTION_ID = B.TRANSACTION_ID  and A.ACCOUNTING_DATE = B.ACCOUNTING_DATE  and A.DETAIL_SEQ_ID = B.DETAIL_SEQ_ID  and A.AGREEMENT_ID = B.AGREEMENT_ID  WHERE A.REC_INSRT_NAME = 419; 

                DELETE COREETL.DBO.COR_TRNSCTN_DETAIL FROM COREETL.DBO.COR_TRNSCTN_DETAIL A INNER JOIN (SELECT TRANSACTION_ID,ACCOUNTING_DATE,DETAIL_SEQ_ID,AGREEMENT_ID FROM COREETL.DBO.COR_TRNSCTN_DETAIL WHERE REC_INSRT_NAME = 419 GROUP BY TRANSACTION_ID,ACCOUNTING_DATE,DETAIL_SEQ_ID,AGREEMENT_ID HAVING COUNT(*) > 1) B ON A.TRANSACTION_ID = B.TRANSACTION_ID  and A.ACCOUNTING_DATE = B.ACCOUNTING_DATE  and A.DETAIL_SEQ_ID = B.DETAIL_SEQ_ID  and A.AGREEMENT_ID = B.AGREEMENT_ID  WHERE A.REC_INSRT_NAME = 419;

                COMMIT TRAN T1

                IF (@@ERROR <> 0) GOTO E_ERROR
        END 

        DROP TABLE #TEMP2


        --<BEG>----------------LOG STEP
  	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[800-->END LOG DUPLICATES]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        ------------------------------------------------------------------------------------
        --900
        --EXPORT ETL TO TEXT FILES
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
  	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[900-->BEG EXTRACT TO TEXT]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP

        
        
        --EXECUTE BCP
        CREATE TABLE #BCPOUTPUT (RESULT VARCHAR(255))

        --changed from SBGETL to @@SERVERNAME for issue 7094  
		set @CMD = 'bcp "SELECT * from CORE1.DBO.REP_TRNSCTN_DETAIL_419" queryout \\SETOPCOREAPP01Q\CORETRANS\MCP\TRAC\REPFILES\SQLLDR_TXT\TRNSCTN_DETAIL_419.TXT -SSETOPCORESQL20Q\COREQA02 -T -c -t"<--REPDLMTR-->"'

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

	  	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES (@ERRORRESULTS);

				SELECT @ERRORRESULTS = 'REP_TRNSCTN_DETAIL_419 FAILED AT 900.  BCP FAILED. '+ CHAR(13) + CHAR(10) + @ERRORRESULTS
                RAISERROR (@ERRORRESULTS, 16, 1)
                GOTO E_ERROR
        END


        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[900-->END EXTRACT TO TEXT]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP
        ------------------------------------------------------------------------------------
        --950
        --RUN SQLLDR
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[950-->BEG RUN SQLLDR]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        CREATE TABLE #SQLLDROUTPUT (RESULT VARCHAR(255))
        CREATE TABLE #SQLLDRINPUT (RESULT VARCHAR(2555))

        --BUILD COMMAND TO EXECUTE ORACLE PROC. Added the SQLLDR path for issue 7094
        SELECT @CMD = 'C:\Oracle\Product\12.1.0\client_11\BIN\sqlldr.exe ' + @ORACLECONNECTION + ' errors=50000 direct=true control=\\SETOPCOREAPP01Q\CORETRANS\MCP\TRAC\REPFILES\SQLLDR_CTL\TRNSCTN_DETAIL_419.CTL log=\\SETOPCOREAPP01Q\CORETRANS\MCP\TRAC\REPFILES\SQLLDR_LOG\TRNSCTN_DETAIL_419.log'
        

        --EXECUTE COMMAND INTO TEMP TABLE
        INSERT INTO #SQLLDROUTPUT EXEC @RSLTS = MASTER..XP_CMDSHELL @CMD


        IF (@@ERROR <> 0) GOTO E_ERROR

        --SEARCH FOR ERRORS
        IF  @RSLTS in (0,2)
        BEGIN

                SELECT @CMD = 'BULK INSERT #SQLLDRINPUT FROM ''\\SETOPCOREAPP01Q\CORETRANS\MCP\TRAC\REPFILES\SQLLDR_LOG\TRNSCTN_DETAIL_419.LOG'' WITH (ROWTERMINATOR = ''\n'')'
                EXEC SP_EXECUTESQL @CMD

                IF (@@ERROR <> 0) GOTO E_ERROR

                SELECT @RECORDSLOADED = CASE WHEN result like '%Rows successfully loaded.' THEN CAST(ltrim(rtrim(replace(result,'Rows successfully loaded.',''))) AS INT) WHEN result like '%Row successfully loaded.' THEN CAST(ltrim(rtrim(replace(result,'Row successfully loaded.',''))) AS INT) END FROM #SQLLDRINPUT where result like '%Rows successfully loaded.' OR  result like '%Row successfully loaded.'

                IF (@@ERROR <> 0) GOTO E_ERROR

                SELECT @RECORDSERRORED = CASE WHEN result like '%Rows not loaded due to data errors.' THEN CAST(ltrim(rtrim(replace(result,'Rows not loaded due to data errors.',''))) AS INT) WHEN result like '%Row not loaded due to data errors.' THEN CAST(ltrim(rtrim(replace(result,'Row not loaded due to data errors.',''))) AS INT) END FROM #SQLLDRINPUT where result like '%Rows not loaded due to data errors.' OR  result like '%Row not loaded due to data errors.'

                IF (@@ERROR <> 0) GOTO E_ERROR

                IF @RECORDSLOADED IS NULL
                BEGIN
						SELECT @ERRORRESULTS = 'REP_TRNSCTN_DETAIL_419 FAILED AT 950.  SQLLDR FAILED 001' + CHAR(13) + CHAR(10) 
						RAISERROR (@ERRORRESULTS, 16, 1)
                        GOTO E_ERROR
                END

                IF @RECORDSERRORED > 50000
                BEGIN
						SELECT @ERRORRESULTS = 'REP_TRNSCTN_DETAIL_419 FAILED AT 950.  SQLLDR EXCEEDED ALLOWED NUMBER OF ERRORS AS SPECIFIED IN PRM_REPLOADTABLES.' + CHAR(13) + CHAR(10) 
						RAISERROR (@ERRORRESULTS, 16, 1)
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

		INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES (@ERRORRESULTS);

                --IF (@@ERROR <> 0) GOTO E_ERROR

				SELECT @ERRORRESULTS = 'REP_TRNSCTN_DETAIL_419 FAILED AT 950.  SQLLDR FAILED 002. '+ CHAR(13) + CHAR(10) + @ERRORRESULTS
                RAISERROR (@ERRORRESULTS, 16, 1)
                GOTO E_ERROR
        END

        DROP TABLE #SQLLDROUTPUT
        DROP TABLE #SQLLDRINPUT

        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[950-->END RUN SQLLDR]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        ------------------------------------------------------------------------------------

        --1000
        --CHECK FOR SQLLDR ERRORS
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[1000-->BEG LOG SQLLDR ERRORS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP

        SELECT TOP 0 TRANSACTION_ID,DETAIL_SEQ_ID,ACCOUNTING_DATE,AGREEMENT_ID,JOB_ID,SRC_FUND_ID,TRAN_ASSET_SOURCE_CODE,DETAIL_TYPE_CODE,AMOUNT,NUMBER_OF_UNITS,VALUE_PER_UNIT,INTEREST_RATE,ORIGINAL_SOURCE_DTL_TYPE,DETAIL_GAIN_LOSS_AMT,LOAN_ID INTO #TEMPSQLLDRERROR FROM COREETL.DBO.COR_TRNSCTN_DETAIL

        IF (@@ERROR <> 0) GOTO E_ERROR

        BULK INSERT #TEMPSQLLDRERROR FROM '\\SETOPCOREAPP01Q\CORETRANS\MCP\TRAC\REPFILES\SQLLDR_BAD\TRNSCTN_DETAIL_419.bad' WITH (FIELDTERMINATOR = '<--REPDLMTR-->',ROWTERMINATOR = '\n')
	
        IF (@@ERROR <> 0) GOTO E_ERROR

        INSERT INTO COREERRLOG.DBO.REPERRORLOG (ERRORDATE, ERRORMESSAGE, ERRORDATA,ERRORSOURCE,SYSTEM) SELECT GETDATE(),'SQLLDR WAS UNABLE TO LOAD ' + CAST(COUNT(*) AS VARCHAR(100)) + ' RECORD(S) INTO COR_TRNSCTN_DETAIL DUE TO A SQLLDR ERROR','REFER TO ERR TABLE FOR DETAIL','REP','TRAC' FROM #TEMPSQLLDRERROR HAVING COUNT(*) > 0
                                                                                                                                                                                                                
        IF (@@ERROR <> 0) GOTO E_ERROR

        SELECT @ERRORID = @@IDENTITY FROM coreerrlog.dbo.reperrorlog

        IF (@@ERROR <> 0) GOTO E_ERROR

        INSERT INTO COREERRLOG.DBO.ERR_TRNSCTN_DETAIL
        (TRANSACTION_ID,DETAIL_SEQ_ID,ACCOUNTING_DATE,AGREEMENT_ID,JOB_ID,SRC_FUND_ID,TRAN_ASSET_SOURCE_CODE,DETAIL_TYPE_CODE,AMOUNT,NUMBER_OF_UNITS,VALUE_PER_UNIT,INTEREST_RATE,ORIGINAL_SOURCE_DTL_TYPE,DETAIL_GAIN_LOSS_AMT,LOAN_ID,ADU,DATETIMESTAMP,REPERRORID)
	SELECT TRANSACTION_ID,DETAIL_SEQ_ID,ACCOUNTING_DATE,AGREEMENT_ID,JOB_ID,SRC_FUND_ID,TRAN_ASSET_SOURCE_CODE,DETAIL_TYPE_CODE,AMOUNT,NUMBER_OF_UNITS,VALUE_PER_UNIT,INTEREST_RATE,ORIGINAL_SOURCE_DTL_TYPE,DETAIL_GAIN_LOSS_AMT,LOAN_ID,'A',GETDATE(),@ERRORID 
        FROM #TEMPSQLLDRERROR
	

        IF (@@ERROR <> 0) GOTO E_ERROR

        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[1000-->END LOG SQLLDR ERRORS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        ------------------------------------------------------------------------------------
        --1100
        --WAIT FOR PARENTS TO COMPLETE
        ------------------------------------------------------------------------------------

        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[1100-->BEG WAIT FOR PARENTS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
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
                and b.parentid in (select repcoretableid from prm_reploadtables with(nolock) where systemid = 49)
                inner join
                prm_repcoretables c
                on b.parentid = c.repcoretableid
                inner join
                prm_reploadtables d
                on c.repcoretableid = d.repcoretableid
		and d.systemid = 49
                and isnull(d.subsystemid,-1)= -1
                where
                not exists(select 1 from mc_segment z with(nolock) where z.segmentinstance = dbo.REP_STAGENAME(c.coretablename,d.reploadtableid) and z.segment = 'REPLICA TRANSFER' and z.sysprocessedlogid = @SYSPROCESSEDLOGID and z.completed = 'T')
                and a.reploadtableid = 419
                
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
                and a.reploadtableid = 419
                
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
	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[1100-->END WAIT FOR PARENTS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP



        ------------------------------------------------------------------------------------
        --1200
        --FILTER ORACLE ERRORS
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[1200-->BEG FILTER ORACLE ERRORS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP

        -- UPDATE STARTDATETIMESTAMP IN MC_SEGMENT TO REFLECT WHEN ERROR CHECKING BEGINS
        UPDATE MC_SEGMENT
        SET STARTDATETIMESTAMP = GETDATE()
        WHERE SEGMENT = 'REPLICA TRANSFER' AND SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID AND SEGMENTINSTANCE = 'TRNSCTN_DETAIL_419'

                
                CREATE TABLE #LOAD0RAOUTPUT (RESULT VARCHAR(255))
                CREATE TABLE #ERRCOUNT (RESULT VARCHAR(255))

                --BUILD COMMAND TO EXECUTE ORACLE PROC
                SELECT @CMD =  'ECHO EXEC SBGSTAGE.SPE_TRNSCTN_DETAIL_419;| SQLPLUS ' + @ORACLECONNECTION 

                IF (@@ERROR <> 0) GOTO E_ERROR
        
                --EXECUTE COMMAND INTO TEMP TABLE
                INSERT INTO #LOAD0RAOUTPUT EXEC @RSLTS = MASTER..XP_CMDSHELL @CMD
        
                IF (@@ERROR <> 0) GOTO E_ERROR
        
                --SEARCH FOR ERRORS 
                IF (SELECT COUNT(*) FROM #LOAD0RAOUTPUT WHERE RESULT LIKE '%ORA-%') = 0 AND @RSLTS = 0
                BEGIN
                --Modified by Senthilkumar Sekaran as on 02-18-2013 for issue no: 7074

                        SELECT @CMD = N'SELECT CNT FROM OPENQUERY(CORE,''SELECT COUNT(*) AS CNT FROM SBGSTAGE.BAD_TRNSCTN_DETAIL_419'')'
                        --SELECT @CMD = N'SELECT CNT FROM OPENROWSET(''OraOLEDB.Oracle'',' + @CONNSTRING + ',''SELECT COUNT(*) AS CNT FROM SBGSTAGE.BAD_TRNSCTN_DETAIL_419'')'
				--Modified by Senthilkumar Sekaran as on 02-18-2013
        
                                INSERT INTO #ERRCOUNT EXEC SP_EXECUTESQL @CMD                
        
                        IF (@@ERROR <> 0) GOTO E_ERROR

                        IF (SELECT RESULT FROM #ERRCOUNT) > 50000
                        BEGIN
								SELECT @ERRORRESULTS = 'REP_TRNSCTN_DETAIL_419 FAILED AT 1200.  ORACLE SPE PROC FAILED.  EXCEEDED MAX ALLOWED ERRORS. '+ CHAR(13) + CHAR(10) 
								RAISERROR (@ERRORRESULTS, 16, 1)
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
        
			INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES (@ERRORRESULTS);

                        --IF (@@ERROR <> 0) GOTO E_ERROR
						SELECT @ERRORRESULTS = 'REP_TRNSCTN_DETAIL_419 FAILED AT 1200.  ORACLE SPE PROC FAILED. '+ CHAR(13) + CHAR(10) + @ERRORRESULTS
						RAISERROR (@ERRORRESULTS, 16, 1)

                        GOTO E_ERROR
                END

                DROP TABLE #LOAD0RAOUTPUT
                DROP TABLE #ERRCOUNT
        --DROP TABLE #LOAD0RAOUTPUT
        --DROP TABLE #ERRCOUNT

        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[1200-->END FILTER ORACLE ERRORS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        ------------------------------------------------------------------------------------
        --1300
        --LOAD ORACLE
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[1300-->BEG LOAD CORE]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        CREATE TABLE #LOUTPUT (RESULT VARCHAR(255))
        CREATE TABLE #LLOADCOUNT (RESULT NUMERIC(18,0))
		


        --BUILD COMMAND TO EXECUTE ORACLE PROC
        SELECT @CMD =  'ECHO EXEC SBGSTAGE.SPI_TRNSCTN_DETAIL_419;| SQLPLUS ' + @ORACLECONNECTION 
 
        IF (@@ERROR <> 0) GOTO E_ERROR

        --EXECUTE COMMAND INTO TEMP TABLE
        INSERT INTO #LOUTPUT EXEC @RSLTS = MASTER..XP_CMDSHELL @CMD

        IF (@@ERROR <> 0) GOTO E_ERROR

        --SEARCH FOR ERRORS 
        IF (SELECT COUNT(*) FROM #LOUTPUT WHERE RESULT LIKE '%ORA-%') = 0 AND @RSLTS = 0
        BEGIN
-- Modified by Senthilkumar Sekaran as on 02-18-2013 for issue no: 7074
                SELECT @CMD = N'SELECT CNT FROM OPENQUERY(CORE,''SELECT COUNT(*) AS CNT FROM SBGSTAGE.TRNSCTN_DETAIL_419'')'
				--SELECT @CMD = N'SELECT CNT FROM OPENROWSET(''OraOLEDB.Oracle'',' + @CONNSTRING + ',''SELECT COUNT(*) AS CNT FROM SBGSTAGE.TRNSCTN_DETAIL_419'')'
-- Modified by Senthilkumar Sekaran as on 02-18-2013 for issue no: 7074
                INSERT INTO #LLOADCOUNT EXEC SP_EXECUTESQL @CMD             

                IF (@@ERROR <> 0) GOTO E_ERROR

                --UPDATE MASTERGENID.COREMASTER.DBO.REP_TABLELOCK SET LOCKFLAG = 0,SUBSYSTEM = NULL WHERE CORETABLENAME = 'COR_TRNSCTN_DETAIL' AND SUBSYSTEM = @@SERVERNAME
                
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

		INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES (@ERRORRESULTS);

                --IF (@@ERROR <> 0) GOTO E_ERROR
				SELECT @ERRORRESULTS = 'REP_TRNSCTN_DETAIL_419 FAILED AT 1300.  ORACLE LOAD PROC FAILED. '+ CHAR(13) + CHAR(10) + @ERRORRESULTS
                RAISERROR (@ERRORRESULTS, 16, 1)

                GOTO E_ERROR
        END



        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[1300-->END LOAD CORE]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP



        ------------------------------------------------------------------------------------
        --1350
        --LOG ORACLE LOAD ERRORS DETECTED BY FILTER ERROR STEP
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[1350-->BEG LOG ORA ERRORS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        CREATE TABLE #QLOADCOUNT (RESULT VARCHAR(255))

--Modified by Senthilkumar Sekaran as on 02-18-2013 for issue no: 7074
        SELECT @CMD = 'INSERT INTO COREERRLOG.DBO.REPERRORLOG (ERRORDATE, ERRORMESSAGE, ERRORDATA,ERRORSOURCE,SYSTEM) SELECT GETDATE(),''UNABLE TO LOAD '' + CAST(CNT AS VARCHAR(100)) + '' RECORD(S) INTO COR_TRNSCTN_DETAIL DUE TO A PARENT KEY CONSTRAINT ERROR'',''REFER TO ERR TABLE FOR DETAIL'',''REP'',''TRAC'' FROM OPENQUERY(CORE,''SELECT COUNT(*) AS CNT FROM SBGSTAGE.BAD_TRNSCTN_DETAIL_419'') WHERE CNT > 0'
		--SELECT @CMD = 'INSERT INTO COREERRLOG.DBO.REPERRORLOG (ERRORDATE, ERRORMESSAGE, ERRORDATA,ERRORSOURCE,SYSTEM) SELECT GETDATE(),''UNABLE TO LOAD '' + CAST(CNT AS VARCHAR(100)) + '' RECORD(S) INTO COR_TRNSCTN_DETAIL DUE TO A PARENT KEY CONSTRAINT ERROR'',''REFER TO ERR TABLE FOR DETAIL'',''REP'',''TRAC'' FROM OPENROWSET(''OraOLEDB.Oracle'',' + @CONNSTRING + ',''SELECT COUNT(*) AS CNT FROM SBGSTAGE.BAD_TRNSCTN_DETAIL_419'') WHERE CNT > 0'
--Modified by Senthilkumar Sekaran as on 02-18-2013 for issue no: 7074
        EXEC SP_EXECUTESQL @CMD

        IF (@@ERROR <> 0) GOTO E_ERROR

        SELECT @ERRORID = @@IDENTITY FROM COREERRLOG.DBO.REPERRORLOG

        IF (@@ERROR <> 0) GOTO E_ERROR


        SELECT @CMD1 = 'INSERT INTO COREERRLOG.DBO.ERR_TRNSCTN_DETAIL
        (TRANSACTION_ID,DETAIL_SEQ_ID,ACCOUNTING_DATE,AGREEMENT_ID,JOB_ID,SRC_FUND_ID,TRAN_ASSET_SOURCE_CODE,DETAIL_TYPE_CODE,AMOUNT,NUMBER_OF_UNITS,VALUE_PER_UNIT,INTEREST_RATE,ORIGINAL_SOURCE_DTL_TYPE,DETAIL_GAIN_LOSS_AMT,LOAN_ID,ADU,DATETIMESTAMP,REPERRORID)SELECT TRANSACTION_ID,DETAIL_SEQ_ID,ACCOUNTING_DATE,AGREEMENT_ID,JOB_ID,SRC_FUND_ID,TRAN_ASSET_SOURCE_CODE,DETAIL_TYPE_CODE,AMOUNT,NUMBER_OF_UNITS,VALUE_PER_UNIT,INTEREST_RATE,ORIGINAL_SOURCE_DTL_TYPE,DETAIL_GAIN_LOSS_AMT,LOAN_ID,''A'',GETDATE(),' + cast(@ERRORID as varchar(100)) + ' FROM OPENQUERY(CORE,''SELECT * FROM SBGSTAGE.BAD_TRNSCTN_DETAIL_419'')'

	SELECT @CMD1 =  REPLACE(@CMD1,'''','''''') 

	EXEC (N'EXEC SP_EXECUTESQL N''' +  @CMD1  + '''')

        IF (@@ERROR <> 0) GOTO E_ERROR

        DROP TABLE #QLOADCOUNT

        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[1350-->END LOG ORA ERRORS]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP


        ------------------------------------------------------------------------------------
        --1400
        --COMPLETE SEGMENT
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
        --PRINT '[1400-->BEG COMPLETE SEGMENT]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,419,'TRNSCTN_DETAIL_419',GETDATE(),'[1400-->BEG COMPLETE SEGMENT]')
        --<END>----------------LOG STEP


        UPDATE MC_SEGMENT
        SET ENDDATETIMESTAMP = GETDATE(),COMPLETED = 'T', RECORDSPROCESSED = (SELECT RESULT FROM #LLOADCOUNT)
        WHERE SEGMENT = 'REPLICA TRANSFER' AND SYSPROCESSEDLOGID = @SYSPROCESSEDLOGID AND SEGMENTINSTANCE = 'TRNSCTN_DETAIL_419'

        IF (@@ERROR <> 0) GOTO E_ERROR


        --<BEG>----------------LOG STEP
        --PRINT '[1400-->END COMPLETE SEGMENT]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114)
        INSERT INTO LOG_RepResults (SYSPROCESSEDLOGID, REPLOADTABLEID, SEGMENT, DATETIMESTAMP, RESULTS) VALUES(@SYSPROCESSEDLOGID,419,'TRNSCTN_DETAIL_419',GETDATE(),'[1400-->END COMPLETE SEGMENT]')
        --<END>----------------LOG STEP


        ------------------------------------------------------------------------------------
        --1500
        --RESET SPID FOR TRACKING PURPOSES
        ------------------------------------------------------------------------------------
        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[1500-->BEG RESET SPID]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP

        UPDATE CORE1.DBO.PRM_REPLOADTABLES
        SET SPID_1 = NULL, PROCESSID = NULL
        WHERE REPLOADTABLEID = 419

        IF (@@ERROR <> 0) GOTO E_ERROR

        --<BEG>----------------LOG STEP
	INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('[1500-->END RESET SPID]	' + CONVERT(VARCHAR(100),GETDATE(),101) + ' ' + CONVERT(VARCHAR(100),GETDATE(),114));
        --<END>----------------LOG STEP

	Print @NREP_START_TIME
	--Added for issue 3825
	--CREATE TABLE #RECCOUNT (RESULT VARCHAR(255))
    --SELECT @CMD = N'SELECT CNT FROM OPENROWSET(''OraOLEDB.Oracle'',' + @CONNSTRING + ',''SELECT ROWS_PROCESSED AS CNT FROM procedure_run_log WHERE PROCEDURE_NAME =''''SPI_TRNSCTN_DETAIL_419'''' AND START_TIME >= TO_DATE(''''' + CONVERT(VARCHAR(100),@NREP_START_TIME,120) + ''''',''''YYYY-MM-DD HH:MI:SS'''') '')'
    --INSERT INTO #RECCOUNT EXEC SP_EXECUTESQL @CMD                

    --IF (@@ERROR <> 0) GOTO E_ERROR

    SET @ROWSPROCESSED = (SELECT RESULT FROM #LLOADCOUNT)

	DROP TABLE #LLOADCOUNT

CLEANUP:
  --changed from SBGETL to @@SERVERNAME for issue 7094  
  SELECT    @sql = 'bcp "select EVENTTEXT FROM ##TEMP_NREP_TRNSCTN_DETAIL_419 " queryout \\SETOPCOREAPP01Q\CORETRANS\MCP\TRAC\REPFILES\DTS_LOG\TRNSCTN_DETAIL_419.TXT -SSETOPCORESQL20Q\COREQA02 -T -c'
  -- execute BCP
  Exec master..xp_cmdshell @sql,no_output

  DROP TABLE ##TEMP_NREP_TRNSCTN_DETAIL_419
  
  SELECT @ROWSPROCESSED AS ROWSPROCESSED
		  
  RETURN

E_ERROR:
UPDATE CORE1.DBO.PRM_REPLOADTABLES
SET SPID_1 = NULL, PROCESSID = NULL
WHERE REPLOADTABLEID = 419
INSERT INTO ##TEMP_NREP_TRNSCTN_DETAIL_419 VALUES ('ERROR IS AS FOLLOWS: ' + @ERRORRESULTS);

GOTO CLEANUP

RETURN
GO
