use RegisterCases
go
if OBJECT_ID('usp_RunRegisterSP_TK',N'P') is not null
	drop proc usp_RunRegisterSP_TK
go
create proc usp_RunRegisterSP_TK
			@idFileBack int
as
exec usp_RegisterSP_TK @idFileBack
select rf_idFiles from t_FileBack where id=@idFileBack
go
