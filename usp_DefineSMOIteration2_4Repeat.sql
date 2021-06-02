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
--определяем на максимальную итерацию
select @iteration=MAX(z.rf_idIteration)
from t_RefCasePatientDefine r inner join t_CasePatientDefineIteration z on
						r.id=z.rf_idRefCaseIteration		
where rf_idFiles=@id and (IsUnloadIntoSP_TK is null)


begin transaction
begin try
if(@iteration=1)
begin
	--удаляем все данные если максимальный номер итерации был 1. т.е сведения могли были найдены на 1 и ушли в ФФОМС
	--но назад не вернулись тогда все за собой зачищаем и делаем повтор запроса в ФФОМС и весь цикл начинаем сначало
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
	--данные для отсылки
	
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
	--удаляем все данные при которые ушли в ФФОМС на 4 шаге итерации
	delete from t_CaseDefineZP1 where rf_idRefCaseIteration in (
																select id 
																from t_RefCasePatientDefine r left join t_CasePatientDefineIteration i on
																			r.id=i.rf_idRefCaseIteration
																where rf_idFiles=@id and i.rf_idRefCaseIteration is null
																)		
	--данные для отсылки	
	exec usp_DefineSMOIteration2_4 @id,4,@fileName
end
end try
begin catch
	select ERROR_MESSAGE()
	if @@TRANCOUNT>0
	rollback transaction
	goto Exit1--выходим из обработки данных
end catch
if @@TRANCOUNT>0
	commit transaction
	
Exit1:
GO
