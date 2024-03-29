USE RegisterCases
GO
IF OBJECT_ID('InsertCompletedCaseIntoMU',N'TR') IS NOT NULL
DROP TRIGGER InsertCompletedCaseIntoMU
GO
CREATE TRIGGER InsertCompletedCaseIntoMU
ON dbo.t_MES
FOR INSERT
AS
--��������� ������ � t_Meduslugi �� ����������� ������� ��� ���������� � ��������������������� ������.
--������ ���-�� ����� ��� ���������� ������� ��� [���� ��������� �����]-[���� ������ ������]
--������ ���-�� ����� ��� �������������������� ������� ��� [���� ��������� �����]-[���� ������ ������]+1
		INSERT t_Meduslugi(rf_idCase,id,GUID_MU,rf_idMO,rf_idSubMO,rf_idDepartmentMO,rf_idV002,IsChildTariff,DateHelpBegin,DateHelpEnd,DiagnosisCode,
							MUCode,Quantity,Price,TotalPrice,rf_idV004,rf_idDoctor)
		SELECT DISTINCT  c.id,c.idRecordCase,NEWID(),c.rf_idMO,c.rf_idSubMO,c.rf_idDepartmentMO,c.rf_idV002,c.IsChildTariff,c.DateBegin,c.DateEnd,d.DiagnosisCode
			   ,vw_c.MU_P			  
			   , case when c.rf_idV006=2 then CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(6,2))+1 
					ELSE (case when(CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(6,2)))=0 then 1 
								else CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(6,2))END ) END AS Quantity
			   ,0.00,0.00,c.rf_idV004,c.rf_idDoctor
		FROM t_Case c INNER JOIN (SELECT DISTINCT * FROM inserted) i ON
				c.id=i.rf_idCase
					  INNER JOIN (
								  SELECT rf_idCase,DiagnosisCode 
								  FROM t_Diagnosis 
								  WHERE TypeDiagnosis=1 
								  GROUP BY rf_idCase,DiagnosisCode 
								  ) d ON
				c.id=d.rf_idCase
					  INNER JOIN (
								  SELECT MU,MU_P, AgeGroupShortName 
								  FROM vw_sprMUCompletedCase m LEFT JOIN (SELECT MU AS MUCode FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78
																			UNION ALL
																			SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=70
																			UNION ALL
																			SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72
																		) m1 ON
											m.MU=m1.MUCode
								  WHERE m1.MUCode IS NULL
								  ) vw_c ON
				rtrim(i.MES)=vw_c.MU	
		WHERE c.DateEnd<'20130401' AND vw_c.AgeGroupShortName=(CASE WHEN c.Age>17 THEN '�' ELSE '�' END)
		UNION ALL ----- ����� ������� ����� �������� ���������� � �������� ��. ���������� ����� �� ��������� � 01.04.2013
		SELECT DISTINCT  c.id,c.idRecordCase,NEWID(),c.rf_idMO,c.rf_idSubMO,c.rf_idDepartmentMO,c.rf_idV002,c.IsChildTariff,c.DateBegin,c.DateEnd,d.DiagnosisCode
			   ,vw_c.MU_P			  
			   , case when(CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(9,2)))=0 then 1 else CAST(DATEDIFF(D,DateBegin,DateEnd) AS DECIMAL(9,2))end
			   ,0.00,0.00,c.rf_idV004,c.rf_idDoctor
		FROM t_Case c INNER JOIN (SELECT DISTINCT * FROM inserted) i ON
				c.id=i.rf_idCase
					  INNER JOIN (
								  SELECT rf_idCase,DiagnosisCode 
								  FROM t_Diagnosis 
								  WHERE TypeDiagnosis=1 
								  GROUP BY rf_idCase,DiagnosisCode 
								  ) d ON
				c.id=d.rf_idCase
					  INNER JOIN (
								  SELECT MU,MU_P, AgeGroupShortName 
								  FROM vw_sprMUCompletedCase m LEFT JOIN (SELECT MU AS MUCode FROM vw_sprMUCompletedCase WHERE MUGroupCode=2 AND MUUnGroupCode=78
																			UNION ALL
																			SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=70
																			UNION ALL
																			SELECT MU FROM vw_sprMUCompletedCase WHERE MUGroupCode=72																												) m1 ON
											m.MU=m1.MUCode
								  WHERE m1.MUCode IS NULL
								  ) vw_c ON
				rtrim(i.MES)=vw_c.MU	
		WHERE c.DateEnd>='20130401' AND c.rf_idV006<>2 AND vw_c.AgeGroupShortName=(CASE WHEN c.Age>17 THEN '�' ELSE '�' END)
--END
GO
ENABLE TRIGGER InsertCompletedCaseIntoMU ON dbo.t_MES
GO