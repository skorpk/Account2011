USE RegisterCases
go
SET NOCOUNT ON
declare @idFile INT=54756

--SELECT @idFile=rf_idFile FROM dbo.t_ErrorProcessControl WHERE ErrorNumber=65 AND DateRegistration>'20141021 10:00:00' GROUP BY rf_idFile ORDER BY NEWID()

select @idFile=id from vw_getIdFileNumber where CodeM='611001' and NumberRegister=16 and ReportYear=2015

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

SELECT *
FROM dbo.t_ErrorProcessControl WHERE rf_idFile=@idFile AND ErrorNumber=57

SELECT pe.ID--c.id,DateBegin,pe.ID,p.*
FROM t_Case c INNER JOIN dbo.t_RecordCase r ON
		c.rf_idRecordCase=r.id
			INNER JOIN dbo.t_RefRegisterPatientRecordCase rp ON
		r.id=rp.rf_idRecordCase
			INNER JOIN dbo.t_RegisterPatient p ON
		rp.rf_idRegisterPatient=p.id
			INNER JOIN (SELECT *
						FROM dbo.t_ErrorProcessControl 
						WHERE rf_idFile=@idFile AND ErrorNumber=57) e ON
		c.id=e.rf_idCase
			INNER JOIN PolicyRegister.dbo.PEOPLE pe ON
		p.Fam=pe.FAM
		AND p.BirthDay=pe.DR
WHERE p.rf_idFiles=@idFile 

SELECT * FROM dbo.vw_Polis WHERE PID IN (2655727,2640323,2619876,2613042,212483,2548119,2548119,2877175,2619876,2642320,2619479) AND DBEG>'20140101'


