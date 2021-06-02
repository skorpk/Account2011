use RegisterCases
go
declare @RecordCase as TVP_CasePatient,
		@idFile int =1

--------------------------------------TVP_CasePatient------------------------------
insert @RecordCase
select c.id,p.id
from t_File f inner join t_RegisterPatient p on
		f.id=p.rf_idFiles
			  inner join t_RegistersCase rc on
		f.id=rc.rf_idFiles
			  inner join t_RecordCase rc1 on
		rc.id=rc1.rf_idRegistersCase and
		p.ID_Patient=rc1.ID_Patient
			  inner join t_Case c on
		rc1.id=c.rf_idRecordCase
			inner join t_RefCasePatientDefine ci on
		c.id=ci.rf_idCase
			inner join t_CaseDefine cd on
		ci.id=cd.rf_idRefCaseIteration
where f.id=@idFile

select c.id,cd.*
from t_File f inner join t_RegisterPatient p on
		f.id=p.rf_idFiles
			  inner join t_RegistersCase rc on
		f.id=rc.rf_idFiles
			  inner join t_RecordCase rc1 on
		rc.id=rc1.rf_idRegistersCase and
		p.ID_Patient=rc1.ID_Patient
			  inner join t_Case c on
		rc1.id=c.rf_idRecordCase
			inner join t_RefCasePatientDefine ci on
		c.id=ci.rf_idCase
			inner join t_CaseDefine cd on
		ci.id=cd.rf_idRefCaseIteration
where f.id=@idFile

-------------------------------------------------------------------------------------
select * from @RecordCase

declare @property tinyint
	
select @property=(case when COUNT(*)=0 then 0 else 1 end)
from t_RegistersCase r inner join t_RecordCase rc on
		r.id=rc.rf_idRegistersCase
					inner join t_Case c on
		rc.id=c.rf_idRecordCase
					left join @RecordCase cd on
		c.id=cd.rf_idCase
where r.rf_idFiles=@idFile and cd.rf_idCase is null
select @property

declare @tError as table(rf_idCase bigint,ErrorNumber int)

insert @tError
exec usp_RunProcessControl @RecordCase,@idFile
select * from @tError

select * 
from @tError e inner join t_Case c on
		e.rf_idCase=c.id
		--		inner join t_Meduslugi m on
		--c.id=m.rf_idCase