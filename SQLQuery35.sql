USE RegisterCases
go
SET NOCOUNT ON

--select * from vw_getIdFileNumber where id=15325
--go
select z.* 
from PolicyRegister.dbo.ZP1LOG l inner join PolicyRegister.dbo.ZP1 z on
				l.ID=z.ZID
where [FILENAME] like '2HRM106001T34_121006'

declare @t as table(rf_idRefCaseIteration bigint,rf_idZP1 int)
insert @t
select r.id,z1.rf_idZP1
from t_RefCasePatientDefine r inner join t_CaseDefineZP1Found z1 on
		r.id=z1.rf_idRefCaseIteration
		and r.rf_idCase=12550187
		
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
		--case when DOUT is not null then 2 else 4 end Iteration,
		cast(LEFT(rtrim(l.FILENAME),1) as tinyint) as Iteration,
		RIGHT(rtrim(l.FILENAME),LEN(l.FILENAME)-1) as FileName
from @t t inner join PolicyRegister.dbo.ZP1 zp1 on
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
					
			insert @RecordCase
			select rf.rf_idCase,rf.rf_idRegisterPatient
			from @tFound t inner join t_RefCasePatientDefine rf on
						t.rf_idRefCaseIteration=rf.id
			where DBEG is null and rf.rf_idFiles=@idFile--заменил отбор случаев
					
			insert @idRecordCaseNext exec usp_DefineSMOIteration1_3 @RecordCase,@iteration

			if(select COUNT(*) from @idRecordCaseNext)>0
			begin
				set @iteration=@iteration+1
				
				select 'Run 3 iteration'
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