USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test432]    Script Date: 05.01.2019 10:26:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test432]
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
		AND c.DateEnd<'20190101'	 	  
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
		AND c.DateEnd<'20190101'	 	  	 	  
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase              
				INNER JOIN dbo.t_DiagnosticBlock d ON
		sl.id=d.rf_idONK_SL              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND DateDiagnostic IS NULL AND TypeDiagnostic=1 AND NOT EXISTS(SELECT 1 FROM #n008 WHERE ID_R_M=d.ResultDiagnostic AND ID_Mrf=d.CodeDiagnostic)

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
		AND c.DateEnd<'20190101'	 	  	 	  
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase              
				INNER JOIN dbo.t_DiagnosticBlock d ON
		sl.id=d.rf_idONK_SL              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND DateDiagnostic IS NULL AND TypeDiagnostic=2 AND NOT EXISTS(SELECT 1 FROM #n11 WHERE ID_R_I=d.ResultDiagnostic AND ID_Igh=d.CodeDiagnostic)

/*
Если B_DIAG присутствует, то DIAG_DATE not is null and DIAG_TIP in (1,2) and DIAG_CODE not is null.
DIAG_DATE и DIAG_CODE по схеме обязательны к заполнению
*/																								 
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
		AND c.DateEnd>='20190101'	
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase              
				INNER JOIN dbo.t_DiagnosticBlock d ON
		sl.id=d.rf_idONK_SL              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND DateDiagnostic IS NOT NULL AND TypeDiagnostic NOT IN(1,2) 

/*
DIAG_TIP=1, то DIAG_CODE равен одному из кодов ID_MRF в N007. Если же присутствует DIAG_RSLT, то DIAG_RSLT равен одному из кодов ID_R_M в N008, для которых N008.ID_MRF=N007.ID_MRF}
*/
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
		AND c.DateEnd>='20190101'		 	  	 	  
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase              
				INNER JOIN dbo.t_DiagnosticBlock d ON
		sl.id=d.rf_idONK_SL              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND TypeDiagnostic=1 AND NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprN007 WHERE ID_Mrf=d.CodeDiagnostic)

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
		AND c.DateEnd>='20190101'	
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase              
				INNER JOIN dbo.t_DiagnosticBlock d ON
		sl.id=d.rf_idONK_SL              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND TypeDiagnostic=1 AND d.ResultDiagnostic IS NOT NULL
	 AND NOT EXISTS(SELECT 1 FROM #n008 WHERE ID_R_M=d.ResultDiagnostic AND ID_Mrf=d.CodeDiagnostic)

/*
Если DIAG_TIP=2, то DIAG_CODE равен одному из кодов ID_IGH в N010. Если же присутсвует DIAG_RSLT, то DIAG_RSLT равен одному из кодов ID_R_I в N011, для которых N011.ID_IGH=N010.ID_IGH
*/
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
		AND c.DateEnd>='20190101'		 	  	 	  
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase              
				INNER JOIN dbo.t_DiagnosticBlock d ON
		sl.id=d.rf_idONK_SL              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND TypeDiagnostic=2 AND NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprN010 WHERE ID_Igh=d.CodeDiagnostic)


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
		AND c.DateEnd>='20190101'	
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase              
				INNER JOIN dbo.t_DiagnosticBlock d ON
		sl.id=d.rf_idONK_SL              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND d.ResultDiagnostic IS NOT NULL AND TypeDiagnostic=2 AND NOT EXISTS(SELECT 1 FROM #n11 WHERE ID_R_I=d.ResultDiagnostic AND ID_Igh=d.CodeDiagnostic)


/*
Если DIAG_RSLT not is null, то REC_RSLT=1, и, наоборот,  если REC_RSLT=1, то DIAG_RSLT not is null.
*/
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
		AND c.DateEnd>='20190101'	
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase              
				INNER JOIN dbo.t_DiagnosticBlock d ON
		sl.id=d.rf_idONK_SL              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND d.ResultDiagnostic IS NOT NULL AND ISNULL(d.REC_RSLT,9)<>1

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
		AND c.DateEnd>='20190101'	
				INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase              
				INNER JOIN dbo.t_DiagnosticBlock d ON
		sl.id=d.rf_idONK_SL              
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND d.ResultDiagnostic IS NULL AND d.REC_RSLT=1

DROP TABLE #n008
DROP TABLE #n11
go