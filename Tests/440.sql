USE RegisterCases
GO
USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT,
	@month TINYINT=9,
	@year SMALLINT=2018

select @idFile=id from vw_getIdFileNumber where CodeM='103001' and NumberRegister=147 and ReportYear=2018

select * from vw_getIdFileNumber where id=@idFile

--SELECT ErrorNumber, COUNT(rf_idCase) FROM dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile GROUP BY ErrorNumber

SELECT DISTINCT c.id,440
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
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.rf_idN013=2 AND sl.TypeDrug IS NULL

SELECT DISTINCT c.id,440
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
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.rf_idN013<>2 AND sl.TypeDrug IS NOT NULL

SELECT DISTINCT c.id,440, TypeDrug
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
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.rf_idN013=2 AND sl.TypeDrug IS NOT NULL AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN015 WHERE ID_TLek_L=sl.TypeDrug)

