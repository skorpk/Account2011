USE RegisterCases
GO
if(OBJECT_ID('usp_Test316',N'P')) is not null
	drop PROCEDURE dbo.usp_Test316
go
CREATE PROC dbo.usp_Test316
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
SELECT DiagnosisCode , 1 AS typeDiag INTO #td FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'D00' AND 'D09'
UNION ALL 
SELECT DiagnosisCode,1 FROM dbo.vw_sprMKB10 WHERE MainDS IN('C00','C01','C02','C03','C04','C05'
															,'C06','C07','C08','C09','C10','C11'
															,'C12','C13','C15','C16','C18','C19'
															,'C20','C21','C22','C23','C25'
															,'C30','C31','C32','C33','C34','C40'
															,'C41','C43','C44','C45','C49','C51'
															,'C52','C53','C54','C56','C57','C58'
															,'C60','C61','C62','C64','C65','C66','C67','C73')
UNION ALL
SELECT DiagnosisCode,2 FROM dbo.vw_sprMKB10 WHERE MainDS IN('C14','C17','C26','C37','C39','C46','C47','C48','C50','C55','C63','C69','C70','C71','C72','C74','C75','C76','C77','C78','C79','C80','C97')

INSERT #td VALUES ('C24.0',1),('C38.1',1),('C38.2',1),('C38.3',1),('C68.0',1),('C24.1',2),('C24.8',2),('C24.9',2),('C38.0',2),('C38.4',2),('C38.8',2),('C68.1',2),('C68.8',2),('C68.9',2)


INSERT #tError
SELECT DISTINCT c.id,'316'
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase			
				INNER JOIN dbo.t_Diagnosis d ON
        c.id=d.rf_idCase				
				INNER JOIN dbo.t_AdditionalCriterion ad ON
        c.id=ad.rf_idCase
where a.rf_idFiles=@idFile AND d.TypeDiagnosis=1 AND ad.rf_idAddCretiria='sh9001' AND NOT EXISTS(SELECT 1 FROM #td dd WHERE d.DiagnosisCode=dd.DiagnosisCode AND dd.typeDiag=1)

INSERT #tError
SELECT DISTINCT c.id,'316'
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase			
				INNER JOIN dbo.t_Diagnosis d ON
        c.id=d.rf_idCase				
				INNER JOIN dbo.t_AdditionalCriterion ad ON
        c.id=ad.rf_idCase
where a.rf_idFiles=@idFile AND d.TypeDiagnosis=1 AND ad.rf_idAddCretiria='sh9002' AND NOT EXISTS(SELECT 1 FROM #td dd WHERE d.DiagnosisCode=dd.DiagnosisCode AND dd.typeDiag=2)

GO
GRANT EXECUTE ON usp_Test316 TO db_RegisterCase