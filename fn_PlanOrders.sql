use RegisterCases
go
-------------------------------------------------------------------------------------------------------------
IF OBJECT_ID (N'dbo.fn_PlanOrders', N'TF') IS NOT NULL
    DROP FUNCTION dbo.fn_PlanOrders;
GO
CREATE FUNCTION dbo.fn_PlanOrders(@codeLPU varchar(6),@month tinyint,@year smallint)
RETURNS @plan TABLE
					(
						CodeLPU varchar(6),
						UnitCode int,
						Vm int,
						Vdm int,
						Spred decimal(11,2),
						[month] tinyint
					)
AS
begin
declare @plan1 TABLE(
						CodeLPU varchar(6),
						UnitCode int,
						Vm int,
						Vdm int,
						Spred decimal(11,2)
					)
--���� ������� ������������� �� ������ � 2011-12-12. � �������� ��������� ������ ���� ������������ ����� �� ������� �������� � ������� 1
-- � ���������� � @month � ����� �� ��� ������������ �������� ��� ����������.

--���� ������� ������������� �� ������ � 2012-02-24. � �������� ��������� ������ ����� ������ �� ������� 
-------------------------------------------------------------------------------------
declare @monthMax tinyint,
		@monthMin tinyint
-------------------------------------------------------------------------------------
declare @t as table(MonthID tinyint,QuarterID tinyint,partitionQuarterID tinyint)
insert @t values(1,1,1),(2,1,2),(3,1,3),
				(4,2,1),(5,2,2),(6,2,3),
				(7,3,1),(8,3,2),(9,3,3),
				(10,4,1),(11,4,2),(12,4,3)
				
select @monthMin=MIN(t1.MonthID),@monthMax=MAX(t1.MonthID)
from @t t inner join @t t1 on
		t.QuarterID=t1.QuarterID
where t.MonthID=@month				
--first query:������ V ��������� ����� ������-�������, ��������������� ���� �������������� ����������� ��������� �� ������� ���
--second query:������ N*Int(Vt/3) ������ �����-������ ������� 
--�� 3 � ���������� �� ���������� ����� ��������� ������ � �������� � ������� �� ������� Vt-Int(Vt/3) c 24.02.2012 �� �� ����� �.�. ������ ���� ������������
--third query: ������ Vkm ��������� ������ ���� ��������� ������ ������� �� tPlanCorrection ��� ���
--third query: ������ Vdm ��������� ������ ���� ��������� ������ ������� �� tPlanCorrection ������ ���
--------------------------------------------------------------------------------------------------------------------------------
declare @tPlan as table(tfomsCode char(6),unitCode tinyint,Vkm bigint,Vdm bigint, Vt bigint,O bigint,V bigint)
insert @tPlan(tfomsCode,unitCode)
select @codeLPU, unitCode
from oms_NSI.dbo.tPlanUnit


update @tPlan
set Vkm=t.Vkm,Vdm=t.Vdm
from @tPlan p inner join (
						select left(mo.tfomsCode,6) as tfomsCode,pu.unitCode,sum(case when pc.mec=0 then ISNULL(pc.correctionRate,0) else 0 end) as Vkm,
								sum(case when pc.mec=1 then ISNULL(pc.correctionRate,0) else 0 end) as Vdm
						from oms_NSI.dbo.tPlanYear py inner join oms_NSI.dbo.tMO mo on
									py.rf_MOId=mo.MOId and
									py.[year]=@year
										inner join oms_NSI.dbo.tPlan pl on
									py.PlanYearId=pl.rf_PlanYearId and 
									pl.flag='A'
										inner join oms_NSI.dbo.tPlanUnit pu on
									pl.rf_PlanUnitId=pu.PlanUnitId
										left join oms_NSI.dbo.tPlanCorrection pc on
									pl.PlanId=pc.rf_PlanId and pc.flag='A'
									and pc.rf_MonthId>=@monthMin and pc.rf_MonthId<=@monthMax 
						where left(mo.tfomsCode,6)=@codeLPU 
						group by mo.tfomsCode,pu.unitCode
						) t on p.tfomsCode=t.tfomsCode and p.unitCode=t.unitCode


update @tPlan
set V=t.V
from @tPlan p inner join (						
							select left(mo.tfomsCode,6) as tfomsCode,SUM(pl.rate) as V,pu.unitCode
							from oms_NSI.dbo.tPlanYear py inner join oms_NSI.dbo.tMO mo on
										py.rf_MOId=mo.MOId and
										py.[year]=@year
											inner join oms_NSI.dbo.tPlan pl on
										py.PlanYearId=pl.rf_PlanYearId and pl.flag='A'
											inner join oms_NSI.dbo.tPlanUnit pu on
										pl.rf_PlanUnitId=pu.PlanUnitId
											inner join @t t on
										pl.rf_QuarterId=t.QuarterID				
							where left(mo.tfomsCode,6)=@codeLPU and t.MonthID=@month
							group by mo.tfomsCode,pu.unitCode
						) t on  p.tfomsCode=t.tfomsCode and p.unitCode=t.unitCode

insert @plan1(CodeLPU,UnitCode,Vm,Vdm)
select p.tfomsCode,p.unitCode,isnull(p.V,0)+isnull(p.Vt,0)+isnull(p.O,0)+isnull(p.Vkm,0),isnull(p.Vdm,0)
from @tPlan p
 
declare @tS as table(CodeLPU char(6),unitCode tinyint,Rate decimal(11,2))
--������� ��� ������ �������������� � �������� �� � �� � ����� ������ 1 � ���� ������ ������ �� �������� �����������
insert @ts
select c.rf_idMO
		,t1.unitCode
		,SUM(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
from t_FileBack f inner join t_RegisterCaseBack r on
		f.id=r.rf_idFilesBack		
				  inner join t_RecordCaseBack cb on
		cb.rf_idRegisterCaseBack=r.id and
		r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
		r.ReportYear=@year
		and cb.TypePay=1
				inner join t_Case c on
		c.id=cb.rf_idCase
				inner join vw_MeduslugiMes m on
		c.id=m.rf_idCase and c.rf_idMO=@codeLPU
				inner join dbo.vw_sprMU t1 on
		m.MUCode=t1.MU			
		and t1.unitCode is not null
				inner join (
							select rf_idRecordCaseBack,rf_idSMO 
							from t_PatientBack
							group by rf_idRecordCaseBack,rf_idSMO 
							) p on
		cb.id=p.rf_idRecordCaseBack
				inner join vw_sprSMO s on
			p.rf_idSMO=s.smocod						
where f.DateCreate<=GETDATE()
group by c.rf_idMO,t1.unitCode
			
insert @tS
select CodeLPU,unitCode,SUM(Rate)
from t_PlanOrders2011 
where CodeLPU=@codeLPU and MonthRate>=@monthMin and MonthRate<=@monthMax and YearRate=@year
group by CodeLPU,unitCode
--------------------------------------------------------------------------------------
insert @plan1(CodeLPU,UnitCode,Vm,Vdm,Spred)
select t.CodeLPU,t.unitCode,0,0,t.Rate
from @tS t
	
insert @plan(CodeLPU,UnitCode,Vm,Vdm,Spred,[month])
select CodeLPU,UnitCode,sum(Vm),sum(Vdm),isnull(sum(Spred),0),(select t.QuarterID from @t t where t.MonthID=@month)
from @plan1 
group by CodeLPU,UnitCode
		
	RETURN
end;
go