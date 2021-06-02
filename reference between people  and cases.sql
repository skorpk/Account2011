USE AccountOMS
GO
CREATE TABLE #t
(
	IDPeople BIGINT,
	rf_idCase BIGINT
)
INSERT #t( IDPeople, rf_idCase )
SELECT DENSE_RANK() OVER(ORDER BY t.ID) AS Id, rf_idCase
FROM (
		SELECT CASE WHEN PID IS NOT NULL THEN CAST(PID AS varchar(20)) 
					WHEN PID IS NULL AND ENP IS NOT NULL THEN ENP END AS ID,rf_idCase
		FROM  dbo.t_Case_PID_ENP 
		UNION ALL
		SELECT rp.Fam+rp.Im+rp.Ot+convert(VARCHAR(10),rp.BirthDay,104),pid.rf_idCase
		FROM  dbo.t_Case_PID_ENP pid INNER JOIN dbo.t_Case c ON
							pid.rf_idCase=c.id
									INNER JOIN dbo.t_RecordCasePatient r ON
							c.rf_idRecordCasePatient=r.id
									INNER JOIN dbo.t_RegisterPatient rp ON
							r.id=rp.rf_idRecordCase
		WHERE PID IS NULL AND ENP IS NULL
	 ) t
	 
DROP TABLE #t