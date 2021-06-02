USE RegisterCases
GO

alter view vw_sprSMOGlobal
as
select TF_OKATO as OKATO,SMOKOD,NAM_SMOK as SMO, OGRN,e.dateBeg,e.dateEnd
from oms_nsi.dbo.sprSMO s INNER JOIN oms_nsi.dbo.sprSMOInOMS e ON
		s.UId=e.rf_sprSMOUId
GO