USE [RegisterCases]
GO
DECLARE @i INT=102991,
		@j TINYINT=1
WHILE(@j<20)
BEGIN		
	SET @i=@i-300
	--DBCC SHRINKFILE (N'account_registerCases' , @i)
	DBCC SHRINKFILE (N'account_registerCasesInsurer' , @i)
	SET @i=@i-300
	SELECT @i
	SET @j=@j+1
END
GO
