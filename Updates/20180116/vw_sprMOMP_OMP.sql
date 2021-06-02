USE RegisterCases
go
alter VIEW vw_sprMOMP_OMP
as
SELECT      LEFT(D.tfomsCode,6) AS CodeM, 
            CAST(A.code AS VARCHAR(6)) AS LPU1, 
            A.date_b AS PlaceDateB, 
            A.date_e AS PlaceDateE, 
            C.code  AS PODR, 
            C.rf_MSConditionId AS UslOk,
            C.date_b AS DeptDateB, 
            C.date_e AS DeptDateE
FROM  oms_nsi.dbo.tMOPlace A INNER JOIN oms_nsi.dbo.tMOPlaceDept B ON 
		A.MOPlaceId = B.rf_MOPlaceId 
						    INNER JOIN oms_nsi.dbo.tMODept C ON 
		B.rf_MODeptId = C.MODeptId 
							right JOIN oms_nsi.dbo.tMO D ON 
		A.rf_MOId = D.MOId
WHERE d.tfomsCode<>''
GO
GRANT SELECT ON vw_sprMOMP_OMP TO db_RegisterCase