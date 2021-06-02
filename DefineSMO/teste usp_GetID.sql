use RegisterCases
go

declare @t as TVP_Insurance,
		@id int=4374


declare @idTable as table(id bigint,rf_idCase bigint,rf_idRegisterPatient int)

insert @idTable
select id,rf_idCase,rf_idRegisterPatient from t_RefCasePatientDefine where rf_idFiles=@id

insert @t
select t.id,case when rc.rf_idF008=3 then rc.SeriaPolis else null end,p.Fam,p.Im,p.Ot,p.BirthDay,p.BirthPlace,pd.SNILS,null,pd.NumberDocument,null,
		c.DateEnd
from @idTable t inner join t_Case c on
		t.rf_idCase=c.id 
				inner join vw_RegisterPatient p on
		t.rf_idRegisterPatient=p.id
				inner join t_RecordCase rc on
		p.rf_idRecordCase=rc.id
				left join t_RegisterPatientDocument pd on
		p.id=pd.rf_idRegisterPatient
--заменил функцию на хранимую процедуру и табличную переменную на временную таблицу
create table #tPeople
(
	rf_idRefCaseIteration bigint,
	PID int,
    DateEnd date
)
exec usp_GetPID @t
go
drop table #tPeople