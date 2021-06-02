USE [RegisterCases]
GO
if(OBJECT_ID('usp_Test306',N'P')) is not null
	drop PROCEDURE dbo.usp_Test306
go
CREATE PROC dbo.usp_Test306
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
CREATE TABLE #sprDiag(DS1  VARCHAR(8))

INSERT #sprDiag(DS1) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'
INSERT #sprDiag(DS1) SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'D0[0-9]'
/*
1.	≈сли в составе случа€ представлены услуги из класса 60.8.* и ZL_LIST\ZAP\Z_SL\SL\DS1=Z03.1, то во всех тегах USL ZL_LIST\ZAP\Z_SL\SL\USL\DS ( NOT like Ђ—%ї and NOT like УD0[0-9]%Ф)
*/
insert #tError
SELECT DISTINCT c.id,306
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20200101'		
			INNER JOIN dbo.t_Meduslugi m ON
        m.rf_idCase = c.id
			INNER JOIN vw_sprMU mm ON
        mm.MU=m.MUCode				
			INNER JOIN dbo.vw_Diagnosis d ON
        c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND mm.MUGroupCode=60 AND mm.MUUnGroupCode=8 AND d.DS1='Z03.01'
		AND EXISTS(SELECT 1 
					FROM dbo.t_Meduslugi m1 INNER JOIN #sprDiag dd ON
							m1.DiagnosisCode=dd.DS1
					WHERE m1.rf_idCase=c.id
					)
/*
2.	≈сли в составе случа€ представлены услуги из класса 60.8.* и ZL_LIST\ZAP\Z_SL\SL\DS1 like СC%Т, то хот€ бы в одном теге USL ZL_LIST\ZAP\Z_SL\SL\USL\DS=ZL_LIST\ZAP\Z_SL\SL\DS1
*/								
insert #tError
SELECT DISTINCT c.id,306
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20200101'		
			INNER JOIN dbo.t_Meduslugi m ON
        m.rf_idCase = c.id
			INNER JOIN vw_sprMU mm ON
        mm.MU=m.MUCode				
			INNER JOIN dbo.vw_Diagnosis d ON
        c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND mm.MUGroupCode=60 AND mm.MUUnGroupCode=8 AND d.DS1 LIKE 'C%'
		AND NOT EXISTS(SELECT 1 FROM dbo.t_Meduslugi m1 WHERE m1.rf_idCase=c.id AND m1.DiagnosisCode<>d.DS1)
GO
GRANT EXECUTE ON usp_Test306 TO db_RegisterCase