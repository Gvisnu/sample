USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[USP_SQLEmailNotification]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO


CREATE PROCEDURE [dbo].[USP_SQLEmailNotification] 
   @From varchar(100) ,
   @To varchar(100) ,
   @Subject varchar(100),
   @Body varchar(4000) 
AS

DECLARE @message int; DECLARE @config int; DECLARE @hr int; DECLARE @src varchar(255), @desc varchar(255)

EXEC @hr = sp_OACreate 'CDO.Message', @message OUT -- create the message object
EXEC @hr = sp_OACreate 'CDO.Configuration', @config OUT -- create the configuration object

EXEC @hr = sp_OASetProperty @config, 'Fields(cdoSendUsingMethod)', 'cdoSendUsingPort' -- Send the message using the network
EXEC @hr = sp_OASetProperty @config, 'Fields(cdosmtpconnectiontimeout)', '10' -- Send the message using the network
EXEC @hr = sp_OASetProperty @config, 'Fields(cdoSMTPServer)', 'exchange2003.sbl.com' -- SMTP Server

EXEC sp_OAMethod @config, 'Fields.Update'

-- Message Object
EXEC @hr = sp_OASetProperty @message, 'Configuration', @config -- set message.configuration = config
EXEC @hr = sp_OASetProperty @message, 'To', @To
EXEC @hr = sp_OASetProperty @message, 'From', @From
EXEC @hr = sp_OASetProperty @message, 'Subject', @Subject
EXEC @hr = sp_OASetProperty @message, 'TextBody', @Body
EXEC sp_OAMethod @message, 'Send'

-- Destroys the objects
EXEC @hr = sp_OADestroy @message
EXEC @hr = sp_OADestroy @config

RETURN

GO
