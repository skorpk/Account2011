USE [RegisterCases]
GO
if(OBJECT_ID('usp_Test496',N'P')) is not null
	drop PROCEDURE dbo.usp_Test496
go
CREATE PROC dbo.usp_Test496
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS

CREATE TABLE #sprMUDiag(MUGroupCode INT,MUUnGroupCode INT, DS1  VARCHAR(8))

INSERT #sprMUDiag(MUGroupCode,MUUnGroupCode,DS1)
VALUES(60,4,'Z01.6'),(60,4,'Z03.1')
	 ,(60,5,'Z01.8'),(60,5,'Z03.1')
	 ,(60,6,'Z01.8'),(60,6,'Z03.1')
	 ,(60,7,'Z01.8'),(60,7,'Z03.1')
INSERT #sprMUDiag(MUGroupCode,MUUnGroupCode,DS1) SELECT 60,5,DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'
INSERT #sprMUDiag(MUGroupCode,MUUnGroupCode,DS1) SELECT 60,6,DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'
INSERT #sprMUDiag(MUGroupCode,MUUnGroupCode,DS1) SELECT 60,7,DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'

insert #tError
SELECT DISTINCT c.id,496
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
			INNER JOIN #sprMUDiag sprm ON
        sprm.MUGroupCode = mm.MUGroupCode
		AND sprm.MUUnGroupCode = mm.MUUnGroupCode
			INNER JOIN dbo.t_Diagnosis d ON
         d.rf_idCase = c.id
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.rf_idV010=28 AND d.TypeDiagnosis=1
	AND NOT EXISTS(SELECT 1 FROM #sprMUDiag dd WHERE sprm.MUGroupCode=dd.MUGroupCode AND sprm.MUUnGroupCode=dd.MUUnGroupCode AND d.DiagnosisCode=dd.DS1)

insert #tError
SELECT DISTINCT c.id,496
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
			INNER JOIN dbo.t_Diagnosis d ON
         d.rf_idCase = c.id
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND c.rf_idV010=28 AND d.TypeDiagnosis=1
	AND m.MUCode LIKE '60.8.%' AND d.DiagnosisCode='Z03.1'



GO
GRANT EXECUTE ON usp_Test496 TO db_RegisterCase
