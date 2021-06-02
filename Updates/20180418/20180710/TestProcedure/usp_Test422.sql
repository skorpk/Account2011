USE [RegisterCases]
GO
create PROC [dbo].[usp_Test422]
		@idFile INT,
		@month tinyint,
		@year smallint,
		@codeLPU char(6)		
AS
--отбираем диагнозы по которым не должна быть выборка
SELECT DiagnosisCode into #tDiag FROM vw_sprMKB10 WHERE MainDS >'C80' AND MainDS<'C97'


insert #tError
SELECT DISTINCT c.id,422
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'	
				LEFT JOIN dbo.t_PurposeOfVisit p ON
		c.id=p.rf_idCase			
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND p.rf_idCase IS null AND c.rf_idV006<4  
		AND NOT EXISTS(SELECT * FROM dbo.t_ONK_SL WHERE rf_idCase=c.id) AND c.rf_idV002<>158 AND ISNULL(p.rf_idV025,'0')<>'1.3'
	AND  EXISTS( SELECT 1 FROM dbo.vw_Diagnosis WHERE rf_idCase=c.id AND DS1 LIKE 'C%'
				UNION ALL
				SELECT 1 FROM dbo.vw_Diagnosis WHERE rf_idCase=c.id AND DS1='D70' and DS2 LIKE 'C%' AND NOT EXISTS(SELECT * FROM #tDiag WHERE DiagnosisCode=ds2)
				)

DROP TABLE #tDiag
GO