USE RegisterCases
GO
SET NOCOUNT ON 
DECLARE @dtStart DATETIME,
		@dtEnd DATETIME,
		@i TINYINT=1

SELECT @dtStart=min(DateRegistration) FROM dbo.t_File WHERE DateRegistration<'20190115'

CREATE TABLE #t(
				id INT, 
				reportMonth TINYINT, 
				reportYear SMALLINT, 
				YearMonth AS cast(CAST(reportYear AS CHAR(4))+RIGHT('0'+CAST(reportMonth AS VARCHAR(2)),2) AS INT)	
				)

 DECLARE @dtBeginCase DATE,
		@dtEndCase DATE


WHILE(@i<2)
BEGIN		  	
	SELECT @dtEnd=dateadd(day,7,@dtStart);
	
	INSERT #t( id, reportMonth, reportYear )
	SELECT f.id,a.ReportMonth,a.ReportYear
	from dbo.t_File f INNER JOIN dbo.t_RegistersCase a ON
			f.id=a.rf_idFiles
	WHERE DateRegistration>=@dtStart AND DateRegistration<@dtEnd
	
	SELECT @dtBeginCase=CAST(MIN(YearMonth) AS VARCHAR(6))+'01', @dtEndCase=dateadd(day,-1, convert(char(6), dateadd(month,1,CAST(MAX(YearMonth) AS VARCHAR(6))+'01'),112)+'01') from #t

	PRINT('start - '+CONVERT(VARCHAR(20),GETDATE(),126))
	DELETE FROM dbo.t_Case WHERE DateEnd BETWEEN @dtBeginCase AND @dtEndCase
	
	DELETE FROM dbo.t_File 
	FROM dbo.t_File f INNER JOIN #t t ON
				f.id=t.id  
	PRINT(@@ROWCOUNT)
	PRINT('end - '+CAST(@i AS VARCHAR(2))+' '+CONVERT(VARCHAR(20),GETDATE(),126))
	PRINT('-------------------------------------------------------------------')
	TRUNCATE TABLE #t
	SET @i=@i+1
	SELECT @dtStart=DATEADD(DAY,7,@dtStart)
END

DBCC SHRINKFILE (N'account_log' , 0, TRUNCATEONLY) WITH NO_INFOMSGS
DROP TABLE #t

GO 5

SELECT min(DateRegistration) FROM dbo.t_File

