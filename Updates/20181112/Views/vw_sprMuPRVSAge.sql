USE [RegisterCases]
GO


ALTER VIEW [dbo].[vw_sprMuPRVSAge]
AS
--select MUCode,MedSpecCode as rf_idV004,case when AgeGroup=2 then 1 else 0 end as IsChildTariff 
--from OMS_NSI.dbo.V_MUMedicalSpeciality

SELECT	A.Код AS MUCode,
		D.CODE AS rf_idV015, 
		case when B.rf_AgeGroupId =2 then 1 else 0 end as IsChildTariff
		,CAST('20170101' AS DATE) AS DateBegin, CAST('20190101' AS DATE) AS DateEnd
FROM	oms_nsi.dbo.V_sprMU A INNER JOIN oms_nsi.dbo.tMUAgeAndsprV015 B 
			ON A.MUId = B.rf_MUId AND B.flag = 'A'
					INNER JOIN oms_nsi.dbo.sprV015 D ON 
			B.rf_sprV015RECID = D.RECID 
UNION ALL
SELECT	A.Код AS MUCode,
		D.IDSPEC AS rf_idV015, 
		case when B.rf_AgeGroupId =2 then 1 else 0 end as IsChildTariff 
		,CAST('20190101' AS DATE) AS DateBegin, CAST('22220101' AS DATE) AS DateEnd
FROM	oms_nsi.dbo.V_sprMU A INNER JOIN oms_nsi.dbo.tMUAgeAndsprV021 B 
			ON A.MUId = B.rf_MUId AND B.flag = 'A'
					INNER JOIN oms_nsi.dbo.sprV021 D ON 
			B.rf_sprV021Id = D.SprV021Id 
GO


