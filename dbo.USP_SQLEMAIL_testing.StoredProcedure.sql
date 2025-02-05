USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[USP_SQLEMAIL_testing]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[USP_SQLEMAIL_testing]    
AS    
BEGIN
    DECLARE @output varchar(1000);    
    DECLARE @TOEMAILIDS varchar(8000);    
    DECLARE @profilename varchar(100);     
    DECLARE @RETURNCODE INT;
    DECLARE @PrmSubject varchar(255);
    DECLARE @BodyMessage varchar(8000); 
    DECLARE @From varchar(100);
    DECLARE @Attachment varchar(1000); -- Assuming you missed this declaration

    -- Added for issue 7094    
    SET @profilename = (SELECT Appsettingvalue FROM Core1.dbo.DT_AppSetting WHERE Appsetting = 'SQLEmailProfileName'); 

    SET @PrmSubject = 'IMPORTANT - Reperrorlog exceeds 100';   
    SET @BodyMessage = 'Please look into the below excel to find out the errors that need attention';
    SET @From = core1.dbo.fn_getEmailIdsbyEmailGroupID(3883); 
    
    -- Get the email addresses for the particular email group id    
    SELECT @TOEMAILIDS = core1.dbo.fn_getEmailIdsbyEmailGroupID(3883);   
   
    IF LEN(ISNULL(@TOEMAILIDS, '')) <= 0     
    BEGIN    
        SET @TOEMAILIDS = 'it-coreon-call@zinnia.com';    
    END;   
   
    IF ISNULL(@Attachment, '') <> ' '   
    BEGIN   
        EXEC @RETURNCODE = msdb.dbo.sp_send_dbmail 
            @profile_name = @profilename,    
            @recipients = @TOEMAILIDS,    
            @subject = @PrmSubject,    
            @body = @BodyMessage,    
            @file_attachments = @Attachment,  
            @from_address = @From;  
    END     
    ELSE    
    BEGIN    
        EXEC @RETURNCODE = msdb.dbo.sp_send_dbmail 
            @profile_name = @profilename,    
            @recipients = @TOEMAILIDS,    
            @subject = @PrmSubject,    
            @body = @BodyMessage,  
            @from_address = @From;  
    END;    
    
    -- If there are no email ids found for the specific email group id, then send an email to it-core on-call group    
    IF LEN(ISNULL(@TOEMAILIDS, '')) <= 0     
    BEGIN    
        SET @PrmSubject = 'EMAILGROUPID 3883 NOT FOUND IN DT_EMAILGROUPS TABLE.';    
    
        EXEC @RETURNCODE = msdb.dbo.sp_send_dbmail 
            @profile_name = @profilename,    
            @recipients = @TOEMAILIDS,    
            @subject = @PrmSubject,    
            @body = @PrmSubject,  
            @from_address = @From;  
    
        PRINT @RETURNCODE;    
    END;    
    
    RETURN;    
END;



GO
