USE [RegisterCases]
GO
/****** Object:  StoredProcedure [dbo].[usp_GetProcessingZP1Data]    Script Date: 09.08.2016 8:56:40 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--процедура по обработке данных которые прешли из ЦС ЕРЗ
--решил избавиться от обработки данных в виде xml
ALTER proc [dbo].[usp_GetProcessingZP1Data]
as
--изменил 09.12.2011 13:43

declare @tFound as table(
							rf_idRefCaseIteration bigint,
							rf_idZP1 int,
							OKATO varchar(5),
							UniqueNumberPolicy varchar(20),
							OGRN_SMO varchar(15),
							TypePolicy char(1),
							SPolicy varchar(20),
							NPolicy varchar(20),
							DBEG date,
							DEND date,
							ERP varchar(50),
							Iteration tinyint,
							[FileName] varchar(50)
				   		 )
/* 2013-10-16 11:49
Изменения в виде типа полиса. В справочнике всего три вида полисов, а ФФОМС возвращает 6 иногда. И по этому все записям у которых 
вид полиса >3 присваиваю 3.
*/
insert @tFound
select t.rf_idRefCaseIteration,zp1.id,ROKATO,RENP,RQOGRN
		,CASE WHEN ROPDOC>3 THEN 3 ELSE ROPDOC END AS TypePolicy
		,RSPOL,RNPOL,cast(RDBEG as date),cast(RDEND as date),EERP,
		--case when DOUT is not null then 2 else 4 end Iteration,
		cast(LEFT(rtrim(l.FILENAME),1) as tinyint) as Iteration,
		RIGHT(rtrim(l.FILENAME),LEN(l.FILENAME)-1) as FileName
from vw_CaseNotDefineYet t inner join PolicyRegister.dbo.ZP1 zp1 on
			t.rf_idZP1=zp1.ID
		  inner join PolicyRegister.dbo.ZP1LOG l on
			zp1.ZID=l.ID
			and zp1.REPL is not null

--Шаг для того что бы записи у которых СМО не действителен в ВО были отосланы на 4 итерацию.
update @tFound set DBEG=null where OKATO='18000' and OGRN_SMO='1057746135325' and Iteration=2

begin transaction
begin try
--раскладываем данные если определена страховая принадлежность
insert t_CasePatientDefineIteration(rf_idRefCaseIteration,rf_idIteration)
select rf_idRefCaseIteration,Iteration 
from @tFound 
where (DBEG is not null) 
group by rf_idRefCaseIteration,Iteration

--или если неопределена, но была 4 итерация
insert t_CasePatientDefineIteration(rf_idRefCaseIteration,rf_idIteration)
select rf_idRefCaseIteration,Iteration 
from @tFound 
where Iteration=4 and (DBEG is null)
group by rf_idRefCaseIteration,Iteration

--вставляем данные если они были определены на 2 итерации
insert t_CaseDefineZP1Found(rf_idRefCaseIteration,rf_idZP1,OKATO,UniqueNumberPolicy,TypePolicy,OGRN_SMO,SPolicy,NPolcy,DateDefine)
select rf_idRefCaseIteration,rf_idZP1,OKATO,UniqueNumberPolicy,TypePolicy,OGRN_SMO,SPolicy,NPolicy,GETDATE()
from @tFound where DBEG is not null and Iteration=2
group by rf_idRefCaseIteration,rf_idZP1,OKATO,UniqueNumberPolicy,TypePolicy,OGRN_SMO,SPolicy,NPolicy

--вставляем данные если они были определены на 4 итерации
insert t_CaseDefineZP1Found(rf_idRefCaseIteration,rf_idZP1,OKATO,UniqueNumberPolicy,TypePolicy,OGRN_SMO,SPolicy,NPolcy,DateDefine)
select rf_idRefCaseIteration,rf_idZP1,OKATO,UniqueNumberPolicy,TypePolicy,OGRN_SMO,SPolicy,NPolicy,GETDATE()
from @tFound where Iteration=4 and DBEG is not null
group by rf_idRefCaseIteration,rf_idZP1,OKATO,UniqueNumberPolicy,OGRN_SMO,TypePolicy,SPolicy,NPolicy

--вставляем данные если они не были определены на 4 итерации
insert t_CaseDefineZP1Found(rf_idRefCaseIteration,rf_idZP1,DateDefine)
select rf_idRefCaseIteration,rf_idZP1,GETDATE() from @tFound where Iteration=4 and DBEG is null
end try
begin catch
if @@TRANCOUNT>0
	select ERROR_MESSAGE()
	rollback transaction
end catch
if @@TRANCOUNT>0
	commit transaction

if EXISTS(select * from @tFound)
begin
	--использую курсор т.к. может быть несколько файлов  которые были отправлены на определение страховой принадлежности.
	declare cIteration cursor for
		select t.FileName,rf.rf_idFiles
		from @tFound t inner join t_RefCasePatientDefine rf on
					t.rf_idRefCaseIteration=rf.id
		where DBEG is null
		group by t.FileName,rf.rf_idFiles
		declare @fileName varchar(30),
				@idFile int
	open cIteration
	fetch next from cIteration into @fileName,@idFile
	while @@FETCH_STATUS = 0
	begin		
		-------------------------------------------------------
		declare @RecordCase as TVP_CasePatient,--для записей который пойдут на 3-ю итерацию
			@idRecordCaseNext as TVP_CasePatient, -- для записей которые пойдут на 4-ю итерацию
			@iteration tinyint

		select @iteration=(Iteration)+1 
		from @tFound 
		where (DBEG is null) and Iteration=2 
		group by Iteration
		
		if @iteration=3
		begin
					
			insert @RecordCase
			select rf.rf_idCase,rf.rf_idRegisterPatient
			from @tFound t inner join t_RefCasePatientDefine rf on
						t.rf_idRefCaseIteration=rf.id
			where DBEG is null and rf.rf_idFiles=@idFile--заменил отбор случаев
			
			--отключил определение страховой принадлежности на 4 шаге 09.08.2016 по требованию Антоновой		
			
			insert @idRecordCaseNext exec usp_DefineSMOIteration1_3 @RecordCase,@iteration
						
			if(select COUNT(*) from @idRecordCaseNext)>0
			begin
			--вставляем ошибку 57 по тем записям у которых не была определена страховая принадлежность после 3 итерации
				insert t_ErrorProcessControl(ErrorNumber,rf_idFile,rf_idCase)
				select 57,a.rf_idFiles,c.id
				FROM @idRecordCaseNext t INNER JOIN dbo.t_Case c ON
						r.rf_idCase=c.id
										INNER JOIN dbo.t_RecordCase r ON
						c.rf_idRecordCase=r.id
										INNER JOIN dbo.t_RegistersCase a ON
						r.rf_idRegistersCase=a.id              
				/*
				set @iteration=@iteration+1
				
				exec usp_DefineSMOIteration2_4 @idFile,@iteration,@fileName
				*/
			end	
		end
		--очищаем таблицу
		delete @idRecordCaseNext		
		delete @RecordCase
		-------------------------------------------------------
		fetch next from cIteration into @fileName,@idFile
	end
	close cIteration
	deallocate cIteration
end
