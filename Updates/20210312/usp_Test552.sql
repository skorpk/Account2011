USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_Test552]    Script Date: 12.03.2021 9:45:28 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROC [dbo].[usp_Test552]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
DECLARE @typeFile CHAR(1)

SELECT @typeFile =UPPER(TypeFile) from dbo.t_File WHERE id=@idFile
--DS0 DS2   DS3
IF @typeFile='H'
BEGIN
	insert #tError
	select distinct c.id,552 
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join dbo.t_Diagnosis d on
				c.id=d.rf_idCase									
	where a.rf_idFiles=@idFile AND d.TypeDiagnosis>1 and d.DiagnosisCode IS NOT NULL AND NOT EXISTS(SELECT * FROM dbo.vw_sprMKB10 WHERE DiagnosisCode=d.DiagnosisCode)
	-------12.03.2021---------------
	insert #tError
	select distinct c.id,553
	from t_RegistersCase a inner join t_RecordCase r on
						a.id=r.rf_idRegistersCase
									inner join t_Case c on
						r.id=c.rf_idRecordCase
									JOIN dbo.t_CompletedCase cc ON
                        cc.rf_idRecordCase = r.id
									inner join (SELECT DISTINCT rf_idCase,DiagnosisCode AS DS FROM dbo.t_Diagnosis WHERE TypeDiagnosis IN(3,4)) d on
						c.id=d.rf_idCase					
	where a.rf_idFiles=@idFile and NOT EXISTS(SELECT 1 FROM oms_nsi.dbo.sprMKBPeriod mkb WHERE mkb.DiagnosisCode=d.DS and cc.DateEnd>=mkb.DateBeg AND cc.DateEnd<=mkb.DateEnd)
END
IF @typeFile='F'
BEGIN
	insert #tError
	select distinct c.id,552 as Error
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join dbo.t_Diagnosis d on
				c.id=d.rf_idCase									
	where a.rf_idFiles=@idFile AND d.TypeDiagnosis=1 AND NOT EXISTS(SELECT * FROM dbo.vw_sprMKB10 WHERE DiagnosisCode=ISNULL(d.DiagnosisCode,'bla-bla'))

	insert #tError
	select distinct c.id,552 as Error
	from t_RegistersCase a inner join t_RecordCase r on
				a.id=r.rf_idRegistersCase
							inner join t_Case c on
				r.id=c.rf_idRecordCase
							inner join dbo.t_DS2_Info d on
				c.id=d.rf_idCase									
	where a.rf_idFiles=@idFile AND NOT EXISTS(SELECT * FROM dbo.vw_sprMKB10 WHERE DiagnosisCode=ISNULL(d.DiagnosisCode,'bla-bla'))
END