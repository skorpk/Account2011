USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='804504' AND ReportYear=2021 AND NumberRegister=1

select * from vw_getIdFileNumber where id=@idFile
declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@mcod CHAR(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@mcod =rc.rf_idMO
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
--устанавливаем дату начала и дату окончания отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	

SET STATISTICS TIME,IO on
 --проверяется участие медицинской организации в системе ОМС в течение всего срока лечения
--но перед этим объединяем интервалы участия МО в системе ОМС
CREATE TABLE #tmpOMS(mcod CHAR(6), DateBegin DATE, DateEnd DATE)

SELECT ROW_NUMBER() OVER(ORDER BY mcod,DateBegin) AS ROWID,mcod ,DateBegin,(DateEnd-1)  AS DateEnd
INTO #tMO
FROM vw_sprLPUInOMS 
WHERE mcod=@mcod

IF (SELECT COUNT(*) FROM vw_sprLPUInOMS WHERE mcod=@mcod)>1
BEGIN
	--;WITH sprPeriod AS
	--(
	--	SELECT ROW_NUMBER() OVER(ORDER BY mcod,DateBegin) AS ROWID,mcod ,DateBegin,(DateEnd-1)  AS DateEnd
	--	FROM vw_sprLPUInOMS 
	--	WHERE mcod=@mcod
	--)
	INSERT #tmpOMS
	SELECT a.mcod, a.DateBegin,a1.DateEnd
	FROM #tMO a INNER JOIN #tMO a1 ON
				a.mcod=a1.mcod
				AND a.RowId<>a1.ROWID
				AND a.DateBegin<=a1.DateEnd
END
ELSE 
BEGIN 
 INSERT #tmpOMS( mcod ,DateBegin ,DateEnd)
 SELECT mcod,DateBegin,DateEnd FROM vw_sprLPUInOMS WHERE mcod=@mcod 
END	

SELECT mcod,DateBegin,DateEnd FROM vw_sprLPUInOMS WHERE mcod=@mcod 

select c.id,551, DateEnd, a.rf_idMO
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile
						inner join t_Case c on
					r.id=c.rf_idRecordCase					
					AND c.DateEnd>=@dateStart
					AND c.DateEnd<=@dateend
where NOT EXISTS(SELECT * FROM #tmpOMS WHERE mcod=a.rf_idMO and c.DateBegin>=DateBegin AND c.DateEnd<=DateEnd)  

SELECT * FROM #tmpOMS WHERE mcod='340316' ORDER BY DateBegin
go
DROP TABLE #tMO
DROP TABLE #tmpOMS
SET STATISTICS TIME,IO OFF