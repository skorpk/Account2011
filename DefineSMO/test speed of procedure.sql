use RegisterCases
go
declare @t as TVP_Insurance_New
DECLARE @iteration TINYINT=1
declare @idTable as table(id bigint,rf_idCase bigint,rf_idRegisterPatient int)

declare @idFile int
select @idFile=id from vw_getIdFileNumber where DateRegistration>'20160915' AND CountSluch>1000 ORDER BY NEWID()
SELECT @idFile

insert @idTable 
select rf.id,rf.rf_idCase,rf.rf_idRegisterPatient
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile
						inner join t_Case c on
			r.id=c.rf_idRecordCase			
			inner join t_RefCasePatientDefine rf on
			c.id=rf.rf_idCase								                      
WHERE rf.rf_idFiles=@idFile	

--SELECT * FROM @idTable 
 --select @@ROWCOUNT
 
insert @t
select t.id,case when rc.rf_idF008=3 then rc.NumberPolis else null end,p.Fam,p.Im,p.Ot,p.BirthDay,p.BirthPlace,pd.SNILS,null,pd.NumberDocument,null,
		c.DateEnd
from @idTable t inner join t_Case c on
		t.rf_idCase=c.id 
				inner join vw_RegisterPatient p on
		t.rf_idRegisterPatient=p.id
				inner join t_RecordCase rc on
		p.rf_idRecordCase=rc.id
				left join t_RegisterPatientDocument pd on
		p.id=pd.rf_idRegisterPatient

--select @@ROWCOUNT
SET STATISTICS TIME ON
create table #tPeople
(
	rf_idRefCaseIteration bigint,
	PID int,
    DateEnd DATE,
    IsDelete TINYINT,
    DateBegin DATE,
	Sex TINYINT,
	DR date
)
exec usp_GetPID @t

SET STATISTICS TIME ON
GO
DROP TABLE #tPeople