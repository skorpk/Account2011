USE RegisterCases
GO
IF OBJECT_ID('usp_PlanOrders',N'P') IS NOT NULL
DROP PROC usp_PlanOrders
GO
CREATE PROCEDURE usp_PlanOrders
		@codeLPU VARCHAR(6),@month TINYINT,@year SMALLINT
AS
DECLARE @plan1 TABLE(
						CodeLPU VARCHAR(6),
						UnitCode INT,
						Vm INT,
						Vdm INT,
						Spred DECIMAL(11,2)
					)
--���� ������� ������������� �� ������ � 2011-12-12. � �������� ��������� ������ ���� ������������ ����� �� ������� �������� � ������� 1
-- � ���������� � @month � ����� �� ��� ������������ �������� ��� ����������.

--���� ������� ������������� �� ������ � 2012-02-24. � �������� ��������� ������ ����� ������ �� ������� 
-------------------------------------------------------------------------------------
DECLARE @monthMax TINYINT,
		@monthMin TINYINT
-------------------------------------------------------------------------------------
DECLARE @t AS TABLE(MonthID TINYINT,QuarterID TINYINT,partitionQuarterID TINYINT)
INSERT @t VALUES(1,1,1),(2,1,2),(3,1,3),
				(4,2,1),(5,2,2),(6,2,3),
				(7,3,1),(8,3,2),(9,3,3),
				(10,4,1),(11,4,2),(12,4,3)
				
SELECT @monthMin=MIN(t1.MonthID),@monthMax=MAX(t1.MonthID)
FROM @t t INNER JOIN @t t1 ON
		t.QuarterID=t1.QuarterID
WHERE t.MonthID=@month				
--first query:������ V ��������� ����� ������-�������, ��������������� ���� �������������� ����������� ��������� �� ������� ���
--second query:������ N*Int(Vt/3) ������ �����-������ ������� 
--�� 3 � ���������� �� ���������� ����� ��������� ������ � �������� � ������� �� ������� Vt-Int(Vt/3) c 24.02.2012 �� �� ����� �.�. ������ ���� ������������
--third query: ������ Vkm ��������� ������ ���� ��������� ������ ������� �� tPlanCorrection ��� ���
--third query: ������ Vdm ��������� ������ ���� ��������� ������ ������� �� tPlanCorrection ������ ���
--------------------------------------------------------------------------------------------------------------------------------
DECLARE @tPlan AS TABLE(tfomsCode CHAR(6),unitCode TINYINT,Vkm BIGINT,Vdm BIGINT, Vt BIGINT,O BIGINT,V BIGINT)
INSERT @tPlan(tfomsCode,unitCode)
SELECT @codeLPU, unitCode
FROM oms_NSI.dbo.tPlanUnit


UPDATE @tPlan
SET Vkm=t.Vkm,Vdm=t.Vdm
FROM @tPlan p INNER JOIN (
						SELECT LEFT(mo.tfomsCode,6) AS tfomsCode,pu.unitCode,SUM(CASE WHEN pc.mec=0 THEN ISNULL(pc.correctionRate,0) ELSE 0 END) AS Vkm,
								SUM(CASE WHEN pc.mec=1 THEN ISNULL(pc.correctionRate,0) ELSE 0 END) AS Vdm
						FROM oms_NSI.dbo.tPlanYear py INNER JOIN oms_NSI.dbo.tMO mo ON
									py.rf_MOId=mo.MOId AND
									py.[year]=@year
										INNER JOIN oms_NSI.dbo.tPlan pl ON
									py.PlanYearId=pl.rf_PlanYearId AND 
									pl.flag='A'
										INNER JOIN oms_NSI.dbo.tPlanUnit pu ON
									pl.rf_PlanUnitId=pu.PlanUnitId
										LEFT JOIN oms_NSI.dbo.tPlanCorrection pc ON
									pl.PlanId=pc.rf_PlanId AND pc.flag='A'
									AND pc.rf_MonthId>=@monthMin AND pc.rf_MonthId<=@monthMax 
						WHERE LEFT(mo.tfomsCode,6)=@codeLPU 
						GROUP BY mo.tfomsCode,pu.unitCode
						) t ON p.tfomsCode=t.tfomsCode AND p.unitCode=t.unitCode


UPDATE @tPlan
SET V=t.V
FROM @tPlan p INNER JOIN (						
							SELECT LEFT(mo.tfomsCode,6) AS tfomsCode,SUM(pl.rate) AS V,pu.unitCode
							FROM oms_NSI.dbo.tPlanYear py INNER JOIN oms_NSI.dbo.tMO mo ON
										py.rf_MOId=mo.MOId AND
										py.[year]=@year
											INNER JOIN oms_NSI.dbo.tPlan pl ON
										py.PlanYearId=pl.rf_PlanYearId AND pl.flag='A'
											INNER JOIN oms_NSI.dbo.tPlanUnit pu ON
										pl.rf_PlanUnitId=pu.PlanUnitId
											INNER JOIN @t t ON
										pl.rf_QuarterId=t.QuarterID				
							WHERE LEFT(mo.tfomsCode,6)=@codeLPU AND t.MonthID=@month
							GROUP BY mo.tfomsCode,pu.unitCode
						) t ON  p.tfomsCode=t.tfomsCode AND p.unitCode=t.unitCode

INSERT @plan1(CodeLPU,UnitCode,Vm,Vdm)
SELECT p.tfomsCode,p.unitCode,ISNULL(p.V,0)+ISNULL(p.Vt,0)+ISNULL(p.O,0)+ISNULL(p.Vkm,0),ISNULL(p.Vdm,0)
FROM @tPlan p
 
declare @p as table(id int)
insert @p
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
						INNER JOIN vw_sprSMO s ON 
			p.rf_idSMO=s.smocod	
 
 
DECLARE @tS AS TABLE(CodeLPU CHAR(6),unitCode TINYINT,Rate DECIMAL(11,2))
--������� ��� ������ �������������� � �������� �� � �� � ����� ������ 1 � ���� ������ ������ �� �������� �����������
INSERT @ts
SELECT c.rf_idMO
		,t1.unitCode
		,SUM(CASE WHEN m.IsChildTariff=1 THEN m.Quantity*t1.ChildUET ELSE m.Quantity*t1.AdultUET END) AS Quantity
FROM t_FileBack f INNER JOIN t_RegisterCaseBack r ON
		f.id=r.rf_idFilesBack		
				  INNER JOIN t_RecordCaseBack cb ON
		cb.rf_idRegisterCaseBack=r.id AND
		r.ReportMonth>=@monthMin AND r.ReportMonth<=@monthMax AND
		r.ReportYear=@year
				INNER JOIN t_CaseBack cb1 on
		cb.id=cb1.rf_idRecordCaseBack
		AND cb.TypePay=1
				INNER JOIN t_Case c ON
		c.id=cb.rf_idCase
				INNER JOIN vw_MeduslugiMes m ON
		c.id=m.rf_idCase AND c.rf_idMO=@codeLPU
				INNER JOIN dbo.vw_sprMU t1 ON
		m.MUCode=t1.MU			
		AND t1.unitCode IS NOT NULL
				INNER JOIN @p p ON
		cb.id=p.id									
WHERE f.DateCreate<=GETDATE()
GROUP BY c.rf_idMO,t1.unitCode		

if @year=2011			
begin
	INSERT @tS SELECT CodeLPU,unitCode,SUM(Rate)FROM t_PlanOrders2011 
	WHERE CodeLPU=@codeLPU AND MonthRate>=@monthMin AND MonthRate<=@monthMax AND YearRate=@year GROUP BY CodeLPU,unitCode
end
--------------------------------------------------------------------------------------
INSERT @plan1(CodeLPU,UnitCode,Vm,Vdm,Spred)
SELECT t.CodeLPU,t.unitCode,0,0,t.Rate
FROM @tS t

insert #tmpPlan(CodeLPU,UnitCode,Vm,Vdm,Spred,[month])	
SELECT CodeLPU,UnitCode,SUM(Vm),SUM(Vdm),ISNULL(SUM(Spred),0),(SELECT t.QuarterID FROM @t t WHERE t.MonthID=@month)
FROM @plan1 GROUP BY CodeLPU,UnitCode

GO