use RegisterCases
go
if OBJECT_ID('usp_UnLoadRegisterSP_TK',N'P') is not null
	drop proc usp_UnLoadRegisterSP_TK
go
create proc usp_UnLoadRegisterSP_TK
			@idFileBack int
as
exec usp_UnloadRegisterSP_TK @idFileBack
select id from t_FileBack where id=@idFileBack
go
