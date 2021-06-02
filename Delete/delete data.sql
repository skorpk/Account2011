USE RegisterCasesTest
GO
DECLARE @dtStart DATETIME,
		@dtEnd DATETIME,
		@i TINYINT=1

SELECT @dtEnd=min(DateCreate) FROM dbo.t_FileBack

WHILE(@i<50)
BEGIN		  	
	--SELECT @dtEnd=dateadd(day,-1, convert(char(6), dateadd(month,1,@yyyy),112)+'01');
	SET @dtStart=@dtEnd
	SELECT @dtEnd=dateadd(day,10,@dtEnd);
	SELECT @dtEnd,@dtStart

	DELETE TOP(1000) FROM dbo.t_FileBack WHERE DateCreate>=@dtStart AND DateCreate<@dtEnd

	DBCC SHRINKFILE (N'account_log' , 0, TRUNCATEONLY)
	
	PRINT 'Данные удалены до '+CAST(cast(@dtEnd AS DATE) AS VARCHAR(10))
	
	
	SET @i=@i+1
END