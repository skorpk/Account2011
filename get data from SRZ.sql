USE RegisterCases
go
declare @idFile int,
		@FileName varchar(26)
select @idFile=id,@FileName=rtrim(FileNameHR) from vw_getIdFileNumber where CodeM='102502' and NumberRegister=4 and ReportYear=2013

select l.id,COUNT(* )
from PolicyRegister.dbo.ZP1LOG l inner join PolicyRegister.dbo.ZP1 z on
		l.ID=z.ZID
where [FILENAME] like '_'+@FileName
group by l.id

select * from t_RefCasePatientDefine r where r.rf_idFiles=@idFile and r.IsUnloadIntoSP_TK is null

go