use RegisterCases
go
--------------------------------------------------------------------------------------------------------------
if OBJECT_ID('usp_RunFillBackTablesAfterAllIteration',N'P') is not null
	drop proc usp_RunFillBackTablesAfterAllIteration
go	
--������ ��������� ������� id ������ �������� �� ������� ���������� ��������� ��������������(� �� ���� ������ � ������� �� � ��) 
--� �������� �� � ��������� usp_FillBackTablesAfterAllIteration � ������� �������.
create proc usp_RunFillBackTablesAfterAllIteration
as
declare @t as table (rf_idFile int)

--������� ������ ������� �� ���� � ������� �� � ��(������ id ����� ��������) ����� 1-�� ����
--� ������ � �� ���� �� ������� �� ����� ���� ���������� ��������� ��������������
--���� �� �� ����� id ����� �������� � ��������� usp_FillBackTablesAfterAllIteration
insert @t
select t1.rf_idFiles
from(
		select COUNT(distinct id) as TotalRow,rf_idFiles
		from t_RefCasePatientDefine 		
		where IsUnloadIntoSP_TK is null
		group by rf_idFiles
	) t1 inner join (
						select COUNT(distinct r.id) as DefineRow,rf_idFiles
						from t_RefCasePatientDefine r inner join t_CasePatientDefineIteration i on
								r.id=i.rf_idRefCaseIteration
								and i.rf_idIteration in (2,3,4)
						where IsUnloadIntoSP_TK is null
						group by rf_idFiles	
					) t2 on 
			t1.rf_idFiles=t2.rf_idFiles
			and t1.TotalRow=t2.DefineRow
order by rf_idFiles

			
if EXISTS(select * from @t)
begin
	--��������� ������ 
	declare cRunProcedure cursor for
		select rf_idFile from @t 
		declare @id int
	open cRunProcedure
	fetch next from cRunProcedure into @id
	while @@FETCH_STATUS = 0
	begin		
		-------------------------------------------------------
		exec usp_FillBackTablesAfterAllIteration @id	
		-------------------------------------------------------
		fetch next from cRunProcedure into @id
	end
	close cRunProcedure
	deallocate cRunProcedure
end
go