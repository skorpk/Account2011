----------------------------------------------------------------RegisterCases----------------------------------------------------------------
USE RegisterCases
GO
IF OBJECT_ID('InsertCompletedCaseIntoMU',N'TR') IS NOT NULL
DROP TRIGGER InsertCompletedCaseIntoMU
GO
CREATE TRIGGER InsertCompletedCaseIntoMU
ON dbo.t_MES
FOR INSERT
AS
--добавляем данные в t_Meduslugi по законченным случаям для стационара и стациоанарозамещающей помощи.
--расчет кол-ва услуг для стационара ведется как [дата окончания слуая]-[дата начала случая]
--расчет кол-ва услуг для стационарозамещающей ведется как [дата окончания слуая]-[дата начала случая]+1
DECLARE @tMU AS TABLE(MUCode AS varchar(16)
INSERT @tMU SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78
INSERT @tMU SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=70
INSERT @tMU SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72
--INSERT @tMU SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=55


		INSERT t_Meduslugi(rf_idCase,id,GUID_MU,rf_idMO,rf_idSubMO,rf_idDepartmentMO,rf_idV002,IsChildTariff,DateHelpBegin,DateHelpEnd,DiagnosisCode,
							MUCode,Quantity,Price,TotalPrice,rf_idV004,rf_idDoctor)
		SELECT DISTINCT  c.id,c.idRecordCase,NEWID(),c.rf_idMO,c.rf_idSubMO,c.rf_idDepartmentMO,c.rf_idV002,c.IsChildTariff,c.DateBegin,c.DateEnd,d.DiagnosisCode
			   ,vw_c.MU_P			  
			   , case when c.rf_idV006=2 then CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(6,2))+1 
					else (case when(CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(6,2)))=0 then 1 else CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(6,2))end) end
			   ,0.00,0.00,c.rf_idV004,c.rf_idDoctor
		FROM t_Case c INNER JOIN (SELECT DISTINCT * FROM inserted) i ON
				c.id=i.rf_idCase
					  INNER JOIN (SELECT rf_idCase,DiagnosisCode FROM t_Diagnosis WHERE TypeDiagnosis=1 GROUP BY rf_idCase,DiagnosisCode ) d ON
				c.id=d.rf_idCase
					  INNER JOIN (
								  SELECT MU,MU_P, AgeGroupShortName 
								  FROM vw_sprMUCompletedCase m LEFT JOIN @tMU m1 ON
											m.MU=m1.MUCode
								  WHERE m1.MUCode IS NULL
								  ) vw_c ON
				rtrim(i.MES)=vw_c.MU	
		WHERE vw_c.AgeGroupShortName=(CASE WHEN c.Age>17 THEN 'в' ELSE 'д' END)
--END
GO
ENABLE TRIGGER InsertCompletedCaseIntoMU ON dbo.t_MES
GO
----------------------------------------------------------------AccountOMS----------------------------------------------------------------
USE AccountOMS
GO
IF OBJECT_ID('InsertCompletedCaseIntoMU',N'TR') IS NOT NULL
DROP TRIGGER InsertCompletedCaseIntoMU
GO
CREATE TRIGGER InsertCompletedCaseIntoMU
ON dbo.t_MES
FOR INSERT
AS
--добавляем данные в t_Meduslugi по законченным случаям для стационара и стациоанарозамещающей помощи.
--расчет кол-ва услуг для стационара ведется как [дата окончания слуая]-[дата начала случая]
--расчет кол-ва услуг для стационарозамещающей ведется как [дата окончания слуая]-[дата начала случая]+1
DECLARE @tMU AS TABLE(MUCode AS varchar(16)
INSERT @tMU SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78
INSERT @tMU SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=70
INSERT @tMU SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72

	INSERT t_Meduslugi(rf_idCase,id,GUID_MU,rf_idMO,rf_idSubMO,rf_idDepartmentMO,rf_idV002,IsChildTariff,DateHelpBegin,DateHelpEnd,DiagnosisCode,
						MUGroupCode,MUUnGroupCode,MUCode,Quantity,Price,TotalPrice,rf_idV004,rf_idDoctor)
	SELECT DISTINCT  c.id,c.idRecordCase,NEWID(),c.rf_idMO,c.rf_idSubMO,c.rf_idDepartmentMO,c.rf_idV002,c.IsChildTariff,c.DateBegin,c.DateEnd,d.DiagnosisCode,
		   vw_c.MUGroupCodeP,vw_c.MUUnGroupCodeP,vw_c.MUCodeP		   
		   , case when c.rf_idV006=2 then CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(6,2))+1 
			else (case when(CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(6,2)))=0 then 1 else CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(6,2))end) end
		   ,0.00,0.00,c.rf_idV004,c.rf_idDoctor
	FROM t_Case c INNER JOIN (SELECT DISTINCT * FROM inserted) i ON
			c.id=i.rf_idCase
				  INNER JOIN (SELECT rf_idCase,DiagnosisCode FROM t_Diagnosis WHERE TypeDiagnosis=1 GROUP BY rf_idCase,DiagnosisCode) d ON
			c.id=d.rf_idCase
				  INNER JOIN (
								SELECT MU,MUGroupCodeP,MUUnGroupCodeP,MUCodeP,AgeGroupShortName 
								FROM vw_sprMUCompletedCase m LEFT JOIN @tMU m1 ON
											m.MU=m1.MUCode
								WHERE m1.MUCode IS NULL
								GROUP BY MU,MUGroupCodeP,MUUnGroupCodeP,MUCodeP,AgeGroupShortName
							  ) vw_c ON
			i.MES=vw_c.MU	
	WHERE vw_c.AgeGroupShortName=(CASE WHEN c.Age>17 THEN 'в' ELSE 'д' END)
END
GO
ENABLE TRIGGER InsertCompletedCaseIntoMU ON dbo.t_MES
GO