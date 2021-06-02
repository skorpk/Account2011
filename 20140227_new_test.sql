USE RegisterCases
GO
DECLARE @idFile INT
SELECT @idFile=id FROM dbo.vw_getIdFileNumber WHERE ReportMonth=2 AND ReportYear=2014 AND DateRegistration>'20140225'   ORDER BY NEWID()
declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile
--устанавливаем дату начала и дату окончания отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))

--select distinct c.id,591
--from t_RegistersCase a inner join t_RecordCase r on
--			a.id=r.rf_idRegistersCase
--			and a.rf_idFiles=@idFile 
--						inner join t_PatientSMO s on
--			r.id=s.ref_idRecordCase
--						inner join (SELECT rf_idRecordCase,id,rf_idV010 from t_Case WHERE rf_idV010<>32 AND rf_idV002!=158 AND DateEnd>=@dateStart AND DateEnd<@dateEnd) c on
--			r.id=c.rf_idRecordCase	
--						inner join t_Meduslugi m on
--			c.id=m.rf_idCase
--WHERE m.MUCode='1.11.1' AND c.rf_idV010<>33

--select distinct c.id,591
--from t_RegistersCase a inner join t_RecordCase r on
--			a.id=r.rf_idRegistersCase
--			and a.rf_idFiles=@idFile 
--						inner join t_PatientSMO s on
--			r.id=s.ref_idRecordCase
--						inner join t_Case c on
--			r.id=c.rf_idRecordCase				
--						inner join t_Meduslugi m on
--			c.id=m.rf_idCase
--WHERE m.MUCode='1.11.2' AND c.rf_idV010<>32 AND c.rf_idV002<>158

--select distinct c.id,570
--from t_RegistersCase a inner join t_RecordCase r on
--			a.id=r.rf_idRegistersCase
--			and a.rf_idFiles=@idFile 
--						inner join (SELECT rf_idRecordCase,id,rf_idV002,IsSpecialCase from t_Case WHERE rf_idV010<>33 AND DateEnd>=@dateStart AND DateEnd<@dateEnd) c on
--			r.id=c.rf_idRecordCase
--			and c.rf_idV002!=158
--			AND c.IsSpecialCase IS null	
--						inner join t_Meduslugi m on
--			c.id=m.rf_idCase			
--where c.rf_idV002<>m.rf_idV002 AND NOT EXISTS(SELECT * from vw_idCaseWithOutPRVSandProfilCompare WHERE rf_idFiles=@idFile AND DateEnd>=@dateStart AND DateEnd<@dateEnd AND id=c.id)
/*
select distinct c.id,591
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
WHERE c.rf_idV006=1 and c.rf_idV010=33 AND EXISTS(SELECT * FROM dbo.t_Meduslugi m LEFT JOIN oms_nsi.dbo.V001 v ON m.MUCode=v.IDRB
													 WHERE v.IDRB IS null AND m.rf_idCase=c.id AND MUCode<>'1.11.1')

select distinct c.id,591
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
WHERE c.rf_idV006=1 and c.rf_idV010=32 AND c.rf_idV002<>58 AND EXISTS(SELECT * FROM dbo.t_Meduslugi m LEFT JOIN oms_nsi.dbo.V001 v ON m.MUCode=v.IDRB
																	  WHERE v.IDRB IS null AND m.rf_idCase=c.id AND MUCode<>'1.11.1')

select distinct c.id,591
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
WHERE c.rf_idV010=32 AND c.rf_idV002=58 AND EXISTS(SELECT * FROM dbo.t_Meduslugi m LEFT JOIN oms_nsi.dbo.V001 v ON m.MUCode=v.IDRB
																	  WHERE v.IDRB IS null AND m.rf_idCase=c.id AND MUCode<>'1.11.2')																	  

select c.id,505
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile 					
								inner join t_Case c on
					r.id=c.rf_idRecordCase														
					AND c.DateEnd>=@dateStart AND c.DateEnd<@dateEnd
								INNER JOIN dbo.t_Diagnosis d ON
					c.id=d.rf_idCase
					AND d.TypeDiagnosis=1
WHERE c.rf_idV010=32 AND c.rf_idV008=32 AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi mu WHERE mu.rf_idCase=c.id AND mu.DiagnosisCode=d.DiagnosisCode
																			AND mu.rf_idV002=c.rf_idV002 AND mu.rf_idV004=c.rf_idV004)																	  

select c.id,505
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile 								
								inner join t_Case c on
					r.id=c.rf_idRecordCase		
					AND c.DateEnd>=@dateStart AND c.DateEnd<@dateEnd												
								INNER JOIN dbo.t_Diagnosis d ON
					c.id=d.rf_idCase
					AND d.TypeDiagnosis=1
WHERE c.rf_idV010=33 AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi mu WHERE mu.rf_idCase=c.id AND mu.DiagnosisCode=d.DiagnosisCode
																			AND mu.rf_idV002=c.rf_idV002 AND mu.rf_idV004=c.rf_idV004)																			
*/																			
select c.id,510
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile 								
								inner join t_Case c on
					r.id=c.rf_idRecordCase														
					AND DateEnd>=@dateStart AND DateEnd<@dateEnd
								INNER JOIN dbo.t_MES m ON
					c.id=m.rf_idCase
								INNER JOIN vw_sprMUCompletedCase s ON
					m.MES=s.MU
WHERE c.rf_idV008=32  AND c.rf_idV010=32 AND s.MUCode<>c.rf_idV018

select c.id,510
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile 								
								inner join t_Case c on
					r.id=c.rf_idRecordCase														
					AND DateEnd>=@dateStart AND DateEnd<@dateEnd
								INNER JOIN dbo.t_MES m ON
					c.id=m.rf_idCase					
WHERE c.rf_idV008=32  AND c.rf_idV010=32 AND m.V018<>c.rf_idV018

select c.id,510
from t_RegistersCase a inner join t_RecordCase r on
					a.id=r.rf_idRegistersCase
					and a.rf_idFiles=@idFile 								
								inner join t_Case c on
					r.id=c.rf_idRecordCase														
					AND DateEnd>=@dateStart AND DateEnd<@dateEnd
								INNER JOIN dbo.t_MES m ON
					c.id=m.rf_idCase					
WHERE c.rf_idV008=32  AND c.rf_idV010=34 AND m.V018<>c.rf_idV018

--select c.id,510
--from t_RegistersCase a inner join t_RecordCase r on
--					a.id=r.rf_idRegistersCase
--					and a.rf_idFiles=@idFile 					
--								inner join t_Case c on
--					r.id=c.rf_idRecordCase														
--					AND DateEnd>=@dateStart AND DateEnd<@dateEnd
--								INNER JOIN dbo.t_MES m ON
--					c.id=m.rf_idCase
--WHERE c.rf_idV008=32  AND c.rf_idV010=34 AND NOT EXISTS(SELECT * FROM dbo.vw_sprMUCompletedCase WHERE MU=m.MES)