use RegisterCases
go
select id,FileNameHRBack,SUBSTRING(FileNameHRBack,8,6) from t_FileBack
go
alter table dbo.t_File add CodeM as SUBSTRING(FileNameHR,4,6)
go
create nonclustered index IX_FileCodeM on dbo.t_File(CodeM)
go
alter table dbo.t_FileBack add CodeM as SUBSTRING(FileNameHRBack,8,6)
go
create nonclustered index IX_FileBackCodeM on dbo.t_FileBack(CodeM)
go
create nonclustered index IX_RegistersCases_Year on dbo.t_RegistersCase(ReportYear,rf_idFiles)
INCLUDE (AmountPayment,NumberRegister,DateRegister) 
go