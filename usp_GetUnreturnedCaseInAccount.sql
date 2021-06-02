USE RegisterCases
GO
if OBJECT_ID('usp_GetUnreturnedCaseInAccount',N'P') is not null
drop proc usp_GetUnreturnedCaseInAccount
go
CREATE PROCEDURE usp_GetUnreturnedCaseInAccount
				@idFileBack INT
AS
SELECT V006 AS Name,NSCHET,COUNT(idCaseCount) AS idCaseCount
FROM (
	select v006.Name AS V006,RTRIM(p.rf_idSMO)+'-'+CAST(rcb.NumberRegister AS VARCHAR(8))+'-'+CAST(PropertyNumberRegister as char(1))+l.AccountParam as NSCHET
					,u.id AS idCaseCount
	from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
						rcb.id=recb.rf_idRegisterCaseBack
										inner join t_RecordCase rc on
						recb.rf_idRecordCase=rc.id
										inner join t_PatientBack p on
						recb.id=p.rf_idRecordCaseBack
										INNER JOIN dbo.t_UnreturnedCaseInAccount u on
						rcb.rf_idFilesBack=u.idFileBack
						AND u.idFileBack=@idFileBack
						AND recb.rf_idCase=u.id
										INNER JOIN dbo.vw_sprV006 v006 ON
						u.rf_idV006=v006.id									
										INNER JOIN dbo.t_MES m ON
						u.id=m.rf_idCase
										INNER JOIN (SELECT MU,AccountParam from AccountOMS.dbo.vw_sprMuWithParamAccount 
													union ALL 
													select MU,AccountParam from vw_sprCSGWithParamAccount
													) l ON
						m.MES=l.MU	
						AND l.AccountParam IS NOT null								
	where rf_idFilesBack=@idFileBack  
	GROUP BY v006.Name,RTRIM(p.rf_idSMO)+'-'+CAST(rcb.NumberRegister AS VARCHAR(8))+'-'+CAST(PropertyNumberRegister as char(1))+l.AccountParam, u.id
	
	UNION  
	select v006.Name,RTRIM(p.rf_idSMO)+'-'+CAST(rcb.NumberRegister AS VARCHAR(8))+'-'+CAST(PropertyNumberRegister as char(1)) +l.AccountParam as NSCHET
					,u.id AS idCaseCount
	from t_RegisterCaseBack rcb inner join t_RecordCaseBack recb on
						rcb.id=recb.rf_idRegisterCaseBack
										inner join t_RecordCase rc on
						recb.rf_idRecordCase=rc.id
										inner join t_PatientBack p on
						recb.id=p.rf_idRecordCaseBack
										INNER JOIN dbo.t_UnreturnedCaseInAccount u on
						rcb.rf_idFilesBack=u.idFileBack
						AND u.idFileBack=@idFileBack
						AND recb.rf_idCase=u.id
										INNER JOIN dbo.vw_sprV006 v006 ON
						u.rf_idV006=v006.id									
										INNER JOIN dbo.t_Meduslugi m ON
						u.id=m.rf_idCase
										left JOIN (SELECT MU,AccountParam from AccountOMS.dbo.vw_sprMuWithParamAccount 
													union ALL 
													select MU,AccountParam from vw_sprCSGWithParamAccount
													) l ON
						m.MUCode=l.MU																	
	where rf_idFilesBack=@idFileBack AND l.AccountParam IS NOT null		
	GROUP BY v006.Name,RTRIM(p.rf_idSMO)+'-'+CAST(rcb.NumberRegister AS VARCHAR(8))+'-'+CAST(PropertyNumberRegister as char(1))+l.AccountParam, u.id
	) t
GROUP BY V006,NSCHET
ORDER BY NSCHET
GO