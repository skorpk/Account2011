USE RegisterCases
go
SET NOCOUNT ON
declare @idFile int

select @idFile=id from vw_getIdFileNumber where CodeM='804504' and NumberRegister=1 and ReportYear=2021

select * from vw_getIdFileNumber where id=@idFile

select distinct c.id,561,c.rf_idV004
from t_RegistersCase a inner join t_RecordCase r on
			a.id=r.rf_idRegistersCase
			and a.rf_idFiles=@idFile 						
						inner join t_Case c on
			r.id=c.rf_idRecordCase	
						left join vw_sprV004 v on
			c.rf_idV004=v.id
			AND c.DateEnd>=v.DateBeg
			AND c.DateEnd<v.DateEnd
where v.id is NULL

SELECT * FROM vw_sprV004 WHERE id=1112

--SELECT id,name,CAST('20110101' AS DATE) AS DateBeg, CAST('20160101' AS DATE) AS DateEnd FROM oms_NSI.dbo.sprMedicalSpeciality WHERE Name IS NOT null
--UNION ALL
SELECT Code,NAME, CAST('20160101' AS DATE),DATEEND  FROM oms_nsi.dbo.sprV015 WHERE Name LIKE 'ќфтальмоло%'