USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[usp_DeleteOldFileBackups]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_DeleteOldFileBackups] @MachineName varchar(255)

AS

SET NOCOUNT ON

DECLARE @DOScmd varchar(2000)
DECLARE @SQLcmd varchar(2000)
DECLARE @PingCmd varchar(255)
DECLARE @FileName varchar(2000)
DECLARE @LastWorkday datetime

CREATE TABLE #PINGSQL_OUTPUT (RETURNVAL VARCHAR(2000) NULL)
CREATE TABLE #DOSFileList ( DOSLine varchar(8000) NULL)

--SET @MachineName = 'COREPROD01'

-- SET @Today = GetDate()
-- EXEC UC4.UC4.dbo.GET_LAST_WORKDAY @Today, @LastWorkday OUTPUT
exec usp_GetOldestDiskBackupSetToKeep 'Core1', @LastWorkday OUTPUT

   -- FIRST, PING THE SERVER
   SET @PingCmd = 'PING -n 1 ' + @MachineName

   INSERT #PINGSQL_OUTPUT
   EXEC master..XP_CMDSHELL @PingCmd

   IF EXISTS (SELECT * FROM #PINGSQL_OUTPUT WHERE PATINDEX('%reply%', RETURNVAL) > 0) 
   BEGIN
       -- SERVER PING SUCCEEDED, SO GET THE FILE NAMES
      --SET @DOScmd = 'DIR "\\CISCO\E$\' + @MachineName + '\*.bak"'  -- DOS command to list all files in the joblog folder
      SET @DOScmd = 'DIR "\\SBTOPFS02P\SQL_Backups\' + @MachineName + '\*.bak"'  -- DOS command to list all files in the joblog folder

      INSERT #DOSFileList
      EXEC master..xp_cmdshell @DOScmd

      DECLARE cur CURSOR  FAST_FORWARD
      FOR SELECT right(DOSLine, (charindex(char(32), REVERSE ( DOSLine )) - 1) ) as FileName
            FROM #DOSFileList
           WHERE isdate(left(DOSLine,10)) = 1  -- all the lines that contain filenames start with a date
             AND patindex('%<DIR>%', DOSLine) = 0  -- don't pick up any subfolder names
             AND patindex('%[0-9].BAK', DOSLine) > 0  -- only look for files of types .BAK
             AND convert(datetime, left(DOSLine,10)) < @LastWorkday
      OPEN cur
 
      FETCH NEXT FROM cur INTO @FileName
 
      WHILE @@fetch_status = 0
      BEGIN
         --SET @DOScmd = 'DEL \\CISCO\E$\' + @MachineName + '\' + @FileName 
         SET @DOScmd = 'DEL \\SBTOPFS02P\SQL_Backups\' + @MachineName + '\' + @FileName 
         --PRINT @DOScmd
         EXEC master..xp_cmdshell @DOScmd, no_output
      
         FETCH NEXT FROM cur INTO @FileName
      END
 
      CLOSE cur
      DEALLOCATE cur

   END -- IF PING SUCCEEDED
   ELSE
   BEGIN
       -- SERVER PING FAILED, SO REPORT THE ERROR
       SET @SQLcmd = 'SERVER ' + @MachineName + ' DOES NOT RESPOND TO PING.'
       RAISERROR(@SQLcmd,16,1)
   END


DROP TABLE #PINGSQL_OUTPUT
DROP TABLE #DOSFileList
GO
