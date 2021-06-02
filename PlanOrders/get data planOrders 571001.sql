USE RegisterCases
GO
DECLARE @idFile INT,
		@idFileBack int
SELECT @idFile=rf_idFiles, @idFileBack=idFileBack 
FROM dbo.vw_getFileBack 
WHERE CodeM='571001' AND NumberRegister=63 AND ReportYear=2019 AND PropertyNumberRegister=1

--EXEC dbo.usp_PlanOrdersReport @idFile,@idFileBack

declare @month tinyint,
		@year smallint,
		@codeLPU char(6),
		@number varchar(15),
		@dateCreate datetime,
		@dateStart DATETIME
--���������� ���������� ������ �� ������ ������� �� � ��
select @number=cast(rc.NumberRegister as varchar(13))+'-'+cast(rc.PropertyNumberRegister as CHAR(1))
		,@dateCreate=fb.DateCreate
		,@month=rc.ReportMonth
		,@year=rc.ReportYear
		,@codeLPU=fb.CodeM
from t_RegisterCaseBack rc inner join t_FileBack fb on
			rc.rf_idFilesBack=fb.id
where fb.id=@idFileBack


CREATE TABLE #plan1(
						CodeLPU varchar(6),
						UnitCode int,
						Vm DECIMAL(11,2),
						Vdm DECIMAL(11,2),
						Spred decimal(11,2)
					)
--���� ������� ������������� �� ������ � 2012-02-24. � �������� ��������� ������ ����� ������ �� ������� 
-------------------------------------------------------------------------------------
declare @monthMax tinyint,
		@monthMin tinyint
-------------------------------------------------------------------------------------
declare @t as table
(
		MonthID tinyint
		,QuarterID tinyint
		,partitionQuarterID tinyint
		,QuarterName as (case when QuarterID=1 then '������ �������'
								when QuarterID=2 then '������ �������' 
								when QuarterID=3 then '������ �������' else '��������� �������' end)
)
insert @t values(1,1,1),(2,1,2),(3,1,3),
				(4,2,1),(5,2,2),(6,2,3),
				(7,3,1),(8,3,2),(9,3,3),
				(10,4,1),(11,4,2),(12,4,3)
				
select @monthMin=MIN(t1.MonthID),@monthMax=MAX(t1.MonthID)
from @t t inner join @t t1 on
		t.QuarterID=t1.QuarterID
where t.MonthID=@month	

SET @dateStart=CAST(@year AS CHAR(4))+RIGHT('0'+CAST(@monthMin AS varCHAR(2)),2)+'01'			
--first query:������ V ��������� ����� ������-�������, ��������������� ���� �������������� ����������� ��������� �� ������� ���
--second query:������ N*Int(Vt/3) ������ �����-������ ������� 
--�� 3 � ���������� �� ���������� ����� ��������� ������ � �������� � ������� �� ������� Vt-Int(Vt/3) c 24.02.2012 �� �� ����� �.�. ������ ���� ������������
--third query: ������ Vkm ��������� ������ ���� ��������� ������ ������� �� tPlanCorrection ��� ���
--third query: ������ Vdm ��������� ������ ���� ��������� ������ ������� �� tPlanCorrection ������ ���
--------------------------------------------------------------------------------------------------------------------------------
CREATE table #tPlan(tfomsCode char(6),unitCode SMALLINT,Vkm DECIMAL(11,2),Vdm DECIMAL(11,2), Vt DECIMAL(11,2),O DECIMAL(11,2),V DECIMAL(11,2))
insert #tPlan(tfomsCode,unitCode) select @codeLPU, unitCode from oms_NSI.dbo.tPlanUnit

update #tPlan
set Vkm=t.Vkm,Vdm=t.Vdm
from #tPlan p inner join (
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


update #tPlan
set V=t.V
from #tPlan p inner join (						
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

insert #plan1(CodeLPU,UnitCode,Vm,Vdm)
select p.tfomsCode,p.unitCode,isnull(p.V,0)+isnull(p.Vt,0)+isnull(p.O,0)+isnull(p.Vkm,0),isnull(p.Vdm,0)
from #tPlan p

CREATE table #p (id int)
insert #p
SELECT distinct p.rf_idRecordCaseBack
FROM t_FileBack f INNER JOIN t_RegisterCaseBack r ON
			f.id=r.rf_idFilesBack		
			and f.CodeM=@codeLPU
				  INNER JOIN t_RecordCaseBack cb ON
	        cb.rf_idRegisterCaseBack=r.id AND
			r.ReportMonth>=@monthMin AND r.ReportMonth<=@monthMax AND
			r.ReportYear=@year
			inner join t_PatientBack p ON 
			cb.id=p.rf_idRecordCaseBack
			and p.rf_idSMO<>'00000'
						INNER JOIN vw_sprSMO s ON 
			p.rf_idSMO=s.smocod	
WHERE f.DateCreate>=@dateStart AND f.DateCreate<=@dateCreate AND r.NumberRegister=63			

--������� ��� ������ �������������� � �������� �� � �� � ����� ������ 1 � ���� ������ ������ �� �������� �����������
---��������� �� 27.12.2017 ��������� ��� �������

select c.rf_idMO
		,t1.unitCode
		,t1.MU
		,SUM(case when m.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
from t_FileBack f inner join t_RegisterCaseBack r on
		f.id=r.rf_idFilesBack		
		and f.DateCreate<=@dateCreate
				  inner join t_RecordCaseBack cb on
		cb.rf_idRegisterCaseBack=r.id and
		r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
		r.ReportYear=@year
				INNER JOIN dbo.t_CaseBack cp ON
		cb.id=cp.rf_idRecordCaseBack					
		and cp.TypePay=1
				inner join t_Case c on
		c.id=cb.rf_idCase
				inner join t_Meduslugi m on
		c.id=m.rf_idCase and c.rf_idMO=@codeLPU
				inner join dbo.vw_sprMU t1 on
		m.MUCode=t1.MU			
		and t1.unitCode is not null
				inner join #p p on
		cb.id=p.id	
WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate AND t1.calculationType=1 --AND unitCode IN (261,262)
group by c.rf_idMO,t1.unitCode,MU
UNION ALL
select c.rf_idMO
		,t1.unitCode
		,t1.MU
		,COUNT(DISTINCT c.id) as Quantity
from t_FileBack f inner join t_RegisterCaseBack r on
		f.id=r.rf_idFilesBack		
		and f.DateCreate<=@dateCreate
				  inner join t_RecordCaseBack cb on
		cb.rf_idRegisterCaseBack=r.id and
		r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
		r.ReportYear=@year
				INNER JOIN dbo.t_CaseBack cp ON
		cb.id=cp.rf_idRecordCaseBack					
		and cp.TypePay=1
				inner join t_Case c on
		c.id=cb.rf_idCase
				inner join t_Meduslugi m on
		c.id=m.rf_idCase and c.rf_idMO=@codeLPU
				inner join dbo.vw_sprMU t1 on
		m.MUCode=t1.MU			
		and t1.unitCode is not null
				inner join #p p on
		cb.id=p.id	
WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate AND t1.calculationType=2-- AND unitCode IN (30,31,32)
group by c.rf_idMO,t1.unitCode,MU		
UNION ALL
select c.rf_idMO
		,t1.unitCode
		,m.MES
		,SUM(case when c.IsChildTariff=1 then m.Quantity*t1.ChildUET else m.Quantity*t1.AdultUET end) as Quantity
from t_FileBack f inner join t_RegisterCaseBack r on
		f.id=r.rf_idFilesBack		
		and f.DateCreate<=@dateCreate
				  inner join t_RecordCaseBack cb on
		cb.rf_idRegisterCaseBack=r.id and
		r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
		r.ReportYear=@year
				INNER JOIN dbo.t_CaseBack cp ON
		cb.id=cp.rf_idRecordCaseBack					
		and cp.TypePay=1
				inner join t_Case c on
		c.id=cb.rf_idCase
				inner join t_MES m on
		c.id=m.rf_idCase and c.rf_idMO=@codeLPU
				inner join (SELECT MU,beginDate,endDate,unitCode,ChildUET,AdultUET FROM dbo.vw_sprMU WHERE calculationType=1
							UNION ALL 
							SELECT CSGCode,beginDate,endDate,UnitCode,ChildUET, AdultUET FROM oms_nsi.dbo.vw_CSGPlanUnit WHERE calculationType=1
							) t1 on
		m.MES=t1.MU			
		and t1.unitCode is not null
				inner join #p p on
		cb.id=p.id							
WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate --AND unitCode IN (261,262)
group by c.rf_idMO,t1.unitCode,m.MES		
 UNION all
select  c.rf_idMO
		,t1.unitCode
		,m.MES
		,COUNT(DISTINCT c.id) as Quantity
from t_FileBack f inner join t_RegisterCaseBack r on
		f.id=r.rf_idFilesBack		
		and f.DateCreate<=@dateCreate
				  inner join t_RecordCaseBack cb on
		cb.rf_idRegisterCaseBack=r.id and
		r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
		r.ReportYear=@year
				INNER JOIN dbo.t_CaseBack cp ON
		cb.id=cp.rf_idRecordCaseBack					
		and cp.TypePay=1
				INNER JOIN dbo.t_PatientBack pb ON
		cb.id=pb.rf_idRecordCaseBack                      
				inner join t_Case c on
		c.id=cb.rf_idCase
				inner join t_MES m on
		c.id=m.rf_idCase and c.rf_idMO=@codeLPU						                     
				inner join (SELECT MU,beginDate,endDate,unitCode FROM dbo.vw_sprMU WHERE calculationType=2
							UNION ALL 
							SELECT CSGCode,beginDate,endDate,UnitCode FROM oms_nsi.dbo.vw_CSGPlanUnit WHERE calculationType=2
							) t1 on
		m.MES=t1.MU			
		and t1.unitCode is not null
				inner join #p p on
		cb.id=p.id							
WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate --AND unitCode IN (261,262)
GROUP BY c.rf_idMO,t1.unitCode,m.MES
---------------------------------------------------------------
/*
select c.id
		,c.GUID_Case
		,m.MES
		,c.AmountPayment
		,unitCode
--INTO #tCases
from t_FileBack f inner join t_RegisterCaseBack r on
		f.id=r.rf_idFilesBack		
		and f.DateCreate<=@dateCreate
				  inner join t_RecordCaseBack cb on
		cb.rf_idRegisterCaseBack=r.id and
		r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
		r.ReportYear=@year
				INNER JOIN dbo.t_CaseBack cp ON
		cb.id=cp.rf_idRecordCaseBack					
		and cp.TypePay=1
				inner join t_Case c on
		c.id=cb.rf_idCase
				inner join t_MES m on
		c.id=m.rf_idCase and c.rf_idMO=@codeLPU
				inner join (SELECT MU,beginDate,endDate,unitCode,ChildUET,AdultUET FROM dbo.vw_sprMU WHERE calculationType=1
							UNION ALL 
							SELECT CSGCode,beginDate,endDate,UnitCode,ChildUET, AdultUET FROM oms_nsi.dbo.vw_CSGPlanUnit WHERE calculationType=1
							) t1 on
		m.MES=t1.MU			
		and t1.unitCode is not null
				inner join #p p on
		cb.id=p.id							
WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate --AND unitCode IN (261,262)
 UNION all
select  c.id
		,c.GUID_Case
		,m.MES
		,c.AmountPayment
		,unitCode
from t_FileBack f inner join t_RegisterCaseBack r on
		f.id=r.rf_idFilesBack		
		and f.DateCreate<=@dateCreate
				  inner join t_RecordCaseBack cb on
		cb.rf_idRegisterCaseBack=r.id and
		r.ReportMonth>=@monthMin and r.ReportMonth<=@monthMax and
		r.ReportYear=@year
				INNER JOIN dbo.t_CaseBack cp ON
		cb.id=cp.rf_idRecordCaseBack					
		and cp.TypePay=1
				INNER JOIN dbo.t_PatientBack pb ON
		cb.id=pb.rf_idRecordCaseBack                      
				inner join t_Case c on
		c.id=cb.rf_idCase
				inner join t_MES m on
		c.id=m.rf_idCase and c.rf_idMO=@codeLPU						                     
				inner join (SELECT MU,beginDate,endDate,unitCode FROM dbo.vw_sprMU WHERE calculationType=2
							UNION ALL 
							SELECT CSGCode,beginDate,endDate,UnitCode FROM oms_nsi.dbo.vw_CSGPlanUnit WHERE calculationType=2
							) t1 on
		m.MES=t1.MU			
		and t1.unitCode is not null
				inner join #p p on
		cb.id=p.id							
WHERE c.DateEnd>= t1.beginDate AND c.DateEnd<=t1.endDate --AND unitCode IN (261,262)

SELECT *
FROM #tCases c 
WHERE NOT EXISTS(SELECT * FROM AccountOMS.dbo.t_Case WHERE GUID_Case=c.GUID_Case)
*/

--;WITH cte
--AS(
--SELECT  c.id ,
--        c.GUID_Case ,
--        c.MES ,
--        c.AmountPayment-p.AmountDeduction AS AmountPayment
--FROM #tCases c INNER JOIN AccountOMS.dbo.t_Case c1 ON
--		c.GUID_Case=c1.GUID_Case
--		AND c1.DateEnd>='20180101'
--				INNER JOIN (SELECT rf_idCase,SUM(AmountDeduction) AS AmountDeduction 
--							FROM AccountOMS.dbo.t_PaymentAcceptedCase2 GROUP BY rf_idCase
--							)p ON
--		c1.id=p.rf_idCase
		              
--)
--SELECT * FROM cte WHERE AmountPayment=0

go
DROP TABLE #p
go
DROP TABLE #tPlan
go
DROP TABLE #Plan1
go
DROP TABLE #tCases