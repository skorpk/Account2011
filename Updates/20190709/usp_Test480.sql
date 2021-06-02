USE [RegisterCases]
GO

/****** Object:  StoredProcedure [dbo].[usp_Test477]    Script Date: 10.06.2019 15:32:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create PROC [dbo].[usp_Test480]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
SELECT DiagnosisCode
INTO #tDS
FROM dbo.vw_sprMKB10 WHERE DiagnosisCode LIKE 'C%' OR DiagnosisCode LIKE 'D0%'

insert #tError
SELECT DISTINCT c.id,480
from t_file f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
				inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190501'	
				INNER JOIN t_DispInfo d1 ON
		c.id=d1.rf_idCase				
				INNER JOIN dbo.t_Diagnosis d ON
		c.id=d.rf_idCase 
				INNER JOIN #tDS dd ON
		d.DiagnosisCode=dd.DiagnosisCode             
where a.rf_idFiles=@idFile AND f.TypeFile='f' AND d.TypeDiagnosis=1 AND d1.IsOnko=1

insert #tError
SELECT DISTINCT c.id,480
from t_file f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
				inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20190501'	
				INNER JOIN t_DispInfo d1 ON
		c.id=d1.rf_idCase				
				INNER JOIN dbo.t_DS2_Info d ON
		c.id=d.rf_idCase 
				INNER JOIN #tDS dd ON
		d.DiagnosisCode=dd.DiagnosisCode             
where a.rf_idFiles=@idFile AND f.TypeFile='f' AND d1.IsOnko=1 
GO
GRANT EXECUTE ON usp_Test480 TO db_RegisterCase
go

