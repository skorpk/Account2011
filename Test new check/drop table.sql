use RegisterCases
go
declare @id int=2261
select * from t_File where id=@id

exec usp_RegisterCaseDelete @id

select * from t_File where id=@id