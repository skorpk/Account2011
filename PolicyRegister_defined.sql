use PolicyRegister
go
--select Fam,Im,Ot,Dr,p2.NPOL,p1.ENP,p2.Q,p2.DBEG,case when p2.DSTOP is null then p2.DEND else p2.DSTOP end as DateEnd
--from people p1 inner join polis p2 on
--		p1.id=p2.pid
--where p1.Fam='Крайнов' and p1.Im='Сергей'

declare @t as table(id int,repl xml)

insert @t
select ID,REPL
from(select ID,'<ANSWER '+(case when REPL='страхование в ЕРП не найдено' then null else REPL end)+' />' as REPL from ZP1 where ZEERP is null) t
where REPL is not null

select *
from @t