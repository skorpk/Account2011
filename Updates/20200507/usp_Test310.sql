USE RegisterCases
GO
if(OBJECT_ID('usp_Test310',N'P')) is not null
	drop PROCEDURE dbo.usp_Test310
go
CREATE PROC dbo.usp_Test310
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--Если МГИ, то тег USL должен быть один в случае
INSERT #tError
SELECT DISTINCT c.id,'310'
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase								
				INNER JOIN dbo.t_Meduslugi m ON
        c.id=m.rf_idCase
where a.rf_idFiles=@idFile AND m.MUCode LIKE '60.9.%' AND EXISTS(SELECT mm.rf_idCase FROM dbo.t_Meduslugi mm WHERE rf_idCase=c.id GROUP BY mm.rf_idCase HAVING COUNT(*)>1)

--Если МГИ, то основной диагноз должен быть равен диагнозу на уровне USL
INSERT #tError
SELECT DISTINCT c.id,'310'
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase								
			  INNER JOIN dbo.vw_Diagnosis d ON
        c.id=d.rf_idCase
				INNER JOIN dbo.t_Meduslugi m ON
        c.id=m.rf_idCase
where a.rf_idFiles=@idFile AND m.MUCode LIKE '60.9.%' AND d.DS1<>m.DiagnosisCode

--Если МГИ, и по услуги нет совпадения с таблицой справочников, то не должно быть блока B_Diag
INSERT #tError
SELECT distinct c.id,'310'
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase											  
				INNER JOIN dbo.t_Meduslugi m ON
        c.id=m.rf_idCase
				INNER JOIN dbo.t_ONK_SL o ON
         c.id=o.rf_idCase
				INNER JOIN dbo.t_DiagnosticBlock db ON
         o.id=db.rf_idONK_SL
where a.rf_idFiles=@idFile AND m.MUCode LIKE '60.9.%' AND NOT EXISTS(SELECT 1 FROM dbo.vw_sprMGI_N010_N012 n WHERE n.mu=m.MUCode)

--Если МГИ, и по услуги есть совпадения с таблицой sprMUN010
INSERT #tError
SELECT DISTINCT c.id,'310'
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase											  
			    inner join dbo.t_CompletedCase cc on
		r.id=cc.rf_idRecordCase											  
				INNER JOIN dbo.vw_Diagnosis d ON
        c.id=d.rf_idCase
				INNER JOIN dbo.t_Meduslugi m ON
        c.id=m.rf_idCase
				INNER JOIN dbo.vw_sprMGI_N010_N012 mg ON
        m.MUCode=mg.MU
		AND d.RubricName=mg.DS_Igh
		AND cc.DateEnd BETWEEN mg.DATEBEG AND mg.DATEEND
where a.rf_idFiles=@idFile AND m.MUCode LIKE '60.9.%' AND NOT EXISTS(SELECT 1 
																	 FROM dbo.t_ONK_SL o INNER JOIN dbo.t_DiagnosticBlock d ON
																				o.id=d.rf_idONK_SL
																	 WHERE o.rf_idCase=c.id AND d.TypeDiagnostic=2 AND d.REC_RSLT=1)
INSERT #tError
SELECT DISTINCT c.id,'310'
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			 inner join dbo.t_CompletedCase cc on
		r.id=cc.rf_idRecordCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase											  
			 INNER JOIN dbo.vw_Diagnosis d ON
        c.id=d.rf_idCase
				INNER JOIN dbo.t_Meduslugi m ON
        c.id=m.rf_idCase
				INNER JOIN dbo.vw_sprMGI_N010_N012 mg ON
        m.MUCode=mg.MU
		AND cc.DateEnd BETWEEN mg.DATEBEG AND mg.DATEEND
				INNER JOIN dbo.t_ONK_SL o ON
         c.id=o.rf_idCase
				INNER JOIN dbo.t_DiagnosticBlock db ON
         o.id=db.rf_idONK_SL
where a.rf_idFiles=@idFile AND m.MUCode LIKE '60.9.%' AND db.TypeDiagnostic=2 AND db.REC_RSLT=1
		AND NOT EXISTS(SELECT 1 FROM dbo.vw_sprMGI_N010_N012 n WHERE n.mu=m.MUCode AND d.RubricName=n.DS_Igh AND db.CodeDiagnostic=n.Diag_Code AND cc.DateEnd BETWEEN n.DATEBEG AND n.DATEEND)


GO
GRANT EXECUTE ON usp_Test310 TO db_RegisterCase