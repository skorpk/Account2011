USE RegisterCases
GO
DECLARE @idFile INT


select @idFile=id FROM dbo.vw_getIdFileNumber WHERE CodeM='103001' AND ReportYear=2019 AND NumberRegister=117
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


select distinct c.id,502
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
WHERE c.rf_idV010=32 AND c.rf_idV002<>158 AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND MUCode='1.11.1')


select distinct c.id,502
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
WHERE c.rf_idV010=32 AND c.rf_idV002=158 AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND MUCode='1.11.2')
-------------------------------------------------
SELECT mu, 31 AS VIDPOM INTO #tMU FROM dbo.vw_sprMU WHERE MUGroupCode=60 AND MUUnGroupCode=3


select distinct c.id,502
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 			
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						INNER JOIN dbo.t_Meduslugi mm  ON
			c.id=mm.rf_idCase			
WHERE c.rf_idV010=32 AND c.rf_idV002<>158 AND mm.MUCode='1.11.1'
		AND EXISTS(SELECT 1 
					FROM dbo.t_Meduslugi m INNER JOIN dbo.t_Case cc ON
									m.rf_idCase=c.id                  
					WHERE cc.id=c.id AND mm.MUCode<>'1.11.1' AND NOT EXISTS(SELECT 1 FROM #tMU WHERE MUCode=m.MUCode AND VIDPOM=cc.rf_idV008)
					)


select distinct c.id,502
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						INNER JOIN dbo.t_Meduslugi mm  ON
			c.id=mm.rf_idCase			
WHERE c.rf_idV010=32 AND c.rf_idV002=158 AND mm.MUCode='1.11.2'
		AND EXISTS(SELECT 1 
					FROM dbo.t_Meduslugi m INNER JOIN dbo.t_Case cc ON
									m.rf_idCase=c.id                  
					WHERE cc.id=c.id AND mm.MUCode<>'1.11.2' AND NOT EXISTS(SELECT 1 FROM #tMU WHERE MUCode=m.MUCode AND VIDPOM=cc.rf_idV008)
					)


select distinct c.id,502
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase				
WHERE c.rf_idV010=43 AND NOT EXISTS(SELECT * FROM dbo.t_Meduslugi m WHERE m.rf_idCase=c.id AND MUCode LIKE '55.1.%')



select distinct c.id,502
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 
						inner join t_PatientSMO s on
			r.id=s.ref_idRecordCase
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						INNER JOIN dbo.t_Meduslugi mm  ON
			c.id=mm.rf_idCase			
WHERE c.rf_idV010=43 AND mm.MUCode LIKE '55.1.%'
			AND EXISTS(SELECT 1 
					FROM dbo.t_Meduslugi m 
					WHERE m.rf_idCase=c.id AND mm.MUCode NOT LIKE '55.1.%' AND NOT EXISTS(SELECT 1 FROM #tMU WHERE MUCode=m.MUCode )
					)	 