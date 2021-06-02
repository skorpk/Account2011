USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT,
	@month TINYINT=8,
	@year SMALLINT=2018

select @idFile=id from vw_getIdFileNumber WHERE CodeM='103001' and NumberRegister=198 and ReportYear=2020

select * from vw_getIdFileNumber where id=@idFile

SELECT * FROM dbo.t_File WHERE id=@idFile

SELECT DiagnosisCode into #tDiag FROM vw_sprMKB10 WHERE MainDS >'C80' AND MainDS<'C97'



SELECT DISTINCT c.id,422,c.GUID_Case,d.*,c.rf_idV002
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles		
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase						
		AND c.DateEnd>='20180901'	
				LEFT JOIN dbo.t_DS_ONK_REAB d ON
		c.id=d.rf_idCase			
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND d.DS_ONK=0 AND c.rf_idV006<4  
		AND NOT EXISTS(SELECT * FROM dbo.t_ONK_SL WHERE rf_idCase=c.id) AND c.rf_idV002<>158 
	AND  EXISTS(SELECT 1 FROM dbo.vw_Diagnosis WHERE rf_idCase=c.id AND DS1 LIKE 'C%'
				UNION ALL
				SELECT 1 FROM dbo.vw_Diagnosis WHERE rf_idCase=c.id AND DS1 LIKE 'D0%'
				UNION ALL              
				SELECT 1 FROM dbo.vw_Diagnosis WHERE rf_idCase=c.id AND DS1='D70' and DS2 LIKE 'C%' AND NOT EXISTS(SELECT * FROM #tDiag WHERE DiagnosisCode=ds2)
				)

DROP TABLE #tDiag
SELECT * FROM dbo.vw_Diagnosis WHERE rf_idCase=126836948

go

--SELECT * FROM dbo.t_ONK_SL WHERE rf_idCase=100763818
