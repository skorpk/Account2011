USE [RegisterCases]
GO
create PROC [dbo].[usp_Test421]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--отбираем диагнозы по которым не должна быть выборка
SELECT DiagnosisCode into #tDiag FROM vw_sprMKB10 WHERE MainDS >'C80' AND MainDS<'C97'

insert #tError
SELECT DISTINCT c.id,421
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'
				INNER JOIN t_DirectionMU d ON
		c.id=d.rf_idCase							 
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND NOT EXISTS(SELECT 1 FROM dbo.t_DS_ONK_REAB WHERE rf_idCase=c.id AND DS_ONK=1
															 UNION ALL 
															 SELECT 1 FROM dbo.vw_Diagnosis WHERE rf_idCase=c.id AND DS1 LIKE 'C%'
															 UNION ALL
															 SELECT 1 FROM dbo.vw_Diagnosis WHERE rf_idCase=c.id AND DS1='D70' and DS2 LIKE 'C%'
															  AND NOT EXISTS(SELECT * FROM #tDiag WHERE DiagnosisCode=ds2)
															 )
DROP TABLE #tDiag
GO
