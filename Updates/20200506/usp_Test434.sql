USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test434]    Script Date: 06.05.2020 11:02:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test434]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
insert #tError
SELECT DISTINCT c.id,434
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
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
			  INNER JOIN dbo.vw_sprMKB10 m ON
		d.DS1=m.DiagnosisCode        
				INNER JOIN dbo.t_DiagnosticBlock dd ON
		sl.id=dd.rf_idONK_SL              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND dd.TypeDiagnostic=2 AND NOT EXISTS(SELECT * FROM oms_nsi.dbo.sprN012 WHERE DS_Igh=m.MainDS AND ID_Igh=dd.CodeDiagnostic) 
AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi mm WHERE mm.MUCode LIKE '60.9%' AND mm.rf_idCase=c.id)

insert #tError
SELECT DISTINCT c.id,434
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
				INNER JOIN dbo.vw_Diagnosis d ON
		c.id=d.rf_idCase
			  INNER JOIN dbo.vw_sprMKB10 m ON
		d.DS1=m.DiagnosisCode        
			 INNER JOIN oms_nsi.dbo.sprN012 n9 ON
		DS_Igh=m.MainDS
			 INNER JOIN dbo.t_DiagnosticBlock dd ON
		sl.id=dd.rf_idONK_SL
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND dd.TypeDiagnostic=2 AND c.DateEnd BETWEEN n9.DATEBEG AND n9.DATEEND
		AND NOT EXISTS(SELECT * FROM dbo.t_DiagnosticBlock dd1 WHERE dd1.rf_idONK_SL=sl.id AND dd1.TypeDiagnostic=2 AND dd1.CodeDiagnostic=n9.ID_Igh) 
		AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi mm WHERE mm.MUCode LIKE '60.9%' AND mm.rf_idCase=c.id)