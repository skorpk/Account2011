USE [RegisterCases]
GO
create PROC [dbo].[usp_Test436]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
insert #tError
SELECT DISTINCT c.id,436
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'		 	  
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase              
				INNER JOIN dbo.t_ONK_USL d ON
		c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND d.rf_idN013 IN(3,4) AND sl.TotalDose IS NULL
---если USL_TIP не 3 или 4, то тега не должно быть
insert #tError
SELECT DISTINCT c.id,436
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'		 	  
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase              
				INNER JOIN dbo.t_ONK_USL d ON
		c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND d.rf_idN013 not IN(3,4) AND sl.TotalDose>=0.0

---если нету ONK_USL, то тега не должно быть
insert #tError
SELECT DISTINCT c.id,436
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'		 	  
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase              				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.TotalDose>=0.0 AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_USL WHERE rf_idCase=c.id)
go