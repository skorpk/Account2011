USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT	

select @idFile=id from vw_getIdFileNumber where CodeM='101801' and NumberRegister=12217 and ReportYear=2020

SELECT  ErrorNumber,COUNT(rf_idCase) from dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile GROUP BY ErrorNumber

select * from vw_getIdFileNumber where id=@idFile

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


SELECT DISTINCT c.id,449,ou.*,c.Age
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				 
			 INNER JOIN dbo.t_ONK_USL ou ON
		c.id=ou.rf_idCase           
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND ou.rf_idN013 IN(1,3,4,6) 
		AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi WHERE rf_idCase=c.id AND MUSurgery IS NOT null)

SELECT * FROM oms_nsi.dbo.sprN013 WHERE ID_TLech IN(1,3,4,6)