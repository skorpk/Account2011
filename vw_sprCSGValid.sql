USE [RegisterCases]
GO
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_sprCSGValid]'))
DROP VIEW dbo.vw_sprCSGValid
GO
CREATE VIEW vw_sprCSGValid
AS 
select distinct l.CodeM,m.code AS MU,vm.beginDate as DateBeg, vm.endDate as DateEnd
from dbo.vw_sprCSG m inner join oms_NSI.dbo.tValidCSG vm on
			m.CSGroupId=vm.rf_CSGroupId
							inner join oms_NSI.dbo.vw_sprT001 l on
			vm.rf_MOId=l.MOId
GO