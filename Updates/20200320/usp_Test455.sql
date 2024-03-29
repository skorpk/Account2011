USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test455]    Script Date: 20.03.2020 9:19:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test455]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
/*
Значение REGNUM должно соответствовать классификатору N020 (для действующих на DATE_Z_2 записей).

*/
INSERT #tError
SELECT DISTINCT c.id,455
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				
			  INNER JOIN dbo.t_CompletedCase cc ON
		r.id=cc.rf_idRecordCase 
			  INNER JOIN dbo.t_DrugTherapy d on
		c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN020 n INNER JOIN oms_nsi.dbo.sprN020Period nn ON
																							n.sprN020Id=nn.rf_sprN020Id
WHERE ID_LEKP=d.rf_idV020 AND nn.DATEBEG<=cc.DateEnd AND nn.DATEEND>=cc.DateEnd)
/*
REGNUM должен быть уникален для ONK_USL(т.е не допускается указывать один и тот же препарат в нескольких тегах LEK_PR)
*/
;WITH cte
AS(
	SELECT c.id,d.rf_idN013,d.rf_idV020
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase						
			AND c.DateEnd>='20190101'							  			  
				  INNER JOIN dbo.t_DrugTherapy d on
			c.id=d.rf_idCase
	where a.rf_idFiles=@idFile AND f.TypeFile='H'
	GROUP BY c.id,d.rf_idN013,d.rf_idV020
	HAVING COUNT(*)>1
)
INSERT #tError SELECT id,455 FROM cte
go