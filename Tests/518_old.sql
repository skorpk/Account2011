USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT=63256



select @idFile=id from vw_getIdFileNumber where CodeM='161007' and NumberRegister=889 AND ReportYear=2016
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

select c.id,518
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>'20160430'
						INNER JOIN vw_CSLP_Coefficient co ON
			c.id=co.rf_idCase
WHERE c.IT_SL<>co.Sum_CSLP

--error 518
select DISTINCT c.id,518
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>'20160430'
						INNER JOIN dbo.t_Coefficient co ON
			c.id=co.rf_idCase
WHERE NOT EXISTS(SELECT * FROM oms_nsi.dbo.tSLP WHERE code=co.Code_SL)			                      

select DISTINCT c.id,518,c.Age
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>'20160430'
						INNER JOIN dbo.t_Coefficient co ON
			c.id=co.rf_idCase
						INNER JOIN (VALUES(1,0,4),(2,74,120)) v(code,ageStart, ageEnd) ON
			co.Code_SL=v.code
			AND c.age<=v.AgeStart
			AND c.age>=v.AgeEnd

select DISTINCT c.id,518
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
			AND c.DateEnd>'20160430'
						INNER JOIN dbo.t_Coefficient co ON
			c.id=co.rf_idCase
WHERE NOT EXISTS(SELECT * FROM dbo.VW_sprCoefficient WHERE code=co.Code_SL AND coefficient=co.Coefficient AND c.DateEnd>=dateBeg AND c.DateEnd<=dateEnd)	