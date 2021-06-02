USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT

select @idFile=id from vw_getIdFileNumber where CodeM='185905' and NumberRegister=1 and ReportYear=2019

select * from vw_getIdFileNumber WHERE id=@idFile
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

SELECT ErrorNumber, COUNT(rf_idCase) FROM dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile GROUP BY ErrorNumber

SELECT DISTINCT c.id,439 , rf_idN013
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'		 	  
				INNER JOIN dbo.t_ONK_USL sl ON
		c.id=sl.rf_idCase       
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.rf_idN013=1 AND sl.TypeSurgery IS NULL

SELECT DISTINCT c.id,439
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'		 	  
				INNER JOIN dbo.t_ONK_USL sl ON
		c.id=sl.rf_idCase       
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.rf_idN013>1 AND sl.TypeSurgery IS NOT NULL

SELECT DISTINCT c.id,439
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'		 	  
				INNER JOIN dbo.t_ONK_USL sl ON
		c.id=sl.rf_idCase       
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.rf_idN013=1 AND sl.TypeSurgery IS NOT NULL AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN014 WHERE ID_THir=sl.TypeSurgery)

