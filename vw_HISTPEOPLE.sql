use RegisterCases
go
if OBJECT_ID('vw_HISTPEOPLE',N'V') is not null
drop view vw_HISTPEOPLE
go
create view vw_HISTPEOPLE
as
select distinct t.ID,t.FAM,t.IM,t.OT,t.DR,t.DOCN
from (
		select p.ID,h.FAM,h.IM,h.OT,h.DR,p.DOCN
		from PolicyRegister.dbo.PEOPLE p inner join PolicyRegister.dbo.HISTFDR h on
				p.ID=h.PID
		union all		
		select p.ID,p.FAM,p.IM,p.OT,p.DR,h.DOCN
		from PolicyRegister.dbo.PEOPLE p inner join PolicyRegister.dbo.HISTUDL h on
				p.ID=h.PID		
  	 ) t
go