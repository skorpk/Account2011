use RegisterCases
go
declare @t as table(codeM char(6),NumberReestr int)

insert @t values(521001,43),(521001,42),(255627,41),(255802,31),(251001,17),(254505,32),
				(255416,25),(571001,17),(255802,32),(255627,42),(255027,36),(254505,33),
				(254504,32),(311001,42),(251002,12310),(441001,12100),(581001,19),(471001,12190),
				(521001,45),(521001,44),(255802,33),(254505,34),(571001,18),(311001,43)
				
select 'exec usp_DefineSMOIteration2_4Repeat '+ cast(v.id as varchar(5))+';'--,COUNT(r.id)
from vw_getIdFileNumber v inner join @t t on
			v.CodeM=t.codeM
			and v.ReportYear=2012
			and v.NumberRegister=t.NumberReestr
--						  inner join t_RefCasePatientDefine r on
--			v.id=r.rf_idFiles
--						left join t_CasePatientDefineIteration i on
--			r.id=i.rf_idRefCaseIteration
--where i.rf_idRefCaseIteration is null
--group by v.id			
 