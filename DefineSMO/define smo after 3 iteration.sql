use RegisterCases
go
--делаю отказ при 4 итерации вручную. т.к. нету ответа до сих пор из ФФ
--часть записей была определена на 1-3 итерациях
select *
from vw_getIdFileNumber where CodeM='251001' and NumberRegister='100028' and ReportYear=2011

begin transaction
declare @t as table(rf_idRefCaseIteration bigint,rf_idZP1 int,Iteration tinyint)

insert @t
select zd.rf_idRefCaseIteration,zd.rf_idZP1,4
from t_RefCasePatientDefine c inner join t_CaseDefineZP1 zd on
		c.id=zd.rf_idRefCaseIteration
							inner join PolicyRegister.dbo.ZP1 zp1 on
		zd.rf_idZP1=zp1.ID
		and ZID=13057
					left join t_CasePatientDefineIteration z on
		c.id=z.rf_idRefCaseIteration														
where rf_idFiles=3476 and z.rf_idRefCaseIteration is null

insert t_CasePatientDefineIteration(rf_idRefCaseIteration,rf_idIteration)
select rf_idRefCaseIteration,Iteration from @t

insert t_CaseDefineZP1Found(rf_idRefCaseIteration,rf_idZP1,DateDefine)
select rf_idRefCaseIteration,rf_idZP1,GETDATE() from @t

commit

select top 10 * 
from t_CaseDefineZP1Found where OKATO is null

