USE RegisterCases
GO
DECLARE @idFile INT


select @idFile=id FROM dbo.vw_getIdFileNumber WHERE CodeM='571002' AND ReportYear=2014 AND NumberRegister=14310
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

--select distinct c.id,503
--from t_RegistersCase a inner join t_RecordCase r on
--			a.id=r.rf_idRegistersCase
--			and a.rf_idFiles=@idFile 						
--						inner join t_Case c on
--			r.id=c.rf_idRecordCase
--						INNER JOIN dbo.t_MES m ON
--			c.id=m.rf_idCase	
--						INNER JOIN vw_sprCSGTherapyMKB s ON
--			m.MES=s.code
--						INNER JOIN dbo.t_Diagnosis d ON
--			c.id=d.rf_idCase
--			AND d.TypeDiagnosis=1					
--WHERE c.rf_idV010=33  AND NOT EXISTS(SELECT * FROM dbo.vw_sprCSGTherapyMKB csg WHERE csg.code=m.MES AND csg.MKBCode=d.DiagnosisCode)

SELECT distinct c.id,503
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase
						INNER JOIN dbo.t_MES m ON
			c.id=m.rf_idCase	
						INNER JOIN vw_sprCSGSurgery s ON
			m.MES=s.code										   
WHERE NOT EXISTS(SELECT * 
				 FROM dbo.t_Meduslugi m INNER JOIN dbo.vw_sprCSGSurgery csg ON
						m.MUCode=csg.CodeMU
				 WHERE m.rf_idCase=c.id)

SELECT * FROM t_Meduslugi WHERE rf_idCase=34494457

---------------------------------------------503-----------------------------------------
--CREATE TABLE #tCSG (rf_idCase BIGINT,CSG VARCHAR(20),CodeMU VARCHAR(20))

--INSERT #tCSG( rf_idCase, CSG, CodeMU )
--select distinct c.id,MES,mu.MUCode
--from t_RegistersCase a inner join t_RecordCase r on
--			a.id=r.rf_idRegistersCase
--			and a.rf_idFiles=@idFile 						
--						inner join t_Case c on
--			r.id=c.rf_idRecordCase
--						INNER JOIN dbo.t_MES m ON
--			c.id=m.rf_idCase	
--						INNER JOIN vw_sprCSGSurgery s ON
--			m.MES=s.code
--						INNER JOIN dbo.t_Meduslugi mu ON
--			c.id=mu.rf_idCase
--			AND mu.MUCode<>'1.11.1'
--WHERE c.rf_idV010=33  

--SELECT t.rf_idCase,503 
--FROM #tCSG t left JOIN (SELECT rf_idCase FROM #tCSG a WHERE EXISTS(SELECT * FROM dbo.vw_sprCSGSurgery csg WHERE csg.code=a.CSG AND csg.CodeMU=a.CodeMU) )t1 ON
--		t.rf_idCase=t1.rf_idCase		
--WHERE t1.rf_idCase IS NULL
-- DROP TABLE #tCSG