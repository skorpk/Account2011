use RegisterCases
go
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
		2 Iteration,
		RIGHT(rtrim(l.FILENAME),LEN(l.FILENAME)-1) as FileName
from (
		select czp1.rf_idRefCaseIteration,czp1.rf_idZP1
		from t_RefCasePatientDefine rf inner join t_CaseDefineZP1 czp1 on
							rf.id=czp1.rf_idRefCaseIteration
							and rf.rf_idCase=9739900											
		group by czp1.rf_idRefCaseIteration,czp1.rf_idZP1					
		) t inner join PolicyRegister.dbo.ZP1 zp1 on
						t.rf_idZP1=zp1.ID
					  inner join PolicyRegister.dbo.ZP1LOG l on
						zp1.ZID=l.ID
						and zp1.REPL is not null

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
					
			--insert @RecordCase
			select rf.rf_idCase,rf.rf_idRegisterPatient
			from @tFound t inner join t_RefCasePatientDefine rf on
						t.rf_idRefCaseIteration=rf.id
			where DBEG is null and rf.rf_idFiles=@idFile--заменил отбор случаев			
			
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