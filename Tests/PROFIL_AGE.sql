USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT--=127080

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='124528' AND ReportYear=2021 AND NumberRegister=25

SELECT * FROM dbo.vw_getIdFileNumber WHERE id=@idFile									  


--select * from vw_getIdFileNumber where id=@idFile
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

SELECT DISTINCT c.id,CASE WHEN c.rf_idV002=14 AND c.age<60 THEN '003K.00.0760' WHEN c.rf_idV002=55 AND c.age>0 THEN '003K.00.0750' END
from t_File f JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  join t_RecordCase r on
		a.id=r.rf_idRegistersCase			  
			  join t_Case c on
		r.id=c.rf_idRecordCase					  		
		AND c.DateEnd>='20210101'	
where a.rf_idFiles=@idFile AND (CASE WHEN c.rf_idV002=14 AND c.age<60 THEN 1 WHEN c.rf_idV002=55 AND c.age>0 THEN 1 ELSE 0 END)=1
go