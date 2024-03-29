USE [RegisterCases]
GO
create PROC [dbo].[usp_Test419]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--Если тег присутствует, то его значение должно быть равно 1 и (DS1=Z03.1 или DS2=Z03.1).
insert #tError
SELECT DISTINCT c.id,419
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'				
			 INNER JOIN dbo.t_DS_ONK_REAB d ON
		c.id=d.rf_idCase 
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT * FROM dbo.t_Diagnosis dd WHERE dd.rf_idCase=c.id AND dd.DiagnosisCode='Z03.1' AND dd.TypeDiagnosis IN(1,3))

--если (DS1=Z03.1 или DS2=Z03.1), то DS_ONK=1
insert #tError
SELECT DISTINCT c.id,419
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'				
			 INNER JOIN dbo.t_DS_ONK_REAB d ON
		c.id=d.rf_idCase 
			 INNER JOIN dbo.t_Diagnosis dd ON
		c.id=dd.rf_idCase           
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND d.DS_ONK<>1 AND dd.DiagnosisCode='Z03.1' AND dd.TypeDiagnosis IN(1,3)

insert #tError
SELECT DISTINCT c.id,419
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'						
			 INNER JOIN dbo.t_Diagnosis dd ON
		c.id=dd.rf_idCase           
where a.rf_idFiles=@idFile AND f.TypeFile='H'  AND dd.DiagnosisCode='Z03.1' AND dd.TypeDiagnosis IN(1,3) AND NOT EXISTS(SELECT * FROM dbo.t_DS_ONK_REAB WHERE rf_idCase=c.id)

GO
