USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT--=127080

SELECT @idFile=f.id 
from vw_getIdFileNumber f WHERE CodeM='141023' AND ReportYear=2021 AND NumberRegister=24

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


SELECT c.id,469
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase
		AND c.DateEnd>='20190101'				
				INNER JOIN dbo.t_Prescriptions p ON
		c.id=p.rf_idCase
				INNER JOIN dbo.t_DispInfo d ON
		c.id=d.rf_idCase              
where a.rf_idFiles=@idFile AND f.TypeFile='F' AND p.NAZR=3 AND d.IsOnko=1 AND NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.V001 WHERE IDRB=ISNULL(p.DirectionMU,'') ) 
