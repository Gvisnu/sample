USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetOldestDiskBackupSetToKeep]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_GetOldestDiskBackupSetToKeep] @dbname varchar(255), @keepdate datetime OUTPUT

AS

SET NOCOUNT ON

DECLARE @MaxBackupDate datetime
DECLARE @NextStart datetime
DECLARE @Start datetime
DECLARE @NextFinish datetime
DECLARE @Finish datetime
DECLARE @DummyFutureDate datetime
DECLARE @DOScmd varchar(2000)
--DECLARE @dbname varchar(255)

DECLARE @FullBackups TABLE ( Backup_Set_ID integer not null
                           , Full_Backup_Start_Date datetime not null
                           , Full_Backup_Finish_Date datetime not null
                           , Next_Full_Backup_Start_Date datetime null
                           , Next_Full_Backup_Finish_Date datetime null
                           -- The clustered primary key is necessary to allow the
                           -- procedure to identify which transactiON AND differential
                           -- backup files fall between each of the full backups.
                           , PRIMARY KEY CLUSTERED( Full_Backup_Start_Date DESC
                                                  , Full_Backup_Finish_Date DESC
                                                  , Backup_Set_ID)
                           )

DECLARE @BackupSets TABLE (  Set_ID integer not null
                           , Set_Start_Date datetime not null
                           , Backup_File_ID integer not null
                           , Backup_File_Start_Date datetime not null
                           , Backup_File_Type char(1) not null )


  SET @DummyFutureDate = '9999-12-31'   -- Dummy date to use for null end date comparisons
--  SET @dbname = 'Core1'

/*
** Load the @FullBackups table variable with a list
** of all the FULL backups in the backup history tables.
** We need the ID, start, and finish times of each in order
** to identify the full set of differential and transaction
** backups that belong with each full backup.
*/
   INSERT @FullBackups
        ( Backup_Set_ID
        , Full_Backup_Start_Date
        , Full_Backup_Finish_Date )
   SELECT TOP 10
          Backup_Set_ID
         ,Backup_Start_Date
         ,Backup_Finish_Date
     FROM msdb..backupset
    WHERE database_name = @dbname
      AND type='D'
 ORDER BY Backup_Start_Date DESC


/*
** This type of recursive update only works on an ORDERED dataset.  Since the table variable
** @FullBackups was created with a primary key clustered on Full_Backup_Start_Date,
** Full_Backup_Finish_Date and Backup_Set_ID, the data should already be sorted in the desired order.
**
** For each full backup, find the start and finish date/time stamps of the NEXT full backup.
** The latest full backup will get null "next" values.
** This will allow us to easily identify the differential and transaction log backups that
** belong to each full backup.
*/
   UPDATE @FullBackups
      SET @NextStart  = Next_Full_Backup_Start_Date = @Start
        , @Start      = Full_Backup_Start_Date
        , @NextFinish = Next_Full_Backup_Finish_Date = @Finish
        , @Finish     = Full_Backup_Finish_Date

/*
** Now load table variable @BackupSets with all the full, differential, and transaction log
** backups as matched SETS of backups.
*/
   INSERT @BackupSets
        ( Set_ID
        , Set_Start_Date
        , Backup_File_ID
        , Backup_File_Start_Date
        , Backup_File_Type )
   SELECT s.Backup_Set_ID
        , s.Full_Backup_Start_Date
        , i.Media_Set_ID
        , i.backup_start_date
        , i.type
     FROM msdb..backupset i
     JOIN @FullBackups s
       ON (    i.backup_start_date >= s.Full_Backup_Finish_Date
           AND i.backup_start_date <  IsNull(s.Next_Full_Backup_Start_Date, @DummyFutureDate)
          )
       OR i.Backup_Set_ID = s.Backup_Set_ID
    WHERE i.database_name = @dbname
      AND i.type != 'F' -- no filegroup backups (we aren't using these anyway)

   SELECT @MaxBackupDate = max(s.Set_Start_Date)
     FROM msdb..backupmediafamily f
     JOIN @BackupSets s
       ON f.media_set_id = s.Backup_File_ID
    WHERE f.device_type IN (2, 102) -- physical disk devices only

   SELECT @keepdate = max(s.Set_Start_Date)
     FROM msdb..backupmediafamily f
     JOIN @BackupSets s
       ON f.media_set_id = s.Backup_File_ID
    WHERE f.device_type IN (2, 102) -- physical disk devices only
      AND s.Set_Start_Date < @MaxBackupDate

--    SELECT s.Set_Start_Date
--         , f.Physical_Device_Name
--      FROM msdb..backupmediafamily f
--      JOIN @BackupSets s
--        ON f.media_set_id = s.Backup_File_ID
--     WHERE f.device_type IN (2, 102) -- physical disk devices only
--       AND s.Set_Start_Date < @MaxBackupDate


GO
