USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test442]    Script Date: 11.10.2019 12:12:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test442]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
insert #tError
SELECT DISTINCT c.id,442
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
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.rf_idN013 IN(3,4) AND sl.TypeRadiationTherapy IS NULL

insert #tError
SELECT DISTINCT c.id,442
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
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.rf_idN013 NOT IN(3,4) AND sl.TypeRadiationTherapy IS NOT NULL

insert #tError
SELECT DISTINCT c.id,442
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
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.rf_idN013 IN(3,4) AND sl.TypeRadiationTherapy IS NOT NULL 
	AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN017 n WHERE ID_TLuch=sl.TypeRadiationTherapy AND c.DateEnd BETWEEN n.DATEBEG AND n.DATEEND)

