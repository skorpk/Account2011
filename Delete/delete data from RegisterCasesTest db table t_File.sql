USE RegisterCases
GO
SET NOCOUNT ON 
DECLARE @dtStart DATETIME,
		@dtEnd DATETIME,
		@i TINYINT=1

SELECT @dtStart=min(DateRegistration) FROM dbo.t_File

WHILE(@i<30)
BEGIN		  	
	SELECT @dtEnd=dateadd(day,7,@dtStart);

	PRINT('start - '+CONVERT(VARCHAR(20),GETDATE(),126))


	DELETE FROM dbo.t_File WHERE DateRegistration>=@dtStart AND DateRegistration<@dtEnd
	
	PRINT('end - '+CAST(@i AS VARCHAR(2))+' '+CONVERT(VARCHAR(20),GETDATE(),126))
	PRINT('-------------------------------------------------------------------')
	
	SET @i=@i+1
	SELECT @dtStart=DATEADD(DAY,7,@dtStart)
END

DBCC SHRINKFILE (N'account_log' , 0, TRUNCATEONLY) WITH NO_INFOMSGS
GO
SELECT min(DateRegistration) FROM dbo.t_File