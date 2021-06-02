--select * 
--from oms_NSI.dbo.tPlan

--select *
--from oms_NSI.dbo.tPlanUnit
SET  IDENTITY_INSERT oms_NSI.dbo.tPlanCorrection ON
go
insert oms_NSI.dbo.tPlanCorrection(PlanCorrectionId, rf_PlanId,rf_MonthId, correctionRate,mec, flag, orderNumber, orderDate)
select pc2.PlanCorrectionId, pc2.rf_PlanId,pc2.rf_MonthId, pc2.correctionRate,pc2.mec, pc2.flag, pc2.orderNumber, pc2.orderDate
from oms_NSI.dbo.tPlanCorrection pc1 right join [srvsql1-st2].oms_NSI.dbo.tPlanCorrection pc2 on
		pc1.PlanCorrectionId=pc2.PlanCorrectionId
where pc1.PlanCorrectionId is null
go
SET  IDENTITY_INSERT oms_NSI.dbo.tPlanCorrection ON
--select *
--from oms_NSI.dbo.tMO