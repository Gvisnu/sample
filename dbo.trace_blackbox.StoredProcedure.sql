USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[trace_blackbox]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE    PROCEDURE [dbo].[trace_blackbox] @on int = 2 AS
  /* If no argument is passed to the @on parameter then get the current blackbox trace status.
     If @on is zero then stop and delete the blackbox trace.
     If @on is one then create and start the blackbox trace.
  */ 
  declare @traceid int, @blackboxstatus int, @dir nvarchar(80)
  set @traceid = 0
  set @blackboxstatus = 0
  set nocount on
  SELECT @traceid = traceid FROM :: fn_trace_getinfo(0)
   where property = 1 and value = 8

 
   IF @on = 0 and @traceid > 0
   begin
    select @blackboxstatus = cast(value as int) FROM :: fn_trace_getinfo(0)
     where traceid = @traceid and property = 5
    IF @blackboxstatus > 0 exec sp_trace_setstatus @traceid,0 --stop blackbox trace
    exec sp_trace_setstatus @traceid,2 --delete blackbox trace definition
   end
 
   IF @on = 1
     begin
      IF @traceid < 1 exec sp_trace_create @traceid OUTPUT, 8 --create blackbox trace
      exec sp_trace_setstatus @traceid,1 --start blackbox trace
     end
 
   set @traceid = 0
  set @blackboxstatus = 0
  SELECT @traceid = traceid FROM :: fn_trace_getinfo(0)
   where property = 1 and value = 8
  select @blackboxstatus = cast(value as int) FROM :: fn_trace_getinfo(0)
   where traceid = @traceid and property = 5
  IF @traceid > 0 and @blackboxstatus > 0
     begin
      select @dir = cast(value as nvarchar(80)) FROM :: fn_trace_getinfo(0)
       where traceid = @traceid and property = 2
      select 'The blackbox trace is running and the trace file is in the following directory.'
      select @dir + '.trc'
     end
  ELSE select 'The blackbox trace is not running.'
 
   set nocount off
 
   
GO
