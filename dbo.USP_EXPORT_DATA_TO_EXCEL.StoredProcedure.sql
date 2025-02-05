USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[USP_EXPORT_DATA_TO_EXCEL]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[USP_EXPORT_DATA_TO_EXCEL]  
(  
    @dbName varchar(100) = 'master',   
    @sql varchar(5000) = '',       
    @fullFileName varchar(100) = ''  
)  
as  
 declare @temp_tab_1 varchar(100)  
 declare @temp_tab_2 varchar(100)  
 declare @temp_sql1 nvarchar(200)  
 declare @temp_sql2 nvarchar(200)  
  
 if @sql = '' or @fullFileName = ''  
 begin  
     select 0 as ReturnValue -- failure  
     return  
 end   
   
 SET @temp_tab_1='##tempExp_'+ (select replace(replace(replace(replace(convert(varchar, getdate(),121),' ',''),'-',''),'.',''),':',''))  
 SET @temp_tab_2=@temp_tab_1+'_1'  
 --print @temp_tab  
 -- if DB isn't passed in set it to master  
 select    @dbName = 'use ' + @dbName + ';'  
   
 SET @temp_sql1='if object_id(''tempdb..'+@temp_tab_1 +''') is not null  
     drop table '+@temp_tab_1  
   
 EXEC SP_EXECUTESQL @temp_sql1  
  
 SET @temp_sql2='if object_id(''tempdb..'+@temp_tab_2 +''') is not null  
     drop table '+@temp_tab_2  
   
 EXEC SP_EXECUTESQL @temp_sql2  
   
  
 -- insert data into a global temp table  
 declare @columnNames varchar(8000), @columnConvert varchar(8000), @tempSQL varchar(8000)  
  
 select    @tempSQL = left(@sql, charindex('from', @sql)-1) + ' into '+ @temp_tab_1 +   
      substring(@sql, charindex('from', @sql)-1, len(@sql))  
  
 select @dbName + @tempSQL  
    
 exec(@dbName + @tempSQL)  
  
  
 if @@error > 0  
 begin  
     select 0 as ReturnValue -- failure  
     return  
 end   
  
 -- build 2 lists  
 -- 1. column names  
 -- 2. columns converted to nvarchar  
 SELECT    @columnNames = COALESCE( @columnNames  + ',', '') + column_name,  
  @columnConvert = COALESCE( @columnConvert  + ',', '') + 'convert(nvarchar(4000),'   
         + column_name + case when data_type in ('datetime', 'smalldatetime') then ',109'  
                              when data_type in ('numeric', 'decimal') then ',128'  
                              when data_type in ('float', 'real', 'money', 'smallmoney') then ',2'  
                              when data_type in ('datetime', 'smalldatetime') then ',120'  
                              else ''  
                         end + ') as ' + column_name  
 FROM    tempdb.INFORMATION_SCHEMA.Columns  
 WHERE    table_name = @temp_tab_1  
  
 -- execute select query to insert data and column names into new temp table  
 SELECT    @tempSQL = 'select ' + @columnNames + ' into '+ @temp_tab_2 + ' from (select ' + @columnConvert   
  + ', ''2'' as [temp##SortID]        from '+@temp_tab_1+ ' union all select '''   
  + replace(@columnNames, ',', ''', ''') + ''', ''1'') t order by [temp##SortID]'  
  
 exec (@tempSQL)  
 -- build full BCP query  
 --changed from SBGETL to @@SERVERNAME for issue 7074   
 select    @tempSQL = 'bcp  "select * from '+@temp_tab_2+'" queryout "' +   
  @fullFileName + '" -c -S' + @@SERVERNAME + ' -T -CRAW'  
  
 --select    @tempSQL = 'bcp "use core1;select * from ##TempExportData2 " queryout "' +   
 -- @fullFileName + '" -c -T -CRAW'  
  
 -- execute BCP  
  
 DECLARE @RSLTS INT  
    DECLARE @OUTPUT VARCHAR(255)  
    DECLARE @ERRORRESULTS VARCHAR(4000)  
    DECLARE @ERRTEXT NVARCHAR(4000)  
  
 CREATE TABLE #BCPOUTPUT (RESULT VARCHAR(255))  
  
 INSERT INTO #BCPOUTPUT EXEC @RSLTS = master..xp_cmdshell @tempSQL  
   
  
 if @@error <> 0  
 begin   
     select @@ERROR as ReturnValue -- failure  
  RAISERROR ('BCP FAILED.'  , 16, 1)  
     return  
 end  
  
 IF @RSLTS <> 0  
    BEGIN  
  
  DECLARE CRSR_RESULTS CURSOR FOR SELECT RESULT FROM #BCPOUTPUT  
  OPEN CRSR_RESULTS  
  SELECT @ERRORRESULTS = ''  
  FETCH Next FROM CRSR_RESULTS INTO @OUTPUT  
  WHILE @@FETCH_STATUS=0  
  BEGIN  
    SELECT @ERRORRESULTS = @ERRORRESULTS + CASE WHEN @OUTPUT IS NOT NULL THEN @OUTPUT + ' ' ELSE '' END  
    FETCH Next FROM CRSR_RESULTS INTO @OUTPUT  
  END  
  CLOSE CRSR_RESULTS  
  DEALLOCATE CRSR_RESULTS  
  
  Print @ERRORRESULTS  
  
        SET @ERRTEXT = 'ECHO  ' + @ERRORRESULTS + ' > ' + @fullFileName + '.LOG'  
  
  Print @ERRTEXT  
  
        EXEC MASTER..XP_CMDSHELL @ERRTEXT, NO_OUTPUT  
    END  
  
 DROP TABLE #BCPOUTPUT   
 EXEC SP_EXECUTESQL @temp_sql1  
 EXEC SP_EXECUTESQL @temp_sql2  
 select 1 as ReturnValue -- success  
  
GO
