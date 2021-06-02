USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='124528' and NumberRegister=26 and ReportYear=2015

DECLARE @tError AS TABLE(rf_idCase bigint)
INSERT @tError( rf_idCase )
SELECT distinct e.rf_idCase
from vw_getIdFileNumber f INNER JOIN dbo.t_ErrorProcessControl e ON
			f.id=e.rf_idFile
where f.id=@idFile AND e.ErrorNumber=513

SELECT distinct e.*,f.NumberRegister
from vw_getIdFileNumber f INNER JOIN dbo.t_ErrorProcessControl e ON
			f.id=e.rf_idFile
where f.id=@idFile AND e.ErrorNumber=513

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
--устанавливаем дату начала и дату окончания отчетного периода
declare @dateStart date=CAST(@year as CHAR(4))+right('0'+CAST(@month as varchar(2)),2)+'01'
declare @dateEnd date=dateadd(month,1,dateadd(day,1-day(@dateStart),@dateStart))	

SELECT DateRegistration FROM dbo.t_File WHERE id=@idFile

SELECT DISTINCT p.*,c.DateBegin,c.DateEnd,c.id,r.*
FROM dbo.t_ErrorProcessControl e INNER JOIN dbo.t_Case c ON
			e.rf_idCase=c.id
							INNER JOIN dbo.t_RecordCase r ON
			c.rf_idRecordCase=r.id
							INNER JOIN dbo.t_RefRegisterPatientRecordCase rp ON
			r.id=rp.rf_idRecordCase
							INNER JOIN dbo.t_RegisterPatient p ON
			rp.rf_idRegisterPatient=p.id
			AND p.rf_idFiles=@idFile
WHERE e.rf_idFile=@idFile AND ErrorNumber=513			

--SELECT DISTINCT p.*,c.DateBegin,c.DateEnd,c.id
--FROM dbo.t_ErrorProcessControl e INNER JOIN dbo.t_Case c ON
--			e.rf_idCase=c.id
--							INNER JOIN dbo.t_RecordCase r ON
--			c.rf_idRecordCase=r.id
--							INNER JOIN dbo.t_RefRegisterPatientRecordCase rp ON
--			r.id=rp.rf_idRecordCase
--							INNER JOIN dbo.t_RegisterPatient p ON
--			rp.rf_idRegisterPatient=p.id
--WHERE ErrorNumber=513 AND c.id IN (47598078,47598277)

SELECT * 
FROM dbo.t_RefCasePatientDefine r INNER JOIN dbo.t_CasePatientDefineIteration i ON
				r.id=i.rf_idRefCaseIteration
								INNER JOIN dbo.t_CaseDefine d ON
				r.id=d.rf_idRefCaseIteration								
WHERE rf_idCase IN (SELECT rf_idCase FROM @tError)

--SELECT * FROM dbo.t_RefCaseAttachLPUItearion2 WHERE rf_idCase=47994770
