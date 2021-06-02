USE RegisterCases
GO
DECLARE @idFile INT


select @idFile=id FROM dbo.vw_getIdFileNumber WHERE CodeM='151005' AND ReportYear=2018 AND NumberRegister=5
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
--устанавливаем дату начала и дату окончания отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))

--SELECT * FROM dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile

select c.id,505	,d.DiagnosisCode,c.rf_idV004, c.rf_idV002
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile 					
								inner join t_Case c on
					r.id=c.rf_idRecordCase	
					AND c.DateEnd>=@dateStart AND c.DateEnd<@dateEnd													
								INNER JOIN dbo.t_Diagnosis d ON
					c.id=d.rf_idCase
					AND d.TypeDiagnosis=1
								INNER JOIN (VALUES (33),(43)) v010(id) ON
					c.rf_idV010=v010.id	
WHERE c.rf_idV002<>158 AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi mu WHERE mu.rf_idCase=c.id AND mu.DiagnosisCode=d.DiagnosisCode
																			AND mu.rf_idV002=c.rf_idV002 AND mu.rf_idV004=c.rf_idV004)

SELECT * FROM dbo.t_Meduslugi mu WHERE rf_idCase=100755282
--SELECT *
--FROM dbo.vw_sprV002 WHERE id IN (2,136)
select c.id,505,rf_idV010
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile 								
								inner join t_Case c on
					r.id=c.rf_idRecordCase	
					AND c.DateEnd>=@dateStart AND c.DateEnd<@dateEnd										
WHERE c.rf_idV010=32 AND c.rf_idV002<>158 AND EXISTS(SELECT * FROM dbo.t_Meduslugi m LEFT JOIN oms_nsi.dbo.V001 v ON m.MUCode=v.IDRB
														WHERE v.IDRB IS null AND m.rf_idCase=c.id AND MUCode<>'1.11.1')

SELECT * FROM dbo.t_Meduslugi m 
WHERE m.MUSurgery LIKE 'А%' AND m.rf_idCase=80949779 AND MUCode<>'1.11.1'

SELECT * FROM oms_nsi.dbo.V001 WHERE IDRB IN('А16.26.093','А16.26.094')

SELECT * FROM  OMS_NSI.dbo.sprDentalMU WHERE code IN('А16.26.093','А16.26.094')