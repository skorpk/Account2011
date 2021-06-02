USE [RegisterCases]
GO
DECLARE @i INT=120439,
		@j TINYINT=1
WHILE(@j<10)
BEGIN		
	SET @i=@i-500
	DBCC SHRINKFILE (N'account_registerCases' , @i)
	SET @j=@j+1
END
SELECT @i
GO
