USE RegisterCases
GO
if(OBJECT_ID('usp_Test314',N'P')) is not null
	drop PROCEDURE dbo.usp_Test314
go
CREATE PROC dbo.usp_Test314
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
SELECT DiagnosisCode INTO #td FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'D00' AND 'D09'
UNION ALL 
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'C%'

INSERT #tError
SELECT DISTINCT c.id,'314'
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
				INNER JOIN #td t ON
		t.DiagnosisCode=d.DS1
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND c.rf_idV009 IN(308,309,315)
AND NOT EXISTS(SELECT 1 FROM dbo.t_DirectionMU dm WHERE dm.rf_idCase=c.id)

INSERT #tError
SELECT DISTINCT c.id,'314'
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase			
				INNER JOIN dbo.t_DS_ONK_REAB d ON
        c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND c.rf_idV009 IN(308,309,315) AND d.DS_ONK=1
AND NOT EXISTS(SELECT 1 FROM dbo.t_DirectionMU dm WHERE dm.rf_idCase=c.id)
-----------------------------------------------------------------------------------------
INSERT #tError
SELECT DISTINCT c.id,'314'
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
				INNER JOIN #td t ON
		t.DiagnosisCode=d.DS1
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND c.rf_idV009 IN(308,309)
AND NOT EXISTS(SELECT 1 FROM dbo.t_DirectionMU dm WHERE dm.rf_idCase=c.id AND dm.TypeDirection IN(1,4))


INSERT #tError
SELECT DISTINCT c.id,'314'
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase			
				INNER JOIN dbo.t_DS_ONK_REAB d ON
        c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND c.rf_idV009 IN(308,309) AND d.DS_ONK=1
AND NOT EXISTS(SELECT 1 FROM dbo.t_DirectionMU dm WHERE dm.rf_idCase=c.id AND dm.TypeDirection IN(1,4))

INSERT #tError
SELECT DISTINCT c.id,'314'
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
				INNER JOIN #td t ON
		t.DiagnosisCode=d.DS1
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND c.rf_idV009=315
AND NOT EXISTS(SELECT 1 FROM dbo.t_DirectionMU dm WHERE dm.rf_idCase=c.id AND dm.TypeDirection=3)


INSERT #tError
SELECT DISTINCT c.id,'314'
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase			
				INNER JOIN dbo.t_DS_ONK_REAB d ON
        c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND c.rf_idV009 =315 AND d.DS_ONK=1
AND NOT EXISTS(SELECT 1 FROM dbo.t_DirectionMU dm WHERE dm.rf_idCase=c.id AND dm.TypeDirection=3)

GO
GRANT EXECUTE ON usp_Test314 TO db_RegisterCase