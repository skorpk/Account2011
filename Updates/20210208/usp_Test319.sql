USE RegisterCases
GO
if(OBJECT_ID('usp_Test319',N'P')) is not null
	drop PROCEDURE dbo.usp_Test319
go
CREATE PROC dbo.usp_Test319
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
	INSERT #tError
	SELECT c.id,319
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase			
				INNER JOIN t_mes m ON
            c.id=m.rf_idCase
				INNER JOIN oms_nsi.dbo.sprMUV018V019V022Relation vr ON
            m.MES=vr.Code_MU
	where a.rf_idFiles=@idFile AND c.rf_idV006=1 AND c.rf_idV008=32 AND NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprMUV018V019V022Relation v WHERE m.MES=v.Code_MU AND IDMPAC=c.rf_idV019 AND IDHVID=c.rf_idV018 AND DateBeg<=c.DateEnd AND c.DateEnd<=DateEnd)

	INSERT #tError
	SELECT c.id,319
	from t_File f INNER JOIN t_RegistersCase a ON
			f.id=a.rf_idFiles
			AND a.ReportMonth=@month
			AND a.ReportYear=@year
				  inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
				  inner join t_Case c on
			r.id=c.rf_idRecordCase			
				INNER JOIN t_mes m ON
            c.id=m.rf_idCase
				INNER JOIN vw_MU_VMP_Diag vr ON
            m.MES=vr.Code_MU
				INNER JOIN dbo.t_Diagnosis d ON
            c.id=d.rf_idCase
			AND d.TypeDiagnosis=1
	where a.rf_idFiles=@idFile AND c.rf_idV006=1 AND c.rf_idV008=32 AND NOT EXISTS(SELECT 1 FROM vw_MU_VMP_Diag v 
																					WHERE m.MES=v.Code_MU AND METOD_HMP=c.rf_idV019 AND VID_HMP=c.rf_idV018 
																							AND DateBeg<=c.DateEnd AND c.DateEnd<=DateEnd 
																							AND v.DiagnosisCode=d.DiagnosisCode)
GO
GRANT EXECUTE ON usp_Test319 TO db_RegisterCase