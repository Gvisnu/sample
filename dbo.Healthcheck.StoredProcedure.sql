USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[Healthcheck]    Script Date: 12/31/2024 8:49:44 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE procedure [dbo].[Healthcheck] as

DECLARE @DBNAME VARCHAR(20)
DECLARE @STATUS_DB VARCHAR(20)
DECLARE @DB_NAME VARCHAR(20)
DECLARE STAT CURSOR FOR 
SELECT STATE,NAME FROM  SYS.DATABASES
OPEN STAT
FETCH NEXT FROM STAT INTO @STATUS_DB,@DB_NAME  
WHILE @@FETCH_STATUS = 0
IF @STATUS_DB=0
BEGIN
PRINT ( @DB_NAME+' DB IS UP AND RUNNING')
FETCH NEXT FROM STAT INTO  @STATUS_DB,@DB_NAME
END

ELSE 
PRINT ( @DB_NAME +' DB IS DOWN')
FETCH NEXT FROM STAT INTO  @STATUS_DB,@DB_NAME  
CLOSE STAT
DEALLOCATE STAT
GO
