USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='124530' and NumberRegister=155 and ReportYear=2019

select * from vw_getIdFileNumber where id=@idFile
declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6)
		
	
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod =rc.rf_idMO
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
--устанавливаем дату начала и дату окончания отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))

select distinct c.id,559,rf_idV006,rf_idV009
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprV009 v on
			c.rf_idV009=v.id
			and c.rf_idV006=v.USL_OK
			AND c.DateEnd <= v.DateEnd
			AND c.DateEnd>=v.DateBeg
where v.id is NULL

SELECT * FROM vw_sprV009 WHERE id IN(345,373,374)
---запись в справочнике V009 должна быть действующей для текущей даты (даты регистрации реестра сведений)
--28.03.2014
select distinct c.id,559
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						INNER JOIN dbo.t_CompletedCase z ON
			r.id=z.rf_idRecordCase								
where NOT EXISTS(SELECT * FROM vw_sprV009 WHERE id=c.rf_idV009 AND z.DateEnd>=DateBeg AND ISNULL(DateEnd,z.DateEnd)>=z.DateEnd)