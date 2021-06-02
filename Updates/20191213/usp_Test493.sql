USE [RegisterCases]
GO
if(OBJECT_ID('usp_Test493',N'P')) is not null
	drop PROCEDURE dbo.usp_Test493
go
CREATE PROC [dbo].[usp_Test493]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS


SELECT DiagnosisCode INTO #tDS1 FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'

INSERT #tDS1( DiagnosisCode ) 
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0[0-9]'

insert #tError
SELECT DISTINCT c.id,493
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'							 				
				INNER JOIN	dbo.vw_Diagnosis d ON
         c.id=d.rf_idCase
				INNER JOIN #tDS1 dd ON
         d.DS1=dd.DiagnosisCode
				left JOIN dbo.t_ONK_SL sl ON
        c.id=sl.rf_idCase				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.DS1_T IN (3,5,6) AND c.rf_idv006<3
		AND EXISTS(SELECT 1 FROM dbo.t_ONK_USL WHERE rf_idCase=c.id)

/*
insert #tError
SELECT DISTINCT c.id,493
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'							 				
				INNER JOIN	dbo.vw_Diagnosis d ON
         c.id=d.rf_idCase
				INNER JOIN #tDS1 dd ON
         d.DS1=dd.DiagnosisCode
				left JOIN dbo.t_ONK_SL sl ON
        c.id=sl.rf_idCase				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND (sl.DS1_T not IN (3,5,6) or c.rf_idv006>2)
		AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_USL WHERE rf_idCase=c.id)


insert #tError
SELECT DISTINCT c.id,493
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'							 				
				INNER JOIN	dbo.vw_Diagnosis d ON
         c.id=d.rf_idCase				
				left JOIN dbo.t_ONK_SL sl ON
        c.id=sl.rf_idCase				
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.DS1_T IN (3,5,6) AND c.rf_idv006<3
		AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_USL WHERE rf_idCase=c.id)
		AND NOT EXISTS(SELECT 1 FROM #tDS1 dd WHERE d.DS1=dd.DiagnosisCode)
		*/
DROP TABLE #tDS1
GO
GRANT EXECUTE ON usp_Test493 TO db_RegisterCase
go


