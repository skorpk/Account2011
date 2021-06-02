USE RegisterCases
GO
SELECT ErrorNumber,COUNT(rf_idCase) 
FROM dbo.t_ErrorProcessControl WHERE DateRegistration>'20180131'
GROUP BY ErrorNumber

SELECT rf_idFile,f.DateRegistration,COUNT(rf_idCase) AS TotalCases,f.CountSluch
FROM dbo.t_ErrorProcessControl e INNER JOIN dbo.t_File f ON
			e.rf_idFile=f.id 
WHERE f.DateRegistration>'20180131' AND ErrorNumber=66
GROUP BY rf_idFile,f.DateRegistration,f.CountSluch
ORDER BY DateRegistration desc
