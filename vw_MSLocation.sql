USE [RegisterCases]
GO
IF  EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_MSLocation]'))
DROP VIEW dbo.vw_MSLocation
GO
CREATE VIEW vw_MSLocation
AS 
SELECT	LEFT(G.tfomsCode,6) AS CodeM,
		F.beginDate AS DateBegin, 
		CASE  
			WHEN F.terminationDate IS NULL THEN F.endDate 
			WHEN F.terminationDate = CONVERT(DATETIME,'01.01.2222',104) THEN F.endDate 
			ELSE F.terminationDate END AS DateEnd, 
		E.code AS rf_idV006, 
		D.code AS rf_idV008, 
		C.code AS rf_idV002  
FROM	oms_nsi.dbo.tMSLocation A INNER JOIN oms_nsi.dbo.tLicenseLocation B 
			ON A.rf_LicenseLocationId = B.LicenseLocationId 
					  INNER JOIN oms_nsi.dbo.tMedicalService C 
			ON A.rf_MedicalServiceId = C.MedicalServiceId 
					  INNER JOIN oms_nsi.dbo.tMSForm D 
			ON A.rf_MSFormId = D.MSFormId 
					  INNER JOIN oms_nsi.dbo.tMSCondition E 
			ON A.rf_MSConditionId = E.MSConditionId 
					INNER JOIN oms_nsi.dbo.tLicensePeriod F 
			ON B.rf_LicenseId = F.rf_LicenseId 
		INNER JOIN oms_nsi.dbo.tMO G 
			ON B.rf_MOId = G.MOId 
WHERE	A.flag = 'A' AND 
		B.flag = 'A' AND 
		F.flag = 'A' 
GO
USE oms_nsi
GO

/****** Object:  Index [tLicensePeriod_tLicense_idx]    Script Date: 02/18/2014 12:15:43 ******/
CREATE NONCLUSTERED INDEX [tLicensePeriod_tLicense_idx] ON [dbo].[tLicensePeriod] 
(
	[rf_LicenseId] ASC
)
INCLUDE(flag,beginDate,endDate,terminationDate)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = ON, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tLicenseLocation_idx] ON [dbo].[tLicenseLocation] 
(
	[rf_MOId] ASC
)
INCLUDE(flag,rf_LicenseId)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = on, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [tMSLocation_tLicenseLocation_idx] ON [dbo].[tMSLocation] 
(
	[rf_LicenseLocationId] ASC
)
INCLUDE(flag,rf_MedicalServiceId,rf_MSConditionId,rf_MSFormId)
WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = ON, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
GO




