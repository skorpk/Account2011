USE RegisterCases
GO
DECLARE @idFile INT 
SELECT @idFile=id FROM dbo.vw_getIdFileNumber WHERE ReportYear=2014 AND ReportMonth=2

SELECT @idFile

declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
--устанавливаем дату начала и дату окончания отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	

--общий алгоритм
SELECT DISTINCT c.id,66,c.GUID_Case,c.rf_idMO,c.rf_idV008,c.rf_idV002 
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			AND c.IsCompletedCase=0
			AND c.DateEnd>=@dateStart
			AND c.DateEnd<@dateEnd
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
			AND m.MUCode NOT LIKE '2.82.%'			
WHERE NOT EXISTS(SELECT * FROM vw_MSLocation 
				 WHERE CodeM=@CodeLPU AND rf_idV006=c.rf_idV006 AND rf_idV008=c.rf_idV008 AND rf_idV002=c.rf_idV002 
						AND DateBegin<=c.DateBegin AND DateEnd>=c.DateEnd)

select c.id,66,c.rf_idMO,c.rf_idV008,c.rf_idV002 
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013
						inner join t_Case c on
			r.id=c.rf_idRecordCase			
			AND c.IsCompletedCase=1				
			AND c.DateEnd>=@dateStart
			AND c.DateEnd<@dateEnd
WHERE NOT EXISTS(SELECT * FROM vw_MSLocation 
				 WHERE CodeM=@CodeLPU AND rf_idV006=c.rf_idV006 AND rf_idV008=c.rf_idV008 AND rf_idV002=c.rf_idV002 
						AND DateBegin<=c.DateBegin AND DateEnd>=c.DateEnd)
-- алгоритм для случаев оказания амбулаторно-поликлинической помощи в приемном отделение стационара						
select c.id,66
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
			AND a.ReportYear>2013
						inner join t_Case c on
			r.id=c.rf_idRecordCase
			AND c.rf_idV006=3	
			AND c.DateEnd>=@dateStart
			AND c.DateEnd<@dateEnd
						INNER JOIN dbo.t_Meduslugi m ON
			c.id=m.rf_idCase
			AND m.MUCode LIKE '2.82.%'			
WHERE NOT EXISTS(SELECT * FROM vw_MSLocation 
				 WHERE CodeM=@CodeLPU AND rf_idV006=1 AND rf_idV008=31 AND rf_idV002=c.rf_idV002 
						AND DateBegin<=c.DateBegin AND DateEnd>=c.DateEnd)	
