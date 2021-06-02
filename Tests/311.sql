USE RegisterCases
GO
SET NOCOUNT ON
declare @idFile INT	

select @idFile=id from vw_getIdFileNumber where CodeM='101801' and NumberRegister=12230 and ReportYear=2020


select * from vw_getIdFileNumber where id=@idFile

declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile

SELECT DiagnosisCode INTO #td FROM dbo.vw_sprMKB10 WHERE MainDS BETWEEN 'A00' AND 'T98'
UNION ALL
SELECT DiagnosisCode FROM dbo.vw_sprMKB10 WHERE MainDS LIKE 'U%'

SELECT DISTINCT c.id,'311',p.rf_idV025,d.DS1
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase			
				INNER JOIN dbo.t_PurposeOfVisit p ON
		c.id=p.rf_idCase					
				INNER JOIN dbo.vw_Diagnosis d ON
        c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND p.rf_idV025 IN('1.0','1.1','1.2','1.3','3.0') AND c.rf_idV010<>28
AND NOT EXISTS(SELECT 1 FROM #td t WHERE t.DiagnosisCode=d.DS1)

SELECT * FROM oms_nsi.dbo.sprV025

SELECT DISTINCT c.id,'311'
from t_File f INNER JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  inner join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  inner join t_Case c on
		r.id=c.rf_idRecordCase			
				INNER JOIN dbo.t_PurposeOfVisit p ON
		c.id=p.rf_idCase					
				INNER JOIN dbo.vw_Diagnosis d ON
        c.id=d.rf_idCase
where a.rf_idFiles=@idFile AND c.rf_idV006=3 AND p.rf_idV025 ='2.6' AND d.DS1='Z%' AND c.rf_idV010=28
go
DROP TABLE #td