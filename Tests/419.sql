USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT,
	@month TINYINT,
	@year SMALLINT

select @idFile=id from vw_getIdFileNumber where CodeM='101801' and NumberRegister=12229 and ReportYear=2020

select * from vw_getIdFileNumber where id=@idFile

DECLARE @codeLPU CHAR(6),
		@dateReg DATE

select @month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile

SELECT DiagnosisCode into #tDiag FROM vw_sprMKB10 WHERE MainDS LIKE 'C%'
INSERT #tDiag( DiagnosisCode ) SELECT DiagnosisCode FROM vw_sprMKB10 WHERE MainDS LIKE 'D0_' 
INSERT #tDiag( DiagnosisCode ) SELECT DiagnosisCode FROM vw_sprMKB10 WHERE MainDS ='D70' 


--Если тег присутствует, то его значение должно быть равно 1 и (DS1=Z03.1 или DS2=Z03.1).
/*
Если DS_ONK=1, то ((DS1=Z03.1) или (DS2=Z03.1 и DS1 НЕ ЗНО, т.е is not like (‘С%' и D0% и нейтропения )).
*/

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
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND d.DS_ONK=1 AND NOT EXISTS(SELECT 1 FROM dbo.t_Diagnosis dd WHERE dd.rf_idCase=c.id AND dd.DiagnosisCode='Z03.1' AND dd.TypeDiagnosis =1
																			UNION ALL 
																			SELECT 1 FROM dbo.vw_Diagnosis dd WHERE dd.rf_idCase=c.id AND DS2 IS NOT NULL AND dd.DS2='Z03.1' 
																					AND NOT EXISTS(SELECT 1 FROM #tDiag WHERE DiagnosisCode=dd.DS1)
																			)

--SELECT * FROM dbo.vw_Diagnosis WHERE rf_idCase=130217696

SELECT DISTINCT c.id,419,dd.DiagnosisCode,d.DS_ONK
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
go
DROP TABLE #tDiag