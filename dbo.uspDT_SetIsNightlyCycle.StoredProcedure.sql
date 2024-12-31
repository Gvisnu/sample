USE [Core1]
GO
/****** Object:  StoredProcedure [dbo].[uspDT_SetIsNightlyCycle]    Script Date: 12/31/2024 8:49:45 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
  
CREATE PROCEDURE [dbo].[uspDT_SetIsNightlyCycle]  
(  
 @NightlyCycle INT,  
 @SystemID INT  
)  
AS  
BEGIN  
UPDATE IsNightlyCycle   
   SET IsNightlyCycle = @NightlyCycle  
  WHERE SystemId = @SystemID  
END  
GO
