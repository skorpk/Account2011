USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test436]    Script Date: 05.01.2019 10:21:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test436]
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
		AND c.DateEnd<'20190101'		 	  
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
		AND c.DateEnd<'20190101'		 	  
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
		AND c.DateEnd<'20190101'	 	  
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase              				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.TotalDose>=0.0 AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_USL WHERE rf_idCase=c.id)

/*
Тег должен присутствовать в обязательном порядке, для которой в теге ONK_USL (USL_TIP=3 или USL_TIP=4).
*/
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
		AND c.DateEnd>='20190101'	
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase              		
				INNER JOIN dbo.t_ONK_USL d ON
		c.id=d.rf_idCase		
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.TotalDose IS NULL AND d.rf_idN013 IN(3,4)