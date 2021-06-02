USE RegisterCases
GO
DECLARE @idFile INT


select @idFile=id FROM dbo.vw_getIdFileNumber WHERE ReportYear=2021 AND CodeM='101001' AND NumberRegister=60
declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@dateReg DATE,
		@mcod CHAR(6)
		
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear,@dateReg=CAST(f.DateRegistration AS DATE),@mcod=rc.rf_idMO
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile

SELECT * FROM dbo.vw_getIdFileNumber WHERE id=@idFile
SELECT DISTINCT codeNomenclMU ,dateBeg, dateEnd INTO #tCSG FROM vw_sprNomenclMUBodyParts
--устанавливаем дату начала и дату окончани€ отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))

SELECT DISTINCT c.id,'006F.00.0430'
from t_File f JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  join t_Case c on
		r.id=c.rf_idRecordCase		
			  JOIN dbo.t_Diagnosis d ON
		c.id=d.rf_idCase				
		AND c.DateEnd>='20210101'					
where a.rf_idFiles=@idFile  AND d.TypeDiagnosis=1 AND EXISTS(SELECT 1 FROM dbo.t_Diagnosis dd WHERE dd.rf_idCase=d.rf_idCase AND d.DiagnosisCode=dd.DiagnosisCode AND dd.TypeDiagnosis IN(3,4)
															 UNION ALL
															 SELECT 1 FROM dbo.t_DS2_Info ds WHERE ds.rf_idCase=c.id AND ds.DiagnosisCode=d.DiagnosisCode )
SELECT d.*
from t_File f JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  join t_Case c on
		r.id=c.rf_idRecordCase		
			  JOIN dbo.t_Diagnosis d ON
		c.id=d.rf_idCase				
		AND c.DateEnd>='20210101'					
where a.rf_idFiles=@idFile AND c.GUID_Case='C0799C85-AA7B-0C04-E053-CD9115AC764F'

SELECT DISTINCT c.id,'006F.00.0440'
from t_File f JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  join t_Case c on
		r.id=c.rf_idRecordCase		
			  JOIN dbo.t_Diagnosis d ON
		c.id=d.rf_idCase				
		AND c.DateEnd>='20210101'					
where a.rf_idFiles=@idFile AND f.TypeFile='H' AND d.TypeDiagnosis=3 
	AND EXISTS(SELECT 1 FROM dbo.t_Diagnosis dd WHERE dd.rf_idCase=c.id AND dd.TypeDiagnosis=4 AND dd.DiagnosisCode=d.DiagnosisCode)

--≈сли DS like 'P%', то Age(количество полных лет)=0  
CREATE TABLE #t(errorVode VARCHAR(20),TypeDiagnosis TINYINT)

INSERT #t(errorVode,TypeDiagnosis) VALUES('003K.00.0590',1),('003K.00.0600',3),('003K.00.0610',4)

SELECT DISTINCT c.id,t.errorVode
from t_File f JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  join t_Case c on
		r.id=c.rf_idRecordCase		
			  JOIN dbo.t_Diagnosis d ON
		c.id=d.rf_idCase				
		AND c.DateEnd>='20210101'					
				JOIN #t t ON
         d.TypeDiagnosis=t.TypeDiagnosis
where a.rf_idFiles=@idFile AND c.Age>0 AND d.DiagnosisCode LIKE 'P%'

SELECT DISTINCT c.id,'003K.00.0610'
from t_File f JOIN t_RegistersCase a ON
		f.id=a.rf_idFiles
		AND a.ReportMonth=@month
		AND a.ReportYear=@year
			  join t_RecordCase r on
		a.id=r.rf_idRegistersCase
			  join t_Case c on
		r.id=c.rf_idRecordCase		
			  JOIN dbo.t_DS2_Info d ON
		c.id=d.rf_idCase				
		AND c.DateEnd>='20210101'									
where a.rf_idFiles=@idFile AND c.Age>0 AND d.DiagnosisCode LIKE 'P%'
go
DROP TABLE #t
GO
DROP TABLE #tCSG
