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

insert @tFound
select t.rf_idRefCaseIteration,zp1.id,ROKATO,RENP,RQOGRN,ROPDOC,RSPOL,RNPOL,cast(RDBEG as date),cast(RDEND as date),EERP,
		case when DOUT is not null then 2 else 4 end Iteration,
		RIGHT(rtrim(l.FILENAME),LEN(l.FILENAME)-1) as FileName
from vw_CaseNotDefineYeat t inner join PolicyRegister.dbo.ZP1 zp1 on
			t.rf_idZP1=zp1.ID
		  inner join PolicyRegister.dbo.ZP1LOG l on
			zp1.ZID=l.ID
			and zp1.REPL is not null

--раскладываем данные если определена страховая принадлежность
insert t_CasePatientDefineIteration(rf_idRefCaseIteration,rf_idIteration)
select rf_idRefCaseIteration,Iteration 
from @tFound 
where (DBEG is not null)
group by rf_idRefCaseIteration,Iteration

--вставляем данные если они были определены на 2 итерации
insert t_CaseDefineZP1Found(rf_idRefCaseIteration,rf_idZP1,OKATO,UniqueNumberPolicy,TypePolicy,OGRN_SMO,SPolicy,NPolcy,DateDefine)
select rf_idRefCaseIteration,rf_idZP1,OKATO,UniqueNumberPolicy,TypePolicy,OGRN_SMO,SPolicy,NPolicy,GETDATE()
from @tFound where DBEG is not null and Iteration=2

--вставляем данные если они были определены на 4 итерации
insert t_CaseDefineZP1Found(rf_idRefCaseIteration,rf_idZP1,OKATO,UniqueNumberPolicy,TypePolicy,OGRN_SMO,SPolicy,NPolcy,DateDefine)
select rf_idRefCaseIteration,rf_idZP1,OKATO,UniqueNumberPolicy,OGRN_SMO,TypePolicy,SPolicy,NPolicy,GETDATE()
from @tFound where Iteration=4 and DBEG is not null

--вставляем данные если они не были определены на 4 итерации
insert t_CaseDefineZP1Found(rf_idRefCaseIteration,rf_idZP1)
select rf_idRefCaseIteration,rf_idZP1 from @tFound where Iteration=4 and DBEG is null

--использую курсор т.к. может быть несколько файлов  которые были отправлены на определение страховой принадлежности.
declare cIteration cursor for
	select FileName
	from @tFound t inner join t_RefCasePatientDefine rf on
				t.rf_idRefCaseIteration=rf.id
	where DBEG is null
	group by FileName
	declare @fileName varchar(30)
open cIteration
fetch next from cIteration into @fileName
while @@FETCH_STATUS = 0
begin		
	
	-------------------------------------------------------
	declare @RecordCase as TVP_CasePatient,--для записей который пойдут на 3-ю итерацию
		@idRecordCaseNext as TVP_CasePatient, -- для записей которые пойдут на 4-ю итерацию
		@iteration tinyint

	select @iteration=(Iteration)+1 from @tFound where (DBEG is not null) and Iteration=2 group by Iteration

	--данные разложили
	if @iteration=3
	begin
		insert @RecordCase
		select rf.rf_idCase,rf.rf_idRegisterPatient
		from @tFound t inner join t_RefCasePatientDefine rf on
					t.rf_idRefCaseIteration=rf.id
		where DBEG is null and FileName=@fileName
		
		insert @idRecordCaseNext exec usp_DefineSMOIteration1_3 @RecordCase,@iteration
		
		
		
		if EXISTS(select * from @idRecordCaseNext)
		begin
			set @iteration=@iteration+1
			
			select @fileName as [FileName],@iteration as Iteration,* from @idRecordCaseNext
			
			exec usp_DefineSMOIteration2_4 @idRecordCaseNext,@iteration,@fileName
		end	
	end
	-------------------------------------------------------
	fetch next from cIteration into @fileName
end
close cIteration
deallocate cIteration