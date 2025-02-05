USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Proc_Update_RepErrorLog_Status]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[Proc_Update_RepErrorLog_Status]     
AS      
SET NOCOUNT ON    
DECLARE      
 -- @SourceServer varchar(4000),    
@ERRTableName      NVARCHAR(4000),      
@ERRID             INT,      
@SQL1              NVARCHAR(4000),    
@ErrorMessage     varchar(1000),    
@CORTableName      NVARCHAR(4000)    
 --set @SourceServer='coredev3'    
CREATE TABLE [#TEMP1] ( [ErrorID] INT NULL, [ErrorMessage] VARCHAR(1000) NULL)       
CREATE TABLE [#TEMP2] ( [ERROR_ID] INT NULL, [ERROR_DATE] DATETIME NULL,     
[ERROR_MESSAGE] VARCHAR(1000) NULL, [ERROR_COUNT] INT NULL, [ERROR_SOURCE] VARCHAR(50) NULL,     
[ERROR_DETAIL] VARCHAR(100)  NULL)     
    
    
INSERT INTO #TEMP1 SELECT DISTINCT ErrorID, ErrorMessage     
FROM CoreErrLog.dbo.RepErrorLog
WHERE (Status IS NULL OR Status <> 'C')
-- Modified by Senthilkumar for the Issue: 7017 on September 14 --starts
  AND ETWErrorID IS NULL AND ErrorMessage LIKE '%COR[_]%'  
-- Modified by Senthilkumar for the Issue: 7017 on September 14 --ends
    
    
Declare RepErrCursor Cursor Local Fast_Forward For    
SELECT  DISTINCT  dbo.fn_Err_Table(ErrorMessage), ErrorID    
FROM #TEMP1    
    
Open RepErrCursor    
Fetch Next From RepErrCursor Into @ERRTableName, @ERRID    
    
    
While (@@Fetch_Status <> -1)    
Begin    
 Set @SQL1 = N'INSERT INTO #TEMP2     
  SELECT ErrorID, ErrorDate, ErrorMessage,     
 (SELECT COUNT(*) FROM CoreErrLog.dbo.' + @ERRTableName +     
 ' WHERE RepErrorID = ' + CAST(@ERRID AS CHAR(10)) +'), System, AccountNbr     
  FROM CoreErrLog.dbo.RepErrorLog WHERE ErrorID = ' + CAST(@ERRID AS CHAR(10))    
 --Print @SQL1    
 EXECUTE sp_executesql @SQL1    
    
 Fetch Next From RepErrCursor Into @ERRTableName, @ERRID    
End     
Close RepErrCursor      
Deallocate RepErrCursor      
    
UPDATE COREERRLOG.DBO.REPERRORLOG     
SET Status = 'C',    
datetimestamp = getdate()        
 FROM COREERRLOG.DBO.REPERRORLOG A , #TEMP2 B     
 WHERE B.[ERROR_COUNT] = 0 AND A.ErrorID = B.ERROR_ID        
    
Drop table #TEMP1    
Drop table #TEMP2    
    
Return
GO
