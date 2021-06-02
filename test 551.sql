USE RegisterCases
GO
DECLARE @idFile INT


select @idFile=id FROM dbo.vw_getIdFileNumber WHERE CodeM='571002' AND NumberRegister=14770 AND ReportYear=2014
declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6)
		
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod=rc.rf_idMO
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile

--устанавливаем дату начала и дату окончания отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))
------------------------------------------------------------------------------------------------------
SELECT * FROM vw_sprLPUInOMS WHERE mcod=@mcod


DECLARE @tmpOMS AS TABLE (mcod CHAR(6), DateBegin DATE, DateEnd DATE)
IF (SELECT COUNT(*) FROM vw_sprLPUInOMS WHERE mcod=@mcod)>1
BEGIN
;WITH sprPeriod AS
(
	SELECT ROW_NUMBER() OVER(ORDER BY mcod,DateBegin) AS ROWID,mcod ,DateBegin,(DateEnd-1)  AS DateEnd
	FROM vw_sprLPUInOMS 
	WHERE mcod=@mcod
)
INSERT @tmpOMS
SELECT a.mcod, a.DateBegin,a1.DateEnd
FROM sprPeriod a INNER JOIN sprPeriod a1 ON
			a.mcod=a1.mcod
			AND a.RowId<>a1.ROWID
			AND a.DateBegin<=a1.DateEnd
END
ELSE 
BEGIN 
 INSERT @tmpOMS( mcod ,DateBegin ,DateEnd)
 SELECT mcod,DateBegin,DateEnd FROM vw_sprLPUInOMS WHERE mcod=@mcod
 
END			
------------------------------------------------------------------------------------------------------

SELECT * FROM dbo.vw_sprT001 WHERE mcod=@mcod
SELECT * FROM @tmpOMS

select c.id,551
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
						inner join t_Case c on
					r.id=c.rf_idRecordCase					
					AND c.DateEnd>=@dateStart
					AND c.DateEnd<=@dateend
where NOT EXISTS(SELECT * FROM @tmpOMS WHERE mcod=a.rf_idMO and c.DateBegin>=DateBegin AND c.DateEnd<=DateEnd) 

/*
DECLARE @CodeM CHAR(6)='126501',--'125901',
		@dateBegin date='20140301',
		@dateEnd date='20140305'
		
SELECT CodeM,COUNT(*) AS ord FROM vw_sprLPUInOMS GROUP BY CodeM HAVING COUNT(*)>1  ORDER BY ord DESC
SELECT * FROM vw_sprLPUInOMS WHERE CodeM=@codeM

DECLARE @t AS TABLE (CodeM CHAR(6), DateBegin DATE, DateEnd DATE)
;WITH sprPeriod AS
(
SELECT ROW_NUMBER() OVER(ORDER BY CodeM,DateBegin) AS ROWID,CodeM,DateBegin,(DateEnd-1)  AS DateEnd
FROM vw_sprLPUInOMS 
WHERE CodeM=@CodeM
)
INSERT @t
SELECT a.CodeM, a.DateBegin,(a1.DateEnd+1)
FROM sprPeriod a INNER JOIN sprPeriod a1 ON
			a.CodeM=a1.CodeM
			AND a.RowId<>a1.ROWID
			AND a.DateBegin<=a1.DateEnd

SELECT *
FROM @t t

*/