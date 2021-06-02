USE RegisterCases
GO
--SELECT * FROM vw_getIdFileNumber WHERE DateRegistration>'20210427' ORDER BY DateRegistration desc

SELECT v.id, v.DateRegistration, v.CodeM, v.NumberRegister,v.ReportMonth,c.idRecordCase,e.ErrorNumber,v.FileNameHR
FROM dbo.t_ErrorProcessControl e JOIN dbo.vw_getIdFileNumber v ON
			e.rf_idFile=v.id
					JOIN t_Case c ON
            e.rf_idCase=c.id					
WHERE v.DateRegistration>'20210426' AND ErrorNumber IN('71' ,'70')
ORDER BY v.DateRegistration desc

--SELECT * FROM dbo.t_ErrorProcessControl where rf_idFile=205807-- AND ErrorNumber IN('71' ,'70')

--SELECT * FROM dbo.t_LogDouble WHERE rf_idFile=205807

SELECT * 
FROM dbo.t_LogDouble 
WHERE TotalRow>0  AND TypeQuery IN('S_D_E','0A_E')
ORDER BY DateRegistration DESC

--SELECT * 
--FROM dbo.t_LogDouble 
--WHERE rf_idFile=205820 
--ORDER BY DateRegistration desc