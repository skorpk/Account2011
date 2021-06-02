USE RegisterCases 
go

declare @CaseDefined TVP_CasePatient,		
		@idFile int
	
--select top 1 @idFile=id from vw_getIdFileNumber where DateRegistration>'20121225' --order by CountSluch desc

select @idFile=18433

declare @month tinyint,
		@year smallint,
		@codeLPU char(6)
		
select @CodeLPU=f.CodeM,@month=ReportMonth,@year=ReportYear
from t_File f inner join t_RegistersCase rc on
			f.id=rc.rf_idFiles
					inner join oms_nsi.dbo.vw_sprT001 v on
			f.CodeM=v.CodeM		
where f.id=@idFile


------------------------------------------------------------------
--�������� N: �������� �����-������. ������ ������ ���� ���������
--���� ������������� � ��� ��� ��������� �� ������ ����� ������ �� ���������� �������� ���
if NOT EXISTS(select * from t_LPUPlanOrdersDisabled where CodeM=@codeLPU and ReportYear=@year and BeforeDate>=GETDATE())
begin
	declare @t1 as table(rf_idCase bigint,idRecordCase int,Quantity decimal(11,2),unitCode int,TotalRest int)
		------------------------------------------------------

	insert @t1(rf_idCase,Quantity,unitCode,idRecordCase)
	select id,Quantity,unitCode,idRecordCase from vw_dataPlanOrder where rf_idFiles=@idFile	order by idRecordCase asc
	print 'get statistics'	
		--SET STATISTICS IO ON
		SET STATISTICS TIME ON
		
		--��������� ������ �.�. �� ������ ������ ��� ����� �����, �� ��� ����� ������� ��������
		declare cPlan cursor for
			select f.UnitCode,f.Vdm,f.Vm,f.Spred from dbo.fn_PlanOrders(@codeLPU,@month,@year) f
			declare @unit int,@vdm decimal(11,2), @vm decimal(11,2), @spred decimal(11,2)
		open cPlan
		fetch next from cPlan into @unit,@vdm,@vm,@spred
		while @@FETCH_STATUS = 0
		begin					
			declare cCase cursor for
				select t.rf_idCase,t.Quantity from @t1 t where unitCode=@unit order by idRecordCase
				declare @idCase bigint, @Quantity decimal(11,2)
			open cCase
			fetch next from cCase into @idCase,@Quantity
			while @@FETCH_STATUS=0
			begin							
				update @t1 set TotalRest=@vm+@vdm-@Quantity-@spred where rf_idCase=@idCase and unitCode=@unit
				select @spred=@spred+@Quantity
				
				fetch next from cCase into @idCase,@Quantity
			end
			close cCase
			deallocate cCase
			fetch next from cPlan into @unit,@vdm,@vm,@spred
		end
		close cPlan
		deallocate cPlan

		--SET STATISTICS IO OFF
		SET STATISTICS TIME OFF

		select distinct rf_idCase,Quantity,TotalRest from @t1 --where TotalRest<0
end
go
