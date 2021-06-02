use RegisterCases
go
if OBJECT_ID('usp_DefineSMOIteration2_4Repeat',N'P') is not null
	drop proc usp_DefineSMOIteration2_4Repeat
go
create proc usp_DefineSMOIteration2_4Repeat
(
	@id int
)
as	
declare @fileName varchar(30)
select @fileName=FileNameHR from vw_getIdFileNumber where id=@id

declare @iteration tinyint
--���������� �� ������������ ��������
select @iteration=MAX(z.rf_idIteration)
from t_RefCasePatientDefine r inner join t_CasePatientDefineIteration z on
						r.id=z.rf_idRefCaseIteration		
where rf_idFiles=@id and (IsUnloadIntoSP_TK is null)


begin transaction
begin try
if(@iteration=1)
begin
	--������� ��� ������ ���� ������������ ����� �������� ��� 1. �.� �������� ����� ���� ������� �� 1 � ���� � �����
	--�� ����� �� ��������� ����� ��� �� ����� �������� � ������ ������ ������� � ����� � ���� ���� �������� �������
	if EXISTS(
				select * 
				from t_RefCasePatientDefine r inner join t_CaseDefineZP1 z on
							r.id=z.rf_idRefCaseIteration		
				 where rf_idFiles=@id and (IsUnloadIntoSP_TK is null)
			  )
	begin
		delete from t_CaseDefineZP1 where rf_idRefCaseIteration in (select id from t_RefCasePatientDefine r where rf_idFiles=@id and (IsUnloadIntoSP_TK is null))
		delete from t_CaseDefineZP1Found where rf_idRefCaseIteration in (select id from t_RefCasePatientDefine r where rf_idFiles=@id and (IsUnloadIntoSP_TK is null))
	end
	--������ ��� �������
	
	if EXISTS(
				select *
				from t_RefCasePatientDefine r inner join t_CaseDefineZP1 z on
						r.id=z.rf_idRefCaseIteration
				where rf_idFiles=@id and (IsUnloadIntoSP_TK is null)
				)
	exec usp_DefineSMOIteration2_4 @id,2,@fileName
	
end
else
begin
	--������� ��� ������ ��� ������� ���� � ����� �� 4 ���� ��������
	delete from t_CaseDefineZP1 where rf_idRefCaseIteration in (
																select id 
																from t_RefCasePatientDefine r left join t_CasePatientDefineIteration i on
																			r.id=i.rf_idRefCaseIteration
																where rf_idFiles=@id and i.rf_idRefCaseIteration is null
																)		
	--������ ��� �������	
	exec usp_DefineSMOIteration2_4 @id,4,@fileName
end
end try
begin catch
	select ERROR_MESSAGE()
	if @@TRANCOUNT>0
	rollback transaction
	goto Exit1--������� �� ��������� ������
end catch
if @@TRANCOUNT>0
	commit transaction
	
Exit1:
GO
