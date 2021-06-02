use RegisterCases
go
if OBJECT_ID('usp_GetProcessingZP1Data',N'P') is not null
	drop proc usp_GetProcessingZP1Data
go			
--��������� �� ��������� ������ ������� ������ �� �� ���
--����� ���������� �� ��������� ������ � ���� xml
create proc [dbo].[usp_GetProcessingZP1Data]
as
--������� 09.12.2011 13:43

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
��������� � ���� ���� ������. � ����������� ����� ��� ���� �������, � ����� ���������� 6 ������. � �� ����� ��� ������� � ������� 
��� ������ >3 ���������� 3.
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

--��� ��� ���� ��� �� ������ � ������� ��� �� ������������ � �� ���� �������� �� 4 ��������.
update @tFound set DBEG=null where OKATO='18000' and OGRN_SMO='1057746135325' and Iteration=2

begin transaction
begin try
--������������ ������ ���� ���������� ��������� ��������������
insert t_CasePatientDefineIteration(rf_idRefCaseIteration,rf_idIteration)
select rf_idRefCaseIteration,Iteration 
from @tFound 
where (DBEG is not null) 
group by rf_idRefCaseIteration,Iteration

--��� ���� ������������, �� ���� 4 ��������
insert t_CasePatientDefineIteration(rf_idRefCaseIteration,rf_idIteration)
select rf_idRefCaseIteration,Iteration 
from @tFound 
where Iteration=4 and (DBEG is null)
group by rf_idRefCaseIteration,Iteration

--��������� ������ ���� ��� ���� ���������� �� 2 ��������
insert t_CaseDefineZP1Found(rf_idRefCaseIteration,rf_idZP1,OKATO,UniqueNumberPolicy,TypePolicy,OGRN_SMO,SPolicy,NPolcy,DateDefine)
select rf_idRefCaseIteration,rf_idZP1,OKATO,UniqueNumberPolicy,TypePolicy,OGRN_SMO,SPolicy,NPolicy,GETDATE()
from @tFound where DBEG is not null and Iteration=2
group by rf_idRefCaseIteration,rf_idZP1,OKATO,UniqueNumberPolicy,TypePolicy,OGRN_SMO,SPolicy,NPolicy

--��������� ������ ���� ��� ���� ���������� �� 4 ��������
insert t_CaseDefineZP1Found(rf_idRefCaseIteration,rf_idZP1,OKATO,UniqueNumberPolicy,TypePolicy,OGRN_SMO,SPolicy,NPolcy,DateDefine)
select rf_idRefCaseIteration,rf_idZP1,OKATO,UniqueNumberPolicy,TypePolicy,OGRN_SMO,SPolicy,NPolicy,GETDATE()
from @tFound where Iteration=4 and DBEG is not null
group by rf_idRefCaseIteration,rf_idZP1,OKATO,UniqueNumberPolicy,OGRN_SMO,TypePolicy,SPolicy,NPolicy

--��������� ������ ���� ��� �� ���� ���������� �� 4 ��������
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
	--��������� ������ �.�. ����� ���� ��������� ������  ������� ���� ���������� �� ����������� ��������� ��������������.
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
		declare @RecordCase as TVP_CasePatient,--��� ������� ������� ������ �� 3-� ��������
			@idRecordCaseNext as TVP_CasePatient, -- ��� ������� ������� ������ �� 4-� ��������
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
			where DBEG is null and rf.rf_idFiles=@idFile--������� ����� �������
					
			insert @idRecordCaseNext exec usp_DefineSMOIteration1_3 @RecordCase,@iteration

			if(select COUNT(*) from @idRecordCaseNext)>0
			begin
				set @iteration=@iteration+1
				
				exec usp_DefineSMOIteration2_4 @idFile,@iteration,@fileName
			end	
		end
		--������� �������
		delete @idRecordCaseNext		
		delete @RecordCase
		-------------------------------------------------------
		fetch next from cIteration into @fileName,@idFile
	end
	close cIteration
	deallocate cIteration
end
