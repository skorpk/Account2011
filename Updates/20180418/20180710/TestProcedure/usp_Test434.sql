USE [RegisterCases]
GO
create PROC [dbo].[usp_Test434]
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
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND dd.TypeDiagnostic=2 
		AND NOT EXISTS(SELECT * FROM dbo.t_DiagnosticBlock dd1 WHERE dd1.rf_idONK_SL=sl.id AND dd1.TypeDiagnostic=2 AND dd1.CodeDiagnostic=n9.ID_Igh) 
GO