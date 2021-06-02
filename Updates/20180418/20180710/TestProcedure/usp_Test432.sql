USE [RegisterCases]
GO
create PROC [dbo].[usp_Test432]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
insert #tError
SELECT DISTINCT c.id,432
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
				INNER JOIN dbo.t_DiagnosticBlock d ON
		sl.id=d.rf_idONK_SL              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND DateDiagnostic IS NOT NULL AND (TypeDiagnostic IS NOT NULL OR CodeDiagnostic IS NOT null OR ResultDiagnostic IS NOT NULL)

SELECT ID_R_M, n7.ID_Mrf
INTO #n008
FROM oms_nsi.dbo.sprN008 n8 INNER JOIN oms_nsi.dbo.sprN007 n7 ON
		n8.ID_Mrf=n7.ID_Mrf 

insert #tError
SELECT DISTINCT c.id,432
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
				INNER JOIN dbo.t_DiagnosticBlock d ON
		sl.id=d.rf_idONK_SL              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND DateDiagnostic IS NULL AND TypeDiagnostic=1 AND NOT EXISTS(SELECT 1 FROM #n008 WHERE ID_R_M=d.ResultDiagnostic AND ID_Mrf=d.CodeDiagnostic)

DROP TABLE #n008

SELECT n10.ID_Igh,ID_R_I
INTO #n11
FROM oms_nsi.dbo.sprN010 n10 INNER JOIN oms_nsi.dbo.sprN011 n11 ON
			n10.ID_Igh = n11.ID_Igh

insert #tError
SELECT DISTINCT c.id,432
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
				INNER JOIN dbo.t_DiagnosticBlock d ON
		sl.id=d.rf_idONK_SL              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND DateDiagnostic IS NULL AND TypeDiagnostic=2 AND NOT EXISTS(SELECT 1 FROM #n11 WHERE ID_R_I=d.ResultDiagnostic AND ID_Igh=d.CodeDiagnostic)

DROP TABLE #n11																										 


go