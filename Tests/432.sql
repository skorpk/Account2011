USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT	

select @idFile=id from vw_getIdFileNumber where CodeM='101801' and NumberRegister=12347 and ReportYear=2020

SELECT  ErrorNumber,COUNT(rf_idCase) AS CountCase from dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile GROUP BY ErrorNumber   ORDER BY CountCase

select * from vw_getIdFileNumber where id=@idFile

declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
--устанавливаем дату начала и дату окончани€ отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	

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
≈сли B_DIAG присутствует, то DIAG_DATE not is null and DIAG_TIP in (1,2) and DIAG_CODE not is null.
DIAG_DATE и DIAG_CODE по схеме об€зательны к заполнению
*/																								 

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
DIAG_TIP=1, то DIAG_CODE равен одному из кодов ID_MRF в N007. ≈сли же присутствует DIAG_RSLT, то DIAG_RSLT равен одному из кодов ID_R_M в N008, дл€ которых N008.ID_MRF=N007.ID_MRF}
*/

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


SELECT DISTINCT c.id,432,'Error',d.*
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

SELECT * FROM #n008 WHERE /*ID_R_M=d.ResultDiagnostic AND*/ ID_Mrf=8
SELECT n8.*
FROM oms_nsi.dbo.sprN008 n8 INNER JOIN oms_nsi.dbo.sprN007 n7 ON
		n8.ID_Mrf=n7.ID_Mrf 
WHERE n8.id_MRF=8
/*
≈сли DIAG_TIP=2, то DIAG_CODE равен одному из кодов ID_IGH в N010. ≈сли же присутсвует DIAG_RSLT, то DIAG_RSLT равен одному из кодов ID_R_I в N011, дл€ которых N011.ID_IGH=N010.ID_IGH
*/

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
≈сли DIAG_RSLT not is null, то REC_RSLT=1, и, наоборот,  если REC_RSLT=1, то DIAG_RSLT not is null.
*/

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
