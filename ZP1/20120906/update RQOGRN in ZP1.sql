use PolicyRegister
go
begin transaction
select * from ZP1 z where z.ID=1733703

update ZP1 set RQOGRN='1028601441274' where ID=1733703

select * from ZP1 z where z.ID=1733703
commit