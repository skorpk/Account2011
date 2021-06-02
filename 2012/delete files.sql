use oms_accounts
go
--прежде чем удалять, не обходимо включить CONSTRAINT FK_t_Accounts_t_FilesEntry
declare @t as table(id uniqueidentifier)

insert @t
select t.id
from (
		select id		
		from oms_accounts.dbo.t_FilesEntry 
		where CodeFilial=5 and DateOfRegistration>='20110101' and DateOfRegistration<='20111201'
		) t left join (
						select id
						from AccountsReplication.dbo.t_FilesEntry 
						where CodeFilial=5 and DateOfRegistration>='20110101'
						) ta on
		t.id=ta.id
where ta.id is null

select * from @t

--delete from t_FilesEntry where id='B73A6ED9-3AA9-43B9-9AAE-71BC837C6B45'

--select * from t_Accounts where rf_idfileentry='B73A6ED9-3AA9-43B9-9AAE-71BC837C6B45'
--select *
--from AccountsReplication.dbo.t_FilesEntry
--where id in (select * from @t)


--select *
--from oms_accounts.dbo.t_FilesEntry
--where id in (select * from @t)
--order by NameFile,id2
delete from t_FilesEntry where id in (select id from @t)
/*
insert @t
select t.id
from (
		select a.id
		from oms_accounts.dbo.t_Accounts a inner join vw_sprLPU l on
				a.CodeLPU=l.CodeLPU
		where FilialCode=5 and DateOfRegistrationOfAccount>='20110101'
		) t left join (
						select a.id
						from AccountsReplication.dbo.t_Accounts a inner join vw_sprLPU l on
								a.CodeLPU=l.CodeLPU
						where FilialCode=5 and DateOfRegistrationOfAccount>='20110101'
						) t1 on t.id=t1.id
where t1.id is null

delete from oms_accounts.dbo.t_Accounts where id in (select id from @t)
*/