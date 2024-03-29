USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test451]    Script Date: 07.10.2020 9:59:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test451]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
SELECT DiagnosisCode INTO #tDIag FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'
UNION ALL
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'D00' AND 'D09'
/*
Если ONK_USL/USL_TIP in (3,4), то K_FR обязательно для заполнения, причем K_FR>=0.
*/
INSERT #tError
SELECT DISTINCT c.id,451
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				 
			  INNER JOIN dbo.t_ONK_USL ou ON
		c.id=ou.rf_idCase            
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND ou.rf_idN013 IN(3,4)	AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_SL WHERE rf_idCase=c.id AND K_FR>=0)

/*
Если в одном из значений CRIT представлено значение like 'fr%' and (DS1 like 'C%' or DS1 like ‘D0[0-9]%’), то K_FR  обязательно для заполнения, причем K_FR>=0
*/
/*
INSERT #tError
SELECT DISTINCT c.id,451
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'			
				INNER JOIN dbo.t_Diagnosis d ON
        c.id=d.rf_idCase
				INNER JOIN #tDIag dd ON
        dd.DiagnosisCode = d.DiagnosisCode	 
			  INNER JOIN dbo.t_AdditionalCriterion ad ON
		c.id=ad.rf_idCase            
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND ad.rf_idAddCretiria LIKE 'fr%' AND NOT EXISTS(SELECT 1 FROM dbo.t_ONK_SL WHERE rf_idCase=c.id AND K_FR>=0)
*/
INSERT #tError
SELECT DISTINCT c.id,451
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190101'				 
			  INNER JOIN dbo.t_AdditionalCriterion ad ON
		c.id=ad.rf_idCase            
			 INNER JOIN dbo.t_ONK_SL sl ON
		c.id=sl.rf_idCase           
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND sl.K_FR>0 AND ad.rf_idAddCretiria LIKE 'fr%' AND NOT EXISTS(SELECT 1 FROM vw_sprV024_Fraction WHERE IDDKK=ad.rf_idAddCretiria AND sl.K_FR >=MinValue AND sl.K_FR<=MaxValue )
