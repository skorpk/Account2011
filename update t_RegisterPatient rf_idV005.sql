USE AccountOMSReports
GO
--DROP TABLE tmp_PeopleSex

BEGIN TRANSACTION
UPDATE p SET p.rf_idV005=s.W
 from dbo.t_RegisterPatient p INNER JOIN dbo.tmp_PeopleSex s ON
			p.id=s.id

SELECT @@rowcount
COMMIT
