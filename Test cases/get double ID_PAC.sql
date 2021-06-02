use RegisterCases
go
--select * from vw_getIdFileNumber where id=2307--FileNameHR='HRM165531T34_111277'

-----------------------------Delete file-----------------------
--exec usp_RegisterCaseDelete 2322
--exec usp_RegisterCaseDelete 2323
----------------------------
--select *
--from vw_RegisterPatient


declare @CaseDefined TVP_CasePatient
declare @tError as table(rf_idCase bigint,ErrorNumber smallint)
declare @idFile int=2307
select COUNT(*) from t_RegisterPatient where rf_idFiles=@idFile

insert @CaseDefined
select c.id,p.id as ID_Patient
from  t_RecordCase r inner join t_Case c on
			r.id=c.rf_idRecordCase
					inner join t_RegisterPatient p on
			r.id=p.rf_idRecordCase
where p.rf_idFiles=@idFile
group by c.id,p.id 

insert @tError
select c.rf_idCase,71
from ( select c1.rf_idCase,c1.ID_Patient
	   from @CaseDefined  c1 left join @tError e on
					c1.rf_idCase=e.rf_idCase
	   where e.rf_idCase is null
	  ) c inner join (
						select p.id,p.ID_Patient
						from (
								select ID_Patient  from t_RegisterPatient where rf_idFiles=@idFile
								group by ID_Patient having COUNT(*)>1 
							  ) t inner join t_RegisterPatient p on
							  t.ID_Patient=p.ID_Patient
							  and p.rf_idFiles=@idFile
						) c1 on
		c.ID_Patient=c1.id
order by c.rf_idCase

